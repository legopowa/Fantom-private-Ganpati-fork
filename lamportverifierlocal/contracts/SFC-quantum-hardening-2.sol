// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LamportBase.sol"; // Adjust the path according to your project structure
import "./Decimal.sol"; //

// Interface for the SFC contract



interface ISFC {
    function transferOwnership(address newOwner) external;
    function updateBaseRewardPerSecond(uint256 value) external;
    function updateOfflinePenaltyThreshold(uint256 blocksNum, uint256 time) external;
    function updateSlashingRefundRatio(uint256 validatorID, uint256 refundRatio) external;
    function updateStakeTokenizerAddress(address addr) external;
    function updateLibAddress(address v) external;
    function updateTreasuryAddress(address v) external;
    function updateConstsAddress(address v) external;
    function constsAddress() external view returns (address);
    function updateVoteBookAddress(address v) external;
    function updateTotalSupply(int256 diff) external;
    function mintFTM(address payable receiver, uint256 amount, string calldata justification) external;
    function migrateTo(address newDriverAuth) external;
    function upgradeCode(address acc, address from) external;
    function copyCode(address acc, address from) external;
    function incNonce(address acc, uint256 diff) external;
    function updateNetworkRules(bytes calldata diff) external;
    function updateNetworkVersion(uint256 version) external;
    function advanceEpochs(uint256 num) external;
    // Add other SFC functions as needed
}

    //function execute(address executable) external onlyOwner;// 
    //function mutExecute(address executable, address newOwner, bytes32 selfCodeHash, bytes32 driverCodeHash) external onlyOwner; //



