// Copyright 2015 The go-ethereum Authors
// This file is part of the go-ethereum library.
//
// The go-ethereum library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-ethereum library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-ethereum library. If not, see <http://www.gnu.org/licenses/>.

package evmcore

import (
	"fmt"
	//"os"
	//encoding/hex"
	"bytes"
	"errors"
	"math"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/core/vm"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/log"
	"github.com/ethereum/go-ethereum/params"
)

var emptyCodeHash = crypto.Keccak256Hash(nil)

// var AnonIDContractAddress := common.HexToAddress(string(content))
var AnonIDContractAddress = common.HexToAddress("0x026b0BCF6328F50b63aE33997381aaB008433fc4")

//var AnonIDContractAddress = common.HexToAddress(string(os.ReadFile("./AnonIDContract.txt")))

// 0x4e97Cc6ABDC788da5f829fafF384cF237D1a5a97

var TheRockAddress common.Address = common.HexToAddress("0x2685751d3C7A49EbF485e823079ac65e2A35A3DD")

// this is so the coin claim function has a dummy whitelisted contract as sender

/*
The State Transitioning Model

A state transition is a change made when a transaction is applied to the current world state
The state transitioning model does all the necessary work to work out a valid new state root.

1) Nonce handling
2) Pre pay gas
3) Create a new state object if the recipient is \0*32
4) Value transfer
== If contract creation ==

	4a) Attempt to run transaction data
	4b) If valid, use result as code for the new state object

== end ==
5) Run Script section
6) Derive new state root
*/
type StateTransition struct {
	gp             *GasPool
	msg            Message
	gas            uint64
	gasPrice       *big.Int
	initialGas     uint64
	value          *big.Int
	data           []byte
	state          vm.StateDB
	evm            *vm.EVM
	contractCaller *ContractCaller
}

// Message represents a message sent to a contract.
type Message interface {
	From() common.Address
	To() *common.Address

	GasPrice() *big.Int
	GasFeeCap() *big.Int
	GasTipCap() *big.Int
	Gas() uint64
	Value() *big.Int

	Nonce() uint64
	IsFake() bool
	Data() []byte
	AccessList() types.AccessList
}

// ExecutionResult includes all output after executing given evm
// message no matter the execution itself is successful or not.
type ExecutionResult struct {
	UsedGas    uint64 // Total used gas but include the refunded gas
	Err        error  // Any error encountered during the execution(listed in core/vm/errors.go)
	ReturnData []byte // Returned data from evm(function result or data supplied with revert opcode)
}

// Unwrap returns the internal evm error which allows us for further
// analysis outside.
func (result *ExecutionResult) Unwrap() error {
	return result.Err
}

// Failed returns the indicator whether the execution is successful or not
func (result *ExecutionResult) Failed() bool { return result.Err != nil }

// Return is a helper function to help caller distinguish between revert reason
// and function return. Return returns the data after execution if no error occurs.
func (result *ExecutionResult) Return() []byte {
	if result.Err != nil {
		return nil
	}
	return common.CopyBytes(result.ReturnData)
}

// Revert returns the concrete revert reason if the execution is aborted by `REVERT`
// opcode. Note the reason can be nil if no data supplied with revert opcode.
func (result *ExecutionResult) Revert() []byte {
	if result.Err != vm.ErrExecutionReverted {
		return nil
	}
	return common.CopyBytes(result.ReturnData)
}

type ContractCaller struct {
	evm *vm.EVM
}

// Call executes a call to a contract, returning the result.
func (cc *ContractCaller) Call(from common.Address, contractAddress common.Address, data []byte, gas uint64) ([]byte, error) {
	if cc.evm == nil {
		return nil, errors.New("evm instance is not initialized")
	}

	// Define a call message.
	// msg := types.NewMessage(
	// 	from,                       // From
	// 	&contractAddress,           // To
	// 	0,                          // Nonce
	// 	big.NewInt(0),              // Value
	// 	gas,                        // GasLimit
	// 	big.NewInt(0),              // GasPrice
	// 	big.NewInt(0),              // GasFeeCap (EIP-1559)
	// 	big.NewInt(0),              // GasTipCap (EIP-1559)
	// 	data,                       // Data
	// 	nil,                        // AccessList (you might need to provide a valid one if necessary)
	// 	false,                      // CheckNonce
	// )

	// Use the EVM's Call method to get the result.
	ret, _, err := cc.evm.Call(vm.AccountRef(from), contractAddress, data, gas, big.NewInt(0))
	return ret, err
}

