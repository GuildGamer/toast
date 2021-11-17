const { expect } = require("chai");

describe("NFTMarket", function () {
  it("Should create and exectute market sales", async function () {
    const Market = await ethers.getContractFactory("NFTMarket")
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address

    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy()
    await nft.deployed()
    const nftContractAddress = nft.address

    let listingPrice = await market.getListingPrice()
    listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('100', 'ether')

    await nft.createToken("link1")
    await nft.createToken("link2")

    await market.createMarketItem(nft.ContractAddress, 1, auctionPrice, {value: listingPrice})
    await market.createMarketItem(nft.ContractAddress, 2, auctionPrice, {value: listingPrice})

    const [_, buyerAddress] = await ethers.getSigners()

    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {value: auctionPrice})

    const items = await market.fetchMarketItems()

    console.log('items: ', items)
  });
});