// Contract to interface with the SFC
contract SFCInterface is LamportBase {
  

    LamportBase public lamportBase;

    IConsts public consts;
    ISFC public sfc;

    address public owner;

    event SFCAddressSet(address newSFCAddress);

    event OwnershipTransferred(address indexed newOwner);

    address private lastUsedLibAddress;
    address private lastUsedTreasuryAddress;
    address private lastUsedSFCAddress;
    address private lastUsedOwner;
    uint256 private lastUsedBaseReward;
    address private lastUsedConstsAddress;
    bytes32 private lastUsedPenaltyThresholdHash;
    bytes32 private lastUsedSlashingRefundRatioHash;
    bytes32 private lastUsedStakeTokenizerAddressHash;
    bytes32 private lastUsedTotalSupplyHash;
    bytes32 private lastUsedMigrateToHash;
    bytes32 private lastUsedUpgradeCodeHash;
    bytes32 private lastUsedCopyCodeHash;
    bytes32 private lastUsedIncNonceHash;
    bytes32 private lastUsedUpdateNetworkRulesHash;
    bytes32 private lastUsedUpdateNetworkVersionHash;
    bytes32 private lastUsedAdvanceEpochsHash;
    uint256 public minSelfStake;
    uint256 public maxDelegatedRatio;





    constructor(address _sfcAddress, address _lamportBase) {
        sfc = ISFC(_sfcAddress);
        //owner = msg.sender;
        lamportBase = LamportBase(_lamportBase);

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    // function setSFCAddress(address newSFCAddress) public onlyOwner {
    //     require(newSFCAddress != address(0), "SFC address cannot be the zero address");
    //     sfc = ISFC(newSFCAddress);
    // }
    // Step 1: Initiate setting the SFC address with Lamport signature





    address public libAddress;
    
    // Step 1 for updateLibAddress

    // prob don't want to touch this, it involve assembly stuff
    // function SFCupdateLibAddressStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address v
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
    //         "Master check failed"
    //     );
    //     lastUsedLibAddress = v;
    // }

    // // Step 2 for updateLibAddress
    // function SFCupdateLibAddressStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address v
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
    //         "Master check failed"
    //     );
    //     require(lastUsedLibAddress == v, "Mismatched libAddress");
    //     sfc.updateLibAddress(v);
    //     lastUsedLibAddress = address(0);
    // }


    // Step 1 for updateTreasuryAddress
    function SFCupdateTreasuryAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedTreasuryAddress = v;
    }

    // Step 2 for updateTreasuryAddress
    function SFCupdateTreasuryAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedTreasuryAddress == v, "Mismatched treasuryAddress");
        sfc.updateTreasuryAddress(v);
        lastUsedTreasuryAddress = 0x0000000000000000000000000000000000000000;
    }

    //event SFCAddressSet(address newSFCAddress);

    // Step 1 for updateConstsAddress
    // vital contract here don't mess with it
    // function SFCupdateConstsAddressStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address v
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(v)
    //     )
    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
    //         "Master check failed"
    //     );
    //     lastUsedConstsAddress = v;
    // }

    // // Step 2 for updateConstsAddress
    // function SFCupdateConstsAddressStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address v
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
    //         "Master check failed"
    //     );
    //     require(lastUsedConstsAddress == v, "Mismatched consts address between step one and two");
    //     sfc.updateConstsAddress(v);
    //     lastUsedConstsAddress = address(0);
    // }
    function setSFCforSFCtAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newSFCAddress
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newSFCAddress)),
            "Master check failed"
        );
        require(newSFCAddress != address(0), "SFC address cannot be the zero address");
        lastUsedSFCAddress = newSFCAddress;
    }

    // Step 2: Verify and set the SFC address
    function setSFCforSFCtAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newSFCAddress
    )
        public

    {

        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newSFCAddress)),
            "Master check failed"
        );
        require(lastUsedSFCAddress == newSFCAddress, "Mismatched SFC address between step one and two");

        sfc = ISFC(newSFCAddress);

        // Reset the temporary variable
        lastUsedSFCAddress = 0x0000000000000000000000000000000000000000;
        emit SFCAddressSet(newSFCAddress);
    }

    // ... [rest of your contract]



    // function transferOwnership(address newOwner) public onlyOwner {
    //     sfc.transferOwnership(newOwner);
    // }
    // Step 1: Initiate ownership transfer with Lamport signature

    function SFCtransferOwnershipStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newOwner
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newOwner)),
            "Master check failed"
        );
        lastUsedOwner = newOwner;
    }

    // Step 2: Verify and complete the ownership transfer
    function SFCtransferOwnershipStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newOwner
    )
        public

    {

        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newOwner)),
            "Master check failed"
        );
        require(lastUsedOwner == newOwner, "Mismatched owner between step one and two");

        sfc.transferOwnership(newOwner);

        // Reset the temporary variable
        lastUsedOwner = 0x0000000000000000000000000000000000000000;
        emit OwnershipTransferred(newOwner);
    }

    // function updateBaseRewardPerSecond(uint256 value) public onlyOwner {
    //     sfc.updateBaseRewardPerSecond(value);
    // }
        // Step 1 for updateBaseRewardPerSecond
    function SFCupdateBaseRewardPerSecondStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 value
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(value)),
            "Master check failed"
        );
        lastUsedBaseReward = value;
    }

    // Step 2 for updateBaseRewardPerSecond
    function SFCupdateBaseRewardPerSecondStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 value
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(value)),
            "Master check failed"
        );
        require(lastUsedBaseReward == value, "Mismatched base reward hash");
        sfc.updateBaseRewardPerSecond(value);
        lastUsedBaseReward = 0;
    }

    // function updateOfflinePenaltyThreshold(uint256 blocksNum, uint256 time) public onlyOwner {
    //     sfc.updateOfflinePenaltyThreshold(blocksNum, time);
    // }
        // Step 1: Initiate updating the offline penalty threshold with Lamport signature
    function SFCupdateOfflinePenaltyThresholdStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 blocksNum,
        uint256 time
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(blocksNum, time)),
            "Master check failed"
        );
        lastUsedPenaltyThresholdHash = keccak256(abi.encodePacked(blocksNum, time));
    }

    // Step 2: Verify and complete updating the offline penalty threshold
    function SFCupdateOfflinePenaltyThresholdStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 blocksNum,
        uint256 time
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(blocksNum, time)),
            "Master check failed"
        );
        require(lastUsedPenaltyThresholdHash == keccak256(abi.encodePacked(blocksNum, time)), "Mismatched penalty threshold hash");

        sfc.updateOfflinePenaltyThreshold(blocksNum, time);

        // Reset the temporary variable
        lastUsedPenaltyThresholdHash = 0;
    }


    // function updateSlashingRefundRatio(uint256 validatorID, uint256 refundRatio) public onlyOwner {
    //     sfc.updateSlashingRefundRatio(validatorID, refundRatio);
    // }
        // Step 1: Initiate updating the slashing refund ratio with Lamport signature
    function SFCupdateSlashingRefundRatioStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 validatorID,
        uint256 refundRatio
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(validatorID, refundRatio)),
            "Master check failed"
        );
        lastUsedSlashingRefundRatioHash = keccak256(abi.encodePacked(validatorID, refundRatio));
    }

    // Step 2: Verify and complete updating the slashing refund ratio
    function SFCupdateSlashingRefundRatioStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 validatorID,
        uint256 refundRatio
    )
        public

    {

        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(validatorID, refundRatio)),
            "Master check failed"
        );
        require(lastUsedSlashingRefundRatioHash == keccak256(abi.encodePacked(validatorID, refundRatio)), "Mismatched slashing refund ratio hash");

        sfc.updateSlashingRefundRatio(validatorID, refundRatio);

        // Reset the temporary variable
        lastUsedSlashingRefundRatioHash = 0;
    }

    // function updateStakeTokenizerAddress(address addr) public onlyOwner {
    //     sfc.updateStakeTokenizerAddress(addr);
    // }

        // Step 1 for updateStakeTokenizerAddress
    function SFCupdateStakeTokenizerAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address addr
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(addr)),
            "Master check failed"
        );
        lastUsedStakeTokenizerAddressHash = keccak256(abi.encodePacked(addr));
    }

    // Step 2 for updateStakeTokenizerAddress
    function SFCupdateStakeTokenizerAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address addr
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(addr)),
            "Master check failed"
        );
        require(lastUsedStakeTokenizerAddressHash == keccak256(abi.encodePacked(addr)), "Mismatched stake tokenizer address hash");
        sfc.updateStakeTokenizerAddress(addr);
        lastUsedStakeTokenizerAddressHash = 0;
    }


    // function updateTotalSupply(int256 diff) public onlyOwner {
    //     sfc.updateTotalSupply(diff);
    // }
        // Step 1 for updateTotalSupply
    function SFCupdateTotalSupplyStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        int256 diff
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(diff)),
            "Master check failed"
        );
        lastUsedTotalSupplyHash = keccak256(abi.encodePacked(diff));
    }

    // Step 2 for updateTotalSupply
    function SFCupdateTotalSupplyStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        int256 diff
    )
        public

    {   
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(diff)),
            "Master check failed"
        );
        require(lastUsedTotalSupplyHash == keccak256(abi.encodePacked(diff)), "Mismatched total supply hash");
        sfc.updateTotalSupply(diff);
        lastUsedTotalSupplyHash = 0;
    }
}
    // NO MINTING BEYOND GPClaim! Only honest mints through there.
    // // function mintFTM(address payable receiver, uint256 amount, string calldata justification) public onlyOwner {
    // //     sfc.mintFTM(receiver, amount, justification);
    // // }
    //     // Step 1 for mintFTM
    // function mintFTMStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address payable receiver,
    //     uint256 amount,
    //     string calldata justification
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(receiver, amount, justification)
    //     )
    // {
    //     lastUsedMintFTMHash = keccak256(abi.encodePacked(receiver, amount, justification));
    // }

    // // Step 2 for mintFTM
    // function mintFTMStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address payable receiver,
    //     uint256 amount,
    //     string calldata justification
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(receiver, amount, justification)
    //     )
    // {
    //     require(lastUsedMintFTMHash == keccak256(abi.encodePacked(receiver, amount, justification)), "Mismatched mintFTM hash");
    //     sfc.mintFTM(receiver, amount, justification);
    //     lastUsedMintFTMHash = 0;
    // }
    // NO MINTING BEYOND GPClaim! Only honest mints through there.

    // function migrateTo(address newDriverAuth) public onlyOwner {
    //     sfc.migrateTo(newDriverAuth);
    // }
        // Step 1 for migrateTo

