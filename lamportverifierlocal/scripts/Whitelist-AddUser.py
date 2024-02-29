import lorem

import sys
from itertools import chain
import random
import hashlib
import base64
from web3 import Web3
from web3.exceptions import InvalidAddress
from brownie import network, web3, accounts, Wei, WhitelistTest, AnonIDContract, Contract
from brownie.network import gas_price
from brownie.network.gas.strategies import LinearScalingStrategy
from eth_utils import encode_hex #, encode
from eth_abi import encode
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
#from offchain.local_functions import get_pkh_list
from offchain.KeyTracker_ import KeyTracker
from offchain.soliditypack import solidity_pack_value_bytes, solidity_pack_value, pack_keys, encode_packed_2d_list, solidity_pack_bytes, encode_packed, solidity_pack_pairs, solidity_pack, solidity_pack_bytes, solidity_pack_array
from offchain.Types import LamportKeyPair, Sig, PubPair
from offchain.functions import hash_b, sign_hash, verify_signed_hash
from eth_abi import encode, encode
from binascii import crc32, hexlify
import binascii
from offchain.crc import compute_crc
#from offchain.oracle_functions import extract_data_from_file, get_pkh_list, send_pkh_with_crc, save_received_data, read_till_eof, send_packed_file
import offchain.data_temp

SOF = b'\x01'  # Start Of File marker
EOF = b'\x04'  # End Of File marker
CRC_START = b'<CRC>'
CRC_END = b'</CRC>'



gas_strategy = LinearScalingStrategy("120 gwei", "1200 gwei", 1.1)

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
    integer_bytes = encode('uint', integer)

    # Concatenate everything together
    result = address_bytes + b'\0' * 12 + integer_bytes + b'\0' * 12

    return result.decode('unicode_escape')

