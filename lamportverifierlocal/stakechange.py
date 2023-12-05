from web3 import Web3

# Connect to your private blockchain
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:4000'))  # Replace with your blockchain's URL

# Ensure connection is established
if not w3.isConnected():
    print("Failed to connect to the blockchain")
    exit()

# Your validator's address and private key
validator_address = w3.toChecksumAddress('0x239fa7623354ec26520de878b52f13fe84b06971')
validator_private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'

# Netinit contract details
contract_address = w3.toChecksumAddress('0xFC00FACE00000000000000000000000000000000')

# Corrected ABI for the updateMinSelfStake function
contract_abi = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "minSelfStake",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "v",
				"type": "uint256"
			}
		],
		"name": "updateMinSelfStake",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]

# Create a contract instance
netinit_contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# Prepare the function call
value_to_set = w3.toWei('160001', 'ether')  # The desired value in Ether
transaction = netinit_contract.functions.updateMinSelfStake(value_to_set).buildTransaction({
    'chainId': 86098,  # Your chain ID
    'gas': 3000000,    # Appropriate gas limit
    'gasPrice': w3.toWei('5000', 'gwei'),
    'nonce': w3.eth.getTransactionCount(validator_address),
    # 'value' field is removed as the function is nonpayable
})

# Sign the transaction
signed_txn = w3.eth.account.signTransaction(transaction, private_key=validator_private_key)

# Send the transaction
txn_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
print(f"Transaction hash: {txn_hash.hex()}")

# Optionally, wait for the transaction receipt
txn_receipt = w3.eth.wait_for_transaction_receipt(txn_hash)
print(f"Transaction receipt: {txn_receipt}")
