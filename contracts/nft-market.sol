// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract Market {
    IERC20 public erc20;
    IERC721 public erc721;

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    struct Order {
        address seller;
        uint256 tokenId;
        uint256 price;
    }

    mapping(uint256 => Order) public orderOfId; // token id to order
    Order[] public orders;
    mapping(uint256 => uint256) public idToOrderIndex; // token id to index in orders

    event Deal(address seller, address buyer, uint256 tokenId, uint256 price);
    event NewOrder(address seller, uint256 tokenId, uint256 price);
    event PriceChanged(
        address seller,
        uint256 tokenId,
        uint256 previousPrice,
        uint256 price
    );
    event OrderCancelled(address seller, uint256 tokenId);

    constructor(address _erc20, address _erc721) {
        require(_erc20 != address(0), "zero address");
        require(_erc721 != address(0), "zero address");
        erc20 = IERC20(_erc20);
        erc721 = IERC721(_erc721);
    }

    function buy(uint256 _tokenId) external {
        address seller = orderOfId[_tokenId].seller;
        address buyer = msg.sender;
        uint256 price = orderOfId[_tokenId].price;

        require(seller != buyer, "seller and buyer are the same");
        require(price > 0, "price is zero");

        require(erc20.transferFrom(buyer, seller, price), "transfer failed");
        erc721.safeTransferFrom(address(this), buyer, _tokenId);

        //  remove order
        removeOrder(_tokenId);
        emit Deal(seller, buyer, _tokenId, price);
    }

    function cancelOrder(uint256 _tokenId) external {
        address seller = orderOfId[_tokenId].seller;
        require(seller == msg.sender, "not the seller");
        erc721.safeTransferFrom(address(this), seller, _tokenId);
        //  remove order
        removeOrder(_tokenId);
        emit OrderCancelled(seller, _tokenId);
    }

    function changePrice(uint256 _tokenId, uint256 _price) external {
        address seller = orderOfId[_tokenId].seller;
        require(seller == msg.sender, "not the seller");
        require(_price > 0, "price is zero");
        uint256 previousPrice = orderOfId[_tokenId].price;
        orderOfId[_tokenId].price = _price;

        Order storage order = orders[idToOrderIndex[_tokenId]];
        order.price = _price;
        emit PriceChanged(seller, _tokenId, previousPrice, _price);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        require(msg.sender == address(erc721), "invalid sender");
        require(
            erc721.ownerOf(tokenId) == address(this),
            "not owned by this contract"
        );
        uint256 price = toUint256(data, 0);
        require(price > 0, "price is zero");
        // 上架
        orders.push(Order(from, tokenId, price));
        orderOfId[tokenId] = Order(from, tokenId, price);
        idToOrderIndex[tokenId] = orders.length - 1;
        emit NewOrder(from, tokenId, price);

        return MAGIC_ON_ERC721_RECEIVED;
    }

    function removeOrder(uint256 _tokenId) internal {
        // 把index 和 最后一个元素进行调换，然后把index pop出去
        uint256 index = idToOrderIndex[_tokenId];
        uint256 lastIndex = orders.length - 1;
        if (index != lastIndex) {
            Order storage lastOrder = orders[lastIndex];
            idToOrderIndex[lastOrder.tokenId] = index;
            orders[index] = lastOrder;
        }
        orders.pop();
        delete orderOfId[_tokenId];
        delete idToOrderIndex[_tokenId];
    }

    // https://stackoverflow.com/questions/63252057/how-to-use-bytestouint-function-in-solidity-the-one-with-assembly
    function toUint256(
        bytes memory _bytes,
        uint256 _start
    ) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market: toUint256_overflow");
        require(_bytes.length >= _start + 32, "Market: toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
}
