// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MultiSigWallet {
    address [] public owners;
    uint public requiredSignatures;
    uint public transactionCount;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint approvalCount;
    }

    mapping(uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public transactionApprovals;

    event Deposit(address indexed sender, uint amount);
    event SubmitTransaction(uint indexed txID, address indexed owner, address to, uint value, bytes data);
    event ApproveTransaction(uint indexed txID, address indexed owner);
    event RevokeApproval(uint indexed txID, address indexed owner);
    event ExecuteTransaction(uint indexed txID);
    event CancelTransaction(uint indexed txID);

    function isOwner(address ads) public view returns (bool) {
        for (uint i = 0; i< owners.length;i++){
            if (owners[i] == ads) {
                return true;
            }
        }
        return false;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not an owner");
        _;
    }

    modifier txExists(uint _txId) {
          require(_txId < transactionCount, "Transaction does not exist");
          _;
    }

    modifier notExecuted(uint _txId) {
          require(!transactions[_txId].executed, "Transaction already executed");
          _;
    }

    modifier notApproved(uint _txId) {
          require(!transactionApprovals[_txId][msg.sender], "Transaction already approved");
          _;
    }

    constructor(address[] memory _owners,uint _requiredSignatures) {
        require(_owners.length > 0, "Owners required");
        require(_requiredSignatures > 0 && _requiredSignatures <= _owners.length, "Invalid number of required signatures");

        for (uint i = 0; i< _owners.length;i++){
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner(owner), "Owner not unique");
            owners.push(owner);
        }

        requiredSignatures = _requiredSignatures;
    }

    receive() external payable {
          emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        uint txId = transactionCount;
        transactions[txId] = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            approvalCount: 0
        });
        transactionCount++;

        emit SubmitTransaction(txId, msg.sender, _to, _value, _data);
    }

    function approveTransaction(uint _txId) public onlyOwner txExists(_txId) notExecuted(_txId) notApproved(_txId) {
          Transaction storage transaction = transactions[_txId];
          transaction.approvalCount++;
          transactionApprovals[_txId][msg.sender] = true;

          emit ApproveTransaction(_txId, msg.sender);
    }

    function revokeApproval(uint _txId) public onlyOwner txExists(_txId) notExecuted(_txId) {
          require(transactionApprovals[_txId][msg.sender], "Transaction not approved");

          Transaction storage transaction = transactions[_txId];
          transaction.approvalCount--;
          transactionApprovals[_txId][msg.sender] = false;

          emit RevokeApproval(_txId, msg.sender);
    }

    function executeTransaction(uint _txId) public onlyOwner txExists(_txId) notExecuted(_txId) {
          Transaction storage transaction = transactions[_txId];
          require(transaction.approvalCount >= requiredSignatures, "Not enough approvals");

          transaction.executed = true;

          (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
          require(success, "Transaction execution failed");

          emit ExecuteTransaction(_txId);
    }

    function cancelTransaction(uint _txId) public onlyOwner txExists(_txId) notExecuted(_txId) {
          Transaction storage transaction = transactions[_txId];
          transaction.executed = true; // Mark as executed to prevent further actions

          emit CancelTransaction(_txId);
    }

}