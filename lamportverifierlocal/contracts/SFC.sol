// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface SFCI {
    function currentSealedEpoch() external view returns (uint256);

    function getEpochSnapshot(uint256) external view returns (uint256 endTime, uint256 epochFee, uint256 totalBaseRewardWeight, uint256 totalTxRewardWeight, uint256 _baseRewardPerSecond, uint256 totalStake, uint256 totalSupply);

    function getLockupInfo(address, uint256) external view returns (uint256 lockedStake, uint256 fromEpoch, uint256 endTime, uint256 duration);

    function getStake(address, uint256) external view returns (uint256);

    function getStashedLockupRewards(address, uint256) external view returns (uint256 lockupExtraReward, uint256 lockupBaseReward, uint256 unlockedReward);

    function getValidator(uint256) external view returns (uint256 status, uint256 deactivatedTime, uint256 deactivatedEpoch, uint256 receivedStake, uint256 createdEpoch, uint256 createdTime, address auth);

    function getValidatorID(address) external view returns (uint256);

    function getValidatorPubkey(uint256) external view returns (bytes memory);

    function getWithdrawalRequest(address, uint256, uint256) external view returns (uint256 epoch, uint256 time, uint256 amount);

    function isOwner() external view returns (bool);

    function lastValidatorID() external view returns (uint256);

    function minGasPrice() external view returns (uint256);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function slashingRefundRatio(uint256) external view returns (uint256);

    function stakeTokenizerAddress() external view returns (address);

    function stashedRewardsUntilEpoch(address, uint256) external view returns (uint256);

    function totalActiveStake() external view returns (uint256);

    function totalSlashedStake() external view returns (uint256);

    function totalStake() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function treasuryAddress() external view returns (address);

    function version() external pure returns (bytes3);

    function currentEpoch() external view returns (uint256);

    function updateConstsAddress(address v) external;

    function constsAddress() external view returns (address);

    function getEpochValidatorIDs(uint256 epoch) external view returns (uint256[] memory);

    function getEpochReceivedStake(uint256 epoch, uint256 validatorID) external view returns (uint256);

    function getEpochAccumulatedRewardPerToken(uint256 epoch, uint256 validatorID) external view returns (uint256);

    function getEpochAccumulatedUptime(uint256 epoch, uint256 validatorID) external view returns (uint256);

    function getEpochAccumulatedOriginatedTxsFee(uint256 epoch, uint256 validatorID) external view returns (uint256);

    function getEpochOfflineTime(uint256 epoch, uint256 validatorID) external view returns (uint256);

    function getEpochOfflineBlocks(uint256 epoch, uint256 validatorID) external view returns (uint256);

    function rewardsStash(address delegator, uint256 validatorID) external view returns (uint256);

    function getLockedStake(address delegator, uint256 toValidatorID) external view returns (uint256);

    function createValidator(bytes calldata pubkey) external payable;

    function getSelfStake(uint256 validatorID) external view returns (uint256);

    function delegate(uint256 toValidatorID) external payable;

    function undelegate(uint256 toValidatorID, uint256 wrID, uint256 amount) external;

    function isSlashed(uint256 validatorID) external view returns (bool);

    function withdraw(uint256 toValidatorID, uint256 wrID) external;

    function deactivateValidator(uint256 validatorID, uint256 status) external;

    function pendingRewards(address delegator, uint256 toValidatorID) external view returns (uint256);

    function stashRewards(address delegator, uint256 toValidatorID) external;

    function claimRewards(uint256 toValidatorID) external;

    function restakeRewards(uint256 toValidatorID) external;

    function updateBaseRewardPerSecond(uint256 value) external;

    function updateOfflinePenaltyThreshold(uint256 blocksNum, uint256 time) external;

    function updateSlashingRefundRatio(uint256 validatorID, uint256 refundRatio) external;

    function updateStakeTokenizerAddress(address addr) external;

    function updateTreasuryAddress(address v) external;

    function mintFTM(address receiver, uint256 amount, string calldata justification) external;

    function burnFTM(uint256 amount) external;

    function sealEpoch(uint256[] calldata offlineTime, uint256[] calldata offlineBlocks, uint256[] calldata uptimes, uint256[] calldata originatedTxsFee, uint256 epochGas) external;

    function sealEpochValidators(uint256[] calldata nextValidatorIDs) external;

    function isLockedUp(address delegator, uint256 toValidatorID) external view returns (bool);

    function getUnlockedStake(address delegator, uint256 toValidatorID) external view returns (uint256);

    function lockStake(uint256 toValidatorID, uint256 lockupDuration, uint256 amount) external;

    function relockStake(uint256 toValidatorID, uint256 lockupDuration, uint256 amount) external;

    function unlockStake(uint256 toValidatorID, uint256 amount) external returns (uint256);

    function initialize(uint256 sealedEpoch, uint256 _totalSupply, address nodeDriver, address lib, address consts, address _owner) external;

    function setGenesisValidator(address auth, uint256 validatorID, bytes calldata pubkey, uint256 status, uint256 createdEpoch, uint256 createdTime, uint256 deactivatedEpoch, uint256 deactivatedTime) external;

    function setGenesisDelegation(address delegator, uint256 toValidatorID, uint256 stake, uint256 lockedStake, uint256 lockupFromEpoch, uint256 lockupEndTime, uint256 lockupDuration, uint256 earlyUnlockPenalty, uint256 rewards) external;

    function updateVoteBookAddress(address v) external;

    function voteBookAddress(address v) external view returns (address);
}

