from web3 import Web3
from eth_account import Account
from bip44 import Wallet
from mnemonic import Mnemonic

Account.enable_unaudited_hdwallet_features()
mnemonic_file_path = './mnemonic.txt'
with open(mnemonic_file_path, 'r') as file:
    mnemonic_phrase = file.readline().strip()
mnemo = Mnemonic("english")

# Derive the seed from the mnemonic
seed = mnemo.to_seed(mnemonic_phrase)

# Derive the private key from the seed
# You can use different paths (e.g., "m/44'/60'/0'/0/0" for the first account)
account_index = 0
path = f"m/44'/60'/0'/0/{account_index}"
wallet = Account.from_mnemonic(mnemonic_phrase, account_path=path)

# Now you can use wallet.privateKey to sign transactions
private_key = wallet.key.hex()

# Connect to local Ethereum node
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:4000'))
#w3 = Web3(Web3.HTTPProvider('http://129.146.76.34:8545'))

# Check if the connection is successful
if not w3.isConnected():
    print("Failed to connect to the Ethereum node.")
else:
    print("Connected to the Ethereum node.")

# The ABI and Bytecode outputted by the Remix compiler
contract_abi = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": True,
				"internalType": "address",
				"name": "userAddress",
				"type": "address"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "lastClaimValue",
				"type": "uint256"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "minutesPlayed",
				"type": "uint256"
			}
		],
		"name": "ClaimedGP",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": True,
				"internalType": "address",
				"name": "newCommissionAddress",
				"type": "address"
			}
		],
		"name": "CommissionAddressSet",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "newCoinCommission",
				"type": "uint256"
			}
		],
		"name": "CommissionSet",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			}
		],
		"name": "ContractPermissionGranted",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			}
		],
		"name": "ContractPermissionRevoked",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "newFreeGasCap",
				"type": "uint256"
			}
		],
		"name": "FreeGasCapSet",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "enum AnonIDContract.KeyType",
				"name": "keyType",
				"type": "uint8"
			},
			{
				"indexed": False,
				"internalType": "bytes32",
				"name": "newPKH",
				"type": "bytes32"
			}
		],
		"name": "KeyAdded",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "enum AnonIDContract.KeyType",
				"name": "originalKeyType",
				"type": "uint8"
			},
			{
				"indexed": False,
				"internalType": "bytes32",
				"name": "originalPKH",
				"type": "bytes32"
			},
			{
				"indexed": False,
				"internalType": "bytes32",
				"name": "modifiedPKH",
				"type": "bytes32"
			},
			{
				"indexed": False,
				"internalType": "enum AnonIDContract.KeyType",
				"name": "newKeyType",
				"type": "uint8"
			}
		],
		"name": "KeyModified",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "hash",
				"type": "uint256"
			}
		],
		"name": "LogLastCalculatedHash",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": True,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "_minutes",
				"type": "uint256"
			}
		],
		"name": "MinutesPlayedIncremented",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "enum AnonIDContract.KeyType",
				"name": "keyType",
				"type": "uint8"
			},
			{
				"indexed": False,
				"internalType": "bytes32",
				"name": "previousPKH",
				"type": "bytes32"
			},
			{
				"indexed": False,
				"internalType": "bytes32",
				"name": "newPKH",
				"type": "bytes32"
			}
		],
		"name": "PkhUpdated",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": True,
				"internalType": "address",
				"name": "_address",
				"type": "address"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "_quota",
				"type": "uint256"
			}
		],
		"name": "QuotaSet",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": True,
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "RemovedFromWhitelist",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": True,
				"internalType": "address",
				"name": "_user",
				"type": "address"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "TxRecorded",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "hashedData",
				"type": "uint256"
			}
		],
		"name": "VerificationFailed",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": True,
				"internalType": "address",
				"name": "_address",
				"type": "address"
			},
			{
				"indexed": False,
				"internalType": "bytes32",
				"name": "hashedID",
				"type": "bytes32"
			}
		],
		"name": "Whitelisted",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "_coinCommission",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "anonID",
				"type": "string"
			}
		],
		"name": "addToWhitelist",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "addressToHashedID",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "claimGP",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "coinCommission",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "commissionAddress",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "bytes",
				"name": "bytecode",
				"type": "bytes"
			}
		],
		"name": "createContractStepOne",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "bytes",
				"name": "bytecode",
				"type": "bytes"
			}
		],
		"name": "createContractStepTwo",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "bytes",
				"name": "newmasterPKH",
				"type": "bytes"
			}
		],
		"name": "createMasterKeyStepOne",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "newmasterPKH",
				"type": "bytes32"
			}
		],
		"name": "createMasterKeyStepTwo",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "neworaclePKH",
				"type": "bytes32"
			}
		],
		"name": "createOracleKeyFromMaster",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "deleteKeyHash",
				"type": "bytes32"
			}
		],
		"name": "deleteKeyStepOne",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "confirmDeleteKeyHash",
				"type": "bytes32"
			}
		],
		"name": "deleteKeyStepTwo",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "freeGasCap",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "pkh",
				"type": "bytes32"
			}
		],
		"name": "getKeyAndPosByPKH",
		"outputs": [
			{
				"internalType": "enum AnonIDContract.KeyType",
				"name": "",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "getMinutesPlayed",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "enum AnonIDContract.KeyType",
				"name": "privilege",
				"type": "uint8"
			}
		],
		"name": "getPKHsByPrivilege",
		"outputs": [
			{
				"internalType": "bytes32[]",
				"name": "",
				"type": "bytes32[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			},
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			}
		],
		"name": "grantActivityContractPermission",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "hourlyTxQuota",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_minutes",
				"type": "uint256"
			}
		],
		"name": "incrementMinutesPlayed",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "isContractPermitted",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "isThisTxFree",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "isWhitelisted",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"name": "keyData",
		"outputs": [
			{
				"internalType": "enum AnonIDContract.KeyType",
				"name": "keyType",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "pkh",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "keys",
		"outputs": [
			{
				"internalType": "enum AnonIDContract.KeyType",
				"name": "keyType",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "pkh",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "lastClaim",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "lastLastClaim",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "lastUsedBytecodeHash",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "lastUsedNextPKH",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "lastVerificationResult",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "minutesPlayed",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "removeFromWhitelist",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			},
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			}
		],
		"name": "revokeActivityContractPermission",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "uint256",
				"name": "newCoinCommission",
				"type": "uint256"
			}
		],
		"name": "setCoinCommissionStepOne",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "uint256",
				"name": "newCoinCommission",
				"type": "uint256"
			}
		],
		"name": "setCoinCommissionStepTwo",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "address",
				"name": "newCommissionAddress",
				"type": "address"
			}
		],
		"name": "setCommissionAddressStepOne",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			},
			{
				"internalType": "address",
				"name": "newCommissionAddress",
				"type": "address"
			}
		],
		"name": "setCommissionAddressStepTwo",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_newCap",
				"type": "uint256"
			},
			{
				"internalType": "bytes32[2][256]",
				"name": "currentpub",
				"type": "bytes32[2][256]"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32",
				"name": "nextPKH",
				"type": "bytes32"
			}
		],
		"name": "setFreeGasCap",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_quota",
				"type": "uint256"
			}
		],
		"name": "setHourlyTxQuota",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "userTxTimestamps",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "bits",
				"type": "uint256"
			},
			{
				"internalType": "bytes[256]",
				"name": "sig",
				"type": "bytes[256]"
			},
			{
				"internalType": "bytes32[2][256]",
				"name": "pub",
				"type": "bytes32[2][256]"
			}
		],
		"name": "verify_u256",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "whitelist",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]

