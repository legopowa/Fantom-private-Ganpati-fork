from brownie.project import LamportverifierlocalProject

def main():
    proj = LamportverifierlocalProject
    proj.load_config()

    contract_name_input = input("Enter the contract name to view its bytecode: ")

    # Check if the entered contract name exists in the project
    if contract_name_input in proj.keys():
        contract = proj[contract_name_input]
        print(f"Contract: {contract_name_input}")
        print("Bytecode:", contract._build['bytecode'])
        print("Deployed Bytecode:", contract._build['deployedBytecode'])
    else:
        print(f"Contract '{contract_name_input}' not found in the project.")

if __name__ == "__main__":
    main()
