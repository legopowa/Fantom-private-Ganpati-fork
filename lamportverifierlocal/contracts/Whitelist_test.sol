// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISystemContract {
    function addToWhitelist(address _address, string calldata anonID) external;
    function setHourlyTxQuota(address _address, uint256 _quota) external;
    function removeFromWhitelist(address _address) external;
    function incrementMinutesPlayed(address user, uint256 _minutes) external;
}

contract WhitelistTest {
    ISystemContract systemContract;

    event OperationResult(bool success, string message);
    event ErrorCaught(string action, string error);


    constructor(address _systemContractAddress) {
        systemContract = ISystemContract(_systemContractAddress);
    }

    function addAddressToWhitelist(address _address, string memory anonID) public {
        try systemContract.addToWhitelist(_address, anonID) {
            emit OperationResult(true, "Address successfully whitelisted");
        } catch Error(string memory reason) {
            emit OperationResult(false, reason);
            emit ErrorCaught("addAddressToWhitelist", reason);
        } catch {
            emit OperationResult(false, "addToWhitelist failed without a specific revert reason");
            emit ErrorCaught("addAddressToWhitelist", "Unknown failure");
        }
    }

    function setQuotaForAddress(address _address, uint256 _quota) public {
        try systemContract.setHourlyTxQuota(_address, _quota) {
            emit OperationResult(true, "Hourly transaction quota set successfully");
        } catch Error(string memory reason) {
            emit OperationResult(false, reason);
            emit ErrorCaught("setHourlyTxQuota", reason);
        } catch {
            emit OperationResult(false, "setHourlyTxQuota failed without a specific revert reason");
            emit ErrorCaught("setHourlyTxQuota", "Unknown failure");
        }
    }

    function removeAddressFromWhitelist(address _address) public {
        try systemContract.removeFromWhitelist(_address) {
            emit OperationResult(true, "Address successfully removed from whitelist");
        } catch Error(string memory reason) {
            emit OperationResult(false, reason);
            emit ErrorCaught("removeFromWhitelist", reason);
        } catch {
            emit OperationResult(false, "removeFromWhitelist failed without a specific revert reason");
            emit ErrorCaught("removeFromWhitelist", "Unknown failure");
        }
    }

    function addMinutesPlayed(address user, uint256 _minutes) public {
        try systemContract.incrementMinutesPlayed(user, _minutes) {
            emit OperationResult(true, "Minutes played added successfully");
        } catch Error(string memory reason) {
            emit OperationResult(false, reason);
            emit ErrorCaught("addMinutesPlayed", reason);
        } catch {
            emit OperationResult(false, "incrementMinutesPlayed failed without a specific revert reason");
            emit ErrorCaught("addMinutesPlayed", "Unknown failure");
        }
    }
}