from brownie import network

def main():
    # Connect to the local network
    network.connect('development')

    # Get the current block number
    current_block = network.web3.eth.blockNumber
    print(f"Current block number: {current_block}")

    # Disconnect from the network
    network.disconnect()
