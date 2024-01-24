// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SfcLib {
    address private _isOwner;
    mapping(uint256 => uint256) private _slashingRefundRatio;
    mapping(uint256 => bytes32) private _isSlashed; // Assuming the structure of _isSlashed

    event SlashingRefundRatioUpdated(uint256 indexed varg0, uint256 varg1);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _isOwner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _isOwner, "Ownable: caller is not the owner");
        _;
    }

    function updateSlashingRefundRatio(uint256 varg0, uint256 varg1) public onlyOwner {
        require(bool(0x80 & _isSlashed[varg0].field0), "validator isn't slashed");
        require(varg0 <= 0xde0b6b3a7640000, "must be less than or equal to 1.0");
        _slashingRefundRatio[varg0] = varg1;
        emit SlashingRefundRatioUpdated(varg0, varg1);
    }

    function burnFTM(uint256 varg0) public onlyOwner {
        // Implementation for burning FTM
    }

    function transferOwnership(address varg0) public onlyOwner {
        require(varg0 != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_isOwner, varg0);
        _isOwner = varg0;
    }
}


contract Netinit {
    address private _owner;
    uint256 private stor_66;
    uint256 private _maxLockupDuration;
    uint256 private _baseRewardPerSecond;
    uint256 private _minLockupDuration;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function updateMinSelfStake(uint256 varg0) public onlyOwner payable {
        require(varg0 >= 0x152d02c7e14af6800000, "too small value");
        require(varg0 <= 0x84595161401484a000000, "too large value");
        stor_66 = varg0;
    }

    function updateMaxLockupDuration(uint256 varg0) public onlyOwner payable {
        require(varg0 >= 0x278d00, "too small value");
        require(varg0 <= 0x784ce00, "too large value");
        _maxLockupDuration = varg0;
    }

    function updateBaseRewardPerSecond(uint256 varg0) public onlyOwner payable {
        require(varg0 >= 0x6f05b59d3b20000, "too small value");
        require(varg0 <= 0x1bc16d674ec800000, "too large value");
        _baseRewardPerSecond = varg0;
    }

    function updateMinLockupDuration(uint256 varg0) public onlyOwner payable {
        require(varg0 >= 0x15180, "too small value");
        require(varg0 <= 0x278d00, "too large value");
        _minLockupDuration = varg0;
    }

    function transferOwnership(address varg0) public onlyOwner payable {
        require(varg0 != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, varg0);
        _owner = varg0;
    }
}

contract Factory {
    function deploySfcLib() public returns (address) {
        SfcLib sfcLib = new SfcLib();
        return address(sfcLib);
    }

    function deployNetinit() public returns (address) {
        Netinit netinit = new Netinit();
        return address(netinit);
    }
}
