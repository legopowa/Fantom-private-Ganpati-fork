// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DummyContract {
    address private _owner;
    uint256 public minSelfStake;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function");
        _;
    }

    function updateMinSelfStake(uint256 v) external onlyOwner {
        require(v >= 100000 * 1e18, "too small value");
        require(v <= 10000000 * 1e18, "too large value");
        minSelfStake = v;
    }
}