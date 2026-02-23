// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OMOToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OMOBOI", "OMO") {
        _mint(msg.sender, initialSupply);
    }
}

contract PropertyManagement{

    struct Property{
        uint256 propertyId;
        string name;
        uint price;
        bool isSold;
    }

    // STATE VARIABLE
    address private owner;

    // CONSTRUCTOR
    constructor(){
        owner = msg.sender;
    }
// MODIFIER
    modifier Onlyowner(){
        require(msg.sender == owner,"not owner");
        _;
    }
// STRUCT ARRAY
    Property[] PropertyDetails;

        uint256 property_Id;
    
    function createProperty (string memory _name,uint _price) external Onlyowner {
        property_Id = property_Id + 1;
        require(_price != 0, "you are broke");
        Property memory newProperty = Property({propertyId: property_Id,name :_name, price: _price, isSold: false});
        PropertyDetails.push(newProperty);

    }

    function getProperty() external view returns (Property[] memory) {
        return PropertyDetails;
    }

    function removeProperty(uint _id) external  Onlyowner{
        for (uint i = 0; i < PropertyDetails.length; i++){
            if (PropertyDetails[i].propertyId == _id) {
                PropertyDetails[i] = PropertyDetails[PropertyDetails.length-1];
                PropertyDetails.pop();

            } 
        }

    }

    

    // function buyPurchaseProperty(uint8 _propertyId) public payable {
//         for (uint i = 0; i < PropertyDetails.length; i++){
//             require(propertyDetails[propertyid] == _propertyId,"The require property isnt found");
            
//     }
// }
    
}