from web3 import Web3

# Connect to your local Ethereum node
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

# Validator account details
validator_private_key = '0xfdfc072182654f163f5f0f9a621d729566c74d10037c4d7bbb0407d1e2c64981'
validator_address = '0x68E62f51a07B3ec869ae8385c907C2671A497D38'

# Destination address
destination_address = '0xfd003CA44BbF4E9fB0b2fF1a33fc2F05A6C2EFF9'

# Fetch balance
balance_wei = w3.eth.getBalance(validator_address)
gas_price = w3.eth.gasPrice
gas_estimate = w3.eth.estimateGas({
    'from': validator_address,
    'to': destination_address,
    'value': balance_wei
})

# Calculate the amount to send after subtracting gas
amount_to_send = balance_wei - (gas_price * gas_estimate)

# Create and sign a raw transaction
transaction = {
    'to': destination_address,
    'value': amount_to_send,
    'gas': gas_estimate,
    'gasPrice': gas_price,
    'nonce': w3.eth.getTransactionCount(validator_address),
    'chainId': 86170  # Adjust this if you're on a different chain
}
signed_txn = w3.eth.account.signTransaction(transaction, validator_private_key)

# Send the transaction
txn_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
print(f"Transaction hash: {txn_hash.hex()}")

# Wait for the transaction to be mined
txn_receipt = w3.eth.waitForTransactionReceipt(txn_hash)
print(f"Transaction {txn_hash.hex()} was included in block {txn_receipt['blockNumber']}")
