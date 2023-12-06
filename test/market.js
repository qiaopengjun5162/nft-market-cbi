const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Market", async function () {
  let usdt, market, nft, accountA, accountB;

  // 测试每一个流程之前都要完成初始化工作
  beforeEach(async () => {
    [accountA, accountB] = await ethers.getSigners();

    const USDT = await ethers.getContractFactory("cUSDT");
    usdt = await USDT.deploy();

    let MyNFT = await ethers.getContractFactory("NFTM");
    nft = await MyNFT.deploy(accountA.address);

    let Market = await ethers.getContractFactory("Market");
    market = await Market.deploy(usdt.target, nft.target);

    await nft.safeMint(accountB.address);
    await nft.safeMint(accountB.address);
    await nft.connect(accountB).setApprovalForAll(accountA.address, true);

    // 默认连接第一个账户
    await usdt.approve(market.target, "1000000000000000000000000");
  });

  it("its erc20 address should be usdt", async function () {
    expect(await market.erc20()).to.equal(usdt.target);
  });

  it("its erc721 address should be nft", async function () {
    expect(await market.erc721()).to.equal(nft.target);
  });

  it("accountB should have two nfts", async () => {
    expect(await nft.balanceOf(accountB.address)).to.equal(2);
  });

  it("account A should have usdt", async () => {
    expect(await usdt.balanceOf(accountA.address)).to.equal(
      "100000000000000000000000000"
    );
  });

  it("account B can list two nfts to market", async () => {
    const price =
      "0x0000000000000000000000000000000000000000000000000001c6bf52634000";

    expect(
      await nft["safeTransferFrom(address,address,uint256,bytes)"](
        accountB.address,
        market.target,
        0,
        price
      )
    ).to.emit(market, "NewOrder");
    expect(
      await nft["safeTransferFrom(address,address,uint256,bytes)"](
        accountB.address,
        market.target,
        1,
        price
      )
    ).to.emit(market, "NewOrder");

    expect(await nft.balanceOf(accountB.address)).to.equal(0);
    expect(await nft.balanceOf(market.target)).to.equal(2);
    expect(await market.isListed(0)).to.equal(true);
    expect(await market.isListed(1)).to.equal(true);

    expect((await market.connect(accountB).getAllNFTs())[0][0]).to.equal(
      accountB.address
    );
    expect((await market.getAllNFTs())[0][1]).to.equal(0);
    expect((await market.getAllNFTs())[0][2]).to.equal(price);
    expect((await market.connect(accountB).getAllNFTs())[1][0]).to.equal(
      accountB.address
    );
    expect((await market.getAllNFTs())[1][1]).to.equal(1);
    expect((await market.getAllNFTs())[1][2]).to.equal(price);
    expect(await market.getOrderLength()).to.equal(2);

    // acountB 用户上架了
    expect((await market.connect(accountB).getMyNFTs())[0][0]).to.equal(
      accountB.address
    );
    expect((await market.connect(accountB).getMyNFTs())[0][1]).to.equal(0);
    expect((await market.connect(accountB).getMyNFTs())[0][2]).to.equal(price);

    expect((await market.connect(accountB).getMyNFTs())[1][0]).to.equal(
      accountB.address
    );
    expect((await market.connect(accountB).getMyNFTs())[1][1]).to.equal(1);
    expect((await market.connect(accountB).getMyNFTs())[1][2]).to.equal(price);

    expect((await market.connect(accountB).getMyNFTs())[0][0]).to.equal(
      accountB.address
    );
    expect((await market.connect(accountB).getMyNFTs())[0][1]).to.equal(0);
    expect((await market.connect(accountB).getMyNFTs())[0][2]).to.equal(price);
  });
});
