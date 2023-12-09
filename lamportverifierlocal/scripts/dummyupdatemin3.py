from brownie import network, Contract
from eth_account import Account

# Define the minimal ABI directly in the script
minimal_abi = [
    {
		"constant": False,
		"inputs": [
			{
				"name": "v",
				"type": "uint256"
			}
		],
		"name": "updateMinLockupDuration",
		"outputs": [],
		"payable": False,
		"stateMutability": "nonpayable",
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

    # Interact with the already deployed contract
    contract_address = '0x6CA548f6DF5B540E72262E935b6Fe3e72cDd68C9'
    deployed_contract = Contract.from_abi("DeployedContract", contract_address, minimal_abi)

    # Create an instance of the UpdateStakeTest class and call try_update_stake
    test = UpdateStakeTest(deployed_contract, deployer_account)
    test.try_update_stake()

class UpdateStakeTest:
    def __init__(self, contract, account):
        self.contract = contract
        self.account = account
        print(f"Account address: {self.account}")  # Printing the account address

    def try_update_stake(self):
        # Value to set for minSelfStake
        value_to_set = 86400  # Adjust as needed
        custom_gas_price = network.web3.toWei(500, 'gwei')  # Using network.web3 for gas price
        try:
            # Call the updateMinSelfStake function with allow_revert=True
            tx = self.contract.updateMinLockupDuration(value_to_set, {
                'from': self.account,
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