contract_bytecode = '608060405234801562000010575f80fd5b506200003d5f7fb7b18ded9664d1a8e923a5942ec1ca5cd8c13c40eb1a5215d5800600f5a587be620000c2565b620000695f7f1ed304ab73e124b0b99406dfa1388a492a818837b4b41ce5693ad84dacfc3f25620000c2565b6200009660017fd62569e61a6423c880a429676be48756c931fe0519121684f5fb05cbd17877fa620000c2565b600680546001600160a01b03191673fd003ca44bbf4e9fb0b2ff1a33fc2f05a6c2eff91790556200021f565b5f6040518060400160405280846002811115620000e357620000e3620001e0565b8152602001839052600d8054600181810183555f92909252825160029182027fd7b6990105719101dabeb77144f2a3385c8033acd3af97e9423a695e81ad1eb5018054949550859490939192849260ff19909216919084908111156200014d576200014d620001e0565b02179055506020918201516001918201555f848152600e9092526040909120825181548493839160ff1916908360028111156200018e576200018e620001e0565b0217905550602082015181600101559050507f2172c7b01a6de957d29fd6166a23025d181bf56538ad606a526ab2d62603f3fc8383604051620001d3929190620001f4565b60405180910390a1505050565b634e487b7160e01b5f52602160045260245ffd5b60408101600384106200021557634e487b7160e01b5f52602160045260245ffd5b9281526020015290565b613766806200022d5f395ff3fe608060405234801561000f575f80fd5b5060043610610255575f3560e01c8063787325ca11610140578063aec43f5a116100bf578063ba69067711610084578063ba690677146105ad578063d47b2e99146105cc578063d83c413c146105df578063e673d71f146105f2578063f82e84fd14610605578063fb632d8914610618575f80fd5b8063aec43f5a1461054c578063af82f3e71461055f578063b3910c9f14610572578063b889b2b714610585578063b97b4f771461058d575f80fd5b80638eb8f1a6116101055780638eb8f1a6146104c7578063931742d3146104da5780639b19251a146104eb578063a9711ee31461050d578063ae61d2c214610539575f80fd5b8063787325ca1461045e5780637e08deae146104865780638705d945146104995780638775b01f146104a15780638ab1d681146104b4575f80fd5b80634a672870116101d75780635796841a1161019c5780635796841a146103bc5780635961f500146103cf5780635c16e15e146103e25780636118b1c3146104015780636c8dd0bd14610414578063753ac6dc14610433575f80fd5b80634a6728701461035b5780634bdd44991461036e5780634e657d2a146103775780634fbbc63f1461038a5780635325758e146103a9575f80fd5b80632fd5c2471161021d5780632fd5c247146102f05780633337db52146102fd5780633af32abf146103145780633b5b27d71461033f5780633e13566b14610352575f80fd5b806303545eac1461025957806305aacc7d146102905780630cb6aaf1146102b2578063142eb8c8146102d35780631a533daa146102dd575b5f80fd5b61027b610267366004612fc0565b60076020525f908152604090205460ff1681565b60405190151581526020015b60405180910390f35b6102a361029e366004612fd9565b610637565b60405161028793929190613024565b6102c56102c0366004612fd9565b61072a565b604051610287929190613043565b6102db61075a565b005b6102db6102eb3660046130e5565b610893565b600f5461027b9060ff1681565b61030660015481565b604051908152602001610287565b61027b610322366004612fc0565b6001600160a01b03165f9081526008602052604090205460ff1690565b61030661034d366004613143565b6109bb565b61030660035481565b6102db610369366004613193565b6109e6565b61030660135481565b6102db6103853660046131f2565b610baf565b610306610398366004612fc0565b600b6020525f908152604090205481565b6102db6103b7366004613283565b610cff565b6102db6103ca366004613193565b610e88565b6102db6103dd3660046132e9565b6110bb565b6103066103f0366004612fc0565b600a6020525f908152604090205481565b6102db61040f366004613143565b61130f565b610306610422366004612fc0565b60096020525f908152604090205481565b6104466104413660046131f2565b611445565b6040516001600160a01b039091168152602001610287565b61030661046c366004612fc0565b6001600160a01b03165f9081526009602052604090205490565b6102db610494366004613193565b61166a565b600154610306565b61027b6104af366004612fc0565b61190f565b6102db6104c2366004612fc0565b611af0565b6102db6104d5366004613352565b611bda565b6006546001600160a01b0316610446565b61027b6104f9366004612fc0565b60086020525f908152604090205460ff1681565b6102c561051b366004612fd9565b600e6020525f90815260409020805460019091015460ff9091169082565b6102db6105473660046132e9565b611d51565b6102db61055a366004613283565b611ee7565b61027b61056d366004613394565b612097565b6102db6105803660046133e9565b612148565b6103065f5481565b6105a061059b36600461340e565b6122db565b604051610287919061342c565b6103066105bb366004612fc0565b600c6020525f908152604090205481565b6102db6105da366004613143565b612470565b6102db6105ed366004613193565b612544565b6102db610600366004613193565b6126ba565b6102db6106133660046131f2565b612bbf565b610306610626366004612fc0565b60056020525f908152604090205481565b5f818152600e602052604080822081518083019092528054839283928392829060ff16600281111561066b5761066b612ff0565b600281111561067c5761067c612ff0565b8152600191909101546020918201528101519091505f036106b85760405162461bcd60e51b81526004016106af9061346f565b60405180910390fd5b5f5b600d5481101561070a5785600d82815481106106d8576106d86134a6565b905f5260205f20906002020160010154036107025781516020909201519194509092509050610723565b6001016106ba565b5060405162461bcd60e51b81526004016106af9061346f565b9193909250565b600d8181548110610739575f80fd5b5f9182526020909120600290910201805460019091015460ff909116915082565b335f8181526008602052604090205460ff166107b85760405162461bcd60e51b815260206004820152601760248201527f55736572206973206e6f742077686974656c697374656400000000000000000060448201526064016106af565b6001600160a01b0381165f908152600a6020908152604080832054600b90925290912054808210156108235760405162461bcd60e51b8152602060048201526014602482015273496e76616c696420636c61696d2076616c75657360601b60448201526064016106af565b6001600160a01b0383165f818152600b60209081526040808320869055600980835281842054600a84529382902084905582528051868152918201929092527fdc5ec23a202853e756bbb0c4f4cb94deea4936fcc71756da3ddebf99aabf6c9e91015b60405180910390a2505050565b335f9081526007602052604090205460ff166108c15760405162461bcd60e51b81526004016106af906134ba565b5f816040516020016108d3919061351d565b60408051601f1981840301815291815281516020928301206001600160a01b0386165f908152600890935291205490915060ff16156109545760405162461bcd60e51b815260206004820152601b60248201527f4164647265737320616c72656164792077686974656c6973746564000000000060448201526064016106af565b6001600160a01b0383165f8181526005602081815260408084209290925560088152818320805460ff19166001179055600c815291819020849055518381527fc27d38ad1bdb4164d72e05492b5ce6099b4169e9f20b41d3c7cf35c114a64d5b9101610886565b6004602052815f5260405f2081815481106109d4575f80fd5b905f5260205f20015f91509150505481565b838383836040516020016109fc91815260200190565b6040516020818303038152906040525f84604051602001610a1d9190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115610a5a57610a5a612ff0565b14610a775760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001610a8b9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f610acd828789612097565b600f805460ff1916821515179055905080610b57576040518281525f805160206136d1833981519152906020015b60405180910390a160405162461bcd60e51b815260206004820152602360248201527f416e6f6e4944436f6e74726163743a20566572696669636174696f6e206661696044820152621b195960ea1b60648201526084016106af565b5f838152600e6020526040908190205490515f8051602061371183398151915291610b8b9160ff9091169086908990613024565b60405180910390a1610b9d8386612d17565b50505060029490945550505050505050565b838383835f84604051602001610bc59190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115610c0257610c02612ff0565b14610c1f5760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001610c339291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f610c75828789612097565b600f805460ff1916821515179055905080610ca7576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f8051602061371183398151915291610cdb9160ff9091169086908990613024565b60405180910390a1610ced8386612d17565b50505060139590955550505050505050565b82828286604051602001610d1391906135c4565b6040516020818303038152906040525f84604051602001610d349190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115610d7157610d71612ff0565b14610d8e5760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001610da29291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f610de4828789612097565b600f805460ff1916821515179055905080610e16576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f8051602061371183398151915291610e4a9160ff9091169086908990613024565b60405180910390a1610e5c8386612d17565b5050506001600160a01b039097165f908152600760205260409020805460ff1916905550505050505050565b83838383604051602001610e9e91815260200190565b6040516020818303038152906040525f84604051602001610ebf9190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115610efc57610efc612ff0565b14610f195760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001610f2d9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f610f6f828789612097565b600f805460ff1916821515179055905080610fa1576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f8051602061371183398151915291610fd59160ff9091169086908990613024565b60405180910390a1610fe78386612d17565b5f8b604051602001610ff99190613538565b60408051601f198184030181529190528051602090910120601380545f9091559091508114158061109e5760405162461bcd60e51b815260206004820152604360248201527f416e6f6e4944436f6e74726163743a20504b48206d617463686573206c61737460448201527f207573656420504b482028757365207365706172617465207365636f6e64206b60648201526265792960e81b608482015260a4016106af565b6110a85f8b612e9f565b50505f6013555050505050505050505050565b838383836040516020016110cf91906135c4565b6040516020818303038152906040525f846040516020016110f09190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff16600281111561112d5761112d612ff0565b1461114a5760405162461bcd60e51b81526004016106af9061356e565b5f828460405160200161115e9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f6111a0828789612097565b600f805460ff19168215151790559050806111d2576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f80516020613711833981519152916112069160ff9091169086908990613024565b60405180910390a16112188386612d17565b8760405160200161122991906135c4565b60405160208183030381529060405280519060200120601054146112b7576040805162461bcd60e51b81526020600482015260248101919091527f416e6f6e4944436f6e74726163743a204d69736d61746368656420616464726560448201527f73732068617368206265747765656e2073746570206f6e6520616e642074776f60648201526084016106af565b600680546001600160a01b0319166001600160a01b038a169081179091555f60108190556040517f78cb7d38f54b570d3aa94edfe9942ff10d8b002a73299229ea4ece39479eb1169190a25050505050505050505050565b335f9081526007602052604090205460ff166113865760405162461bcd60e51b815260206004820152603060248201527f4e6f74207065726d697474656420746f206d6f6469667920686f75726c79207460448201526f72616e73616374696f6e2071756f746160801b60648201526084016106af565b6001600160a01b0382165f9081526008602052604090205460ff166113ed5760405162461bcd60e51b815260206004820152601e60248201527f41646472657373206e6f7420666f756e6420696e2077686974656c697374000060448201526064016106af565b6001600160a01b0382165f8181526005602052604090819020839055517f49e4e7ca63dcc35a72589f844cb844ce25176e8e1aff16f1ad1fb46624c65372906114399084815260200190565b60405180910390a25050565b5f848484845f8460405160200161145c9190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff16600281111561149957611499612ff0565b146114b65760405162461bcd60e51b81526004016106af9061356e565b5f82846040516020016114ca9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f61150c828789612097565b600f805460ff191682151517905590508061153e576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f80516020613711833981519152916115729160ff9091169086908990613024565b60405180910390a16115848386612d17565b600354895160208b0120146115f95760405162461bcd60e51b815260206004820152603560248201527f42797465636f646520646f6573206e6f74206d617463682070726576696f7573604482015274363c90383937bb34b232b210313cba32b1b7b2329760591b60648201526084016106af565b5f895160208b015ff090506001600160a01b03811661165a5760405162461bcd60e51b815260206004820152601860248201527f436f6e7472616374206372656174696f6e206661696c6564000000000000000060448201526064016106af565b9c9b505050505050505050505050565b8383838360405160200161168091815260200190565b6040516020818303038152906040525f846040516020016116a19190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff1660028111156116de576116de612ff0565b146116fb5760405162461bcd60e51b81526004016106af9061356e565b5f828460405160200161170f9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f611751828789612097565b600f805460ff1916821515179055905080611783576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f80516020613711833981519152916117b79160ff9091169086908990613024565b60405180910390a16117c98386612d17565b60148811156118405760405162461bcd60e51b815260206004820152603760248201527f416e6f6e4944436f6e74726163743a20436f6d6d697373696f6e2073686f756c60448201527f64206265206265747765656e20302520616e642032302500000000000000000060648201526084016106af565b60025488146118c55760405162461bcd60e51b815260206004820152604560248201527f416e6f6e4944436f6e74726163743a204d69736d61746368656420636f6d6d6960448201527f7373696f6e2076616c756573206265747765656e2073746570206f6e6520616e606482015264642074776f60d81b608482015260a4016106af565b60018890555f6002556040518881527f11bf320227562bd5f6c9b575913cf92b3b996b47873159df227324ae1bb4d0ea906020015b60405180910390a15050505050505050505050565b5f3341146119855760405162461bcd60e51b815260206004820152603860248201527f4f6e6c79207468652063757272656e7420626c6f636b277320636f696e62617360448201527f652063616e2063616c6c20746869732066756e6374696f6e000000000000000060648201526084016106af565b6001600160a01b0382165f9081526008602052604090205460ff166119ab57505f919050565b6001600160a01b0382165f8181526004602090815260409182902091514281529192917f9ed0861f8fc182c8888f48e900842f475ccd2a3c93c6f966168eaa67d52d2ee1910160405180910390a26001600160a01b0383165f90815260056020526040902054815403611ad457610e10815f81548110611a2d57611a2d6134a6565b905f5260205f20015442611a4191906135f5565b11611a4e57505f92915050565b5f5b8154611a5e906001906135f5565b811015611aaf5781611a71826001613608565b81548110611a8157611a816134a6565b905f5260205f200154828281548110611a9c57611a9c6134a6565b5f91825260209091200155600101611a50565b5080805480611ac057611ac061361b565b600190038181905f5260205f20015f905590555b8054600181810183555f92835260209092204291015592915050565b335f9081526007602052604090205460ff16611b1e5760405162461bcd60e51b81526004016106af906134ba565b6001600160a01b0381165f9081526008602052604090205460ff16611b855760405162461bcd60e51b815260206004820152601e60248201527f41646472657373206e6f7420666f756e6420696e2077686974656c697374000060448201526064016106af565b6001600160a01b0381165f818152600860209081526040808320805460ff19169055600c909152808220829055517fcdd2e9b91a56913d370075169cefa1602ba36be5301664f752192bb1709df7579190a250565b83828483604051602001611bf091815260200190565b6040516020818303038152906040525f84604051602001611c119190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115611c4e57611c4e612ff0565b14611c6b5760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001611c7f9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f611cc1828789612097565b600f805460ff1916821515179055905080611cf3576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f8051602061371183398151915291611d279160ff9091169086908990613024565b60405180910390a1611d398386612d17565b611d44600189612e9f565b5050505050505050505050565b83838383604051602001611d6591906135c4565b6040516020818303038152906040525f84604051602001611d869190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115611dc357611dc3612ff0565b14611de05760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001611df49291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f611e36828789612097565b600f805460ff1916821515179055905080611e68576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f8051602061371183398151915291611e9c9160ff9091169086908990613024565b60405180910390a1611eae8386612d17565b87604051602001611ebf91906135c4565b60408051601f1981840301815291905280516020909101206010555050505050505050505050565b82828286604051602001611efb91906135c4565b6040516020818303038152906040525f84604051602001611f1c9190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115611f5957611f59612ff0565b14611f765760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001611f8a9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f611fcc828789612097565b600f805460ff1916821515179055905080611ffe576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f80516020613711833981519152916120329160ff9091169086908990613024565b60405180910390a16120448386612d17565b6001600160a01b038b165f81815260076020908152604091829020805460ff1916600117905590519182527f9c2d3039f3d15023b5382d61054aae8f70288e4bffb8676398baca3c389e8f1891016118fa565b5f805b61010081101561213b57838161010081106120b7576120b76134a6565b6020028101906120c7919061362f565b6040516120d5929190613679565b6040518091039020838261010081106120f0576120f06134a6565b604002015f8360ff036001901b88161161210a575f61210d565b60015b60ff1660028110612120576121206134a6565b602002013514612133575f915050612141565b60010161209a565b50600190505b9392505050565b8282828660405160200161215e91815260200190565b6040516020818303038152906040525f8460405160200161217f9190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff1660028111156121bc576121bc612ff0565b146121d95760405162461bcd60e51b81526004016106af9061356e565b5f82846040516020016121ed9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f61222f828789612097565b600f805460ff1916821515179055905080612261576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f80516020613711833981519152916122959160ff9091169086908990613024565b60405180910390a16122a78386612d17565b5f8b90556040518b81527f58098eeec115cba633a1b8765151f8a2e4efbdcb42846e0968e430d56e21d370906020016118fa565b600d546060905f9067ffffffffffffffff8111156122fb576122fb61305e565b604051908082528060200260200182016040528015612324578160200160208202803683370190505b5090505f805b600d548110156123d75784600281111561234657612346612ff0565b600d8281548110612359576123596134a6565b5f91825260209091206002918202015460ff169081111561237c5761237c612ff0565b036123cf57600d8181548110612394576123946134a6565b905f5260205f209060020201600101548383815181106123b6576123b66134a6565b6020908102919091010152816123cb81613688565b9250505b60010161232a565b505f8167ffffffffffffffff8111156123f2576123f261305e565b60405190808252806020026020018201604052801561241b578160200160208202803683370190505b5090505f5b828110156124675783818151811061243a5761243a6134a6565b6020026020010151828281518110612454576124546134a6565b6020908102919091010152600101612420565b50949350505050565b335f9081526007602052604090205460ff166124dd5760405162461bcd60e51b815260206004820152602660248201527f4e6f74207065726d697474656420746f206d6f64696679206d696e75746573206044820152651c1b185e595960d21b60648201526084016106af565b6001600160a01b0382165f9081526009602052604081208054839290612504908490613608565b90915550506040518181526001600160a01b038316907f54ecab596bd73e6a3fd6d8bb310aa69a74c3f78ddc040f88c6f5d06dffb3542b90602001611439565b8383838360405160200161255a91815260200190565b6040516020818303038152906040525f8460405160200161257b9190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff1660028111156125b8576125b8612ff0565b146125d55760405162461bcd60e51b81526004016106af9061356e565b5f82846040516020016125e99291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f61262b828789612097565b600f805460ff191682151517905590508061265d576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f80516020613711833981519152916126919160ff9091169086908990613024565b60405180910390a16126a38386612d17565b505050601194909455505050601291909155505050565b838383836040516020016126d091815260200190565b6040516020818303038152906040525f846040516020016126f19190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff16600281111561272e5761272e612ff0565b1461274b5760405162461bcd60e51b81526004016106af9061356e565b5f828460405160200161275f9291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f6127a1828789612097565b600f805460ff19168215151790559050806127d3576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f80516020613711833981519152916128079160ff9091169086908990613024565b60405180910390a16128198386612d17565b5f8b60405160200161282b9190613538565b60405160208183030381529060405280519060200120905060125481036128c85760405162461bcd60e51b8152602060048201526044602482018190527f416e6f6e4944436f6e74726163743a2043616e6e6f7420757365207468652073908201527f616d65206b6579636861696e20747769636520666f7220746869732066756e636064820152633a34b7b760e11b608482015260a4016106af565b88601154146129235760405162461bcd60e51b815260206004820152602160248201527f416e6f6e4944436f6e74726163743a204b65797320646f206e6f74206d6174636044820152600d60fb1b60648201526084016106af565b601254818a5f80848152600e602052604090205460ff16600281111561294b5761294b612ff0565b14801561297757505f828152600e602052604081205460ff16600281111561297557612975612ff0565b145b6129dd5760405162461bcd60e51b815260206004820152603160248201527f416e6f6e4944436f6e74726163743a2050726f7669646564206b65797320617260448201527065206e6f74206d6173746572206b65797360781b60648201526084016106af565b8281141580156129ed5750818114155b612a565760405162461bcd60e51b815260206004820152603460248201527f416e6f6e4944436f6e74726163743a204d6173746572206b6579732063616e6e6044820152736f742064656c657465207468656d73656c76657360601b60648201526084016106af565b5f818152600e60205260408120600101549003612ac45760405162461bcd60e51b815260206004820152602660248201527f416e6f6e4944436f6e74726163743a204e6f2073756368206b6579202864656c6044820152656574696f6e2960d01b60648201526084016106af565b5f5b600d54811015612ba45781600d8281548110612ae457612ae46134a6565b905f5260205f2090600202016001015403612b9c575f828152600e6020818152604080842080548251428186015244818501528351808203850181526060909101938490528051908501209588905293909252630de1e7ed60e41b841860018301819055600260ff198516811790935560ff90931693917f0643be3612916977c69d5ed1abb75a50cca49df49ba2444d836e2a0cf65fe07491612b8c918691899187916136a0565b60405180910390a1505050612ba4565b600101612ac6565b50505f60118190556012555050505050505050505050505050565b838383835f84604051602001612bd59190613538565b60408051601f19818403018152919052805160209091012090505f80828152600e602052604090205460ff166002811115612c1257612c12612ff0565b14612c2f5760405162461bcd60e51b81526004016106af9061356e565b5f8284604051602001612c439291906135a3565b60408051601f1981840301815290829052805160209182012080835292505f805160206136f1833981519152910160405180910390a15f612c85828789612097565b600f805460ff1916821515179055905080612cb7576040518281525f805160206136d183398151915290602001610afb565b5f838152600e6020526040908190205490515f8051602061371183398151915291612ceb9160ff9091169086908990613024565b60405180910390a1612cfd8386612d17565b505085516020909601959095206003555050505050505050565b5f828152600e60205260408120600101549003612d465760405162461bcd60e51b81526004016106af9061346f565b6040805180820182525f848152600e60205291822054819060ff166002811115612d7257612d72612ff0565b815260209081018490525f848152600e90915260409020815181549293508392829060ff19166001836002811115612dac57612dac612ff0565b02179055506020918201516001918201555f858152600e90925260408220805460ff19168155018190555b600d54811015612e705783600d8281548110612df557612df56134a6565b905f5260205f2090600202016001015403612e685781600d8281548110612e1e57612e1e6134a6565b905f5260205f2090600202015f820151815f015f6101000a81548160ff02191690836002811115612e5157612e51612ff0565b021790555060208201518160010155905050612e70565b600101612dd7565b5080516040515f8051602061371183398151915291612e929186908690613024565b60405180910390a1505050565b5f6040518060400160405280846002811115612ebd57612ebd612ff0565b8152602001839052600d8054600181810183555f92909252825160029182027fd7b6990105719101dabeb77144f2a3385c8033acd3af97e9423a695e81ad1eb5018054949550859490939192849260ff1990921691908490811115612f2457612f24612ff0565b02179055506020918201516001918201555f848152600e9092526040909120825181548493839160ff191690836002811115612f6257612f62612ff0565b0217905550602082015181600101559050507f2172c7b01a6de957d29fd6166a23025d181bf56538ad606a526ab2d62603f3fc8383604051612e92929190613043565b80356001600160a01b0381168114612fbb575f80fd5b919050565b5f60208284031215612fd0575f80fd5b61214182612fa5565b5f60208284031215612fe9575f80fd5b5035919050565b634e487b7160e01b5f52602160045260245ffd5b6003811061302057634e487b7160e01b5f52602160045260245ffd5b9052565b606081016130328286613004565b602082019390935260400152919050565b604081016130518285613004565b8260208301529392505050565b634e487b7160e01b5f52604160045260245ffd5b5f67ffffffffffffffff8084111561308c5761308c61305e565b604051601f8501601f19908116603f011681019082821181831017156130b4576130b461305e565b816040528093508581528686860111156130cc575f80fd5b858560208301375f602087830101525050509392505050565b5f80604083850312156130f6575f80fd5b6130ff83612fa5565b9150602083013567ffffffffffffffff81111561311a575f80fd5b8301601f8101851361312a575f80fd5b61313985823560208401613072565b9150509250929050565b5f8060408385031215613154575f80fd5b61315d83612fa5565b946020939093013593505050565b80614000810183101561317c575f80fd5b92915050565b80612000810183101561317c575f80fd5b5f805f8061406085870312156131a7575f80fd5b6131b1868661316b565b935061400085013567ffffffffffffffff8111156131cd575f80fd5b6131d987828801613182565b9497949650505050614020830135926140400135919050565b5f805f806140608587031215613206575f80fd5b613210868661316b565b935061400085013567ffffffffffffffff8082111561322d575f80fd5b61323988838901613182565b94506140208701359350614040870135915080821115613257575f80fd5b508501601f81018713613268575f80fd5b61327787823560208401613072565b91505092959194509250565b5f805f806140608587031215613297575f80fd5b6132a085612fa5565b93506132af866020870161316b565b925061402085013567ffffffffffffffff8111156132cb575f80fd5b6132d787828801613182565b94979396509394614040013593505050565b5f805f8061406085870312156132fd575f80fd5b613307868661316b565b935061400085013567ffffffffffffffff811115613323575f80fd5b61332f87828801613182565b93505061402085013591506133476140408601612fa5565b905092959194509250565b5f805f806140608587031215613366575f80fd5b613370868661316b565b9350614000850135925061402085013567ffffffffffffffff8111156132cb575f80fd5b5f805f61404084860312156133a7575f80fd5b83359250602084013567ffffffffffffffff8111156133c4575f80fd5b6133d086828701613182565b9250506133e0856040860161316b565b90509250925092565b5f805f8061406085870312156133fd575f80fd5b843593506132af866020870161316b565b5f6020828403121561341e575f80fd5b813560038110612141575f80fd5b602080825282518282018190525f9190848201906040850190845b8181101561346357835183529284019291840191600101613447565b50909695505050505050565b6020808252601b908201527f416e6f6e4944436f6e74726163743a204e6f2073756368206b65790000000000604082015260600190565b634e487b7160e01b5f52603260045260245ffd5b60208082526021908201527f4e6f74207065726d697474656420746f206d6f646966792077686974656c69736040820152601d60fa1b606082015260800190565b5f5b838110156135155781810151838201526020016134fd565b50505f910152565b5f825161352e8184602087016134fb565b9190910192915050565b5f8183825b61010081101561355e5760408083853792830192919091019060010161353d565b5050506140008201905092915050565b6020808252818101527f416e6f6e4944436f6e74726163743a204e6f742061206d6173746572206b6579604082015260600190565b5f83516135b48184602088016134fb565b9190910191825250602001919050565b60609190911b6bffffffffffffffffffffffff1916815260140190565b634e487b7160e01b5f52601160045260245ffd5b8181038181111561317c5761317c6135e1565b8082018082111561317c5761317c6135e1565b634e487b7160e01b5f52603160045260245ffd5b5f808335601e19843603018112613644575f80fd5b83018035915067ffffffffffffffff82111561365e575f80fd5b602001915036819003821315613672575f80fd5b9250929050565b818382375f9101908152919050565b5f60018201613699576136996135e1565b5060010190565b608081016136ae8287613004565b8460208301528360408301526136c76060830184613004565b9594505050505056fe32629d580208e19f97e5752eef849e102f803999c88aa7f75e12b1744eecd5a7d87e68f36f73a7eb22739d6639e36cafebfcde0b5543340b39f42cac68fdd1f06825a39bd161f4ef5aab6cfd2c26db3ee0005c11b43cffd544fc876312116edda264697066735822122002f933d5ce00906db0c193498b66c37ff31afe813578a4be0980edb42d42985a64736f6c63430008160033'

# Create a contract in Python
contract = w3.eth.contract(abi=contract_abi, bytecode=contract_bytecode)

# Account to deploy the contract (make sure it's unlocked with sufficient funds)
account_address = '0xfd003CA44BbF4E9fB0b2fF1a33fc2F05A6C2EFF9'
#private_key = 'YOUR_PRIVATE_KEY'

# Build transaction
construct_txn = contract.constructor().buildTransaction({
    'from': account_address,
    'nonce': w3.eth.getTransactionCount(account_address),
    'gas': 9500000,
    'gasPrice': w3.toWei('50', 'gwei')
})

# Sign the transaction with the private key
signed_txn = w3.eth.account.sign_transaction(construct_txn, private_key=private_key)

# Send the transaction
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)

# Wait for the transaction to be mined and get the transaction receipt
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

print(f"Contract deployed at address: {tx_receipt.contractAddress}")
