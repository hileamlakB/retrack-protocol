// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/ERC20.sol";

contract RetrackProtocol is ERC20 {
    
    struct SenderInfo {
        address sender;
        uint256 amount;
        bool retracktable;
    }


    struct expiringAmount{
        uint256 amount;
        uint expiry_date;
    }
    
    mapping(address => mapping (address => expiringAmount )) private recipients;


    event MoneyTransferred (address from, address to, uint256 amount);
    event MoneyReedemed (address from, address reedemer, uint256 amount);


    constructor() ERC20("RetrackProtocol", "REPRO") {
    }


    /// @notice Safe transfer money to another user, user will have to reedem the money
    /// @dev Instead of sending money the contract sends equivalent number of tokens 
    //       that can be used to reedem the same amount of money 
    /// @param account account to transfer it to
    function send (address account, uint redeeming_period) public payable {
        require(msg.value > 0, "No money deposited");
        
        // Money even tho stored can't be pulled out before token is minted 
        // so no rentry attack can happen here between updating recipients and 
        // minting coin 
        
        recipients[account][msg.sender] += expiringAmount(msg.value, block.timestamp + redeeming_period * 86400); 
        // Tokens are symbolic here, they can be used to trade right but they
        // are only symbolic, the system would work without tokens
        _mint(account, msg.value);
        emit MoneyTransferred(msg.sender, account, msg.value);

    }

    function reedem (address from, bool all, uint256 reedem_amount) public{
        
        uint256 amount = 0;

        if (all){           
            amount = recipients[msg.sender][from]; 
        }
        else{
            amount = reedem_amount;
        }

        require(amount >= 0, "You don't have anything to withdraw");
        require(recipients[msg.sender][from].amount >= amount, "You don't have this much amount from provided address");
        require(block.timestamp <= recipients[msg.sender][from].expiry_date, "Reedming period has passed only sender can claim it now");
        // This is to insure an invariant
        require(balanceOf(msg.sender) >= amount, "You should have equivalent number of coins");

        _burn(msg.sender, amount);
        recipients[msg.sender][from].amount -= amount;
        payable(msg.sender).transfer(amount);
            
    }

    function transferRight(address from, address to, uint256 amount, uint redeeming_period) public returns (bool){

        require(recipients[msg.sender][from].amount >= amount, "You don't have this much amount from provided address");
        require(balanceOf(msg.sender) >= amount, "You should have equivalent number of coins");
        require(block.timestamp <= recipients[msg.sender][from].expiry_date, "you can't access this fund anymore contact your sender");


        _transfer(msg.sender, to, amount);
        recipients[msg.sender][from] -= amount;
        recipients[to][msg.sender] += amount;

    }

   

    function retrack (address from, uint356 amount){

        // What is the best way to prevent conccurency problems where
        // both retracker and reedemer try to withrdraw money forcing
        // the system to send money twice
        require(recipients[from][msg.sender].amount >= amount, "Address doesn't owe you this much! May be amount is redeemed");
        require(balanceOf(from) >= amount, "Address already reedmed transfer");
        require(recipients[from][msg.sender].expiry_date < block.timestamp, "Fund hasn't yet expired");

        _burn(from, amount);
        recipients[from][msg.sender].amount -= amount;
       
    }


    function transfer (
    address to, 
    uint256 amount) public  override(ERC20) returns (bool){
        return false;
    }

    function allowance(
        address owner, 
        address spender) public view override(ERC20) returns (uint256){
        return 0;
    } 

    function approve(address spender, uint256 amount) public override(ERC20) 
    returns (bool){
        return false;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override(ERC20) returns (bool) {
        return false;
    }

    function increaseAllowance(address spender, uint256 addedValue) 
    public override(ERC20) returns (bool){
        return false;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public 
    override(ERC20) returns (bool){
        return false;
    }

}