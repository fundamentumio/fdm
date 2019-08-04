pragma solidity ^0.5;

import './RealEstate.sol';
import './FinanceAudits.sol';
import './Audits.sol';
import './Fundamentum-ERC1404/FundamentumToken.sol';

contract Fundamentum is Audits, FinanceAudits, FundamentumToken {

    using SafeMath for uint;
    address[] public realEstates;
    
    constructor(string memory _name,
                string memory _symbol,
                uint256 _totalSupply) FundamentumToken(_name, _symbol, _totalSupply) public {
    }
    
    function newRealEstate(
                bytes32[6] memory _estateAddress, //[0]-country, [1]-region, [2]-city, [3]-district, [4]-streetAddress1, [5]-streetAddress2
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
                uint _issueTokens
          ) public onlyOwner returns(address)
    {
         _mint(address(this), _issueTokens * 10 ** uint256(decimals));
         RealEstate c = new RealEstate(
            _estateAddress,
            _buildingName,
            _commencement,
            _completion,
            _extensionDateCompletion,
            _buildingOwner,
            _developer,
            _floors,
            _totalArea,
            _livingSpace,
            _administrativeSpace,
            _issueTokens
        );
        address contractAddress = address(c);
        realEstates.push(contractAddress);
        return address(contractAddress);
    }
    
    function getEstateCount() public view returns(uint) {
        return realEstates.length;
    }
}
    
