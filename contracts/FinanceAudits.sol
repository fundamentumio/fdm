pragma solidity ^0.5.0;

import "./Owned.sol";
import "./SafeMath.sol";

contract FinanceAudits is Owned{

    using SafeMath for uint;
    
    struct FinanceAudit{
        uint dateOfAudit;
        uint total;
    }

    FinanceAudit[] public financeAudits;
    

    function getFinanceAuditsCount() view public returns(uint) {
        return financeAudits.length;
    }

    function addFinanceAudit(uint dateOfAudit, uint total) public onlyManagerOrOwner {
        FinanceAudit memory newAudit = FinanceAudit({
            dateOfAudit: dateOfAudit,
            total: total
            });
        financeAudits.push(newAudit);
    }
}