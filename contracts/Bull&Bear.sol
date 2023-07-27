// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Chainlink Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// This import includes functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract BullBear is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    KeeperCompatibleInterface
{
    using Counters for Counters.Counter;
 
    Counters.Counter private _tokenIdCounter;

event TokenUpdated(string);
    uint256 public interval;
    uint256 public lastTimeStamp;

    AggregatorV3Interface public priceFeed;
    int256 currentPrice;

    string[] bullUrisIpfs = [
        "https://ipfs.io/ipfs/QmRXyfi3oNZCubDxiVFre3kLZ8XeGt6pQsnAQRZ7akhSNs?filename=gamer_bull.json",
        "https://ipfs.io/ipfs/QmRJVFeMrtYS2CUVUM2cHJpBV5aX2xurpnsfZxLTTQbiD3?filename=party_bull.json",
        "https://ipfs.io/ipfs/QmdcURmN1kEEtKgnbkVJJ8hrmsSWHpZvLkRgsKKoiWvW9g?filename=simple_bull.json"
    ];
    string[] bearUrisIpfs = [
        "https://ipfs.io/ipfs/Qmdx9Hx7FCDZGExyjLR6vYcnutUR8KhBZBnZfAPHiUommN?filename=beanie_bear.json",
        "https://ipfs.io/ipfs/QmTVLyTSuiKGUEmb88BgXG3qNC8YgpHZiFbjHrXKH3QHEu?filename=coolio_bear.json",
        "https://ipfs.io/ipfs/QmbKhBXVWmwrYsTPFYfroR2N7NAekAMxHUVg2CWks7i9qj?filename=simple_bear.json"
    ];

    constructor(uint256 updateInterval, address _priceFeed)
        ERC721("BullBear", "BBT")
    {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        priceFeed = AggregatorV3Interface(_priceFeed);

        //https://goerli.etherscan.io/address/0xA39434A63A52E749F02807ae27335515BA4b07F7
        currentPrice = getLatestPrice();
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        string memory defaultUri = bullUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);
    }

    function checkUpkeep(bytes calldata )
        external
        view
        override
        returns (bool upKeepNeeded, bytes memory )
    {
        upKeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }
 
    function performUpkeep(bytes calldata ) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            int256 latestPrice = getLatestPrice();

            if (latestPrice == currentPrice) {
                return;
            }
            if (latestPrice < currentPrice) {
                updateAllTokenUris("bear");
            } else {
                updateAllTokenUris("bulls");
            }
            currentPrice = latestPrice;
        } else {}
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function updateAllTokenUris(string memory trend) internal {
        if(compare("bear", trend)){
          for (uint i; i < _tokenIdCounter.current(); ++i) 
          {
              _setTokenURI(i,bearUrisIpfs[0] );
          }
        } else if(compare("bull", trend)){
          for (uint i; i < _tokenIdCounter.current(); ++i) 
          {
              _setTokenURI(i,bullUrisIpfs[0] );
          }}
emit TokenUpdated(trend);
    }

    function compare(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
      return   keccak256(abi.encode(a)) == keccak256(abi.encode(b));
    }


function setInterval(uint _interval) public {
    interval = _interval;
}

function setPriceFeed(address _priceFeed) external {
        priceFeed = AggregatorV3Interface(_priceFeed);
}



    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
