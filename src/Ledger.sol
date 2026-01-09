//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Ledger {
    uint256 accountBalance;
    uint256 transactionCount;
    address owner;

    struct Transaction {
        string name;
        uint256 amount;
    }

    Transaction[] transactions;

    mapping(string => uint256) balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        accountBalance = 0;
        transactionCount = 0;
    }

    function Debit(
        string memory transactionPurpose,
        uint debitAmount
    ) public onlyOwner {
        transactions.push(Transaction(transactionPurpose, debitAmount));
        accountBalance -= debitAmount;
        transactionCount++;
        balances[transactionPurpose] = debitAmount;
    }

    function Credit(
        string memory transactionPurpose,
        uint256 creditAmount
    ) public onlyOwner {
        transactions.push(Transaction(transactionPurpose, creditAmount));
        accountBalance += creditAmount;
        transactionCount++;
        balances[transactionPurpose] = creditAmount;
    }

    function getBalance() public view onlyOwner returns (uint256) {
        return accountBalance;
    }

    function getTransactionDetails(
        uint256 index
    ) public view onlyOwner returns (string memory, uint256) {
        require(index - 1 < transactionCount, "Invalid transaction index");
        Transaction memory txn = transactions[index - 1];
        return (txn.name, txn.amount);
    }

    function getTransactionAmountByPurpose(
        string memory transactionPurpose
    ) public view onlyOwner returns (uint256) {
        return balances[transactionPurpose];
    }
}
