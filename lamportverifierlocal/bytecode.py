import binascii

def string_to_bytecode(strings):
    bytecode_list = []
    for string in strings:
        # Convert string to bytes, then to hex, and finally prepend '0x'
        bytecode = binascii.hexlify(string.encode()).decode()
        bytecode_list.append(bytecode)
    return bytecode_list

# Example usage
strings = ["HelloWorldExample"]
bytecodes = string_to_bytecode(strings)

for string, bytecode in zip(strings, bytecodes):
    print(f"String: {string} -> Bytecode: {bytecode}")
