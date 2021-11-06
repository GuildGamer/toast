//SPDX-Lincense-identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    // Payable is a modifier of the variable owner ot type address
    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor(){
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns(uint256){
        return listingPrice;
    }
    // Here nonReentrant is a modifier as well
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant{
        require(price > 0, "Price must be greater than 0");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId, 
            msg.sender, 
            address(0), 
            price, 
            false
        );
    }

    function createMarketSale(
        address nftContract,
        uint256 itemId
    )public payable nonReentrant{
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].price;

        require(msg.value == price, "Please submit the asking price in orfer to purchase");
        // We are transfering the token(eth) i.e asking price paid by buyer to the seller
        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
         idToMarketItem[itemId].owner = payable(msg.sender);
         idToMarketItem[itemId].sold = true;
         _itemsSold.increment();
         // To pay commision to the owner of the market
         payable(owner).transfer(listingPrice);    
    }


    // Function to fetch all market items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;
        
        // Datatype [indicates array] memory keyword arrayName = new MarketItem obj array of lenght unsoldItemCount
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
            for (uint i = 0; i<itemCount; i++){
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
        }
        return items;
    }

    // Function to fetch your own market items(NFTs)
    function FetchMyNFTs() public view returns(MarketItem[] memory){
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0; 
        // msg.sender is just like request.user
        for(uint i = 0; i<=totalItemCount; i++){
            if (idToMarketItem[currentIndex].owner == msg.sender ) {
                itemCount += 1;
            }
        }

        MarketItem[] memory myNFTs = new MarketItem[](itemCount);
        for(uint i = 0; i<=totalItemCount; i++){
            if (idToMarketItem[currentIndex].owner == msg.sender ) {
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                myNFTs[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return myNFTs;

    }


}