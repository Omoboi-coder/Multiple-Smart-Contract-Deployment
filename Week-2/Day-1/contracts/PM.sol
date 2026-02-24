// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OMOToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OMOBOI", "OMO") {
        _mint(msg.sender, initialSupply);
    }
}

contract ProjectManagement {
    // Errors
    error OnlyOwnerCanCallThisFunction();
    error OnlyThePropertyOwnerCanCallThisFunction();
    error PropertyNotFound();
    error PurchaseFailed();
    error PropertyNotForSale();
    error InvalidPropertyId();

    // State Variables
    OMOToken immutable token;
    address immutable owner;

    struct Property {
        uint id;
        string name;
        uint cost;
        address owner;
        bool isForSale;
    }

    Property[] private allProperties;

    constructor(address tokenCA) {
        owner = msg.sender;
        token = OMOToken(tokenCA);
    }

    modifier onlyOwner() {
        if(msg.sender != owner) revert OnlyOwnerCanCallThisFunction();
        _;
    }

    modifier onlyPropertyOwner(uint id) {
        (uint index, bool found) = getPropertyIndex(id);
        if(msg.sender != allProperties[index].owner) revert OnlyThePropertyOwnerCanCallThisFunction();
        _;
    }

    modifier onlyValidProperty(uint id) {
        (uint index, bool found) = getPropertyIndex(id);

        if(!found) revert InvalidPropertyId();
        if(allProperties[index].owner == address(0)) revert PropertyNotFound();

        _;
    }

    function createProperty(string memory _name, uint _cost) public onlyOwner {
        Property memory newProperty = Property({
            id: block.timestamp,
            name: _name,
            cost: _cost,
            owner: msg.sender,
            isForSale: true
        });

        allProperties.push(newProperty);
    }

    function purchaseProperty(uint _id) external onlyValidProperty(_id) {
        (uint index, ) = getPropertyIndex(_id);
        Property storage property = allProperties[index];

        
        if(!property.isForSale) revert PropertyNotForSale();

        bool success = token.transferFrom(msg.sender, property.owner, property.cost);

        if(!success) revert PurchaseFailed();

        property.owner = msg.sender;
        property.isForSale = false;
    }

    function removeProperty(uint _id) public onlyPropertyOwner(_id) onlyValidProperty(_id) {
        (uint index, ) = getPropertyIndex(_id);
        allProperties[index] = allProperties[allProperties.length - 1];
        allProperties.pop();
    }

    // [0, 1, 2, (3), 4]
    // [0, 1, 2, (4), 4]
    // [0, 1, 2, (4)]

    function editPropertyDetails(uint _id, string memory _name, uint _cost, bool _isForSale) public onlyPropertyOwner(_id) onlyValidProperty(_id) {
        (uint index, ) = getPropertyIndex(_id);
        allProperties[index] = Property({
            id: _id,
            name: _name,
            cost: _cost,
            isForSale: _isForSale,
            owner: msg.sender
        });
    }

    function setForSale(uint _id, bool _isForSale) public onlyPropertyOwner(_id) onlyValidProperty(_id) {
        (uint index, ) = getPropertyIndex(_id);
        allProperties[index].isForSale = _isForSale;
    }

    function getPropertyIndex(uint _id) internal view returns(uint propertyIndex, bool found) {
        for(uint index; index < allProperties.length; index++) {
            if (allProperties[index].id == _id) {
                propertyIndex = index;
                found = true;
            }
        }
    }

    function getAllProperties() external view returns(Property[] memory) {
        return allProperties;
    }
