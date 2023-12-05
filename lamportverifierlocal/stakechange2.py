from web3 import Web3
from eth_utils import function_abi_to_4byte_selector, encode_hex

# Connect to your private blockchain
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:4000'))  # Replace with your blockchain's URL

# Ensure connection is established
if not w3.isConnected():
    print("Failed to connect to the blockchain")
    exit()

# Your validator's address and private key
validator_address = w3.toChecksumAddress('0x239fa7623354ec26520de878b52f13fe84b06971')
validator_private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'

# Netinit contract address
contract_address = w3.toChecksumAddress('0xFC00FACE00000000000000000000000000000000')

# Function signature
function_signature = "updateMinSelfStake(uint256)"

# Compute function selector
function_selector = w3.sha3(text=function_signature).hex()[:10]

# Value to be set (in Wei)
value_to_set = w3.toWei('16000', 'ether')  # Adjust this value as per your requirement

# ABI-encode the argument (padded to 32 bytes)
argument = value_to_set.to_bytes(32, byteorder='big')

# Create transaction data
transaction_data = function_selector + argument.hex()

# Build the transaction
transaction = {
    'to': contract_address,
    'value': 0,  # No Ether to be sent
    'gas': 3000000,
    'gasPrice': w3.toWei('5000', 'gwei'),
    'nonce': w3.eth.getTransactionCount(validator_address),
    'data': transaction_data,
    'chainId': 86098
}

# Sign the transaction
signed_txn = w3.eth.account.signTransaction(transaction, private_key=validator_private_key)

# Send the transaction
txn_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
print(f"Transaction hash: {txn_hash.hex()}")

# Optionally, wait for the transaction receipt
txn_receipt = w3.eth.wait_for_transaction_receipt(txn_hash)
print(f"Transaction receipt: {txn_receipt}")