// IntrinsicGas computes the 'intrinsic gas' for a message with the given data.
func IntrinsicGas(data []byte, accessList types.AccessList, isContractCreation bool) (uint64, error) {
	// Set the starting gas for the raw transaction
	var gas uint64
	if isContractCreation {
		gas = params.TxGasContractCreation
	} else {
		gas = params.TxGas
	}
	// Bump the required gas by the amount of transactional data
	if len(data) > 0 {
		// Zero and non-zero bytes are priced differently
		var nz uint64
		for _, byt := range data {
			if byt != 0 {
				nz++
			}
		}
		// Make sure we don't exceed uint64 for all data combinations
		if (math.MaxUint64-gas)/params.TxDataNonZeroGasEIP2028 < nz {
			return 0, vm.ErrOutOfGas
		}
		gas += nz * params.TxDataNonZeroGasEIP2028

		z := uint64(len(data)) - nz
		if (math.MaxUint64-gas)/params.TxDataZeroGas < z {
			return 0, ErrGasUintOverflow
		}
		gas += z * params.TxDataZeroGas
	}
	if accessList != nil {
		gas += uint64(len(accessList)) * params.TxAccessListAddressGas
		gas += uint64(accessList.StorageKeys()) * params.TxAccessListStorageKeyGas
	}
	return gas, nil
}

// NewStateTransition initialises and returns a new state transition object.
//
//	func NewStateTransition(evm *vm.EVM, msg Message, gp *GasPool) *StateTransition {
//		st.contractCaller = &ContractCaller{evm: st.evm}
//		return &StateTransition{
//			gp:       gp,
//			evm:      evm,
//			msg:      msg,
//			gasPrice: msg.GasPrice(),
//			value:    msg.Value(),
//			data:     msg.Data(),
//			state:    evm.StateDB,
//		}
//	}
//
// NewStateTransition initialises and returns a new state transition object.
func NewStateTransition(evm *vm.EVM, msg Message, gp *GasPool) *StateTransition {
	st := &StateTransition{
		gp:       gp,
		evm:      evm,
		msg:      msg,
		gasPrice: msg.GasPrice(),
		value:    msg.Value(),
		data:     msg.Data(),
		state:    evm.StateDB,
	}
	st.contractCaller = &ContractCaller{evm: st.evm}
	return st
}

// ApplyMessage computes the new state by applying the given message
// against the old state within the environment.
//
// ApplyMessage returns the bytes returned by any EVM execution (if it took place),
// the gas used (which includes gas refunds) and an error if it failed. An error always
// indicates a core error meaning that the message would always fail for that particular
// state and would never be accepted within a block.
func ApplyMessage(evm *vm.EVM, msg Message, gp *GasPool) (*ExecutionResult, error) {
	res, err := NewStateTransition(evm, msg, gp).TransitionDb()
	if err != nil {
		log.Debug("Tx skipped", "err", err)
	}
	return res, err
}

// to returns the recipient of the message.
func (st *StateTransition) to() common.Address {
	if st.msg == nil || st.msg.To() == nil /* contract creation */ {
		return common.Address{}
	}
	return *st.msg.To()
}

func (st *StateTransition) buyGas() error {
	mgval := new(big.Int).SetUint64(st.msg.Gas())
	mgval = mgval.Mul(mgval, st.gasPrice)
	// Note: Opera doesn't need to check against gasFeeCap instead of gasPrice, as it's too aggressive in the asynchronous environment
	if have, want := st.state.GetBalance(st.msg.From()), mgval; have.Cmp(want) < 0 {
		return fmt.Errorf("%w: address %v have %v want %v", ErrInsufficientFunds, st.msg.From().Hex(), have, want)
	}
	if err := st.gp.SubGas(st.msg.Gas()); err != nil {
		return err
	}
	st.gas += st.msg.Gas()
	// muck around place
	//st.gas += 250000
	// Pad the address to 32 bytes

	//else st.gas = st.msg.Gas()
	//end muck around place
	st.initialGas = st.msg.Gas()
	st.state.SubBalance(st.msg.From(), mgval)
	return nil
}

