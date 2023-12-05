from brownie import AnonIDContract, accounts, network
from pathlib import Path
from dotenv import load_dotenv
import os

def main():
    # Load the environment variables from the .env file
    load_dotenv()

    # Connect to the local development network
    #network.connect('development')

    # Read mnemonic from file
    mnemonic_path = Path('mnemonic.txt')
    if not mnemonic_path.is_file():
        raise Exception(f"Can't find {mnemonic_path}")

    with open(mnemonic_path, "r") as file:
        mnemonic = file.read().strip()

    # Generate the account using the mnemonic
    account = accounts.from_mnemonic(mnemonic)

    # Deploy the contract
    deployed_contract = AnonIDContract.deploy({'from': account})

    # After deploying, you can interact with the contract
    print(f"Contract deployed at address: {deployed_contract.address}")

    # Disconnect from the network when done
    network.disconnect()

    return deployed_contract
