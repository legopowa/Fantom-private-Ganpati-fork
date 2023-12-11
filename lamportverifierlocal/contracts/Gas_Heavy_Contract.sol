// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasHeavyContract {

    uint256[] private largeArray;

    constructor() {
        // Populate the array with a large number of elements
        for (uint i = 0; i < 10000; i++) {
            largeArray.push(i);
        }
    }

    function computeExpensiveOperation() public {
        uint256 sum = 0;
        for (uint i = 0; i < largeArray.length; i++) {
            // Perform some arbitrary expensive computation
            sum += (largeArray[i] * i) / 2;
        }
    }

    function addData(uint256 data) public {
        largeArray.push(data);
    }

    function clearData() public {
        delete largeArray;
    }
}