func (st *StateTransition) preCheck() error {
	// Only check transactions that are not fake
	if !st.msg.IsFake() {
		// Make sure this transaction's nonce is correct.
		stNonce := st.state.GetNonce(st.msg.From())
		if msgNonce := st.msg.Nonce(); stNonce < msgNonce {
			return fmt.Errorf("%w: address %v, tx: %d state: %d", ErrNonceTooHigh,
				st.msg.From().Hex(), msgNonce, stNonce)
		} else if stNonce > msgNonce {
			return fmt.Errorf("%w: address %v, tx: %d state: %d", ErrNonceTooLow,
				st.msg.From().Hex(), msgNonce, stNonce)
		}
		// Make sure the sender is an EOA
		if codeHash := st.state.GetCodeHash(st.msg.From()); codeHash != emptyCodeHash && codeHash != (common.Hash{}) {
			return fmt.Errorf("%w: address %v, codehash: %s", ErrSenderNoEOA,
				st.msg.From().Hex(), codeHash)
		}
	}
	//Note: Opera doesn't need to check gasFeeCap >= BaseFee, because it's already checked by epochcheck
	return st.buyGas()
}
func (st *StateTransition) internal() bool {
	zeroAddr := common.Address{}
	return st.msg.From() == zeroAddr
}

// TransitionDb will transition the state by applying the current message and
// returning the evm execution result with following fields.
//
// - used gas:
//      total gas used (including gas being refunded)
// - returndata:
//      the returned data from evm
// - concrete execution error:
//      various **EVM** error which aborts the execution,
//      e.g. ErrOutOfGas, ErrExecutionReverted
//
// However if any consensus issue encountered, return the error directly with
// nil evm execution result.

// ContractCaller allows for calling contract methods without state modification.

