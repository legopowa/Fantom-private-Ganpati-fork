// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPlayerDatabase {
    function getAllPlayerNames() external view returns (string[] memory);
    function getServerIPList() external view returns (string[] memory);
    function getValidRewardAddressesByNames(string[] memory playerNames, uint256 lastMintTime) external view returns (address[] memory);
    function isValidator(address _address) external view returns (bool);

}
interface IGP_Mint {
    function mintTokens(address to, uint256 amount) external;
    // Add other function signatures as needed
}
contract GameValidator {

    IPlayerDatabase playerDatabase;
    IGP_Mint public mintContract;

    mapping(string => address[]) private validatorsPerServerIP;
    mapping(string => mapping(address => ServerSubmission)) public serverSubmissions; 
    mapping(bytes32 => string[]) public hashToPlayerList; // playerListHash -> playerNames

    uint256 public lastMintTime;
    uint256 public constant MINT_INTERVAL = 5 minutes;
    uint256 public constant MAX_PLAYERS_PER_SUBMISSION = 64;
    uint256 public constant MAX_MINT_TIME = 10 minutes; // 10 minutes cap
    uint256 public constant TOKENS_PER_SECOND = (1e18 * 60) / 60; // 1e18 represents 1 token, and we divide by 60 seconds

    constructor(address _playerDatabaseAddress, address _mintContractAddress) {
        playerDatabase = IPlayerDatabase(_playerDatabaseAddress);
        mintContract = IGP_Mint(_mintContractAddress);
    }

    struct ServerSubmission {
        //address validator;
        bytes32 playerListHash; // Hash of the player list for gas efficiency
        bool canMint;
    }

    struct ServerPlayers {
        string serverIP;
        string[] playerNames;
    }
    //mapping(string => ServerSubmission[]) public serverSubmissions; // serverIP -> submissions
    struct HashCount {
        bytes32 hash;
        uint256 count;
    }


    // Function to set the GP_Mint contract address
    function setMintContractAddress(address _mintContractAddress) public {
        // Additional checks for access control, like onlyOwner
    }
    function calculateMintAmount() private view returns (uint256) {
        uint256 elapsedSeconds = block.timestamp - lastMintTime;

        if (elapsedSeconds > MAX_MINT_TIME) {
            elapsedSeconds = MAX_MINT_TIME; // Cap the elapsed time to MAX_MINT_TIME
        }

        return elapsedSeconds * TOKENS_PER_SECOND; // Calculate the mint amount based on elapsed time
    }

    function updateValidatorsList(string memory serverIP, address validator) private {
        bool validatorExists = false;
        for (uint i = 0; i < validatorsPerServerIP[serverIP].length; i++) {
            if (validatorsPerServerIP[serverIP][i] == validator) {
                validatorExists = true;
                break;
            }
        }
        if (!validatorExists) {
            validatorsPerServerIP[serverIP].push(validator);
        }
    }

    function submitPlayerList(ServerPlayers[] memory serverPlayerLists, address validatorID, bool canMintFlag) public {
        require(isValidator(validatorID), "Caller is not a registered validator");

        uint256 totalPlayerCount = 0;


        for (uint i = 0; i < serverPlayerLists.length; i++) {
            uint256 serverPlayerCount = serverPlayerLists[i].playerNames.length;
            if (totalPlayerCount + serverPlayerCount > MAX_PLAYERS_PER_SUBMISSION) {
                break; // Stop if the max players per submission is exceeded
            }
            totalPlayerCount += serverPlayerCount;

            // Encode each string in the playerNames array individually
            bytes memory encodedPlayerNames;
            for (uint j = 0; j < serverPlayerLists[i].playerNames.length; j++) {
                encodedPlayerNames = abi.encodePacked(encodedPlayerNames, serverPlayerLists[i].playerNames[j]);
            }

            // Compute the hash of the concatenated byte array
            bytes32 playerListHash = keccak256(encodedPlayerNames);
            hashToPlayerList[playerListHash] = serverPlayerLists[i].playerNames;

            // Update or add the validator to the list for this server IP
            updateValidatorsList(serverPlayerLists[i].serverIP, validatorID);

            // Overwrite the existing submission for this server IP and validator
            serverSubmissions[serverPlayerLists[i].serverIP][validatorID] = ServerSubmission({
                playerListHash: playerListHash,
                canMint: canMintFlag
            });
        }
        // Check if it's time to perform mass minting
        uint256 currentTime = block.timestamp;
        uint256 timeSinceLastMint = currentTime - lastMintTime;
        uint256 timeToNextInterval = MINT_INTERVAL - (currentTime % MINT_INTERVAL);

        if (timeSinceLastMint >= MINT_INTERVAL && timeToNextInterval < MINT_INTERVAL) {
            performMassMinting();
            lastMintTime = currentTime - timeToNextInterval; // Align with the 5-minute interval
        }
    }
    // function submitPlayerList(ServerPlayers[] memory serverPlayerLists, address validatorID, bool canMintFlag) public {
    //     require(isValidator(validatorID), "Caller is not a registered validator");

    //     uint256 totalPlayerCount = 0;

    //     for (uint i = 0; i < serverPlayerLists.length; i++) {
    //         uint256 serverPlayerCount = serverPlayerLists[i].playerNames.length;
    //         if (totalPlayerCount + serverPlayerCount > MAX_PLAYERS_PER_SUBMISSION) {
    //             break; // Stop if the max players per submission is exceeded
    //         }

    //         totalPlayerCount += serverPlayerCount;

    //         // Create a hash for the player list
    //         bytes32 playerListHash = keccak256(abi.encodePacked(serverPlayerLists[i].playerNames));
    //         hashToPlayerList[playerListHash] = serverPlayerLists[i].playerNames;

    //         // Overwrite the existing submission for this server IP and validator
    //         serverSubmissions[serverPlayerLists[i].serverIP][validatorID] = ServerSubmission({
    //             playerListHash: playerListHash,
    //             canMint: canMintFlag
    //         });
    //     }
    // }

    function isValidator(address _address) public view returns (bool) {
        //PlayerDatabase playerDatabase = PlayerDatabase(playerDatabaseAddress);
        return playerDatabase.isValidator(_address);
    }

    function resetSubmissions() private {
        string[] memory serverIPs = playerDatabase.getServerIPList();
        for (uint i = 0; i < serverIPs.length; i++) {
            string memory serverIP = serverIPs[i];
            address[] memory validators = validatorsPerServerIP[serverIP];
            for (uint j = 0; j < validators.length; j++) {
                serverSubmissions[serverIP][validators[j]].canMint = false;
            }
        }
    }

    // Function to perform mass minting
    function performMassMinting() public {
        string[] memory serverIPs = playerDatabase.getServerIPList();
        for (uint i = 0; i < serverIPs.length; i++) {
            string memory serverIP = serverIPs[i];
            bytes32 commonHash = findMostCommonHash(serverIP);
            if (commonHash != bytes32(0)) {
                mintForServer(commonHash);
            }
        }
        resetSubmissions();
    }
    function mintForServer(bytes32 playerListHash) private {
        // Retrieve the player list for the given hash
        string[] memory playerList = hashToPlayerList[playerListHash];
        address[] memory rewardAddresses = getValidRewardAddressesByNames(playerList);

        uint256 mintAmount = calculateMintAmount(); // Define logic for mint amount

        // Mint tokens for each player
        for (uint i = 0; i < rewardAddresses.length; i++) {
            if (rewardAddresses[i] != address(0)) { // Check for valid address
                mintContract.mintTokens(rewardAddresses[i], mintAmount);
            }
        }
    }
    function findMostCommonHash(string memory serverIP) private view returns (bytes32) {
        // Assume validatorsPerServerIP is a mapping that tracks validators per server IP
        address[] memory validators = validatorsPerServerIP[serverIP];
        uint256 majorityThreshold = (validators.length * 60) / 100; // 60% of total validators

        bytes32 majorityHash = bytes32(0);
        uint256 highestCount = 0;

        // Use a structure to keep track of each hash count


        HashCount[] memory hashCounts = new HashCount[](validators.length);

        // Count occurrences of each hash
        for (uint i = 0; i < validators.length; i++) {
            bytes32 currentHash = serverSubmissions[serverIP][validators[i]].playerListHash;
            bool found = false;

            for (uint j = 0; j < hashCounts.length; j++) {
                if (hashCounts[j].hash == currentHash) {
                    hashCounts[j].count++;
                    found = true;
                    break;
                }
            }

            if (!found) {
                hashCounts[i] = HashCount({hash: currentHash, count: 1});
            }

            // Update majority hash if necessary
            if (hashCounts[i].count > highestCount) {
                highestCount = hashCounts[i].count;
                majorityHash = hashCounts[i].hash;
            }
        }

        // Check if the highest count meets the majority threshold
        if (highestCount >= majorityThreshold) {
            return majorityHash;
        }

        return bytes32(0); // No majority found
    }

    // Helper function to check if a hash is present in the tempUniqueHashes array


    function getValidRewardAddressesByNames(string[] memory playerNames) public view returns (address[] memory) {
        return playerDatabase.getValidRewardAddressesByNames(playerNames, lastMintTime);
    }



    // Additional functions...
}
