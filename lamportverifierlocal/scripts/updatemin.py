from brownie import Contract, network
from eth_account import Account
from web3 import Web3

# Define the minimal ABI directly in the script
minimal_abi = [
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

# Your private key

def main():
    # Set up the SFC contract using the minimal ABI
    contract_address = "0xFC00FACE00000000000000000000000000000000"  # Replace with the actual contract address
    sfc_contract = Contract.from_abi("SFC", contract_address, minimal_abi)

    # Create an instance of the UpdateStakeTest class and call try_update_stake
    test = UpdateStakeTest(sfc_contract)
    test.try_update_stake()

class UpdateStakeTest:

    def __init__(self, contract):
        private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'
        self.account = Account.from_key(private_key)
        self.contract = contract
        print(f"Account address: {self.account.address}")  # Printing the account address


    def try_update_stake(self):
        # Value to set for minSelfStake
        value_to_set = 1600100 * 10**18  # Adjust as needed
        custom_gas_price = Web3.toWei(500, 'gwei') 
        try:
            # Call the updateMinSelfStake function with allow_revert=True
            tx = self.contract.updateMinSelfStake('16001000000000000000000', {
                'from': self.account.address,
                'gas_limit': 2000000,  # Adjust this value as needed
                'gas_price': custom_gas_price,
                'allow_revert': True
            })
            tx.wait(1)  # Wait for 1 confirmation
            print(f"Transaction confirmed. Transaction hash: {tx.txid}")
        except Exception as e:
            print(f"Transaction failed: {e}")

if __name__ == "__main__":
    main()