contract SFCInterfacePart2 is LamportBase {
    // State variables continuation from Part 1
    ISFC public sfc;
    LamportBase public lamportBase;
    event SFCAddressSet2(address newSFCAddress);

    address private lastUsedLibAddress;
    address private lastUsedTreasuryAddress;
    address private lastUsedSFCAddress;
    address private lastUsedOwner;
    uint256 private lastUsedBaseReward;
    address private lastUsedConstsAddress;
    bytes32 private lastUsedPenaltyThresholdHash;
    bytes32 private lastUsedSlashingRefundRatioHash;
    bytes32 private lastUsedStakeTokenizerAddressHash;
    bytes32 private lastUsedTotalSupplyHash;
    bytes32 private lastUsedMigrateToHash;
    bytes32 private lastUsedUpgradeCodeHash;
    bytes32 private lastUsedCopyCodeHash;
    bytes32 private lastUsedIncNonceHash;
    bytes32 private lastUsedUpdateNetworkRulesHash;
    bytes32 private lastUsedUpdateNetworkVersionHash;
    bytes32 private lastUsedAdvanceEpochsHash;
    uint256 public minSelfStake;
    uint256 public maxDelegatedRatio;


    constructor(address _sfcAddress, address _lamportBase) {
        sfc = ISFC(_sfcAddress);
        //owner = msg.sender;
        lamportBase = LamportBase(_lamportBase);

    }

    // function SFCmigrateToStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address newDriverAuth
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newDriverAuth)),
    //         "Master check failed"
    //     );
    //     lastUsedMigrateToHash = keccak256(abi.encodePacked(newDriverAuth));
    // }

    // // Step 2 for migrateTo
    // function SFCmigrateToStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address newDriverAuth
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newDriverAuth)),
    //         "Master check failed"
    //     );
    //     require(lastUsedMigrateToHash == keccak256(abi.encodePacked(newDriverAuth)), "Mismatched migrateTo hash");
    //     sfc.migrateTo(newDriverAuth);
    //     lastUsedMigrateToHash = 0;
    // }


    // function upgradeCode(address acc, address from) public onlyOwner {
    //     sfc.upgradeCode(acc, from);
    // }

    // // Step 1 for upgradeCode
    // function SFCupgradeCodeStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address acc,
    //     address from
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(acc, from)),
    //         "Master check failed"
    //     );
    //     lastUsedUpgradeCodeHash = keccak256(abi.encodePacked(acc, from));
    // }

    // // Step 2 for upgradeCode
    // function SFCupgradeCodeStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address acc,
    //     address from
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(acc, from)),
    //         "Master check failed"
    //     );
    //     require(lastUsedUpgradeCodeHash == keccak256(abi.encodePacked(acc, from)), "Mismatched upgradeCode hash");
    //     sfc.upgradeCode(acc, from);
    //     lastUsedUpgradeCodeHash = 0;
    // }

    // function copyCode(address acc, address from) public onlyOwner {
    //     sfc.copyCode(acc, from);
    // }
    // // Step 1 for copyCode
    // function SFCcopyCodeStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address acc,
    //     address from
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(acc, from)),
    //         "Master check failed"
    //     );
    //     lastUsedCopyCodeHash = keccak256(abi.encodePacked(acc, from));
    // }

    // // Step 2 for copyCode
    // function SFCcopyCodeStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address acc,
    //     address from
    // )
    //     public

    // {
    //     require(
    //         lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(acc, from)),
    //         "Master check failed"
    //     );
    //     require(lastUsedCopyCodeHash == keccak256(abi.encodePacked(acc, from)), "Mismatched copyCode hash");
    //     sfc.copyCode(acc, from);
    //     lastUsedCopyCodeHash = 0;
    // }

    // function incNonce(address acc, uint256 diff) public onlyOwner {
    //     sfc.incNonce(acc, diff);
    // }

    // function updateNetworkRules(bytes calldata diff) public onlyOwner {
    //     sfc.updateNetworkRules(diff);
    // }
    // Step 1 for incNonce
    function SFCincNonceStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address acc,
        uint256 diff
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(acc, diff)),
            "Master check failed"
        );
        lastUsedIncNonceHash = keccak256(abi.encodePacked(acc, diff));
    }

    // Step 2 for incNonce
    function SFCincNonceStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address acc,
        uint256 diff
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(acc, diff)),
            "Master check failed"
        );
        require(lastUsedIncNonceHash == keccak256(abi.encodePacked(acc, diff)), "Mismatched incNonce hash");
        sfc.incNonce(acc, diff);
        lastUsedIncNonceHash = 0;
    }

    //Step 1 for updateNetworkRules
    function SFCupdateNetworkRulesStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        bytes calldata diff
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(diff)),
            "Master check failed"
        );
        lastUsedUpdateNetworkRulesHash = keccak256(abi.encodePacked(diff));
    }

    // Step 2 for updateNetworkRules
    function SFCupdateNetworkRulesStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        bytes calldata diff
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(diff)),
            "Master check failed"
        );
        require(lastUsedUpdateNetworkRulesHash == keccak256(abi.encodePacked(diff)), "Mismatched updateNetworkRules hash");
        sfc.updateNetworkRules(diff);
        lastUsedUpdateNetworkRulesHash = 0;
    }

    // function updateNetworkVersion(uint256 version) public onlyOwner {
    //     sfc.updateNetworkVersion(version);
    // }

    // function advanceEpochs(uint256 num) public onlyOwner {
    //     sfc.advanceEpochs(num);
    // }
    // Step 1 for updateNetworkVersion 
    function SFCupdateNetworkVersionStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 version
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(version)),
            "Master check failed"
        );
        lastUsedUpdateNetworkVersionHash = keccak256(abi.encodePacked(version));
    }

    // Step 2 for updateNetworkVersion
    function SFCupdateNetworkVersionStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 version
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(version)),
            "Master check failed"
        );
        require(lastUsedUpdateNetworkVersionHash == keccak256(abi.encodePacked(version)), "Mismatched updateNetworkVersion hash");
        sfc.updateNetworkVersion(version);
        lastUsedUpdateNetworkVersionHash = 0;
    }

    // Step 1 for advanceEpochs
    function SFCadvanceEpochsStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 num
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(num)),
            "Master check failed"
        );
        lastUsedAdvanceEpochsHash = keccak256(abi.encodePacked(num));
    }

    // Step 2 for advanceEpochs
    function SFCadvanceEpochsStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 num
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(num)),
            "Master check failed"
        );
        require(lastUsedAdvanceEpochsHash == keccak256(abi.encodePacked(num)), "Mismatched advanceEpochs hash");
        sfc.advanceEpochs(num);
        lastUsedAdvanceEpochsHash = 0;
    }


    address private lastUsedVoteBookAddress;
    // Step 1 for updateVoteBookAddress
    function updateVoteBookAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedVoteBookAddress = v;
    }

    // Step 2 for updateVoteBookAddress
    function updateVoteBookAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedVoteBookAddress == v, "Mismatched voteBook address between step one and two");
        sfc.updateVoteBookAddress(v);
        lastUsedVoteBookAddress = address(0);
    }

    function setSFCforSFCtAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newSFCAddress
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newSFCAddress)),
            "Master check failed"
        );
        require(newSFCAddress != address(0), "SFC address cannot be the zero address");
        lastUsedSFCAddress = newSFCAddress;
    }

    // Step 2: Verify and set the SFC address
    function setSFCforSFCtAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newSFCAddress
    )
        public

    {

        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(newSFCAddress)),
            "Master check failed"
        );
        require(lastUsedSFCAddress == newSFCAddress, "Mismatched SFC address between step one and two");

        sfc = ISFC(newSFCAddress);

        // Reset the temporary variable
        lastUsedSFCAddress = 0x0000000000000000000000000000000000000000;
        emit SFCAddressSet2(newSFCAddress);
    }

}
    //     NodeDriverAuth (also 0xFC00FACE00...)


    // function execute(address executable) external onlyOwner {
    //     _execute(executable, owner(), _getCodeHash(address(this)), _getCodeHash(address(driver)));
    // }

    // function mutExecute(address executable, address newOwner, bytes32 selfCodeHash, bytes32 driverCodeHash) external onlyOwner {
    //     _execute(executable, newOwner, selfCodeHash, driverCodeHash);
    // }
	
    // Additional functions and logic can be added here




    // ConstantsManager contract

    // Step 1 for updateMinSelfStake