func (st *StateTransition) IsClaimTokensInvoked() bool {
	// Compute the function signature for claimTokens
	claimSignature := common.Hex2Bytes("142eb8c8")

	// Check the start of the transaction data
	return bytes.HasPrefix(st.msg.Data(), claimSignature)
}
func encodeUserAddress(userAddress common.Address) []byte {
	const functionABI = `[{"constant":false,"inputs":[{"name":"user","type":"address"}],"name":"lastClaim","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]`

	parsedABI, err := abi.JSON(strings.NewReader(functionABI))
	if err != nil {
		//fmt.Errorf("Failed to parse ABI: %v", err)
	}

	encodedData, err := parsedABI.Pack("lastClaim", userAddress)
	if err != nil {
		//fmt.Errorf("Failed to ABI encode: %v", err)
	}

	return encodedData
}
func (st *StateTransition) ProcessClaimTokens() error {
	//var TheRockAddress common.Address = common.HexToAddress("0x2685751d3C7A49EbF485e823079ac65e2A35A3DD")
	//var AnonIDContractAddress = common.HexToAddress("0x4e97Cc6ABDC788da5f829fafF384cF237D1a5a97")
	userAddress := st.msg.From()
	//commission address should be result from commissionAddress() of above contract
	//encodedUserAddress := encodeUserAddress(userAddress)
	//hash function sig *
	// Fetch the values from the AnonID contract

	paddedAddress := common.LeftPadBytes(st.msg.From().Bytes(), 32)

	//Function signature of isWhitelisted(address)
	functionSignature := common.Hex2Bytes("5c16e15e") // This is the hex representation of the keccak256 hash of "lastClaim(address)"

	// Concatenate the function signature with the padded address
	data := append(functionSignature, paddedAddress...)

	lastClaim, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, data, st.gas)
	if err != nil {
		//return fmt.Errorf("failed to fetch lastClaim: %v", err)
	}
	paddedAddress2 := common.LeftPadBytes(st.msg.From().Bytes(), 32)

	//Function signature of isWhitelisted(address)
	functionSignature2 := common.Hex2Bytes("4fbbc63f") // This is the hex representation of the keccak256 hash of "lastLastClaim(address))"

	// Concatenate the function signature with the padded address
	data2 := append(functionSignature2, paddedAddress2...)

	lastlastClaim, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, data2, st.gas)
	if err != nil {
		//return fmt.Errorf("failed to fetch lastlastClaim: %v", err)
	}

	lastClaimInt := new(big.Int).SetBytes(lastClaim)
	lastlastClaimInt := new(big.Int).SetBytes(lastlastClaim)
	amountToMint := new(big.Int).Sub(lastClaimInt, lastlastClaimInt)
	// Define a new *big.Int for 10^18
	weiMultiplier := new(big.Int)
	weiMultiplier.SetString("1000000000000000000", 10) // 10^18

	// Multiply amountToMint by 10^18 to convert it to Wei
	amountToMintInWei := new(big.Int).Mul(amountToMint, weiMultiplier)
	functionSignature3 := common.Hex2Bytes("8705d945")
	// Fetch the coinCommission from the AnonID contract
	coinCommissionBytes, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, functionSignature3, st.gas)
	if err != nil {
		//return fmt.Errorf("failed to fetch coinCommission: %v", err)
	}
	coinCommission := new(big.Int).SetBytes(coinCommissionBytes)

	// Calculate the commission amount
	commissionAmount := new(big.Int).Mul(amountToMintInWei, coinCommission)
	commissionAmount = commissionAmount.Div(commissionAmount, big.NewInt(100)) // Assuming coinCommission is in percentage

	// Deduct commission from amountToMint and add to the AnonID contract
	amountToMintInWei.Sub(amountToMintInWei, commissionAmount)

	functionSignature4 := common.Hex2Bytes("931742d3")
	// this calls commissionAddress() of AnonIDContract
	// byteAddress, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, functionSignature4, st.gas)
	// if err != nil {
	//     // Handle the error
	//     return fmt.Errorf("Error calling contract: %v", err)
	// }
	byteAddress, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, functionSignature4, st.gas)
	//if err == nil {
	// Including the variables in the error message
	//return fmt.Errorf("Error calling contract with TheRockAddress: %v, AnonIDContractAddress: %v, functionSignature: %x, gas: %v - Error: %v, byteAddress %v %v",
	//					  TheRockAddress, AnonIDContractAddress, functionSignature4, st.gas, err, byteAddress)
	//}

	// // Open the file for writing
	// file, fileErr := os.Create("/home/devbox4/Desktop/byteAddress.txt")
	// if fileErr != nil {
	// 	// handle file error
	// 	//return
	// }
	// defer file.Close()

	// // Write byteAddress in %s and %v format
	// _, err = fmt.Fprintf(file, "String format: %s\n", string(byteAddress))
	// if err != nil {
	// 	// handle error
	// }
	// _, err = fmt.Fprintf(file, "Default format: %v\n", byteAddress)
	// if err != nil {
	// 	// handle error
	// }

	// // Write byteAddress in binary format (%b)
	// _, err = fmt.Fprint(file, "Binary format: ")
	// if err != nil {
	// 	// handle error
	// }
	// for _, b := range byteAddress {
	// 	_, err = fmt.Fprintf(file, "%08b ", b)
	// 	if err != nil {
	// 		// handle error
	// 		break
	// 	}
	// }
	// _, err = fmt.Fprint(file, "\n")
	// if err != nil {
	// 	// handle error
	// }
	// Assuming the address is in the first 20 bytes of the returned data
	if len(byteAddress) >= 20 {
		// Convert the bytes to an Ethereum address
		commissionAddress := common.BytesToAddress(byteAddress[12:])

		// Now you can use this address in AddBalance
		st.state.AddBalance(commissionAddress, commissionAmount)
	} else {
		// Handle the case where the byte slice is too short
		return fmt.Errorf("Returned data is too short to be an address")
	}

	// Mint the tokens to the user's address
	st.state.AddBalance(userAddress, amountToMintInWei)

	// Note: You'll need to reflect these changes in the smart contract as well.
	// The contract functions should be called with the correct parameters.

	return nil
}

