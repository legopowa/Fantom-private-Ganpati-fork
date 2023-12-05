from web3 import Web3

# Connect to your Ethereum node
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:4000'))  # Replace with your node's URL

# Ensure connection is established
if not w3.isConnected():
    print("Failed to connect to the Ethereum node")
    exit()

# Contract details
contract_address = w3.toChecksumAddress('0xFC00FACE00000000000000000000000000000000')
contract_abi = [
    {
        "constant": True,
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "name": "",
                "type": "address"
            }
        ],
        "payable": False,
        "stateMutability": "view",
        "type": "function"
    }
]

# Create a contract instance
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# Call the owner function
owner_address = contract.functions.owner().call()
print(f"The owner's address is: {owner_address}")
