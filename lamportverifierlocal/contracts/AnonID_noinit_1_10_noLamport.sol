// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface ILamportBase {
    function performLamportMasterCheck(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        bytes memory prepacked
    ) external returns (bool);

    function performLamportOracleCheck(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        bytes memory prepacked
    ) external returns (bool);

    function getPKHsByPrivilege(uint8 privilege) external view returns (bytes32[] memory);
}
contract AnonIDContract {

    ILamportBase public lamportBase;

    event LogLastCalculatedHash(uint256 hash);

    // free transactional quota section

    struct UserQuota {
        uint256 start; // Index of the oldest timestamp
        uint256 count; // Current count of timestamps
    }

    mapping(address => UserQuota) private userQuotaInfo;
    mapping(address => uint256[500]) private userTxTimestamps; // Example with max 500 transactions
    mapping(address => uint256) public hourlyTxQuota;
    mapping(address => LastPlayedInfo) public lastPlayed;

    event TxRecorded(address indexed _user, uint256 timestamp);
    event QuotaSet(address indexed _address, uint256 _quota);

    // permissions

    mapping(address => bool) public isContractPermitted;
    mapping(address => bool) public whitelist;

    event VerificationFailed(uint256 hashedData);
    event Whitelisted(address indexed _address, bytes32 hashedID);
    event RemovedFromWhitelist(address indexed _address);
    event ContractCreated(address indexed contractAddress);

    bool public lastVerificationResult;

    // profile things

    mapping(address => uint256) public minutesPlayed;
    mapping(address => uint256) public lastClaim;
    mapping(address => uint256) public lastLastClaim;
    mapping(address => bytes32) public addressToHashedID;

    event MinutesPlayedIncremented(address indexed user, uint256 _minutes);
    event ClaimedGP(address indexed userAddress, uint256 lastClaimValue, uint256 minutesPlayed);

    struct LastPlayedInfo {
        string gameId;
        uint256 timestamp;
    }


    // globals

    uint256 private lastUsedFreeGasCap;
    address private lastUsedContractAddress;
    address private lastUsedContractAddressForRevoke;


    uint256 public freeGasCap; // Add this state variable for freeGasFee
    bytes32 public lastUsedBytecodeHash;

    event ContractPermissionGranted(address contractAddress);
    event ContractPermissionRevoked(address contractAddress);
    event FreeGasCapSet(uint256 newFreeGasCap);
 
    // commission section

    event CommissionSet(uint256 newCoinCommission);
    event CommissionAddressSet(address indexed newCommissionAddress);

    uint256 public _coinCommission;
    
    address private _commissionAddress; // ideally make this a quantum-hard contract, commissions go here
    uint256 private lastUsedCommission;
    bytes32 private lastUsedCommissionAddressHash;

    constructor() {

        _commissionAddress = 0xfd003CA44BbF4E9fB0b2fF1a33fc2F05A6C2EFF9;
        lamportBase = ILamportBase(0x0759a02f763375305aef8b3afb0051eDe0c0577f);
    }




    //AnonID functions
    function setCoinCommissionStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 newCoinCommission
    )
        public
    {
        // Convert the new commission to bytes and pass it to performLamportMasterCheck
        bytes memory prepacked = abi.encodePacked(newCoinCommission);
        
        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            prepacked
        );
        
        // Require that the Lamport Master check passes
        require(lamportCheckPassed, "Lamport Master validation failed");
        
        // Proceed with updating the commission
        lastUsedCommission = newCoinCommission;
    }

    function setCoinCommissionStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 newCoinCommission
    )
        public
    {
        // Convert the new commission to bytes and pass it to performLamportMasterCheck
        bytes memory prepacked = abi.encodePacked(newCoinCommission);
        
        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            prepacked
        );
        
        // Require that the Lamport Master check passes
        require(lamportCheckPassed, "Lamport Master validation failed");

        // Check the commission range and match with last used commission
        require(newCoinCommission >= 0 && newCoinCommission <= 20, "Commission should be between 0% and 20%");
        require(newCoinCommission == lastUsedCommission, "Mismatched commission values between steps");

        // Update the coin commission
        _coinCommission = newCoinCommission;

        // Reset the temporary variable
        lastUsedCommission = 0;
        emit CommissionSet(newCoinCommission);
    }
    function commissionAddress() public view returns (address) {
        return _commissionAddress;
    }
    function coinCommission() public view returns (uint256) {
        return _coinCommission;
    }

    // Assuming there's a mapping to track the last mint time for each player in each game
    // Mapping for each player's last played information

    function isPlayerActiveInGame(string memory gameID, address player) public view returns (uint8) {
        LastPlayedInfo memory lastPlayedInfo = lastPlayed[player];
        bool isWithinTimeLimit = block.timestamp - lastPlayedInfo.timestamp < 8 minutes;

        // Compare keccak256 hash of strings
        if (isWithinTimeLimit && keccak256(abi.encodePacked(lastPlayedInfo.gameId)) == keccak256(abi.encodePacked(gameID))) {
            return 2; // Player is active in this game and recently minted
        } else if (isWithinTimeLimit && keccak256(abi.encodePacked(lastPlayedInfo.gameId)) != keccak256(abi.encodePacked(gameID))) {
            return 1; // Player is active but in a different game
        }
        return 0; // Player is not currently active
    }


    function addToWhitelist(address _address, string memory anonID) external {
        require(isContractPermitted[msg.sender], "Not permitted to modify whitelist");
        
        bytes32 hashedID = keccak256(abi.encodePacked(anonID));

        // Ensure the address is not already whitelisted
        require(!whitelist[_address], "Address already whitelisted");

         // Initialize the hourly transaction quota for the address
        hourlyTxQuota[_address] = 5; // Initial quota set to 10, adjust as needed

        // Whitelist the address
        whitelist[_address] = true;

        // Update the address to hashedID mapping
        addressToHashedID[_address] = hashedID;

        emit Whitelisted(_address, hashedID);

    }


    function setHourlyTxQuota(address _address, uint256 _quota) external {
        require(isContractPermitted[msg.sender], "Not permitted to modify hourly transaction quota");

        // Ensure the address is indeed whitelisted before setting the quota
        require(whitelist[_address], "Address not found in whitelist");

        // Set the hourly transaction quota for the address
        hourlyTxQuota[_address] = _quota;
        emit QuotaSet(_address, _quota);

    }

    function toHexString(address _address) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_address)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);

        str[0] = '0';
        str[1] = 'x';

        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }

        return string(str);
    }
    function isThisTxFree(address _user) external returns (bool) {
        // Ensure only TheRock can call this function
        require(msg.sender == 0x2685751d3C7A49EbF485e823079ac65e2A35A3DD,
                string(abi.encodePacked("Only TheRock can call this function. Caller: ", toHexString(msg.sender))));

        // Check if the user is whitelisted
        if (!whitelist[_user]) {
            return false;
        }

        // Return false if quota is zero
        if (hourlyTxQuota[_user] == 0) {
            return false;
        }

        UserQuota storage quotaInfo = userQuotaInfo[_user];
        uint256[500] storage timestamps = userTxTimestamps[_user];

        // Check if quota is exceeded within the last hour
        if (quotaInfo.count >= hourlyTxQuota[_user]) {
            uint256 oldestTimestampIndex = quotaInfo.start;
            if (block.timestamp - timestamps[oldestTimestampIndex] <= 1 hours) {
                // Quota exceeded, as the oldest transaction is within the last hour
                return false;
            }

            // Move the start index forward as we will overwrite the oldest timestamp
            quotaInfo.start = (quotaInfo.start + 1) % hourlyTxQuota[_user];
        } else {
            // Increment the count if the buffer is not full
            quotaInfo.count++;
        }

        // Add the new transaction timestamp
        uint256 newIndex = (quotaInfo.start + quotaInfo.count - 1) % hourlyTxQuota[_user];
        timestamps[newIndex] = block.timestamp;

        emit TxRecorded(_user, block.timestamp);
        return true;
    }

    function getRemainingTxQuota(address _user) public view returns (uint256) {
        // Check if the user is whitelisted
        if (!whitelist[_user]) {
            return 0;  // Not whitelisted, so no quota
        }

        // Get user's quota and transaction timestamps
        uint256 quota = hourlyTxQuota[_user];
        UserQuota storage quotaInfo = userQuotaInfo[_user];
        uint256[500] storage timestamps = userTxTimestamps[_user];

        // If quota buffer is not full, return the remaining quota
        if (quotaInfo.count < quota) {
            return quota - quotaInfo.count;
        }

        // If buffer is full, check the timestamp of the oldest transaction
        uint256 oldestTimestampIndex = quotaInfo.start;
        if (block.timestamp - timestamps[oldestTimestampIndex] > 1 hours) {
            // The oldest transaction is older than an hour, so full quota is available
            return quota;
        }

        // Calculate remaining quota based on the timestamp of the next oldest transaction
        uint256 nextOldestIndex = (quotaInfo.start + 1) % quota;
        if (block.timestamp - timestamps[nextOldestIndex] > 1 hours) {
            return quota - 1; // One transaction will be available when the oldest timestamp expires
        }

        // If none of the above conditions are met, no transactions are available this hour
        return 0;
    }

