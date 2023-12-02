---
runme:
  id: 01HGMPYVASYM17XDG2Y7CBP932
  version: v2.0
---

# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell {"id":"01HGMPYVASYM17XDG2Y4QG99GE"}
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js

```

## 实操

- 发行一个符合ERC20标准的测试 Token，要求如下：
- 总量：1亿
- 精度：18
- 名称：Fake USDT in CBI
- 简称：cUSDT

```shell {"id":"01HGMPYVASYM17XDG2Y5BPZJHP"}
mcd nft-market-cbi

npx hardhat init

Need to install the following packages:
hardhat@2.19.1
Ok to proceed? (y) y


👷 Welcome to Hardhat v2.19.1 👷‍

✔ What do you want to do? · Create a JavaScript project
✔ Hardhat project root: · /Users/qiaopengjun/Code/sui/nft-market-cbi
✔ Do you want to add a .gitignore? (Y/n) · y
✔ Do you want to install this sample project's dependencies with npm (hardhat @nomicfoundation/hardhat-toolbox)? (Y/n) · y

npm install @openzeppelin/contracts  
npm install -g @remix-project/remixd
remixd --version
remixd -s /Users/qiaopengjun/Code/sui/nft-market-cbi --remix-ide https://remix.ethereum.org

```

- <https://docs.openzeppelin.com/contracts/5.x/wizard>
