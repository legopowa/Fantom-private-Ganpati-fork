from brownie import network, web3

def main():
    # Address to check balance for
    address = "0x20A45360809174bae2C4f94562F30b817910c0d9"
    
    # Print the balance
    balance = web3.eth.getBalance(address)
    print(f"Balance of {address}: {web3.fromWei(balance, 'ether')} ETH")
