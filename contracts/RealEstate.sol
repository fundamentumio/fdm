pragma solidity ^0.5.0;


import "./RealEstateOwned.sol";
import "./SafeMath.sol";

contract RealEstate is RealEstateOwned {
    
    using SafeMath for *;

    bytes32 public country;
    bytes32 public region;
    bytes32 public city;
    bytes32 public district;
    bytes32 public streetAddress1;
    bytes32 public streetAddress2;
    string public buildingName;
    uint public commencement;
    uint8 public completion;
    uint public extensionDateCompletion;
    string public buildingOwner;
    string public developer;
    uint8 public floors;
    uint public totalArea;
    uint public livingSpace;
    uint public administrativeSpace;
    uint public costOfHome;
    uint public oneSquarePrice;
    uint public issuedTokens;

    uint public numberOfSpents = 0; 
    
    struct Spent {
        uint timestamp;
        uint amount;
        string details;
    }

    Spent[] public spents; 

    constructor(
        bytes32[6] memory _buildingAddress, //[0]-country, [1]-region, [2]-city, [3]-district, [4]-streetAddress1, [5]-streetAddress2
        string memory _buildingName,
        uint _commencement,
        uint8 _completion,
        uint _extensionDateCompletion,
        string memory _buildingOwner,
        string memory _developer,
        uint8 _floors,
        uint _totalArea,
        uint _livingSpace,
        uint _administrativeSpace,
        uint _issuedTokens) public{
            country = _buildingAddress[0];
            region = _buildingAddress[1];
            city = _buildingAddress[2];
            district = _buildingAddress[3];
            streetAddress1 = _buildingAddress[4];
            streetAddress2 = _buildingAddress[5];
            buildingName = _buildingName;
            commencement = _commencement;
            completion = _completion;
            extensionDateCompletion = _extensionDateCompletion;
            buildingOwner = _buildingOwner;
            developer = _developer;
            floors = _floors;
            totalArea = _totalArea;
            livingSpace = _livingSpace;
            administrativeSpace = _administrativeSpace;
            issuedTokens = _issuedTokens;
    }
    
    function setOneSquarePrice(uint _price) onlyManagerOrOriginOwner public {
        oneSquarePrice = _price;
    }
    
    function setCostOfHome(uint _cost) onlyManagerOrOriginOwner public {
        costOfHome = _cost;
    }
    
    function setCompletion(uint8 _completion) onlyManagerOrOriginOwner public {
        completion = _completion;
    }

    function addSpent(uint timestamp,
        uint amount,
        string memory details) onlyManagerOrOriginOwner public{
        Spent memory newSpent = Spent({
            timestamp: timestamp,
            amount: amount,
            details: details
            });
        spents.push(newSpent);
        ++numberOfSpents;
    }
}