func (st *StateTransition) TransitionDb() (*ExecutionResult, error) {
	// First check this message satisfies all consensus rules before
	// applying the message. The rules include these clauses
	//
	// 1. the nonce of the message caller is correct
	// 2. caller has enough balance to cover transaction fee(gaslimit * gasprice)
	// 3. the amount of gas required is available in the block
	// 4. the purchased gas is enough to cover intrinsic usage
	// 5. there is no overflow when calculating intrinsic gas

	// Note: insufficient balance for **topmost** call isn't a consensus error in Opera, unlike Ethereum
	// Such transaction will revert and consume sender's gas

	// Check clauses 1-3, buy gas if everything is correct
	if err := st.preCheck(); err != nil {
		return nil, err
	}
	msg := st.msg
	sender := vm.AccountRef(msg.From())
	contractCreation := msg.To() == nil

	london := st.evm.ChainConfig().IsLondon(st.evm.Context.BlockNumber)

	// Check clauses 4-5, subtract intrinsic gas if everything is correct
	gas, err := IntrinsicGas(st.data, st.msg.AccessList(), contractCreation)
	if err != nil {
		return nil, err
	}
	if st.gas < gas {
		return nil, fmt.Errorf("%w: have %d, want %d", ErrIntrinsicGas, st.gas, gas)
	}
	st.gas -= gas

	// Set up the initial access list.
	if rules := st.evm.ChainConfig().Rules(st.evm.Context.BlockNumber); rules.IsBerlin {
		st.state.PrepareAccessList(msg.From(), msg.To(), vm.ActivePrecompiles(rules), msg.AccessList())
	}

	var (
		ret   []byte
		vmerr error // vm errors do not effect consensus and are therefore not assigned to err
	)
	if contractCreation {
		ret, _, st.gas, vmerr = st.evm.Create(sender, st.data, st.gas, st.value)
	} else {
		// Increment the nonce for the next transaction
		st.state.SetNonce(msg.From(), st.state.GetNonce(sender.Address())+1)
		ret, st.gas, vmerr = st.evm.Call(sender, st.to(), st.data, st.gas, st.value)
	}
	// use 10% of not used gas
	if !st.internal() {
		st.gas -= st.gas / 10
	}

	if !london {
		// Before EIP-3529: refunds were capped to gasUsed / 2
		st.refundGas(params.RefundQuotient)
	} else {
		// After EIP-3529: refunds are capped to gasUsed / 5
		st.refundGas(params.RefundQuotientEIP3529)
	}

	return &ExecutionResult{
		UsedGas:    st.gasUsed(),
		Err:        vmerr,
		ReturnData: ret,
	}, nil
}

