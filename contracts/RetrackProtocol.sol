// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/ERC20.sol";


// TODO
// Expand this protocol for other tokens as well on top of native currency 


contract RetrackProtocol is ERC20 {
    
   
    struct expiringAmount{
        uint256 amount;
        uint expiry_date;
    }
    
    mapping(address => mapping (address => expiringAmount)) private recipients;


    event MoneyTransferred (address from, address to, uint256 amount);
    event Moneyredeemed (address from, address redeemer, uint256 amount);


    constructor() ERC20("RetrackProtocol", "REPRO") {
    }


    /// @notice send equivalent tokens to account that can be used to redeem the initial money
    /// @dev Tokens are symbolic and the system would work just fine with them, wallets should
    ///      have an event listener waiting for emited events to alert redeem functionality, 
    ///      if there was a money waiting to be reedemed the redeeming_period will just be updated
    /// @param account account to transfer it to
    /// @param redeeming_period Period during which transfered could be redeemed, during this period
    ///                 senders can't retrack, the unit is in days
    ///                 the redeeming_period exists to prevent concquerency attack where sender
    ///                 and redeemer try to access the same fund at the same time
    function send (address account, uint redeeming_period) public payable {
        require(msg.value > 0, "No money deposited");
        // This is to make sure no typo error happens for the redeeming period
        require(redeeming_period < 30, "Making sure your reedming period is less than 30 days");
                
        recipients[account][msg.sender] = expiringAmount( recipients[account][msg.sender].amount + msg.value, block.timestamp + redeeming_period * 86400); 
        _mint(account, msg.value);
        emit MoneyTransferred(msg.sender, account, msg.value);

    }

    /// @notice Exchange tokens for underlying currency
    /// @dev a single user can have multiple senders so they will have to choose 
    ///      which one to redeem from 
    /// @param from sender to redeem from 
    /// @param redeem_amount amount to redeem
    /// @return status true on sucess
    function redeem (address from, uint256 redeem_amount) public returns(bool){
        
        require(redeem_amount >= 0, "You don't have anything to withdraw");
        require(recipients[msg.sender][from].amount >= redeem_amount, "You don't have this much redeem_amount from provided address");
        require(block.timestamp <= recipients[msg.sender][from].expiry_date, "Reedming period has passed only sender can claim it now");
        // This is to insure an invariant
        require(balanceOf(msg.sender) >= redeem_amount, "You should have equivalent number of coins");

        _burn(msg.sender, redeem_amount);
        recipients[msg.sender][from].amount = recipients[msg.sender][from].amount - redeem_amount;
        payable(msg.sender).transfer(redeem_amount);
        return true;
            
    }

    /// @notice you can safe transfer your payments without having to withdraw them
    /// @dev upon retransfering redeeming_period is updated
    /// @param from initial sender address
    /// @param to new reciever address
    /// @param amount amount to be transfered
    /// @param redeeming_period new redeeming_period starting from transfering time
    /// @return status returns true on sucess
    function transferRight(address from, address to, uint256 amount, uint redeeming_period) public returns (bool){

        require(recipients[msg.sender][from].amount >= amount, "You don't have this much amount from provided address");
        require(balanceOf(msg.sender) >= amount, "You should have equivalent number of coins");
        require(block.timestamp <= recipients[msg.sender][from].expiry_date, "you can't access this fund anymore contact your sender");


        _transfer(msg.sender, to, amount);
        recipients[msg.sender][from].amount = recipients[msg.sender][from].amount - amount;
        recipients[to][msg.sender] = expiringAmount(recipients[to][msg.sender].amount + amount, block.timestamp + redeeming_period * 86400);
        return true;

    }

   
    /// @notice senders can pullback their cash once redeeming period expires
    /// @dev EAs explained above redeeming period is inplace to prevent race conditions
    /// @param from recievers addres to pool back from
    /// @param amount amount to pull back
    /// @return status true on success
    function retrack (address from, uint256 amount) public returns (bool){


        require(recipients[from][msg.sender].amount >= amount, "Address doesn't owe you this much! May be amount is redeemed");
        require(balanceOf(from) >= amount, "Address already reedmed transfer");
        // There is one day period before expiray and retraction to prevent race conditions
        // This time must be updated if the maximum execution time of a block grows longer than a day
        require(recipients[from][msg.sender].expiry_date + 86400 < block.timestamp, "Fund hasn't yet expired");

        _burn(from, amount);
        recipients[from][msg.sender].amount =  recipients[from][msg.sender].amount - amount;
        // send back deposited money
        payable(msg.sender).transfer(amount);
        return true;
       
    }

    function checkAccount(address from) public view returns(uint256, uint){
        return (recipients[msg.sender][from].amount, recipients[msg.sender][from].expiry_date) ;
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