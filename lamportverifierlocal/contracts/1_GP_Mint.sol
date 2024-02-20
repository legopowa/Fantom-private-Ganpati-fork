// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import "./LamportBase.sol"; // Adjust the path according to your project structure

// This is a full ERC20 token mint with Lamport permissions on which contract can mint it.
interface ILamportBase {
    function performLamportMasterCheck(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        bytes memory prepacked
    ) external returns (bool);
}

contract GP_Mint {

    ILamportBase public lamportBase;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    // Function to set the authorized minter (Step One)
    address private authorizedMinter;
    mapping(address => address) private proposedMinters; // Temporary storage for proposed minters

    event AuthorizedMinterSet(address indexed minter);
    event AuthorizedMinterRemoved(address indexed minter);
    constructor() {
        lamportBase = ILamportBase(
        _name = "GPGrens";
        _symbol = "GPG";
        _mint(0x239fA7623354eC26520dE878B52f13Fe84b06971, 80000 * (10 ** uint256(decimals())));  // Mint 80,000 tokens for the deployer
    }

    // Function to propose a new authorized minter (Step One)
    // function setAuthorizedMinterStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address minter
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(minter)
    //     )
    // {
    //     proposedMinters[msg.sender] = minter;
    // }
    function setAuthorizedMinterStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address minter
    ) public {
        // Encode the minter address to bytes
        bytes memory prepacked = abi.encodePacked(minter);

        // Perform the Lamport Master Check
        bool isAuthorized = performLamportMasterCheck(currentpub, sig, nextPKH, prepacked);

        // Ensure that the Lamport Master Check passed
        require(isAuthorized, "LamportBase: Authorization failed");

        proposedMinters[msg.sender] = minter;
    }
    // Function to confirm the authorized minter (Step Two)
    // function setAuthorizedMinterStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH,
    //     address minter
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(minter)
    //     )
    // {
    //     require(proposedMinters[msg.sender] == minter, "MyERC20: Minter address mismatch");
    //     require(authorizedMinter == address(0) || authorizedMinter == minter, "MyERC20: Another minter already set");
    //     authorizedMinter = minter;
    //     emit AuthorizedMinterSet(minter);

    //     // Clear the temporary storage
    //     delete proposedMinters[msg.sender];
    // }
    function setAuthorizedMinterStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH,
        address minter
    ) public {
        // Encode the minter address to bytes
        bytes memory prepacked = abi.encodePacked(minter);

        // Perform the Lamport Master Check
        bool isAuthorized = performLamportMasterCheck(currentpub, sig, nextPKH, prepacked);

        // Ensure that the Lamport Master Check passed
        require(isAuthorized, "LamportBase: Authorization failed");

        // Check that the proposed minter matches the minter in the current call
        require(proposedMinters[msg.sender] == minter, "MyERC20: Minter address mismatch");

        // Check if the authorized minter is either not set or matches the minter being set
        require(authorizedMinter == address(0) || authorizedMinter == minter, "MyERC20: Another minter already set");

        // Set the authorized minter
        authorizedMinter = minter;

        // Emit the event for setting the authorized minter
        emit AuthorizedMinterSet(minter);

        // Clear the temporary storage for the proposed minter
        delete proposedMinters[msg.sender];
    }

    // Step One: Propose to remove the minter
    // function removeAuthorizedMinterStepOne(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(authorizedMinter)
    //     )
    // {
    //     proposedMinters[msg.sender] = address(0);
    // }
    function removeAuthorizedMinterStepOne(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH
    ) public {
        // Encode the authorizedMinter address to bytes
        bytes memory prepacked = abi.encodePacked(authorizedMinter);

        // Perform the Lamport Master Check
        bool isAuthorized = performLamportMasterCheck(currentpub, sig, nextPKH, prepacked);

        // Ensure that the Lamport Master Check passed
        require(isAuthorized, "LamportBase: Authorization failed");

        // Set the proposed minter to the zero address
        proposedMinters[msg.sender] = address(0);
    }

    // Step Two: Confirm the removal of the minter
    // function removeAuthorizedMinterStepTwo(
    //     bytes32[2][256] calldata currentpub,
    //     bytes[256] calldata sig,
    //     bytes32 nextPKH
    // )
    //     public
    //     onlyLamportMaster(
    //         currentpub,
    //         sig,
    //         nextPKH,
    //         abi.encodePacked(address(0))
    //     )
    // {
    //     require(proposedMinters[msg.sender] == address(0), "MyERC20: No minter removal proposed");
    //     require(authorizedMinter != address(0), "MyERC20: No minter set");
    //     emit AuthorizedMinterRemoved(authorizedMinter);
    //     authorizedMinter = address(0);

    //     // Clear the temporary storage
    //     delete proposedMinters[msg.sender];
    // }
    function removeAuthorizedMinterStepTwo(
        bytes32[2][256] calldata currentpub,
        bytes[256] calldata sig,
        bytes32 nextPKH
    ) public {
        // Encode the zero address to bytes
        bytes memory prepacked = abi.encodePacked(address(0));

        // Perform the Lamport Master Check
        bool isAuthorized = performLamportMasterCheck(currentpub, sig, nextPKH, prepacked);

        // Ensure that the Lamport Master Check passed
        require(isAuthorized, "LamportBase: Authorization failed");

        // Check the conditions for removing the minter
        require(proposedMinters[msg.sender] == address(0), "GP_Mint: No minter removal proposed");
        require(authorizedMinter != address(0), "GP_Mint: No minter set");

        // Emit the AuthorizedMinterRemoved event
        emit AuthorizedMinterRemoved(authorizedMinter);

        // Set the authorizedMinter to the zero address
        authorizedMinter = address(0);

        // Clear the temporary storage
        delete proposedMinters[msg.sender];
    }

    // External function to mint tokens, callable by the authorized minter
    function mintTokens(address account, uint256 amount) external {
        require(msg.sender == authorizedMinter, "GP_Mint: Unauthorized minter");
        _mint(account, amount);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= value, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value <= _balances[from], "ERC20: transfer amount exceeds balance");
        require(value <= _allowances[from][msg.sender], "ERC20: transfer amount exceeds allowance");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(msg.sender == authorizedMinter, "GP_Mint: Unauthorized minter");
        _totalSupply += amount;
        _balances[account] += amount;
        //emit Minted(address(0), account, amount);
        emit Minted(msg.sender, account, amount);

    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Minted(address indexed minter, address indexed account, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
