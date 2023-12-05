from brownie import Contract, network
from eth_account import Account

# ABI definition for the constsAddress function
consts_address_abi = [
    {
        "constant": True,
        "inputs": [],
        "name": "constsAddress",
        "outputs": [{"name": "", "type": "address"}],
        "payable": False,
        "stateMutability": "view",
        "type": "function"
    }
]

def main():
    # Initialize the account from the private key
    private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'
    account = Account.from_key(private_key)

    # Add your account to Brownie's account list
    #if account.address not in network.accounts:
    #    network.accounts.add(private_key)
    deployer_account = account.address

    # Interact with the already deployed contract using the consts_address_abi
    contract_address = '0xFC00FACE00000000000000000000000000000000'
    consts_contract = Contract.from_abi("ConstantsManager", contract_address, consts_address_abi)

    # Call the constsAddress function to get the address
    consts_address = consts_contract.constsAddress({'from': deployer_account})
    print(f"Address returned by constsAddress: {consts_address}")

if __name__ == "__main__":
    main()