// Remove an address from the whitelist
    function removeFromWhitelist(address _address) external {
        require(isContractPermitted[msg.sender], "Not permitted to modify whitelist");

        // Ensure the address is indeed whitelisted before removing
        require(whitelist[_address], "Address not found in whitelist");

        // Remove the address from the whitelist
        whitelist[_address] = false;

        // Remove the address and hashedID association from the addressToHashedID mapping
        delete addressToHashedID[_address];
        emit RemovedFromWhitelist(_address);

    }

    function incrementMinutesPlayed(address user, uint256 _minutes) external {
        require(isContractPermitted[msg.sender], "Not permitted to modify minutes played");
        minutesPlayed[user] += _minutes;
        emit MinutesPlayedIncremented(user, _minutes);

    }

    function updateLastPlayed(address _address, string memory _gameId) external {
        require(isContractPermitted[msg.sender], "Not permitted to update last played");

        lastPlayed[_address] = LastPlayedInfo({
            gameId: _gameId,
            timestamp: block.timestamp
        });

    }
    // Function to get the minutes played by a user
    function getMinutesPlayed(address user) external view returns (uint256) {
        return minutesPlayed[user];
    }
 // New function to check if an address is whitelisted
    function isWhitelisted(address _address) external view returns (bool) {
        return whitelist[_address];
    }
    function claimGP() external {
        // The invoking address is the user's address
        address userAddress = msg.sender;

        // Check if the user's address is whitelisted
        require(whitelist[userAddress], "User is not whitelisted");

        // Use the user's address to fetch lastClaim and lastLastClaim from AnonID contract
        uint256 lastClaimValue = lastClaim[userAddress];
        uint256 lastLastClaimValue = lastLastClaim[userAddress];
        
        require(lastClaimValue >= lastLastClaimValue, "Invalid claim values");

        lastLastClaim[userAddress] = lastClaimValue;
        lastClaim[userAddress] = minutesPlayed[userAddress];  // Update with the current minutes played
        emit ClaimedGP(userAddress, lastClaimValue, minutesPlayed[userAddress]);

    }
    // Step One: Store the contract address temporarily
    function grantActivityContractPermissionStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address contractAddress
    )
        public
    {
        // Convert the contract address to bytes and pass it to performLamportMasterCheck
        bytes memory prepacked = abi.encodePacked(contractAddress);

        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            prepacked
        );

        // Require that the Lamport Master check passes
        require(lamportCheckPassed, "Lamport Master validation failed");

        // Save the contract address for the next step
        lastUsedContractAddress = contractAddress;
    }
    // Step Two: Apply the permission to the stored contract address
    function grantActivityContractPermissionStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH
    )
        public
    {
        // Convert the last used contract address to bytes and pass it to performLamportMasterCheck
        bytes memory prepacked = abi.encodePacked(lastUsedContractAddress);

        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            prepacked
        );

        // Require that the Lamport Master check passes
        require(lamportCheckPassed, "Lamport Master validation failed");

        // Grant permission to the contract address
        isContractPermitted[lastUsedContractAddress] = true;
        emit ContractPermissionGranted(lastUsedContractAddress);
    }
    // Step One: Store the contract address temporarily
    function revokeActivityContractPermissionStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address contractAddress
    )
        public
    {
        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            abi.encodePacked(contractAddress)
        );

        require(lamportCheckPassed, "Lamport Master validation failed");

        lastUsedContractAddressForRevoke = contractAddress;
    }

    // Step Two: Revoke the permission for the stored contract address
    function revokeActivityContractPermissionStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH
    )
        public
    {
        // Convert the last used contract address for revoking to bytes and pass it to performLamportMasterCheck
        bytes memory prepacked = abi.encodePacked(lastUsedContractAddressForRevoke);

        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            prepacked
        );

        require(lamportCheckPassed, "Lamport Master validation failed");

        isContractPermitted[lastUsedContractAddressForRevoke] = false;
        emit ContractPermissionRevoked(lastUsedContractAddressForRevoke);
    }
    

    // Step 1: Temporarily store the hash of the new commission address
    function setCommissionAddressStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newCommissionAddress
    ) public {
        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            abi.encodePacked(newCommissionAddress)
        );

        require(lamportCheckPassed, "Lamport Master validation failed");

        // Save the hash of the new commission address
        lastUsedCommissionAddressHash = keccak256(abi.encodePacked(newCommissionAddress));
    }

    // Step 2: Verify and set the commissionAddress
    function setCommissionAddressStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address newCommissionAddress
    ) public {
        // Convert the new commission address to bytes and pass it to performLamportMasterCheck
        bytes memory prepacked = abi.encodePacked(newCommissionAddress);

        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            prepacked
        );

        require(lamportCheckPassed, "Lamport Master validation failed");

        // Verify the hash of the new commission address matches the saved hash
        require(
            keccak256(prepacked) == lastUsedCommissionAddressHash,
            "Mismatched commission address"
        );

        // Update the commission address
        _commissionAddress = newCommissionAddress;

        // Emit an event if needed
        // emit CommissionAddressSet(newCommissionAddress);
    }

    function createContractStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        bytes32 bytecodeKeccak
    ) public {
        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            abi.encodePacked(bytecodeKeccak)
        );

        require(lamportCheckPassed, "Lamport Master validation failed");

        // Save the hash of the bytecode in a global variable
        lastUsedBytecodeHash = bytecodeKeccak;
    }
    function createContractStepTwo(
        bytes memory bytecode
    ) public returns (address) {
        // Verify bytecode hash matches
        require(keccak256(bytecode) == lastUsedBytecodeHash, "Bytecode does not match previously provided hash.");
        
        address newContract;
        assembly {
            newContract := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(newContract != address(0), "Contract creation failed");

        // Emitting the ContractCreated event
        emit ContractCreated(newContract);

        return newContract;
    }
    // function createContractStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     bytes memory bytecode
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(bytecode)
    //     )
    //     returns (address)
    // {
    //      // Verify bytecode hash matches
    //     require(keccak256(bytecode) == lastUsedBytecodeHash, "Bytecode does not match previously provided bytecode.");
    //     address newContract;
    //     assembly {
    //         newContract := create(0, add(bytecode, 0x20), mload(bytecode))
    //     }
    //     require(newContract != address(0), "Contract creation failed");
    //     return newContract;
    // }
    // Step One: Store the new value temporarily
    function setFreeGasCapStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        uint256 _newCap
    ) public {
        // Perform the Lamport Master check
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            abi.encodePacked(_newCap)
        );

        require(lamportCheckPassed, "Lamport Master validation failed");

        // Save the new free gas cap in a global variable
        lastUsedFreeGasCap = _newCap;
    }


    // Step Two: Apply the new value
    function setFreeGasCapStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH
    ) public {
        // Perform the Lamport Master check again
        bool lamportCheckPassed = lamportBase.performLamportMasterCheck(
            currentpub, 
            sig, 
            nextPKH, 
            abi.encodePacked(lastUsedFreeGasCap)
        );

        require(lamportCheckPassed, "Lamport Master validation failed");

        // Apply the new free gas cap
        freeGasCap = lastUsedFreeGasCap;
        emit FreeGasCapSet(lastUsedFreeGasCap);
    }

}
