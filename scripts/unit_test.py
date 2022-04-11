from brownie import RetrackProtocol, accounts, chain
from brownie.network.account import Account


def to_wei(ether):
    return (ether * (10 ** 18))
def to_sec(day):
    return (day * 86400)


def upload(deployer):
    return RetrackProtocol.deploy({'from':deployer})


def send_normal (
        contract : RetrackProtocol, 
        from_: Account, 
        receiver : Account, 
        reedeming_period : int, 
        amount : int) -> None:
    
    """Test normal with excpected inputs"""
    
    before_sending = int(from_.balance())
    contract.send(receiver, reedeming_period, {'from': from_, 'value':f'{amount} ether'})
    
    assert(int(from_.balance()) <= before_sending - to_wei(10))
    
    redeemable_amnt, reedem_period = contract.checkAccount(from_, {'from':receiver})
    assert(redeemable_amnt == to_wei(amount))
    
    assert(abs((reedem_period - chain.time()) - to_sec(reedeming_period)) < to_sec(1))

def redeem_normal (
    contract : RetrackProtocol, 
    reedemer : Account, 
    from_ : Account, 
    redeem_amount : int) -> None:
    
    """Test redeem function with execpected inputs"""
    
    before_redeeming = int(reedemer.balance())
    contract.redeem (from_, to_wei(redeem_amount), {'from':reedemer})
    assert(abs(int(reedemer.balance()) - (before_redeeming + to_wei(redeem_amount))) < to_wei(1))

def transferRight_normal (
    contract : RetrackProtocol, 
    from_ : Account, 
    to : Account, 
    amount : int, 
    new_redeeming_period : int, 
    transferer : Account) -> None:
    
    """Test transferRight with expecpected inputs"""
    
    redeemable_amnt, reedem_period = contract.checkAccount(from_, {'from':transferer})
    contract.transferRight(from_, to, to_wei(amount), new_redeeming_period, {'from':transferer})
    after_transfer_amnt, after_period = contract.checkAccount(from_, {'from':transferer})
    
    assert(after_period == reedem_period)
    assert(after_transfer_amnt == redeemable_amnt - to_wei(amount))
    
    transferd, new_period = contract.checkAccount(transferer, {'from':to})
    assert(transferd == to_wei(amount))
    assert(abs((new_period - chain.time()) - to_sec(new_redeeming_period)) < to_sec(1))
    

def retrack_normal (
    contract : RetrackProtocol, 
    from_ : Account, 
    amount : int, 
    retracker : Account) -> None:
    
    retrackable, reedem_period = contract.checkAccount(retracker, {'from':from_})
    
    chain.sleep(reedem_period + to_sec(1))
    
    balance_before = int(retracker.balance())
    
    contract.retrack(from_, amount, {'from':retracker})
    
    # check if balance is up by about amount after retracking
    assert(abs((int(retracker.balance()) - balance_before) - amount) <= to_wei(1))
    
    after_retrackable, after_reedem_period = contract.checkAccount(retracker, {'from':from_})
    
    assert(after_reedem_period == reedem_period)
    assert(after_retrackable == retrackable - amount)


def main():
    
    contract = upload(accounts[0])
    
    # TEST 1
    # 1 sends 10 eth to 2
    send_normal(contract, accounts[1], accounts[2], 10, 10)
    # 2 reedems 20 eth
    redeem_normal(contract, accounts[2], accounts[1], 10)
    

    # TEST 2
    # 1 sends 50 eth to 2
    send_normal(contract, accounts[1], accounts[2], 10, 50)
    # # 2 delegates 20 of that 50 eth, from 1,  to 3
    transferRight_normal(contract, accounts[1], accounts[3], 20, 5, accounts[2])
     # # 3 reedems 10 of the ether
    redeem_normal(contract, accounts[3], accounts[2], 10)
    # # 2 Pulls back remaning 10 after period has passed
    retrack_normal(contract, accounts[3], 10, accounts[2])
   