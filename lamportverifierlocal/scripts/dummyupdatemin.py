from brownie import DummyContract, network
from eth_account import Account
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:4000'))

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

def main():
    # Initialize the account from the private key
    private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'
    account = Account.from_key(private_key)

    # Add your account to Brownie's account list and set it as the default
    #if account.address not in network.accounts:
    #    network.accounts.add(private_key)
    deployer_account = account.address

    # Deploy the DummyContract
    #deployed_contract = DummyContract.deploy({'from': deployer_account})
    contract_address = w3.toChecksumAddress('0xFC00FACE00000000000000000000000000000000')

    #print(f"Contract deployed at: {deployed_contract.address}")

    # Create an instance of the UpdateStakeTest class and call try_update_stake
    test = UpdateStakeTest(contract_address, deployer_account)
    test.try_update_stake()

class UpdateStakeTest:
    def __init__(self, contract, account):
        self.contract = contract
        self.account = account
        print(f"Account address: {self.account}")  # Printing the account address

    def try_update_stake(self):
        # Value to set for minSelfStake
        value_to_set = 160010 * 10**18  # Adjust as needed
        custom_gas_price = Web3.toWei(500, 'gwei') 
        try:
            # Call the updateMinSelfStake function with allow_revert=True
            tx = self.contract.updateMinSelfStake(value_to_set, {
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
