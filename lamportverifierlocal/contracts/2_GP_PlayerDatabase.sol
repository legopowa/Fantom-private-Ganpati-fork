// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IAnonID {
    function incrementMinutesPlayed(address user, uint256 _minutes) external;
    function updateLastPlayed(address _address, string memory _gameId) external;
    function isWhitelisted(address _address) external view returns (bool);
    function isPlayerActiveInGame(string memory gameID, address player) external view returns (uint8);
}
// MintyDatabase contract inheriting from AnonID
contract PlayerDatabase  {
    // ERC20 Token variables
    // string public name;
    // string public symbol;
    // uint8 public decimals;
    // uint256 public totalSupply;
    //uint256 public gameID; // Variable to store the game ID 
    mapping(string => bool) public gameServerIPs; // Mapping to store game server IPs
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string gameID = "TFC"; // Define your game ID for TFC
    string[] public serverIPList; // Array for listing all server IPs

    // Player Database variables
    struct Player {
        bool isRegistered;
        bool isValidator;
        bool isModerator;
        bool isTourneyMod;
        bool isGameAdmin;
        string playerName; // Name of the player
        bytes32 forumKey; // Unique key for forum entitlements
        string steamID;
        address rewardAddress;
    }

    mapping(address => Player) public playerData;
    address[] public playerAddresses;

    // Shared variables
    address public gameValContract; // Address of the game subcontractor
    IAnonID public anonIDContract; // Reference to the AnonID contract
    address public onrampContract; // Address of the onramp contract
    address public forumContract; // Address of the forum contract

    // Events
    event GameValContractUpdated(address indexed newGameValContract);
    event OnrampContractUpdated(address indexed newOnrampContract);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Constructor
    //constructor(string memory _name, string memory _symbol, uint8 _decimals) { //}, uint256 _totalSupply) {
    constructor() {
        // name = "GPConcs";
        // symbol = "GPConcs";
        // decimals = 18;
        // balanceOf[msg.sender] = 80000000000000000000000;
        // gameID = "TFC";
    }
    function isValidator(address _address) public view returns (bool) {
        return playerData[_address].isValidator;
    }
    function isModerator(address _address) public view returns (bool) {
        return playerData[_address].isModerator;
    }
    // Function to set the AnonID contract address
    function setAnonIDContractAddress(address _anonIDAddress) public {
        // Add appropriate security checks
        anonIDContract = IAnonID(_anonIDAddress);
    }

    function isRegistered(address _address) public view returns (bool) {
        return playerData[_address].isRegistered;
    }
    // function getRewardAddressesByNames(string[] memory playerNames) public view returns (address[] memory) {
    //     address[] memory rewardAddresses = new address[](playerNames.length);

    //     for (uint i = 0; i < playerNames.length; i++) {
    //         for (uint j = 0; j < playerAddresses.length; j++) {
    //             if (keccak256(abi.encodePacked(playerData[playerAddresses[j]].playerName)) == keccak256(abi.encodePacked(playerNames[i]))) {
    //                 rewardAddresses[i] = playerData[playerAddresses[j]].rewardAddress;
    //                 break; // Stop the inner loop once the address is found
    //             }
    //         }
    //     }

    //     return rewardAddresses;
    // }
    function getValidRewardAddressesByNames(string[] memory playerNames, uint256 lastMintTime) public returns (address[] memory) {
        address[] memory validRewardAddresses = new address[](playerNames.length);

        for (uint i = 0; i < playerNames.length; i++) {
            for (uint j = 0; j < playerAddresses.length; j++) {
                if (keccak256(abi.encodePacked(playerData[playerAddresses[j]].playerName)) == keccak256(abi.encodePacked(playerNames[i]))) {
                    uint8 playerStatus = anonIDContract.isPlayerActiveInGame(gameID, playerAddresses[j]);

                    if (playerStatus == 2) { // Player already minted for TFC
                        validRewardAddresses[i] = playerData[playerAddresses[j]].rewardAddress;
                        // Increment the minutes played using lastMintTime
                        uint256 minutesPlayed = lastMintTime / 60; // Convert seconds to minutes
                        anonIDContract.incrementMinutesPlayed(playerAddresses[j], minutesPlayed);
                        anonIDContract.updateLastPlayed(playerAddresses[j], gameID);

                    } else if (playerStatus == 0) { // Player not in a game, flag as active
                        anonIDContract.updateLastPlayed(playerAddresses[j], gameID);
                        // block.timestamp - lastMintTime = i
                        // Do not include this player in the reward addresses for this round
                    }
                    break; // Stop the inner loop once the player is processed
                }
            }
        }

        return validRewardAddresses;
    }
    // // Function to interact with AnonID contract
    // function updateAnonIDData(address _user, uint256 _minutes, uint256 _gameId) public {
    //     // Ensure the caller has permission to update AnonID data
    //     anonIDContract.incrementMinutesPlayed(_user, _minutes);
    //     anonIDContract.updateLastPlayed(_user, _gameId);
    // }// validator does this

    // Player Database functions
    // Assuming IAnonID interface and anonIDContract are already defined and set up in your contract
    function updateGameServerIP(string memory serverIP, bool add) public {
        require(playerData[msg.sender].isGameAdmin, "Caller is not a game admin");

        if (add) {
            if (!gameServerIPs[serverIP]) {
                gameServerIPs[serverIP] = true;
                serverIPList.push(serverIP);
            }
        } else {
            if (gameServerIPs[serverIP]) {
                gameServerIPs[serverIP] = false;
                removeServerIPFromArray(serverIP);
            }
        }
    }

    // Helper function to remove a server IP from the array
    function removeServerIPFromArray(string memory serverIP) private {
        for (uint i = 0; i < serverIPList.length; i++) {
            if (keccak256(abi.encodePacked(serverIPList[i])) == keccak256(abi.encodePacked(serverIP))) {
                // Update the mapping to reflect the server IP is no longer registered
                gameServerIPs[serverIP] = false;

                // Remove the server IP from the array
                serverIPList[i] = serverIPList[serverIPList.length - 1];
                serverIPList.pop();
                break;
            }
        }
    }

    // Function to get the full list of server IPs
    function getAllServerIPs() public view returns (string[] memory) {
        return serverIPList;
    }
    function addOrUpdatePlayer(address _address, string memory _steamID, bool _isValidator, bool _isRegistered, string memory _playerName) public {
        require(msg.sender == onrampContract, "Only the onramp contract can add/update players");
        require(anonIDContract.isWhitelisted(_address), "Address not whitelisted in AnonID");

        Player storage player = playerData[_address];
        bool alreadyRegistered = player.isRegistered;

        playerData[_address] = Player({
            steamID: _steamID,
            isValidator: _isValidator,
            isRegistered: _isRegistered,
            rewardAddress: _address,
            playerName: _playerName,
            // Zero out or set default values for the non-argument fields
            isModerator: false,
            isTourneyMod: false,
            isGameAdmin: false,
            forumKey: 0 // Assuming 0 is the default value for forumKey
        });

        if (!alreadyRegistered) {
            playerAddresses.push(_address);
        }
    }

    function getAllPlayerNames() public view returns (string[] memory) {
        string[] memory playerNames = new string[](playerAddresses.length);

        for (uint i = 0; i < playerAddresses.length; i++) {
            Player storage player = playerData[playerAddresses[i]];
            playerNames[i] = player.playerName;
        }

        return playerNames;
    }
    // ... [Other Player Database functions]

    // Shared functions
    function updateGameValContract(address _gameValContract) public {
        gameValContract = _gameValContract;
        emit GameValContractUpdated(_gameValContract);
    }

    function updateOnrampContract(address _onrampContract) public {
        onrampContract = _onrampContract;
        emit OnrampContractUpdated(_onrampContract);
    }
    // ... [Previous variables and functions]


    // ... [Rest of the existing contract]

    // Function to update the forum contract address
    function updateForumContract(address _forumContract) public {
        // Add appropriate security checks
        forumContract = _forumContract;
    }

    // Function to change a player's moderator status
    function toggleModeratorStatus(address _player, bool _status) external {
        require(msg.sender == forumContract, "Only the forum contract can modify moderator status");
        playerData[_player].isModerator = _status;
    }

    // Function to change a player's tournament moderator status
    function toggleTourneyModStatus(address _player, bool _status) external {
        require(msg.sender == forumContract, "Only the forum contract can modify tournament moderator status");
        playerData[_player].isTourneyMod = _status;
    }

    // Function to set or update a player's forum key
    function setForumKey(address _player, bytes32 _key) external {
        require(msg.sender == forumContract, "Only the forum contract can set forum key");
        playerData[_player].forumKey = _key;
    }
    function setGameAdminStatus(address admin, bool status) external {
        // Add security check to ensure only authorized contract or account can call this
        playerData[admin].isGameAdmin = status;
    }

    function setValidatorStatus(address validator, bool status) external {
        // Add security check to ensure only authorized contract or account can call this
        playerData[validator].isValidator = status;
    }
    // ... [Additional functions and security checks as necessary]
}
// pragma solidity ^0.8.0;

// contract TFCPlayAndEarn {
//     // Other contract variables...

//     struct Submission {
//         address validator;
//         string[] names;
//     }
//     Submission[] submissions;

//     function processSubmissions(string[] memory rawNames, address validator) public {
//         require(isValidator(validator), "Not a validator");
//         string[] memory sanitizedNames = sanitizeNames(rawNames);
        
//         // Store the sanitized names along with the validator's address
//         submissions.push(Submission({
//             validator: validator,
//             names: sanitizedNames
//         }));
//     }

//     function sanitizeNames(string[] memory rawNames) private pure returns (string[] memory) {
//         string[] memory sanitizedNames = new string[](rawNames.length);

//         for (uint i = 0; i < rawNames.length; i++) {
//             // Implement sanitation logic
//             // This might include removing or replacing brackets, punctuation, etc.
//             sanitizedNames[i] = sanitize(rawNames[i]);
//         }

//         return sanitizedNames;
//     }

//     function sanitize(string memory name) private pure returns (string memory) {
//         // Detailed implementation of the sanitization logic
//         // Could involve regex replacements or character filtering
//         // Solidity does not natively support regex, so this might require character-by-character processing
//     }

//     // Additional functions like isValidator, auditSubmissions, etc.
// }
