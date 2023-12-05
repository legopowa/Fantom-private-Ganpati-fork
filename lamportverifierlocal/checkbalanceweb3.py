from web3 import Web3

# Connect to your local Ethereum node
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

current_chain_id = w3.eth.chainId
print(f"Connected to chain ID: {current_chain_id}")

if current_chain_id != 86090:
    print(f"Warning: The connected chain ID is not 86090. It is {current_chain_id}")
    exit()

# Address to check
#address = '0xfd003CA44BbF4E9fB0b2fF1a33fc2F05A6C2EFF9'
address = '0x68E62f51a07B3ec869ae8385c907C2671A497D38'
#address = '0x20A45360809174bae2C4f94562F30b817910c0d9'

# Fetch balance
balance_wei = w3.eth.getBalance(address)
balance_eth = w3.fromWei(balance_wei, 'ether')

print(f"Balance of address {address}: {balance_eth} ETH")