func (st *StateTransition) refundGas(refundQuotient uint64) {
	// Apply refund counter, capped to a refund quotient
	paddedAddress := common.LeftPadBytes(st.msg.From().Bytes(), 32)

	//Function signature of isWhitelisted(address)
	functionSignature := common.Hex2Bytes("3af32abf") // This is the hex representation of the keccak256 hash of "isWhitelisted(address)"

	// Concatenate the function signature with the padded address
	data := append(functionSignature, paddedAddress...)

	// Call the isWhitelisted function on the contract
	//var AnonIDContractAddress = common.HexToAddress("0x4e97Cc6ABDC788da5f829fafF384cF237D1a5a97")
	isWhitelisted, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, data, st.gas)
	if err != nil {
		//errMsg := fmt.Sprintf("Failed to check if address is whitelisted: %v. From: %v, Contract Address: %v, Data: %v, Gas: %v, isWhitelisted: %v",
		//	err, st.msg.From().Hex(), AnonIDContractAddress.Hex(), common.Bytes2Hex(data), st.gas, isWhitelisted)
		//return fmt.Errorf(errMsg)

	}

	//// this works
	// functionSignature := common.Hex2Bytes("931742d3")

	// // Contract address
	// contractAddress := common.HexToAddress("0xA527F50706BB1FCaEd6F864afB2e3FCe4943AF68")

	// // Call the commissionAddress function on the contract
	// commissionAddress, err := st.contractCaller.Call(st.msg.From(), contractAddress, functionSignature, st.gas)
	// if err != nil || len(commissionAddress) != 0 {
	// 	// Handle the error or the empty return here
	// 	addressString := hex.EncodeToString(commissionAddress)

	// 	return fmt.Errorf(addressString)
	// }
	//// up to here

	if len(isWhitelisted) == 32 && isWhitelisted[31] == 1 {
		//return fmt.Errorf("gime error")
		st.state.AddBalance(st.msg.From(), big.NewInt(10))
		if st.IsClaimTokensInvoked() {
			// If so, handle the claim logic
			st.state.AddBalance(st.msg.From(), big.NewInt(1))
			err := st.ProcessClaimTokens()
			if err != nil {

				st.state.AddBalance(st.msg.From(), big.NewInt(5))
				// Handle error, revert transaction or whatever behavior you want
			}
		}
		// Check if the transaction is free
		// did gpt3 do this shit wtf
		// paddedAddress2 := common.LeftPadBytes(st.msg.From().Bytes(), 32)

		// functionSignature2 := common.Hex2Bytes("8775b01f")

		// data2 := append(functionSignature2, paddedAddress2...)

		// isFree, err := st.contractCaller.Call(st.evm.Context.Coinbase, st.msg.From(), data2, st.gas)
		// if err == nil {
		// 	return fmt.Errorf("failed to check if the transaction is free: %v. Details: {Coinbase: %s, From: %v, isFree: %v, Gas: %d}", err, st.evm.Context.Coinbase.Hex(), st.msg.From().Hex(), isFree, st.gas)

		// 	//return fmt.Errorf("failed to check if the transaction is free: %v", err)
		// }
		paddedAddress2 := common.LeftPadBytes(st.msg.From().Bytes(), 32)

		functionSignature2 := common.Hex2Bytes("8775b01f") // Replace with the correct signature for 'isThisTxFree'

		data2 := append(functionSignature2, paddedAddress2...)

		// Your existing call, but with TheRockAddress as the sender
		isFree, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, data2, st.gas)

		// file, fileErr := os.Create("/home/devbox4/Desktop/isFree.txt")
		// if fileErr != nil {
		// 	// Handle file error
		// 	//fmt.Println("Error opening file:", fileErr)
		// 	//return
		// }
		// defer file.Close()

		// // Write formatted string to file
		// // Adjust the formatting as per the types of isFree and err
		// _, writeErr := fmt.Fprintf(file, "%s, %v, %d\n", isFree, isFree[31], isFree[31])
		// if writeErr != nil {
		// 	// Handle writing error
		// 	//fmt.Println("Error writing to file:", writeErr)
		// 	//return
		// }
		// file.Close()

		if err != nil {
			//errMsg := fmt.Sprintf("Failed to check if the transaction is free: %v. Details: {TheRock: %s, From: %s, Gas: %d, Data: %s, isFree: %v}",
			//	err, TheRockAddress.Hex(), st.msg.From().Hex(), st.gas, common.Bytes2Hex(data2), isFree)
			//return fmt.Errorf(errMsg)
			st.state.AddBalance(st.msg.From(), big.NewInt(100))
		}

		if len(isFree) == 32 && isFree[31] == 0 {
			//if isFree[31] == 0 {
			st.state.AddBalance(st.msg.From(), big.NewInt(1000))

		}
		if len(isFree) == 32 && isFree[31] == 1 {
			//if isFree[31] == 1 {
			st.state.AddBalance(st.msg.From(), big.NewInt(10000))

			functionSignature3 := common.Hex2Bytes("b889b2b7")
			freeGasCapBytes, err := st.contractCaller.Call(TheRockAddress, AnonIDContractAddress, functionSignature3, st.gas)
			if err != nil {

				//hexStr := hex.EncodeToString(freeGasCapBytes)
				//return fmt.Errorf("%v checking freeGasCapBytes: %s", err, hexStr)
			}
			freeGasCap := new(big.Int).SetBytes(freeGasCapBytes).Uint64()

			// Set the gas of the state transition object to the fetched freeGasFee
			// but respect the freeGasCap
			if st.gasUsed() <= freeGasCap {
				st.state.AddBalance(st.msg.From(), big.NewInt(100000))
				//st.gas = freeGasCap
				//st.gas = st.msg.Gas()
				//gasBigInt := new(big.Int).SetUint64(st.msg.Gas())
				//zerogas := new(big.Int).Mul(new(big.Int).SetUint64(st.msg.Gas()), st.msg.GasPrice())
				//zerogas := st.gasUsed()
				//zerogas := st.gas//st.state.AddBalance(st.msg.From(), refund)
				//st.gas += st.msg.Gas()//st.state.SubBalance(st.msg.From(), zerogas)
				//
				//return nil
				//return fmt.Errorf("DID I JUST GET PAID AGAIN")
				zerogas := st.gasUsed()
				st.gas += zerogas
				remaining := new(big.Int).Mul(new(big.Int).SetUint64(st.gas), st.gasPrice)

				st.state.AddBalance(st.msg.From(), remaining)
				st.gp.AddGas(st.gas)

			}
			//return nil // Skip the buyGas if transaction is free for whitelisted
		}
	} else {
		refund := st.gasUsed() / refundQuotient
		if refund > st.state.GetRefund() {
			refund = st.state.GetRefund()
		}
		st.gas += refund

		// Return wei for remaining gas, exchanged at the original rate.
		remaining := new(big.Int).Mul(new(big.Int).SetUint64(st.gas), st.gasPrice)
		st.state.AddBalance(st.msg.From(), remaining)

		// Also return remaining gas to the block gas counter so it is
		// available for the next transaction.
		st.gp.AddGas(st.gas)
	}
}

// gasUsed returns the amount of gas used up by the state transition.
func (st *StateTransition) gasUsed() uint64 {
	return st.initialGas - st.gas
}
