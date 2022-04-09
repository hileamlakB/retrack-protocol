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

    struct RecieverInfo {
        uint256 quantity;
        SenderInfo [] senders;
    }
    mapping(address => RecieverInfo) private recipients;


    event MoneyTransferred (address from, address to, uint256 amount);
    event MoneyReedemed (address from, address reedemer, uint256 amount);


    constructor() ERC20("RetrackProtocol", "REPRO") {
    }


    /// @notice Safe transfer money to another user, user will have to reedem the money
    /// @dev Instead of sending money the contract sends equivalent number of tokens 
    //       that can be used to reedem the same amount of money 
    /// @param account account to transfer it to
    function send (address account) public payable {
        require(msg.value > 0, "No money deposited");

        SenderInfo sender_info =  SenderInfo(msg.sender, msg.value);
        // Money even tho stored can't be pulled out before token is minted 
        // so no rentry attack can happen here between updating recipients and 
        // minting coin 
        
        recipients[account].push(
            RecieverInfo
                (recipients[account].quantity + 1,
                sender_info)
            ); 
        // Tokens are symbolic here, they can be used to trade right but they
        // are only symbolic, the system would work without tokens
        _mint(account, msg.value);
        emit MoneyTransferred(msg.sender, account, msg.value);

    }

    function reedem (bool all, address from) public{
        require(recipients[msg.sender].quantity > 0, "You don't have anything to be reedemed");

        if (all) {
            for (uint256 i = recipients[msg.sender].quantity; )
            
        }

    }

    function transferRight() public returns (bool){

    }

   

    function retrack (){}

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