// File: contracts/common/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) internal initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/sfc/NodeDriver.sol

pragma solidity ^0.5.0;






interface NodeDriverExecutable {
    function execute() external;
}

contract NodeDriverAuth is Initializable, Ownable {
    using SafeMath for uint256;

    SFCI internal sfc;
    NodeDriver internal driver;

    // Initialize NodeDriverAuth, NodeDriver and SFC in one call to allow fewer genesis transactions
    function initialize(address payable _sfc, address _driver, address _owner) external initializer {
        Ownable.initialize(_owner);
        driver = NodeDriver(_driver);
        sfc = SFCI(_sfc);
    }

    modifier onlySFC() {
        require(msg.sender == address(sfc), "caller is not the SFC contract");
        _;
    }

    modifier onlyDriver() {
        require(msg.sender == address(driver), "caller is not the NodeDriver contract");
        _;
    }

    function migrateTo(address newDriverAuth) external onlyOwner {
        driver.setBackend(newDriverAuth);
    }

    function _execute(address executable, address newOwner, bytes32 selfCodeHash, bytes32 driverCodeHash) internal {
        _transferOwnership(executable);
        NodeDriverExecutable(executable).execute();
        _transferOwnership(newOwner);
        //require(driver.backend() == address(this), "ownership of driver is lost");
        require(_getCodeHash(address(this)) == selfCodeHash, "self code hash doesn't match");
        require(_getCodeHash(address(driver)) == driverCodeHash, "driver code hash doesn't match");
    }

    function execute(address executable) external onlyOwner {
        _execute(executable, owner(), _getCodeHash(address(this)), _getCodeHash(address(driver)));
    }

    function mutExecute(address executable, address newOwner, bytes32 selfCodeHash, bytes32 driverCodeHash) external onlyOwner {
        _execute(executable, newOwner, selfCodeHash, driverCodeHash);
    }

    function incBalance(address acc, uint256 diff) external onlySFC {
        require(acc == address(sfc), "recipient is not the SFC contract");
        driver.setBalance(acc, address(acc).balance.add(diff));
    }

    function upgradeCode(address acc, address from) external onlyOwner {
        require(isContract(acc) && isContract(from), "not a contract");
        driver.copyCode(acc, from);
    }

    function copyCode(address acc, address from) external onlyOwner {
        driver.copyCode(acc, from);
    }

    function incNonce(address acc, uint256 diff) external onlyOwner {
        driver.incNonce(acc, diff);
    }

    function updateNetworkRules(bytes calldata diff) external onlyOwner {
        driver.updateNetworkRules(diff);
    }

    function updateMinGasPrice(uint256 minGasPrice) external onlySFC {
        driver.updateNetworkRules(bytes(strConcat("{\"Economy\":{\"MinGasPrice\":", uint256ToStr(minGasPrice), "}}")));
    }

    function updateNetworkVersion(uint256 version) external onlyOwner {
        driver.updateNetworkVersion(version);
    }

    function advanceEpochs(uint256 num) external onlyOwner {
        driver.advanceEpochs(num);
    }

    function updateValidatorWeight(uint256 validatorID, uint256 value) external onlySFC {
        driver.updateValidatorWeight(validatorID, value);
    }

    function updateValidatorPubkey(uint256 validatorID, bytes calldata pubkey) external onlySFC {
        driver.updateValidatorPubkey(validatorID, pubkey);
    }

    function setGenesisValidator(address _auth, uint256 validatorID, bytes calldata pubkey, uint256 status, uint256 createdEpoch, uint256 createdTime, uint256 deactivatedEpoch, uint256 deactivatedTime) external onlyDriver {
        sfc.setGenesisValidator(_auth, validatorID, pubkey, status, createdEpoch, createdTime, deactivatedEpoch, deactivatedTime);
    }

    function setGenesisDelegation(address delegator, uint256 toValidatorID, uint256 stake, uint256 lockedStake, uint256 lockupFromEpoch, uint256 lockupEndTime, uint256 lockupDuration, uint256 earlyUnlockPenalty, uint256 rewards) external onlyDriver {
        sfc.setGenesisDelegation(delegator, toValidatorID, stake, lockedStake, lockupFromEpoch, lockupEndTime, lockupDuration, earlyUnlockPenalty, rewards);
    }

    function deactivateValidator(uint256 validatorID, uint256 status) external onlyDriver {
        sfc.deactivateValidator(validatorID, status);
    }

    function sealEpochValidators(uint256[] calldata nextValidatorIDs) external onlyDriver {
        sfc.sealEpochValidators(nextValidatorIDs);
    }

    function sealEpoch(uint256[] calldata offlineTimes, uint256[] calldata offlineBlocks, uint256[] calldata uptimes, uint256[] calldata originatedTxsFee, uint256 usedGas) external onlyDriver {
        sfc.sealEpoch(offlineTimes, offlineBlocks, uptimes, originatedTxsFee, usedGas);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function decimalsNum(uint256 num) internal pure returns (uint256) {
        uint decimals;
        while (num != 0) {
            decimals++;
            num /= 10;
        }
        return decimals;
    }

    function uint256ToStr(uint256 num) internal pure returns (string memory) {
        if (num == 0) {
            return "0";
        }
        uint decimals = decimalsNum(num);
        bytes memory bstr = new bytes(decimals);
        uint strIdx = decimals - 1;
        while (num != 0) {
            bstr[strIdx] = byte(uint8(48 + num % 10));
            num /= 10;
            strIdx--;
        }
        return string(bstr);
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        string memory abc = new string(_ba.length + _bb.length + _bc.length);
        bytes memory babc = bytes(abc);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babc[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babc[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babc[k++] = _bc[i];
        }
        return string(babc);
    }

    function _getCodeHash(address addr) internal view returns (bytes32) {
        bytes32 codeHash;
        assembly {codeHash := extcodehash(addr)}
        return codeHash;
    }
}

contract NodeDriver is Initializable {
    uint256 private erased0;
    NodeDriverAuth internal backend;
    EVMWriter internal evmWriter;

    event UpdatedBackend(address indexed backend);

    function setBackend(address _backend) external onlyBackend {
        emit UpdatedBackend(_backend);
        backend = NodeDriverAuth(_backend);
    }

    modifier onlyBackend() {
        require(msg.sender == address(backend), "caller is not the backend");
        _;
    }

    event UpdateValidatorWeight(uint256 indexed validatorID, uint256 weight);
    event UpdateValidatorPubkey(uint256 indexed validatorID, bytes pubkey);

    event UpdateNetworkRules(bytes diff);
    event UpdateNetworkVersion(uint256 version);
    event AdvanceEpochs(uint256 num);

    function initialize(address _backend, address _evmWriterAddress) external initializer {
        backend = NodeDriverAuth(_backend);
        emit UpdatedBackend(_backend);
        evmWriter = EVMWriter(_evmWriterAddress);
    }

    function setBalance(address acc, uint256 value) external onlyBackend {
        evmWriter.setBalance(acc, value);
    }

    function copyCode(address acc, address from) external onlyBackend {
        evmWriter.copyCode(acc, from);
    }

    function swapCode(address acc, address with) external onlyBackend {
        evmWriter.swapCode(acc, with);
    }

    function setStorage(address acc, bytes32 key, bytes32 value) external onlyBackend {
        evmWriter.setStorage(acc, key, value);
    }

    function incNonce(address acc, uint256 diff) external onlyBackend {
        evmWriter.incNonce(acc, diff);
    }

    function updateNetworkRules(bytes calldata diff) external onlyBackend {
        emit UpdateNetworkRules(diff);
    }

    function updateNetworkVersion(uint256 version) external onlyBackend {
        emit UpdateNetworkVersion(version);
    }

    function advanceEpochs(uint256 num) external onlyBackend {
        emit AdvanceEpochs(num);
    }

    function updateValidatorWeight(uint256 validatorID, uint256 value) external onlyBackend {
        emit UpdateValidatorWeight(validatorID, value);
    }

    function updateValidatorPubkey(uint256 validatorID, bytes calldata pubkey) external onlyBackend {
        emit UpdateValidatorPubkey(validatorID, pubkey);
    }

    modifier onlyNode() {
        require(msg.sender == address(0), "not callable");
        _;
    }

    // Methods which are called only by the node

    function setGenesisValidator(address _auth, uint256 validatorID, bytes calldata pubkey, uint256 status, uint256 createdEpoch, uint256 createdTime, uint256 deactivatedEpoch, uint256 deactivatedTime) external onlyNode {
        backend.setGenesisValidator(_auth, validatorID, pubkey, status, createdEpoch, createdTime, deactivatedEpoch, deactivatedTime);
    }

    function setGenesisDelegation(address delegator, uint256 toValidatorID, uint256 stake, uint256 lockedStake, uint256 lockupFromEpoch, uint256 lockupEndTime, uint256 lockupDuration, uint256 earlyUnlockPenalty, uint256 rewards) external onlyNode {
        backend.setGenesisDelegation(delegator, toValidatorID, stake, lockedStake, lockupFromEpoch, lockupEndTime, lockupDuration, earlyUnlockPenalty, rewards);
    }

    function deactivateValidator(uint256 validatorID, uint256 status) external onlyNode {
        backend.deactivateValidator(validatorID, status);
    }

    function sealEpochValidators(uint256[] calldata nextValidatorIDs) external onlyNode {
        backend.sealEpochValidators(nextValidatorIDs);
    }

    function sealEpoch(uint256[] calldata offlineTimes, uint256[] calldata offlineBlocks, uint256[] calldata uptimes, uint256[] calldata originatedTxsFee) external onlyNode {
        backend.sealEpoch(offlineTimes, offlineBlocks, uptimes, originatedTxsFee, 841669690);
    }

    function sealEpochV1(uint256[] calldata offlineTimes, uint256[] calldata offlineBlocks, uint256[] calldata uptimes, uint256[] calldata originatedTxsFee, uint256 usedGas) external onlyNode {
        backend.sealEpoch(offlineTimes, offlineBlocks, uptimes, originatedTxsFee, usedGas);
    }
}

interface EVMWriter {
    function setBalance(address acc, uint256 value) external;

    function copyCode(address acc, address from) external;

    function swapCode(address acc, address with) external;

    function setStorage(address acc, bytes32 key, bytes32 value) external;

    function incNonce(address acc, uint256 diff) external;
}

// File: contracts/version/Version.sol

pragma solidity ^0.5.0;

/**
 * @dev Version contract gives the versioning information of the implementation contract
 */
contract Version {
    /**
     * @dev Returns the address of the current owner.
     */
    function version() public pure returns (bytes3) {
        // version 3.0.4
        return "304";
    }
}

// File: contracts/common/Decimal.sol

pragma solidity ^0.5.0;

library Decimal {
    // unit is used for decimals, e.g. 0.123456
    function unit() internal pure returns (uint256) {
        return 1e18;
    }
}

// File: contracts/sfc/ConstantsManager.sol

pragma solidity ^0.5.0;




contract ConstantsManager is Ownable {
    using SafeMath for uint256;

    // Minimum amount of stake for a validator, i.e., 500000 FTM
    uint256 public minSelfStake;
    // Maximum ratio of delegations a validator can have, say, 15 times of self-stake
    uint256 public maxDelegatedRatio;
    // The commission fee in percentage a validator will get from a delegation, e.g., 15%
    uint256 public validatorCommission;
    // The percentage of fees to burn, e.g., 20%
    uint256 public burntFeeShare;
    // The percentage of fees to transfer to treasury address, e.g., 10%
    uint256 public treasuryFeeShare;
    // The ratio of the reward rate at base rate (no lock), e.g., 30%
    uint256 public unlockedRewardRatio;
    // The minimum duration of a stake/delegation lockup, e.g. 2 weeks
    uint256 public minLockupDuration;
    // The maximum duration of a stake/delegation lockup, e.g. 1 year
    uint256 public maxLockupDuration;
    // the number of epochs that undelegated stake is locked for
    uint256 public withdrawalPeriodEpochs;
    // the number of seconds that undelegated stake is locked for
    uint256 public withdrawalPeriodTime;

    uint256 public baseRewardPerSecond;
    uint256 public offlinePenaltyThresholdBlocksNum;
    uint256 public offlinePenaltyThresholdTime;
    uint256 public targetGasPowerPerSecond;
    uint256 public gasPriceBalancingCounterweight;

    address private secondaryOwner_erased;

//    event SecondaryOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize() external initializer {
        Ownable.initialize(msg.sender);
    }

//    function setSecondaryOwner(address v) onlyOwner external {
//        emit SecondaryOwnershipTransferred(secondaryOwner, v);
//        secondaryOwner = v;
//    }

    function updateMinSelfStake(uint256 v) onlyOwner external {
        require(v >= 100000 * 1e18, "too small value");
        require(v <= 10000000 * 1e18, "too large value");
        minSelfStake = v;
    }

    function updateMaxDelegatedRatio(uint256 v) onlyOwner external {
        require(v >= Decimal.unit(), "too small value");
        require(v <= 31 * Decimal.unit(), "too large value");
        maxDelegatedRatio = v;
    }

    function updateValidatorCommission(uint256 v) onlyOwner external {
        require(v <= Decimal.unit() / 2, "too large value");
        validatorCommission = v;
    }

    function updateBurntFeeShare(uint256 v) onlyOwner external {
        require(v <= Decimal.unit() / 2, "too large value");
        burntFeeShare = v;
    }

    function updateTreasuryFeeShare(uint256 v) onlyOwner external {
        require(v <= Decimal.unit() / 2, "too large value");
        treasuryFeeShare = v;
    }

    function updateUnlockedRewardRatio(uint256 v) onlyOwner external {
        require(v >= (5 * Decimal.unit()) / 100, "too small value");
        require(v <= Decimal.unit() / 2, "too large value");
        unlockedRewardRatio = v;
    }

    function updateMinLockupDuration(uint256 v) onlyOwner external {
        require(v >= 86400, "too small value");
        require(v <= 86400 * 30, "too large value");
        minLockupDuration = v;
    }

    function updateMaxLockupDuration(uint256 v) onlyOwner external {
        require(v >= 86400 * 30, "too small value");
        require(v <= 86400 * 1460, "too large value");
        maxLockupDuration = v;
    }

    function updateWithdrawalPeriodEpochs(uint256 v) onlyOwner external {
        require(v >= 2, "too small value");
        require(v <= 100, "too large value");
        withdrawalPeriodEpochs = v;
    }

    function updateWithdrawalPeriodTime(uint256 v) onlyOwner external {
        require(v >= 86400, "too small value");
        require(v <= 30 * 86400, "too large value");
        withdrawalPeriodTime = v;
    }

    function updateBaseRewardPerSecond(uint256 v) onlyOwner external {
        require(v >= 0.5 * 1e18, "too small value");
        require(v <= 32 * 1e18, "too large value");
        baseRewardPerSecond = v;
    }

    function updateOfflinePenaltyThresholdTime(uint256 v) onlyOwner external {
        require(v >= 86400, "too small value");
        require(v <= 10 * 86400, "too large value");
        offlinePenaltyThresholdTime = v;
    }

    function updateOfflinePenaltyThresholdBlocksNum(uint256 v) onlyOwner external {
        require(v >= 100, "too small value");
        require(v <= 1000000, "too large value");
        offlinePenaltyThresholdBlocksNum = v;
    }

    function updateTargetGasPowerPerSecond(uint256 v) onlyOwner external {
        require(v >= 1000000, "too small value");
        require(v <= 500000000, "too large value");
        targetGasPowerPerSecond = v;
    }

    function updateGasPriceBalancingCounterweight(uint256 v) onlyOwner external {
        require(v >= 100, "too small value");
        require(v <= 10 * 86400, "too large value");
        gasPriceBalancingCounterweight = v;
    }
}

// File: contracts/sfc/SFCState.sol

pragma solidity ^0.5.0;




contract SFCState is Initializable, Ownable {
    using SafeMath for uint256;
    /**
     * @dev The staking for validation
     */
    struct Validator {
        uint256 status;
        uint256 deactivatedTime;
        uint256 deactivatedEpoch;

        uint256 receivedStake;
        uint256 createdEpoch;
        uint256 createdTime;

        address auth;
    }

    NodeDriverAuth internal node;

    struct Rewards {
        uint256 lockupExtraReward;
        uint256 lockupBaseReward;
        uint256 unlockedReward;
    }

    uint256 public currentSealedEpoch;
    mapping(uint256 => Validator) public getValidator;
    mapping(address => uint256) public getValidatorID;
    mapping(uint256 => bytes) public getValidatorPubkey;

    uint256 public lastValidatorID;
    uint256 public totalStake;
    uint256 public totalActiveStake;
    uint256 public totalSlashedStake;

    mapping(address => mapping(uint256 => Rewards)) internal _rewardsStash; // addr, validatorID -> Rewards

    mapping(address => mapping(uint256 => uint256)) public stashedRewardsUntilEpoch;

    struct WithdrawalRequest {
        uint256 epoch;
        uint256 time;

        uint256 amount;
    }

    mapping(address => mapping(uint256 => mapping(uint256 => WithdrawalRequest))) public getWithdrawalRequest;

    struct LockedDelegation {
        uint256 lockedStake;
        uint256 fromEpoch;
        uint256 endTime;
        uint256 duration;
    }

    mapping(address => mapping(uint256 => uint256)) public getStake;

    mapping(address => mapping(uint256 => LockedDelegation)) public getLockupInfo;

    mapping(address => mapping(uint256 => Rewards)) public getStashedLockupRewards;

    struct EpochSnapshot {
        mapping(uint256 => uint256) receivedStake;
        mapping(uint256 => uint256) accumulatedRewardPerToken;
        mapping(uint256 => uint256) accumulatedUptime;
        mapping(uint256 => uint256) accumulatedOriginatedTxsFee;
        mapping(uint256 => uint256) offlineTime;
        mapping(uint256 => uint256) offlineBlocks;

        uint256[] validatorIDs;

        uint256 endTime;
        uint256 epochFee;
        uint256 totalBaseRewardWeight;
        uint256 totalTxRewardWeight;
        uint256 baseRewardPerSecond;
        uint256 totalStake;
        uint256 totalSupply;
    }

    uint256 private erased0;
    uint256 public totalSupply;
    mapping(uint256 => EpochSnapshot) public getEpochSnapshot;

    uint256 private erased1;
    uint256 private erased2;

    mapping(uint256 => uint256) public slashingRefundRatio; // validator ID -> (slashing refund ratio)

    address public stakeTokenizerAddress;

    uint256 private erased3;
    uint256 private erased4;
    uint256 public minGasPrice;

    address public treasuryAddress;

    address internal libAddress;

    ConstantsManager internal c;

    address public voteBookAddress;
}

// File: contracts/sfc/SFCBase.sol

pragma solidity ^0.5.0;


contract SFCBase is SFCState {
    using SafeMath for uint256;

    uint256 internal constant OK_STATUS = 0;
    uint256 internal constant WITHDRAWN_BIT = 1;
    uint256 internal constant OFFLINE_BIT = 1 << 3;
    uint256 internal constant DOUBLESIGN_BIT = 1 << 7;
    uint256 internal constant CHEATER_MASK = DOUBLESIGN_BIT;

    event DeactivatedValidator(uint256 indexed validatorID, uint256 deactivatedEpoch, uint256 deactivatedTime);
    event ChangedValidatorStatus(uint256 indexed validatorID, uint256 status);

    function isNode(address addr) internal view returns (bool) {
        return addr == address(node);
    }

    modifier onlyDriver() {
        require(isNode(msg.sender), "caller is not the NodeDriverAuth contract");
        _;
    }

    function currentEpoch() public view returns (uint256) {
        return currentSealedEpoch + 1;
    }

    function _calcRawValidatorEpochTxReward(uint256 epochFee, uint256 txRewardWeight, uint256 totalTxRewardWeight) internal view returns (uint256) {
        if (txRewardWeight == 0) {
            return 0;
        }
        uint256 txReward = epochFee.mul(txRewardWeight).div(totalTxRewardWeight);
        // fee reward except burntFeeShare and treasuryFeeShare
        return txReward.mul(Decimal.unit() - c.burntFeeShare() - c.treasuryFeeShare()).div(Decimal.unit());
    }

    function _calcRawValidatorEpochBaseReward(uint256 epochDuration, uint256 _baseRewardPerSecond, uint256 baseRewardWeight, uint256 totalBaseRewardWeight) internal pure returns (uint256) {
        if (baseRewardWeight == 0) {
            return 0;
        }
        uint256 totalReward = epochDuration.mul(_baseRewardPerSecond);
        return totalReward.mul(baseRewardWeight).div(totalBaseRewardWeight);
    }

    function _mintNativeToken(uint256 amount) internal {
        // balance will be increased after the transaction is processed
        node.incBalance(address(this), amount);
        totalSupply = totalSupply.add(amount);
    }

    function sumRewards(Rewards memory a, Rewards memory b) internal pure returns (Rewards memory) {
        return Rewards(a.lockupExtraReward.add(b.lockupExtraReward), a.lockupBaseReward.add(b.lockupBaseReward), a.unlockedReward.add(b.unlockedReward));
    }

    function sumRewards(Rewards memory a, Rewards memory b, Rewards memory c) internal pure returns (Rewards memory) {
        return sumRewards(sumRewards(a, b), c);
    }

    function _scaleLockupReward(uint256 fullReward, uint256 lockupDuration) internal view returns (Rewards memory reward) {
        reward = Rewards(0, 0, 0);
        uint256 unlockedRewardRatio = c.unlockedRewardRatio();
        if (lockupDuration != 0) {
            uint256 maxLockupExtraRatio = Decimal.unit() - unlockedRewardRatio;
            uint256 lockupExtraRatio = maxLockupExtraRatio.mul(lockupDuration).div(c.maxLockupDuration());
            uint256 totalScaledReward = fullReward.mul(unlockedRewardRatio + lockupExtraRatio).div(Decimal.unit());
            reward.lockupBaseReward = fullReward.mul(unlockedRewardRatio).div(Decimal.unit());
            reward.lockupExtraReward = totalScaledReward - reward.lockupBaseReward;
        } else {
            reward.unlockedReward = fullReward.mul(unlockedRewardRatio).div(Decimal.unit());
        }
        return reward;
    }

    function _recountVotes(address delegator, address validatorAuth, bool strict) internal {
        if (voteBookAddress != address(0)) {
            // Don't allow recountVotes to use up all the gas
            (bool success,) = voteBookAddress.call.gas(8000000)(abi.encodeWithSignature("recountVotes(address,address)", delegator, validatorAuth));
            // Don't revert if recountVotes failed unless strict mode enabled
            require(success || !strict, "gov votes recounting failed");
        }
    }

    function _setValidatorDeactivated(uint256 validatorID, uint256 status) internal {
        if (getValidator[validatorID].status == OK_STATUS && status != OK_STATUS) {
            totalActiveStake = totalActiveStake.sub(getValidator[validatorID].receivedStake);
        }
        // status as a number is proportional to severity
        if (status > getValidator[validatorID].status) {
            getValidator[validatorID].status = status;
            if (getValidator[validatorID].deactivatedEpoch == 0) {
                getValidator[validatorID].deactivatedEpoch = currentEpoch();
                getValidator[validatorID].deactivatedTime = _now();
                emit DeactivatedValidator(validatorID, getValidator[validatorID].deactivatedEpoch, getValidator[validatorID].deactivatedTime);
            }
            emit ChangedValidatorStatus(validatorID, status);
        }
    }

    function _syncValidator(uint256 validatorID, bool syncPubkey) public {
        require(_validatorExists(validatorID), "validator doesn't exist");
        // emit special log for node
        uint256 weight = getValidator[validatorID].receivedStake;
        if (getValidator[validatorID].status != OK_STATUS) {
            weight = 0;
        }
        node.updateValidatorWeight(validatorID, weight);
        if (syncPubkey && weight != 0) {
            node.updateValidatorPubkey(validatorID, getValidatorPubkey[validatorID]);
        }
    }

    function _validatorExists(uint256 validatorID) view internal returns (bool) {
        return getValidator[validatorID].createdTime != 0;
    }

    function _calcValidatorCommission(uint256 rawReward, uint256 commission) internal pure returns (uint256)  {
        return rawReward.mul(commission).div(Decimal.unit());
    }

    function getLockedStake(address delegator, uint256 toValidatorID) public view returns (uint256) {
        if (!isLockedUp(delegator, toValidatorID)) {
            return 0;
        }
        return getLockupInfo[delegator][toValidatorID].lockedStake;
    }

    function isLockedUp(address delegator, uint256 toValidatorID) view public returns (bool) {
        return getLockupInfo[delegator][toValidatorID].endTime != 0 && getLockupInfo[delegator][toValidatorID].lockedStake != 0 && _now() <= getLockupInfo[delegator][toValidatorID].endTime;
    }

    function _now() internal view returns (uint256) {
        return block.timestamp;
    }
}

// File: contracts/sfc/GasPriceConstants.sol

pragma solidity ^0.5.0;


library GP {
    function trimGasPriceChangeRatio(uint256 x) internal pure returns (uint256) {
        if (x > Decimal.unit() * 105 / 100) {
            return Decimal.unit() * 105 / 100;
        }
        if (x < Decimal.unit() * 95 / 100) {
            return Decimal.unit() * 95 / 100;
        }
        return x;
    }

    function trimMinGasPrice(uint256 x) internal pure returns (uint256) {
        if (x > 1000000 * 1e9) {
            return 1000000 * 1e9;
        }
        if (x < 1e9) {
            return 1e9;
        }
        return x;
    }

    function initialMinGasPrice() internal pure returns (uint256) {
        return 100 * 1e9;
    }
}

// File: contracts/sfc/SFC.sol

pragma solidity ^0.5.0;




/**
 * @dev Stakers contract defines data structure and methods for validators / validators.
 */
contract SFC is SFCBase, Version {
    function _delegate(address implementation) internal {
        assembly {
        // Copy msg.data. We take full control of memory in this inline assembly
        // block because it will not return to Solidity code. We overwrite the
        // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

        // Call the implementation.
        // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

        // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
            // delegatecall returns 0 on error.
            case 0 {revert(0, returndatasize)}
            default {return (0, returndatasize)}
        }
    }

    function() payable external {
        require(msg.data.length != 0, "transfers not allowed");
        _delegate(libAddress);
    }

    event UpdatedBaseRewardPerSec(uint256 value);
    event UpdatedOfflinePenaltyThreshold(uint256 blocksNum, uint256 period);

    /*
    Constructor
    */

    function initialize(uint256 sealedEpoch, uint256 _totalSupply, address nodeDriver, address lib, address _c, address owner) external initializer {
        Ownable.initialize(owner);
        currentSealedEpoch = sealedEpoch;
        node = NodeDriverAuth(nodeDriver);
        libAddress = lib;
        c = ConstantsManager(_c);
        totalSupply = _totalSupply;
        minGasPrice = GP.initialMinGasPrice();
        getEpochSnapshot[sealedEpoch].endTime = _now();
    }

    function updateStakeTokenizerAddress(address addr) onlyOwner external {
        stakeTokenizerAddress = addr;
    }

    function updateLibAddress(address v) onlyOwner external {
        libAddress = v;
    }

    function updateTreasuryAddress(address v) onlyOwner external {
        treasuryAddress = v;
    }

    function updateConstsAddress(address v) onlyOwner external {
        c = ConstantsManager(v);
    }

    function constsAddress() external view returns (address) {
        return address(c);
    }

    function updateVoteBookAddress(address v) onlyOwner external {
        voteBookAddress = v;
    }

    /*
    Epoch callbacks
    */

    function _sealEpoch_offline(EpochSnapshot storage snapshot, uint256[] memory validatorIDs, uint256[] memory offlineTime, uint256[] memory offlineBlocks) internal {
        // mark offline nodes
        for (uint256 i = 0; i < validatorIDs.length; i++) {
            if (offlineBlocks[i] > c.offlinePenaltyThresholdBlocksNum() && offlineTime[i] >= c.offlinePenaltyThresholdTime()) {
                _setValidatorDeactivated(validatorIDs[i], OFFLINE_BIT);
                _syncValidator(validatorIDs[i], false);
            }
            // log data
            snapshot.offlineTime[validatorIDs[i]] = offlineTime[i];
            snapshot.offlineBlocks[validatorIDs[i]] = offlineBlocks[i];
        }
    }

    struct _SealEpochRewardsCtx {
        uint256[] baseRewardWeights;
        uint256 totalBaseRewardWeight;
        uint256[] txRewardWeights;
        uint256 totalTxRewardWeight;
        uint256 epochFee;
    }

    function _sealEpoch_rewards(uint256 epochDuration, EpochSnapshot storage snapshot, EpochSnapshot storage prevSnapshot, uint256[] memory validatorIDs, uint256[] memory uptimes, uint256[] memory accumulatedOriginatedTxsFee) internal {
        _SealEpochRewardsCtx memory ctx = _SealEpochRewardsCtx(new uint[](validatorIDs.length), 0, new uint[](validatorIDs.length), 0, 0);

        for (uint256 i = 0; i < validatorIDs.length; i++) {
            uint256 prevAccumulatedTxsFee = prevSnapshot.accumulatedOriginatedTxsFee[validatorIDs[i]];
            uint256 originatedTxsFee = 0;
            if (accumulatedOriginatedTxsFee[i] > prevAccumulatedTxsFee) {
                originatedTxsFee = accumulatedOriginatedTxsFee[i] - prevAccumulatedTxsFee;
            }
            // txRewardWeight = {originatedTxsFee} * {uptime}
            // originatedTxsFee is roughly proportional to {uptime} * {stake}, so the whole formula is roughly
            // {stake} * {uptime} ^ 2
            ctx.txRewardWeights[i] = originatedTxsFee * uptimes[i] / epochDuration;
            ctx.totalTxRewardWeight = ctx.totalTxRewardWeight.add(ctx.txRewardWeights[i]);
            ctx.epochFee = ctx.epochFee.add(originatedTxsFee);
        }

        for (uint256 i = 0; i < validatorIDs.length; i++) {
            // baseRewardWeight = {stake} * {uptime ^ 2}
            ctx.baseRewardWeights[i] = (((snapshot.receivedStake[validatorIDs[i]] * uptimes[i]) / epochDuration) * uptimes[i]) / epochDuration;
            ctx.totalBaseRewardWeight = ctx.totalBaseRewardWeight.add(ctx.baseRewardWeights[i]);
        }

        for (uint256 i = 0; i < validatorIDs.length; i++) {
            uint256 rawReward = _calcRawValidatorEpochBaseReward(epochDuration, c.baseRewardPerSecond(), ctx.baseRewardWeights[i], ctx.totalBaseRewardWeight);
            rawReward = rawReward.add(_calcRawValidatorEpochTxReward(ctx.epochFee, ctx.txRewardWeights[i], ctx.totalTxRewardWeight));

            uint256 validatorID = validatorIDs[i];
            address validatorAddr = getValidator[validatorID].auth;
            // accounting validator's commission
            uint256 commissionRewardFull = _calcValidatorCommission(rawReward, c.validatorCommission());
            uint256 selfStake = getStake[validatorAddr][validatorID];
            if (selfStake != 0) {
                uint256 lCommissionRewardFull = (commissionRewardFull * getLockedStake(validatorAddr, validatorID)) / selfStake;
                uint256 uCommissionRewardFull = commissionRewardFull - lCommissionRewardFull;
                Rewards memory lCommissionReward = _scaleLockupReward(lCommissionRewardFull, getLockupInfo[validatorAddr][validatorID].duration);
                Rewards memory uCommissionReward = _scaleLockupReward(uCommissionRewardFull, 0);
                _rewardsStash[validatorAddr][validatorID] = sumRewards(_rewardsStash[validatorAddr][validatorID], lCommissionReward, uCommissionReward);
                getStashedLockupRewards[validatorAddr][validatorID] = sumRewards(getStashedLockupRewards[validatorAddr][validatorID], lCommissionReward, uCommissionReward);
            }
            // accounting reward per token for delegators
            uint256 delegatorsReward = rawReward - commissionRewardFull;
            // note: use latest stake for the sake of rewards distribution accuracy, not snapshot.receivedStake
            uint256 receivedStake = getValidator[validatorID].receivedStake;
            uint256 rewardPerToken = 0;
            if (receivedStake != 0) {
                rewardPerToken = (delegatorsReward * Decimal.unit()) / receivedStake;
            }
            snapshot.accumulatedRewardPerToken[validatorID] = prevSnapshot.accumulatedRewardPerToken[validatorID] + rewardPerToken;

            snapshot.accumulatedOriginatedTxsFee[validatorID] = accumulatedOriginatedTxsFee[i];
            snapshot.accumulatedUptime[validatorID] = prevSnapshot.accumulatedUptime[validatorID] + uptimes[i];
        }

        snapshot.epochFee = ctx.epochFee;
        snapshot.totalBaseRewardWeight = ctx.totalBaseRewardWeight;
        snapshot.totalTxRewardWeight = ctx.totalTxRewardWeight;
        if (totalSupply > snapshot.epochFee) {
            totalSupply -= snapshot.epochFee;
        } else {
            totalSupply = 0;
        }

        // transfer 10% of fees to treasury
        if (treasuryAddress != address(0)) {
            uint256 feeShare = ctx.epochFee * c.treasuryFeeShare() / Decimal.unit();
            _mintNativeToken(feeShare);
            treasuryAddress.call.value(feeShare)("");
        }
    }


    function _sealEpoch_minGasPrice(uint256 epochDuration, uint256 epochGas) internal {
        // change minGasPrice proportionally to the difference between target and received epochGas
        uint256 targetEpochGas = epochDuration * c.targetGasPowerPerSecond() + 1;
        uint256 gasPriceDeltaRatio = epochGas * Decimal.unit() / targetEpochGas;
        uint256 counterweight = c.gasPriceBalancingCounterweight();
        // scale down the change speed (estimate gasPriceDeltaRatio ^ (epochDuration / counterweight))
        gasPriceDeltaRatio = (epochDuration * gasPriceDeltaRatio + counterweight * Decimal.unit()) / (epochDuration + counterweight);
        // limit the max/min possible delta in one epoch
        gasPriceDeltaRatio = GP.trimGasPriceChangeRatio(gasPriceDeltaRatio);

        // apply the ratio
        uint256 newMinGasPrice = minGasPrice * gasPriceDeltaRatio / Decimal.unit();
        // limit the max/min possible minGasPrice
        newMinGasPrice = GP.trimMinGasPrice(newMinGasPrice);
        // apply new minGasPrice
        minGasPrice = newMinGasPrice;
    }

    function sealEpoch(uint256[] calldata offlineTime, uint256[] calldata offlineBlocks, uint256[] calldata uptimes, uint256[] calldata originatedTxsFee, uint256 epochGas) external onlyDriver {
        EpochSnapshot storage snapshot = getEpochSnapshot[currentEpoch()];
        uint256[] memory validatorIDs = snapshot.validatorIDs;

        _sealEpoch_offline(snapshot, validatorIDs, offlineTime, offlineBlocks);
        {
            EpochSnapshot storage prevSnapshot = getEpochSnapshot[currentSealedEpoch];
            uint256 epochDuration = 1;
            if (_now() > prevSnapshot.endTime) {
                epochDuration = _now() - prevSnapshot.endTime;
            }
            _sealEpoch_rewards(epochDuration, snapshot, prevSnapshot, validatorIDs, uptimes, originatedTxsFee);
            _sealEpoch_minGasPrice(epochDuration, epochGas);
        }

        currentSealedEpoch = currentEpoch();
        snapshot.endTime = _now();
        snapshot.baseRewardPerSecond = c.baseRewardPerSecond();
        snapshot.totalSupply = totalSupply;
    }

    function sealEpochValidators(uint256[] calldata nextValidatorIDs) external onlyDriver {
        EpochSnapshot storage snapshot = getEpochSnapshot[currentEpoch()];
        // fill data for the next snapshot
        for (uint256 i = 0; i < nextValidatorIDs.length; i++) {
            uint256 validatorID = nextValidatorIDs[i];
            uint256 receivedStake = getValidator[validatorID].receivedStake;
            snapshot.receivedStake[validatorID] = receivedStake;
            snapshot.totalStake = snapshot.totalStake.add(receivedStake);
        }
        snapshot.validatorIDs = nextValidatorIDs;
        node.updateMinGasPrice(minGasPrice);
    }
}