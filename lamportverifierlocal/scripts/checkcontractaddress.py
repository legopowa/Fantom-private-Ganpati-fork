from brownie import network, AnonIDContract

def main():
    # Set up the contract address
    contract_address = '0x06833D303855ffC9813Fd96e0dF1256F97D02ACA'

    # Connect to the network
    #network.connect('mainnet', launch_rpc=False)

    # Create contract instance using the ABI from AnonIDContract
    contract = AnonIDContract.at(contract_address)

    # Call the function
    commission_address = contract.commissionAddress()
    print(f"Commission Address: {commission_address}")
