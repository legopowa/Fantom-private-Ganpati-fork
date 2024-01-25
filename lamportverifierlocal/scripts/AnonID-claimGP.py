import lorem
from pathlib import Path
import sys
from itertools import chain
import random
import hashlib
import base64
from web3 import Web3
from web3.exceptions import InvalidAddress
from brownie import network, web3, accounts, Wei, AnonIDContract, Contract
from brownie.network import gas_price
from brownie.network.gas.strategies import LinearScalingStrategy
from eth_utils import encode_hex #, encode_single
from eth_abi import encode_single
from Crypto.Hash import keccak
from typing import List
import json
import os
import ast
import time
from time import sleep
import re
from typing import List
import struct
from offchain.local_functions import get_pkh_list
from offchain.KeyTracker_ import KeyTracker
from offchain.soliditypack import solidity_pack_value_bytes, solidity_pack_value, pack_keys, encode_packed_2d_list, solidity_pack_bytes, encode_packed, solidity_pack_pairs, solidity_pack, solidity_pack_bytes, solidity_pack_array
from offchain.Types import LamportKeyPair, Sig, PubPair
from offchain.functions import hash_b, sign_hash, verify_signed_hash
from eth_abi import encode_abi, encode_single
from binascii import crc32, hexlify
import binascii
from offchain.crc import compute_crc
#from offchain.oracle_functions import extract_data_from_file, get_pkh_list, send_pkh_with_crc, save_received_data, read_till_eof, send_packed_file
import offchain.data_temp

SOF = b'\x01'  # Start Of File marker
EOF = b'\x04'  # End Of File marker
CRC_START = b'<CRC>'
CRC_END = b'</CRC>'



gas_strategy = LinearScalingStrategy("1200 gwei", "120000 gwei", 1.1)

# if network.show_active() == "development":
gas_price(gas_strategy)

ITERATIONS = 3

# def compute_crc(self, data: str) -> int:
#     return crc32(data.encode())

offchain.data_temp.received_data = b''

def encode_packed(*args):
    return b"".join([struct.pack(f"<{len(arg)}s", arg) for arg in args])

# def solidity_pack_pairs(pairs):
#     packed_pairs = []
#     for pair in pairs:
#         address = pair[0]
#         value = pair[1]
#         packed_pairs.append(solidity_pack_bytes([address, value]))
#     return b''.join(packed_pairs)

# def solidity_pack_bytes(values):
#     packed_values = []

#     for value in values:
#         if isinstance(value, int):
#             # solidity uses big endian
#             packed_value = value.to_bytes((value.bit_length() + 7) // 8, 'big').rjust(32, b'\0')
#         elif isinstance(value, str) and re.match(r"^0x[a-fA-F0-9]{40}$", value):
#             packed_value = bytes.fromhex(value[2:]).rjust(32, b'\0')
#         elif isinstance(value, str):
#             packed_value = value.encode('utf-8')
#         else:
#             raise ValueError("Unsupported type")
            
#         packed_values.append(packed_value)

    return b''.join(packed_values)
# def generate_address_value_pairs(n_pairs):
#     pairs = [[None, None]] * 10
#     for i in range(n_pairs):
#         address = '0x' + binascii.hexlify(os.urandom(20)).decode()  # An Ethereum address is 20 bytes
#         value = random.randint(1, 1000)  # You can adjust this as per your needs
#         pairs[i][0] = address
#         pairs[i][1] = value
#     return pairs
# # def generate_address_value_pairs(n):

# #         addr = generate_address()  # Replace with your own logic to generate an address
# #         value = generate_value()  # Replace with your own logic to generate a value
 
def custom_encode_packed(address, integer):
    # Convert the address to bytes and pad with zeroes
    address_bytes = bytes(Web3.toBytes(hexstr=address))

    # Convert the integer to bytes and pad with zeroes
    integer_bytes = encode_single('uint', integer)

    # Concatenate everything together
    result = address_bytes + b'\0' * 12 + integer_bytes + b'\0' * 12

    return result.decode('unicode_escape')

def main():
    for _ in range(1):  # This will repeat the whole logic 3 times
        lamport_test = LamportTest()
        
        # Convert all account objects to strings before passing them
        lamport_test.can_test_key_functions([str(acc) for acc in accounts])

        # lamport_test.load_keys()
        # lamport_test.load_two_masters()

        # lamport_test.can_broadcast_message_via_broadcast2([str(acc) for acc in accounts])
        # lamport_test.can_broadcast_message_via_broadcast_with_number([str(acc) for acc in accounts])
        # lamport_test.can_broadcast_message_via_broadcast_with_number_and_address([str(acc) for acc in accounts])
        
#port = serial.Serial('/dev/ttyUSB0', 115200, timeout=1)

oracle_pkh = []
master_pkh_1 = []
master_pkh_2 = []
master_pkh_3 = []

class LamportTest:
    
    def __init__(self):

        print("Initializing LamportTest...")
        with open('contract_AnonID.txt', 'r') as file:
            contract_address = file.read().strip()
        #print(contract_address)
        self.contract = AnonIDContract.at(contract_address)
        #lamport_base = LamportBase.at(contract_address) # <<< not working!
        accounts.default = str(accounts[0]) 
        # link it up
    
        print('init done')

    def can_test_key_functions(self, accs):
        global master_pkh_1
        global master_pkh_2
        #global master_pkh_3
        print("Running 'can_test_key_functions'...")
        with open('contract_AnonID.txt', 'r') as file:
            contract_address = file.read()
            contract_address = contract_address.strip().replace('\n', '')  # Remove whitespace and newlines

        _contract = AnonIDContract.at(contract_address)
        print("Contract referenced.")
        print('master_pkh_1', master_pkh_1)
        private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'
        brownie_account = accounts.add(private_key)
        ##mnemonic using user acct
                # Read mnemonic from file
        mnemonic_path = Path('mnemonic.txt')
        if not mnemonic_path.is_file():
            raise Exception(f"Can't find {mnemonic_path}")

        with open(mnemonic_path, "r") as file:
            mnemonic = file.read().strip()

        # Generate the account using the mnemonic
        user_account = accounts.from_mnemonic(mnemonic) # for account from mnemonic

        _contract.claimGP(
                            
            {'from': user_account, 'gas_limit': 500000}

        )

        
        ClaimedGP_filter = _contract.events.ClaimedGP.createFilter(fromBlock='latest')

        # Iterate through the events
        for event in ClaimedGP_filter.get_all_entries():
            # Access event data
            userAddress = event['args']['userAddress']
            lastClaimValue = event['args']['lastClaimValue']
            minutesPlayed = event['args']['minutesPlayed']

            # Print the data
            print(f"userAddress: {userAddress}, lastClaimValue: {lastClaimValue}, minutesPlayed: {minutesPlayed}")
        exit()