pragma solidity ^0.5.0;

import './Owned.sol';

contract Audits is Owned {

    struct Audit{
        uint256  dateOfAudit;
        address  estateObject;
        uint256  actualPrice;
        string  linkToInformation;
    }

    Audit[] public audits;

    function getAuditsCount() view public returns(uint) {
        return audits.length;
    }

    function addAudit(
                uint256  _dateOfAudit,
                address  _estateObject,
                uint256  _actualPrice,
                string memory  _linkToInformation
        ) public onlyManagerOrOwner {
        Audit memory newAudit = Audit({
            dateOfAudit: _dateOfAudit,
            estateObject: _estateObject,
            actualPrice: _actualPrice,
            linkToInformation: _linkToInformation
            });
        audits.push(newAudit);
    }
}