def main():
    for _ in range(1):  # This will repeat the whole logic 3 times
        lamport_test = LamportTest()
        
        # Convert all account objects to strings before passing them
        lamport_test.can_test_key_functions([str(acc) for acc in accounts])
        lamport_test.can_test_message_functions([str(acc) for acc in accounts])
        lamport_test.can_test_del_functions([str(acc) for acc in accounts])       

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

        self.k1 = KeyTracker("master1") # new keys made here
        self.k2 = KeyTracker("master2")
        self.k3 = KeyTracker("oracle1")
        self.k4 = KeyTracker("master3")
        print("Initializing LamportTest...")
        with open('whitelist_contract.txt', 'r') as file:
            contract_address = file.read().strip()
        #print(contract_address)
        self.contract = WhitelistTest.at(contract_address)
        #lamport_base = LamportBase.at(contract_address) # <<< not working!
        accounts.default = str(accounts[0]) 
        # link it up
        #pkhs = self.get_pkh_list(self.contract, 0) lamport
        #opkhs = self.get_pkh_list(self.contract, 1)
        # priv level set here with integer ^
        #print("contract pkh", pkhs)

        #self.load_two_masters(pkhs, "master")
        #self.load_keys(opkhs, "oracle")
        print('init done')

    #def get_pkh_list(self, contract, privilege_level):
        #contract_pkh = str(contract.getPKHsByPrivilege(privilege_level)) lamport
        # gonna need some kind of wait / delay here for primetime
        #print(contract_pkh)
        #contract_pkh_list = re.findall(r'0x[a-fA-F0-9]+', contract_pkh)
        #pkh_list = [pkh for pkh in contract_pkh_list]  # Removing '0x' prefix
        #contract_pkh_string = json.dumps(contract_pkh)
        #contract_pkh_list = json.dumps(contract_pkh_string)
        #return pkh_list

    
    def load_two_masters(self, pkhs, filename):
        pkh_index = 0
        master1_loaded = False
        master2_loaded = False
        global master_pkh_1
        global master_pkh_2

        while not master1_loaded and pkh_index < len(pkhs):
            try:
                self.k1.load(self, filename + '1', pkhs[pkh_index])
                print(f"Load successful for Master 1, PKH: {pkhs[pkh_index]}")
                master1_loaded = True
                key_tracker_1 = self.k1.current_key_pair()
                master_pkh_1 = pkhs[pkh_index]
                pkh_index += 1  # increment the pkh_index after successful load
            except InvalidAddress:
                print(f"No valid keys found for Master 1, PKH: {pkhs[pkh_index]}")
                pkh_index += 1  # increment the pkh_index if load failed

        if not master1_loaded:
            print("Load failed for all provided PKHs for Master 1")
            return

        while not master2_loaded and pkh_index < len(pkhs):
            try:
                self.k2.load(self, filename + '2', pkhs[pkh_index])
                print(f"Load successful for Master 2, PKH: {pkhs[pkh_index]}")
                master2_loaded = True
                key_tracker_2 = self.k2.current_key_pair()
                master_pkh_2 = pkhs[pkh_index]
                pkh_index += 1  # increment the pkh_index after successful load
            except InvalidAddress:
                print(f"No valid keys found for Master 2, PKH: {pkhs[pkh_index]}")
                pkh_index += 1  # increment the pkh_index if load failed

        if not master2_loaded:
            print("Load failed for all provided PKHs for Master 2")

    def load_keys(self, pkhs, filename):
        global oracle_pkh
        for pkh in pkhs:
            try:
                oracle_pkh = pkh
                self.k3.load(self, filename + '1', pkh)
                print(f"Load successful for PKH: {pkh}")
                return  # Exit function after successful load
            except InvalidAddress:
                print(f"No valid keys found for PKH: {pkh}")
                continue  # Try the next pkh if this one fails
        print("Load failed for all provided PKHs")

    def can_test_key_functions(self, accs):
        global master_pkh_1
        global master_pkh_2
        #global master_pkh_3
        print("Running 'can_test_key_functions'...")
        with open('whitelist_contract.txt', 'r') as file:
            contract_address = file.read()
            contract_address = contract_address.strip().replace('\n', '')  # Remove whitespace and newlines

        _contract = WhitelistTest.at(contract_address)
        print("Contract referenced.")
        print('master_pkh_1', master_pkh_1)
        private_key = '163f5f0f9a621d72fedd85ffca3d08d131ab4e812181e0d30ffd1c885d20aac7'
        brownie_account = accounts.add(private_key)
        #current_keys = self.k1.load(self, "master1", master_pkh_1) lamport
        #current_pkh = self.k1.pkh_from_public_key(current_keys.pub)
        #print('current pkh', current_pkh)
        next_keys = self.k1.get_next_key_pair()
        nextpkh = self.k1.pkh_from_public_key(next_keys.pub)
        #pairs = generate_address_value_pairs(10)
        #packed_pairs = solidity_pack_pairs(pairs)
        #_newCap = int(300000)
        #numToBroadcast = int(1000000)
        #pnumToBroadcast = numToBroadcast.to_bytes(4, 'big')
        #paddednumToBroadcast = solidity_pack_value_bytes(pnumToBroadcast)
        paddressToBroadcast = '0x239fa7623354ec26520de878b52f13fe84b06971'
        #paddressToBroadcast = '0xfd003CA44BbF4E9fB0b2fF1a33fc2F05A6C2EFF9'


        #packed_message = binascii.hexlify(_newCap) + nextpkh[2:].encode()
        #packed_message = paddednumToBroadcast.hex().encode() + nextpkh[2:].encode()
        packed_message = str.lower(paddressToBroadcast)[2:].encode() + nextpkh[2:].encode()
        
        callhash = hash_b(str(packed_message.decode()))
        #sig = sign_hash(callhash, current_keys.pri) 
        # _contract.addAddressToWhitelist(
                            
        #     paddressToBroadcast,
        #     'blank',
        #     #current_keys.pub,
        #     #sig,
        #     #nextpkh,
        #     {'from': brownie_account}
        # )
        # OperationResult_filter = _contract.events.OperationResult.createFilter(fromBlock='latest')

        # for event in OperationResult_filter.get_all_entries():
        #     data = event['args']['success']
        #     print(f"Operation Result: {data}")


    # # Addresses of the deployed contracts
    #     anonid_contract_address = '0xA527F50706BB1FCaEd6F864afB2e3FCe4943AF68'
    #     whitelist_test_contract_address = '0x09c7F5BB03497990AAE0a40dF2A6c87a15aaD430'  # Replace with actual address
        # Read the AnonID contract address from contract_AnonID.txt
        with open('contract_AnonID.txt', 'r') as file:
            anonid_contract_address = file.read().strip()
        print(f"AnonID Contract Address: {anonid_contract_address}")

        # Read the WhitelistTest contract address from whitelist_contract.txt
        with open('whitelist_contract.txt', 'r') as file:
            whitelist_test_contract_address = file.read().strip()
        print(f"WhitelistTest Contract Address: {whitelist_test_contract_address}")


        # Access the deployed contracts
        anonid_contract = AnonIDContract.at(anonid_contract_address)
        whitelist_test_contract = WhitelistTest.at(whitelist_test_contract_address)

        # Address to be whitelisted
        #paddressToBroadcast = 'Some_Ethereum_Address'  # Replace with actual address

        # Perform a transaction
        tx = whitelist_test_contract.addAddressToWhitelist(paddressToBroadcast, "anonID", {'from': brownie_account})
        # user added here                                  ^^^^^^^^^^^^^^^^^^^^

        
        # Capture events
        whitelist_events = tx.events['Whitelisted']
        failed_events = tx.events['WhitelistAdditionFailed']
        error_events = tx.events['ErrorCaught']
        operation_results = tx.events['OperationResult']

        for event in operation_results:
            success = event['success']
            message = event['message']  # Assuming the event also includes a 'message' field for success or error message
            print(f"Operation Result: Success={success}, Message='{message}'")
        # Process success events
        for event in whitelist_events:
            print(f"Address {event['_address']} whitelisted with ID {event['hashedID']}")

        # Process failure events
        for event in failed_events:
            print(f"Failed to whitelist {event['_address']}: {event['reason']}")

        # Process error events
        for event in error_events:
            print(f"Error in action {event['action']}: {event['error']}")

        #exit()
        #self.k1.save(trim = False)
        exit()