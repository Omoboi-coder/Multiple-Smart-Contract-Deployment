// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OmoboiNFT is ERC721, Ownable {

    
    uint256 public tokenCounter;

   
    mapping(uint256 => string) private tokenURIs;

    constructor() ERC721("OmoboiNFT", "OMBNFT") Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function mint(address _to, string memory _tokenURI) public onlyOwner {
        uint256 newTokenId = tokenCounter;

        _safeMint(_to, newTokenId);

        tokenURIs[newTokenId] = _tokenURI;

        tokenCounter = tokenCounter + 1;
    }

  
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        return tokenURIs[_tokenId];
    }
}