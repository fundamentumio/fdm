pragma solidity ^0.5.0;

contract Owned {
    address public owner;
    
    mapping(address => bool) public managers;
    uint public managersCount = 0;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, 'OWNER_IS_REQUIRED');
        _;
    }

    modifier onlyManager {
        require(managers[msg.sender] == true, 'MANAGER_IS_REQUIRED');
        _;
    }
    
    modifier onlyManagerOrOwner {
        require(msg.sender == owner || managers[msg.sender] == true, 'MANAGER_IS_REQUIRED');
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
    
    function addManager(address newManager) onlyOwner public {
        managers[newManager] = true;
        managersCount++;
    }
    
    function removeManager(address manager) onlyOwner public {
        managers[manager] = false;
        managersCount--;
    }
}