pragma solidity ^0.8.0;

import "./LamportBase.sol"; // Adjust the path according to your project structure
import "./Decimal.sol"; // Ensure this is included if needed

// Interface for the Constants contract
interface IConsts {
    function constsAddress() external view returns (address);
    function updateMinSelfStake(uint256 v) external;
    function updateMaxDelegatedRatio(uint256 v) external;
    function updateValidatorCommission(uint256 v) external;
    function updateBurntFeeShare(uint256 v) external;
    function updateTreasuryFeeShare(uint256 v) external;
    function updateUnlockedRewardRatio(uint256 v) external;
    function updateMinLockupDuration(uint256 v) external;
    function updateMaxLockupDuration(uint256 v) external;
    function updateWithdrawalPeriodEpochs(uint256 v) external;
    function updateWithdrawalPeriodTime(uint256 v) external;
    function updateBaseRewardPerSecond(uint256 v) external;
    function updateOfflinePenaltyThresholdTime(uint256 v) external;
    function updateOfflinePenaltyThresholdBlocksNum(uint256 v) external;
    function updateTargetGasPowerPerSecond(uint256 v) external;
    function updateGasPriceBalancingCounterweight(uint256 v) external;
}

    // Contract to manage constants
contract ConstantsInterface is LamportBase {

    bytes32 private lastUsedMinSelfStakeHash;
    bytes32 private lastUsedMaxDelegatedRatioHash;
    IConsts public consts;
    LamportBase public lamportBase;
    
    event SFCConstsAddressSet(address newConstsAddress);


    constructor(address _consts, address _lamportBase) {
        consts = IConsts(_consts);
        lamportBase = LamportBase(_lamportBase);

        //owner = msg.sender;
    }
    function constsUpdateMinSelfStakeStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedMinSelfStakeHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateMinSelfStake
    function constsUpdateMinSelfStakeStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedMinSelfStakeHash == keccak256(abi.encodePacked(v)), "Mismatched minSelfStake hash");
        require(v >= 100000 * 1e18 && v <= 10000000 * 1e18, "Invalid value range");
        consts.updateMinSelfStake(v);
        lastUsedMinSelfStakeHash = 0;
    }

    // Step 1 for updateMaxDelegatedRatio
    function constsUpdateMaxDelegatedRatioStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedMaxDelegatedRatioHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateMaxDelegatedRatio
    function constsUpdateMaxDelegatedRatioStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedMaxDelegatedRatioHash == keccak256(abi.encodePacked(v)), "Mismatched maxDelegatedRatio hash");
        require(v >= Decimal.unit() && v <= 31 * Decimal.unit(), "Invalid value range");
        consts.updateMaxDelegatedRatio(v);
        lastUsedMaxDelegatedRatioHash = 0;
    }
    // Step 1 for updateValidatorCommission
    function constsUpdateValidatorCommissionStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedValidatorCommissionHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateValidatorCommission
    function constsUpdateValidatorCommissionStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedValidatorCommissionHash == keccak256(abi.encodePacked(v)), "Mismatched validatorCommission hash");
        require(v <= Decimal.unit() / 2, "too large value");
        consts.updateValidatorCommission(v);
        lastUsedValidatorCommissionHash = 0;
    }

    // Step 1 for updateBurntFeeShare
    function constsUpdateBurntFeeShareStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedBurntFeeShareHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateBurntFeeShare
    function constsUpdateBurntFeeShareStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {

        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedBurntFeeShareHash == keccak256(abi.encodePacked(v)), "Mismatched burntFeeShare hash");
        require(v <= Decimal.unit() / 2, "too large value");
        consts.updateBurntFeeShare(v);
        lastUsedBurntFeeShareHash = 0;
    }
    uint256 public treasuryFeeShare;
    uint256 public unlockedRewardRatio;

    bytes32 private lastUsedTreasuryFeeShareHash;
    bytes32 private lastUsedUnlockedRewardRatioHash;

    // Step 1 for updateTreasuryFeeShare
    function constsUpdateTreasuryFeeShareStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedTreasuryFeeShareHash = keccak256(abi.encodePacked(v));
    }
    uint256 public validatorCommission;
    uint256 public burntFeeShare;

    bytes32 private lastUsedValidatorCommissionHash;
    bytes32 private lastUsedBurntFeeShareHash;

    // Step 2 for updateTreasuryFeeShare
    function constsUpdateTreasuryFeeShareStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedTreasuryFeeShareHash == keccak256(abi.encodePacked(v)), "Mismatched treasuryFeeShare hash");
        require(v <= Decimal.unit() / 2, "too large value");
        consts.updateTreasuryFeeShare(v);
        lastUsedTreasuryFeeShareHash = 0;
    }

    // Step 1 for updateUnlockedRewardRatio
    function constsUpdateUnlockedRewardRatioStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedUnlockedRewardRatioHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateUnlockedRewardRatio
    function constsUpdateUnlockedRewardRatioStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedUnlockedRewardRatioHash == keccak256(abi.encodePacked(v)), "Mismatched unlockedRewardRatio hash");
        require(v >= (5 * Decimal.unit()) / 100 && v <= Decimal.unit() / 2, "Invalid value range");
        consts.updateUnlockedRewardRatio(v);
        lastUsedUnlockedRewardRatioHash = 0;
    }
    uint256 public minLockupDuration;
    uint256 public maxLockupDuration;

    bytes32 private lastUsedMinLockupDurationHash;
    bytes32 private lastUsedMaxLockupDurationHash;

    // Step 1 for updateMinLockupDuration
    function constsUpdateMinLockupDurationStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedMinLockupDurationHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateMinLockupDuration
    function constsUpdateMinLockupDurationStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedMinLockupDurationHash == keccak256(abi.encodePacked(v)), "Mismatched minLockupDuration hash");
        require(v >= 86400 && v <= 86400 * 30, "Invalid minLockupDuration range");
        consts.updateMinLockupDuration(v);
        lastUsedMinLockupDurationHash = 0;
    }

    // Step 1 for updateMaxLockupDuration
    function constsUpdateMaxLockupDurationStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedMaxLockupDurationHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateMaxLockupDuration
    function constsUpdateMaxLockupDurationStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {

        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedMaxLockupDurationHash == keccak256(abi.encodePacked(v)), "Mismatched maxLockupDuration hash");
        require(v >= 86400 * 30 && v <= 86400 * 1460, "Invalid maxLockupDuration range");
        consts.updateMaxLockupDuration(v);
        lastUsedMaxLockupDurationHash = 0;
    }
    uint256 public withdrawalPeriodEpochs;

    bytes32 private lastUsedWithdrawalPeriodEpochsHash;

    // Step 1 for updateWithdrawalPeriodEpochs
    function constsUpdateWithdrawalPeriodEpochsStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedWithdrawalPeriodEpochsHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateWithdrawalPeriodEpochs
    function constsUpdateWithdrawalPeriodEpochsStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedWithdrawalPeriodEpochsHash == keccak256(abi.encodePacked(v)), "Mismatched withdrawalPeriodEpochs hash");
        require(v >= 2 && v <= 100, "Invalid withdrawalPeriodEpochs range");
        consts.updateWithdrawalPeriodEpochs(v);
        lastUsedWithdrawalPeriodEpochsHash = 0;
    }
        function setSFCtConstsAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address _constsAddress
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(_constsAddress)),
            "Master check failed"
        );
        lastUsedSFCtConstsAddress = _constsAddress;
    }
    address private lastUsedSFCtConstsAddress;

    // Step 2 for setSFCtConstsAddress
    function setSFCtConstsAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address _constsAddress
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(_constsAddress)),
            "Master check failed"
        );
        require(lastUsedSFCtConstsAddress == _constsAddress, "Mismatched SFCtConsts address between step one and two");
        consts = IConsts(_constsAddress);
        lastUsedSFCtConstsAddress = address(0);
        emit SFCConstsAddressSet(_constsAddress);

    }
    function constsAddress() external view returns (address) {
        return consts.constsAddress();
    }
}

