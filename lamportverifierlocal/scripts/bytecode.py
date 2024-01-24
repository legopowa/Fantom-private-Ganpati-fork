from brownie import project

def main():
    my_project = project.load('.', name='lamportverifierlocal')
    
    # Print available contract names
    contract_names = [contract._name for contract in my_project]
    print("Available contract names:", contract_names)

    # Access and print bytecode for each contract
    for contract_name in contract_names:
        contract = my_project[contract_name]
        bytecode = contract.bytecode
        print(f"Bytecode for {contract_name}:")
        print(bytecode)

if __name__ == "__main__":
    main()
