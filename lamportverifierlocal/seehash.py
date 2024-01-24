from web3 import Web3

# Function signature
function_signature = "isThisTxFree(address)"

# Calculate the keccak256 hash of the function signature
function_signature_hash = Web3.keccak(text=function_signature).hex()[:10]
print(function_signature_hash)
