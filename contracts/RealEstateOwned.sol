pragma solidity ^0.5.0;

contract RealEstateOwned {
    address public originOwner;
    
    mapping(address => bool) public managers;
    uint public managersCount = 0;

    constructor() public {
        originOwner = tx.origin;
    }

    modifier onlyEstateManager {
        require(managers[msg.sender] == true, 'MANAGER_IS_REQUIRED');
        _;
    }
    
    modifier onlyEstateManagerOrOwner {
        require(msg.sender == originOwner || managers[msg.sender] == true, 'MANAGER_IS_REQUIRED');
        _;
    }
    
    modifier onlyManagerOrOriginOwner {
        require(msg.sender == originOwner || managers[msg.sender] == true, 'MANAGER_IS_REQUIRED');
        _;
    }

    modifier onlyOriginOwner {
        require(msg.sender == originOwner, 'ORIGIN_OWNER_IS_REQUIRED');
        _;
    }

    function transferOriginOwnership(address newOwner) onlyOriginOwner public {
        originOwner = newOwner;
    }
    
    function addManager(address newManager) onlyOriginOwner public {
        managers[newManager] = true;
        managersCount++;
    }
    
    function removeManager(address manager) onlyOriginOwner public {
        managers[manager] = false;
        managersCount--;
    }
}