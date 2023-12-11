from brownie import accounts, AnonIDContract#, firewallet
from brownie.network import gas_price
from brownie.network.gas.strategies import LinearScalingStrategy
from eth_account import Account
#import signal
import sys
import json
import base64
import time
import ast
from typing import List
import codecs
import re
import hashlib
import binascii
from eth_abi import encode
from offchain.KeyTracker_ import KeyTracker, InvalidAddress
from offchain.soliditypack import solidity_pack, solidity_pack_bytes, solidity_pack_pairs
from offchain.soliditypack import _pack 
from time import sleep
from binascii import crc32, hexlify
#from offchain.fortress_functions import validate_pkh, validate_pkh_wait, ValidResponseFound, send_file, send_pubkey, f_save_received_data, f_sign_and_send, send_signed_files
import offchain.data_temp
from offchain.functions import hash_b, sign_hash, verify_signed_hash
from offchain.Types import LamportKeyPair, Sig, PubPair




gas_strategy = LinearScalingStrategy("1200 gwei", "12000 gwei", 1.1)

# if network.show_active() == "development":
gas_price(gas_strategy)

def main():
    # Initialize the account from the private key and add it to Brownie's accounts
    private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'
    brownie_account = accounts.add(private_key)
    print(f"Address of brownie_account: {brownie_account.address}")

    # Interact with the already deployed contract
    # contract_address = '0x6CA548f6DF5B540E72262E935b6Fe3e72cDd68C9'
    # deployed_contract = Contract.from_abi("DeployedContract", contract_address, minimal_abi)

    contract2 = AnonIDContract.deploy({'from': brownie_account})
    print(f"AnonID deployed: {contract2.address}")
    #contract = AnonIDContract.deploy({'from': accounts[0]})
    #print(f"AnonID deployed: {contract.address}")


    with open('contract_AnonID.txt', 'w') as file:
            # Write the contract address to the file
        file.write(contract2.address)
   
    print("AnonID contract address " + contract2.address + " saved to 'contract_AnonID.txt'")

