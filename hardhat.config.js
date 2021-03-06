require("@nomiclabs/hardhat-waffle");
const fs = require("fs")
const privateKey  = fs.readFileSync(".secret").toString()

module.exports = {
  networks : {
    hardhat: {
      chainId: 1337
    },
    mumbai : {
      url: 'https://polygon-mumbai.infura.io/v3/551e335d086f456eb6f81cf6ed6ad984',
      accounts: [privateKey]
    },
    mainnet : {
      url: 'https://polygon-mainnet.infura.io/v3/551e335d086f456eb6f81cf6ed6ad984',
      accounts: [privateKey]
    }
  },
  solidity: "0.8.4",
};
