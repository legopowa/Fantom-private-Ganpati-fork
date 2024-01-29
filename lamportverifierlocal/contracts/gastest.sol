pragma solidity ^0.8.0;

contract NameStorage {
    string[] public names;

    function addNames(string[] memory newNames) public {
        for (uint i = 0; i < newNames.length; i++) {
            names.push(newNames[i]);
        }
    }
}
