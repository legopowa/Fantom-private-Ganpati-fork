from web3 import Web3

# Connect to local node using HTTP
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:4000'))

# Or, to connect to a remote node (e.g., Infura), replace the URL with the endpoint URL:
# w3 = Web3(Web3.HTTPProvider('https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID'))

# Check if connected to node
if w3.isConnected():
    # Get the current block number
    block_number = w3.eth.block_number
    print(f"Current block number: {block_number}")
else:
    print("Failed to connect to the Ethereum node.")
