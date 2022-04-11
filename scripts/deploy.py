from brownie import RetrackProtocol, accounts

def main():
    accnt = accounts.load('hilea-main')
    contract = RetrackProtocol.deploy({
        'from':accnt
    })
    print(contract)
