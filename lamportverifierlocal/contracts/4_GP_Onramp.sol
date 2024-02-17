// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// interface IPlayerDatabaseSubcontract {
//     function addOrUpdatePlayer(address _address, string calldata _steamID, bool _isValidator, bool _isRegistered) external;
// }

interface IPlayerDatabase {
    function addOrUpdatePlayer(address _address, string calldata _steamID, bool _isValidator, bool _isRegistered, string memory _playerName) external;
    // Include other functions from PlayerDatabase that PlayerOnrampContract needs to call

    function setGameAdminStatus(address admin, bool status) external;
    function setValidatorStatus(address validator, bool status) external;

}

contract PlayerOnrampContract {
    IPlayerDatabase public playerDatabase;

    event PlayerOnboarded(address indexed playerAddress, string steamID, bool isValidator, bool isRegistered, string _playerName);

    constructor(address _playerDatabaseAddress) {
        playerDatabase = IPlayerDatabase(_playerDatabaseAddress);
    }

    function onboardPlayer(address _address, string calldata _steamID, bool _isValidator, bool _isRegistered, string memory _playerName) public {
        // Additional logic and security checks as needed
        playerDatabase.addOrUpdatePlayer(_address, _steamID, _isValidator, _isRegistered, _playerName);
        emit PlayerOnboarded(_address, _steamID, _isValidator, _isRegistered, _playerName);
    }

    // Additional functions and logic as required for onramping...


    function registerValidator(address validator) public {
        // Add appropriate checks here
        playerDatabase.setValidatorStatus(validator, true);
    }

    function removeValidator(address validator) public {
        // Add appropriate checks here
        playerDatabase.setValidatorStatus(validator, false);
    }

    function registerAdmin(address admin) public {
        // Add appropriate checks here
        playerDatabase.setGameAdminStatus(admin, true);
    }

    function removeAdmin(address admin) public {
        // Add appropriate checks here
        playerDatabase.setGameAdminStatus(admin, false);
    }
}
// contract PlayerOnrampContract {
//     IMintyDatabaseSubcontract public mintyDatabase;

//     event PlayerOnboarded(address indexed playerAddress, string steamID, bool isValidator, bool isRegistered);

//     constructor(address _mintyDatabaseAddress) {
//         mintyDatabase = IMintyDatabaseSubcontract(_mintyDatabaseAddress);
//     }

//     function onboardPlayer(address _address, string calldata _steamID, bool _isValidator, bool _isRegistered) public {
//         // Additional logic and security checks as needed
//         mintyDatabase.addOrUpdatePlayer(_address, _steamID, _isValidator, _isRegistered);
//         emit PlayerOnboarded(_address, _steamID, _isValidator, _isRegistered);
//     }

//     // Additional functions and logic as required for onramping...
// }
