// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract OmoboiOnchainNFT is ERC721, Ownable {

    uint256 public tokenCounter;

    constructor() ERC721("OmoboiOnchainNFT", "OMOC") Ownable(msg.sender) {
        tokenCounter = 0;
    }

   function getSVG() internal pure returns (string memory) {
    return string.concat(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350" width="350" height="350">',
        '<defs>',
        '<radialGradient id="bg" cx="50%" cy="50%" r="70%">',
        '<stop offset="0%" stop-color="#0f0c29"/>',
        '<stop offset="50%" stop-color="#302b63"/>',
        '<stop offset="100%" stop-color="#24243e"/>',
        '</radialGradient>',
        '<radialGradient id="glow" cx="50%" cy="50%" r="50%">',
        '<stop offset="0%" stop-color="#f97316" stop-opacity="0.3"/>',
        '<stop offset="100%" stop-color="#f97316" stop-opacity="0"/>',
        '</radialGradient>',
        '<linearGradient id="ring1" x1="0%" y1="0%" x2="100%" y2="100%">',
        '<stop offset="0%" stop-color="#f97316"/>',
        '<stop offset="100%" stop-color="#ec4899"/>',
        '</linearGradient>',
        '<linearGradient id="ring2" x1="100%" y1="0%" x2="0%" y2="100%">',
        '<stop offset="0%" stop-color="#3b82f6"/>',
        '<stop offset="100%" stop-color="#8b5cf6"/>',
        '</linearGradient>',
        '<linearGradient id="textGrad" x1="0%" y1="0%" x2="100%" y2="0%">',
        '<stop offset="0%" stop-color="#f97316"/>',
        '<stop offset="100%" stop-color="#ec4899"/>',
        '</linearGradient>',
        '<filter id="glow-filter">',
        '<feGaussianBlur stdDeviation="3" result="blur"/>',
        '<feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>',
        '</filter>',
        '</defs>',
        '<rect width="350" height="350" fill="url(#bg)" rx="20"/>',
        '<circle cx="175" cy="175" r="120" fill="url(#glow)"/>',
        '<circle cx="175" cy="175" r="130" fill="none" stroke="url(#ring1)" stroke-width="1.5" stroke-dasharray="6 4" opacity="0.6"/>',
        '<polygon points="175,60 245,102 245,188 175,230 105,188 105,102" fill="none" stroke="url(#ring2)" stroke-width="1.2" opacity="0.5"/>',
        '<polygon points="175,80 230,112 230,178 175,210 120,178 120,112" fill="none" stroke="url(#ring1)" stroke-width="0.8" opacity="0.4"/>',
        '<circle cx="175" cy="155" r="55" fill="none" stroke="url(#ring1)" stroke-width="2" filter="url(#glow-filter)"/>',
        '<circle cx="175" cy="155" r="48" fill="#0f0c29" opacity="0.8"/>',
        '<text x="175" y="148" font-family="serif" font-size="22" font-weight="bold" fill="url(#textGrad)" text-anchor="middle" filter="url(#glow-filter)">OMO</text>',
        '<text x="175" y="170" font-family="monospace" font-size="9" fill="#8b5cf6" text-anchor="middle" letter-spacing="3">TOKEN</text>',
        '<circle cx="175" cy="97" r="3" fill="#f97316" filter="url(#glow-filter)"/>',
        '<circle cx="175" cy="213" r="3" fill="#ec4899" filter="url(#glow-filter)"/>',
        '<circle cx="121" cy="125" r="2.5" fill="#3b82f6" filter="url(#glow-filter)"/>',
        '<circle cx="229" cy="125" r="2.5" fill="#8b5cf6" filter="url(#glow-filter)"/>',
        '<circle cx="121" cy="185" r="2.5" fill="#f97316" filter="url(#glow-filter)"/>',
        '<circle cx="229" cy="185" r="2.5" fill="#ec4899" filter="url(#glow-filter)"/>',
        '<line x1="20" y1="20" x2="50" y2="20" stroke="#f97316" stroke-width="1.5" opacity="0.6"/>',
        '<line x1="20" y1="20" x2="20" y2="50" stroke="#f97316" stroke-width="1.5" opacity="0.6"/>',
        '<line x1="330" y1="20" x2="300" y2="20" stroke="#ec4899" stroke-width="1.5" opacity="0.6"/>',
        '<line x1="330" y1="20" x2="330" y2="50" stroke="#ec4899" stroke-width="1.5" opacity="0.6"/>',
        '<line x1="20" y1="330" x2="50" y2="330" stroke="#3b82f6" stroke-width="1.5" opacity="0.6"/>',
        '<line x1="20" y1="330" x2="20" y2="300" stroke="#3b82f6" stroke-width="1.5" opacity="0.6"/>',
        '<line x1="330" y1="330" x2="300" y2="330" stroke="#8b5cf6" stroke-width="1.5" opacity="0.6"/>',
        '<line x1="330" y1="330" x2="330" y2="300" stroke="#8b5cf6" stroke-width="1.5" opacity="0.6"/>',
        '<text x="175" y="268" font-family="monospace" font-size="11" fill="url(#textGrad)" text-anchor="middle" letter-spacing="4" font-weight="bold">OMOBOI NFT</text>',
        '<circle cx="60" cy="80" r="1.5" fill="white" opacity="0.6"/>',
        '<circle cx="290" cy="70" r="1" fill="white" opacity="0.5"/>',
        '<circle cx="40" cy="200" r="1.5" fill="white" opacity="0.4"/>',
        '<circle cx="310" cy="220" r="1" fill="white" opacity="0.6"/>',
        '<circle cx="80" cy="290" r="1.5" fill="white" opacity="0.3"/>',
        '<circle cx="270" cy="300" r="1" fill="white" opacity="0.5"/>',
        '<circle cx="100" cy="50" r="1" fill="#f97316" opacity="0.7"/>',
        '<circle cx="250" cy="40" r="1.5" fill="#ec4899" opacity="0.6"/>',
        '<circle cx="320" cy="150" r="1" fill="#3b82f6" opacity="0.7"/>',
        '<circle cx="30" cy="140" r="1.5" fill="#8b5cf6" opacity="0.5"/>',
        '</svg>'
    );
}

    // Builds the metadata entirely onchain — no Pinata needed!
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // Convert SVG to Base64
        string memory svgBase64 = Base64.encode(bytes(getSVG()));

        // Build the metadata JSON onchain
        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "OmoboiOnchainNFT #',
            toString(_tokenId),
            '", "description": " onchain NFT by Omoboi", "image": "data:image/svg+xml;base64,',
            svgBase64,
            '"}'
        ))));

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Mint function
    function mint(address _to) public onlyOwner {
        _safeMint(_to, tokenCounter);
        tokenCounter = tokenCounter + 1;
    }

    // Helper to convert uint to string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}