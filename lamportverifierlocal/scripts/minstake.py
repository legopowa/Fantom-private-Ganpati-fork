from brownie import Contract, web3

def main():
    # The contract's address
    contract_address = "0xFC00FACE00000000000000000000000000000000"
    
    # The signature of the minStake function
    min_stake_signature = web3.keccak(text="minStake()")[:4].hex()
    
    # Construct the call data
    call_data = min_stake_signature

    # Make a call to the contract
    result = web3.eth.call({'to': contract_address, 'data': call_data})
    
    # The result is returned in bytes, which we need to convert to an integer
    min_stake = web3.toInt(hexstr=result.hex())
    
    print(f"minStake: {min_stake}")

    return min_stake
