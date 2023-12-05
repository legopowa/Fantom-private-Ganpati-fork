from brownie import Contract, network
from eth_account import Account

# ABI definition for the minGasPrice function
min_gas_price_abi = [
    {
        "constant": True,
        "inputs": [],
        "name": "minGasPrice",
        "outputs": [{"name": "", "type": "uint256"}],
        "payable": False,
        "stateMutability": "view",
        "type": "function"
    }
]

def main():
    # Initialize the account from the private key
    private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'
    account = Account.from_key(private_key)


    deployer_account = account.address

    # Interact with the already deployed contract using the min_gas_price_abi
    contract_address = '0xFC00FACE00000000000000000000000000000000'
    contract = Contract.from_abi("ContractWithMinGasPrice", contract_address, min_gas_price_abi)

    # Call the minGasPrice function to get the value
    min_gas_price = contract.minGasPrice({'from': deployer_account})
    print(f"Minimum Gas Price: {min_gas_price}")

if __name__ == "__main__":
    main()
