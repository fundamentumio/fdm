pragma solidity ^0.5.0;
import "./MessagedERC1404.sol";
import "./Whitelist.sol";

/**
 * @title Fundamentum ERC1404 token
 *
 * @dev Implementation of the ERC1404 token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract FundamentumToken is MessagedERC1404, Whitelist {
    /**
    * @dev Restriction codes for erc1404
    */
    uint8 public NON_WHITELIST_CODE;
    string public constant NON_WHITELIST_ERROR = "ILLEGAL_TRANSFER_TO_NON_WHITELISTED_ADDRESS";

    /**
    * @dev Sell and buy prices for 1 token
    */
    uint256 public sellPrice = 1000000000000000000; 
    uint256 public buyPrice = 1000000000000000000;
    
    struct order 
    {
        uint256 blockNumber;
        uint256 quantity;
        uint256 timestamp;
        uint256 weiValue;
    }
    
    /**
     * @dev This create array with all transfers and prices
     */
    mapping (address => order[]) internal orders;
    
    constructor (string memory _name,
                string memory _symbol,
                uint256 _totalSupply) public 
    {
        decimals = 18; 
        NON_WHITELIST_CODE = messagesAndCodes.autoAddMessage(NON_WHITELIST_ERROR);
        name = _name;
        symbol =_symbol;
        _mint(address(this), _totalSupply * 10 ** uint256(decimals) );
    }

    /**
    * @dev Gets the number of orders.
    * @param buyer The address to query the orders of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function getOrdersNum(address buyer) external view returns (uint256)
    {
        return orders[buyer].length;
    }
    
    function getOrder(address buyer, uint index) external view returns (uint256, uint256, uint256, uint256) {
        require(orders[buyer].length > index, "INVALID_INDEX");
        return (orders[buyer][index].blockNumber, orders[buyer][index].quantity, orders[buyer][index].timestamp, orders[buyer][index].weiValue);
    }
    
    function() payable external {
        buy();
    }

    function burn(uint256 value) onlyOwner external
    {
        _burn(address(this), value);
    } 

    function detectTransferRestriction (address from, address to, uint value)
        public
        view
        returns (uint8 restrictionCode)
    {
        if (!whitelist(to) && from == address(this)) {
            restrictionCode = NON_WHITELIST_CODE; // illegal transfer outside of whitelist
        } else {
            restrictionCode = SUCCESS_CODE; // successful transfer (required)
        }
    }
    
    /**
     * @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
     * @param newSellPrice Price the users can sell to the contract
     * @param newBuyPrice Price users can buy from the contract
     */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner external {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /**
     * @notice Buy tokens from contract by sending ether
     */
    function buy() notRestricted(address(this), msg.sender, msg.value) payable public
    {
        uint amount = msg.value * 10**18 / buyPrice;               // calculates the amount
        _transfer(address(this), msg.sender, amount);              // makes the transfers
        order memory currentOrder = order({                        // save order
            weiValue: msg.value,
            blockNumber: block.number,
            timestamp: now,
            quantity: amount
        });
        orders[msg.sender].push(currentOrder);
    }
    
     /**
     * @notice Buy tokens from contract by sending ether
     * @param to The address to get tokens
     */
    function buy(address to) notRestricted(address(this), to, msg.value) payable external
    {
        uint amount = msg.value * 10**18 / buyPrice;               // calculates the amount
        _transfer(address(this), to, amount);                      // makes the transfers
        order memory currentOrder = order({                        // save order
            weiValue: msg.value,
            blockNumber: block.number,
            timestamp: now,
            quantity: amount
        });
        orders[msg.sender].push(currentOrder);
    }
    
     /**
     * @notice Owner can withdraw ether
     * @param amount Ether amount to withdraw
     * @param to The address to get ether
     */
    function withdraw(uint amount, address payable to) onlyOwner external 
    {
        require(amount >= address(this).balance, 'NOT_ENOUGH_ETHER');
        address(to).transfer(amount);
    } 
    
    /**
     * @notice Sell `amount` tokens to contract
     * @param amount amount of tokens to be sold
     */
    function sell(uint256 amount) external 
    {
        require(address(this).balance >= amount * sellPrice / 10**18, "NOT_ENOUGH ETHER"); // checks if the contract has enough ether to buy
        _transfer(msg.sender, address(this), amount);                  // makes the transfers
        msg.sender.transfer(amount * sellPrice / 10**18);     // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
    
    
    /**
     * @notice Credited to the balance of the contract transferred ether
     */
    function topUp() external onlyManagerOrOwner payable {}
    
}