contract ConstantsInterfacePart2 is LamportBase {
    // State variables continuation from Part 1
    IConsts public consts;
    bytes32 private lastUsedWithdrawalPeriodTimeHash;
    uint256 public withdrawalPeriodTime;
    LamportBase public lamportBase;
    event SFCConstsAddressSet2(address newConstsAddress);

    address private lastUsedSFCtConstsAddress;
    constructor(address _consts, address _lamportBase) {
        consts = IConsts(_consts);
        lamportBase = LamportBase(_lamportBase);

        //owner = msg.sender;
    }
    // Step 1 for updateWithdrawalPeriodTime
    function constsUpdateWithdrawalPeriodTimeStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedWithdrawalPeriodTimeHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateWithdrawalPeriodTime
    function constsUpdateWithdrawalPeriodTimeStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedWithdrawalPeriodTimeHash == keccak256(abi.encodePacked(v)), "Mismatched withdrawalPeriodTime hash");
        require(v >= 86400 && v <= 30 * 86400, "Invalid withdrawalPeriodTime range");
        consts.updateWithdrawalPeriodTime(v);
        lastUsedWithdrawalPeriodTimeHash = 0;
    }
    uint256 public baseRewardPerSecond;
    uint256 public offlinePenaltyThresholdTime;

    bytes32 private lastUsedBaseRewardPerSecondHash;
    bytes32 private lastUsedOfflinePenaltyThresholdTimeHash;

    // Step 1 for updateBaseRewardPerSecond
    function constsUpdateBaseRewardPerSecondStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedBaseRewardPerSecondHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateBaseRewardPerSecond
    function constsUpdateBaseRewardPerSecondStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedBaseRewardPerSecondHash == keccak256(abi.encodePacked(v)), "Mismatched baseRewardPerSecond hash");
        require(v >= 0.5 * 1e18 && v <= 32 * 1e18, "Invalid baseRewardPerSecond range");
        consts.updateBaseRewardPerSecond(v);
        lastUsedBaseRewardPerSecondHash = 0;
    }

    // Step 1 for updateOfflinePenaltyThresholdTime
    function constsUpdateOfflinePenaltyThresholdTimeStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedOfflinePenaltyThresholdTimeHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateOfflinePenaltyThresholdTime
    function constsUpdateOfflinePenaltyThresholdTimeStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedOfflinePenaltyThresholdTimeHash == keccak256(abi.encodePacked(v)), "Mismatched offlinePenaltyThresholdTime hash");
        require(v >= 86400 && v <= 10 * 86400, "Invalid offlinePenaltyThresholdTime range");
        consts.updateOfflinePenaltyThresholdTime(v);
        lastUsedOfflinePenaltyThresholdTimeHash = 0;
    }
    uint256 public offlinePenaltyThresholdBlocksNum;
    uint256 public targetGasPowerPerSecond;
    uint256 public gasPriceBalancingCounterweight;

    bytes32 private lastUsedOfflinePenaltyThresholdBlocksNumHash;
    bytes32 private lastUsedTargetGasPowerPerSecondHash;
    bytes32 private lastUsedGasPriceBalancingCounterweightHash;

    // Step 1 for updateOfflinePenaltyThresholdBlocksNum
    function constsUpdateOfflinePenaltyThresholdBlocksNumStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedOfflinePenaltyThresholdBlocksNumHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateOfflinePenaltyThresholdBlocksNum
    function constsUpdateOfflinePenaltyThresholdBlocksNumStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedOfflinePenaltyThresholdBlocksNumHash == keccak256(abi.encodePacked(v)), "Mismatched offlinePenaltyThresholdBlocksNum hash");
        require(v >= 100 && v <= 1000000, "Invalid offlinePenaltyThresholdBlocksNum range");
        consts.updateOfflinePenaltyThresholdBlocksNum(v);
        lastUsedOfflinePenaltyThresholdBlocksNumHash = 0;
    }

    // Step 1 for updateTargetGasPowerPerSecond
    function constsUpdateTargetGasPowerPerSecondStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedTargetGasPowerPerSecondHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateTargetGasPowerPerSecond
    function constsUpdateTargetGasPowerPerSecondStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedTargetGasPowerPerSecondHash == keccak256(abi.encodePacked(v)), "Mismatched targetGasPowerPerSecond hash");
        require(v >= 1000000 && v <= 500000000, "Invalid targetGasPowerPerSecond range");
        consts.updateTargetGasPowerPerSecond(v);
        lastUsedTargetGasPowerPerSecondHash = 0;
    }

    // Step 1 for updateGasPriceBalancingCounterweight
    function constsUpdateGasPriceBalancingCounterweightStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        lastUsedGasPriceBalancingCounterweightHash = keccak256(abi.encodePacked(v));
    }

    // Step 2 for updateGasPriceBalancingCounterweight
    function constsUpdateGasPriceBalancingCounterweightStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 v
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(v)),
            "Master check failed"
        );
        require(lastUsedGasPriceBalancingCounterweightHash == keccak256(abi.encodePacked(v)), "Mismatched gasPriceBalancingCounterweight hash");
        require(v >= 100 && v <= 10 * 86400, "Invalid gasPriceBalancingCounterweight range");
        consts.updateGasPriceBalancingCounterweight(v);
        lastUsedGasPriceBalancingCounterweightHash = 0;
    }
    // Step 1 for setSFCtConstsAddress
    function setSFCtConstsAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address _constsAddress
    )
        public

    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(_constsAddress)),
            "Master check failed"
        );
        lastUsedSFCtConstsAddress = _constsAddress;
    }

    // Step 2 for setSFCtConstsAddress
    function setSFCtConstsAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address _constsAddress
    )
        public
    {
        require(
            lamportBase.performLamportMasterCheck(currentpub, sig, nextPKH, abi.encodePacked(_constsAddress)),
            "Master check failed"
        );
        require(lastUsedSFCtConstsAddress == _constsAddress, "Mismatched SFCtConsts address between step one and two");
        consts = IConsts(_constsAddress);
        lastUsedSFCtConstsAddress = address(0);
        emit SFCConstsAddressSet2(_constsAddress);

    }
    function constsAddress() external view returns (address) {
        return consts.constsAddress();
    }
}

