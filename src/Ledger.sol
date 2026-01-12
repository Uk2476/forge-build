//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Ledger {
    uint256 accountBalance = 0;
    uint256 transactionCount = 0;

    struct Transaction {
        string name;
        uint256 amount;
    }

    event CreditAdded(string purpose, uint256 amount, uint256 newBalance);
    event DebitAdded(string purpose, uint256 amount, uint256 newBalance);

    Transaction[] transactions;

    mapping(string => uint256) balances;

    function Debit(string memory transactionPurpose, uint debitAmount) public {
        transactions.push(Transaction(transactionPurpose, debitAmount));
        accountBalance -= debitAmount;
        transactionCount++;
        balances[transactionPurpose] = debitAmount;
        emit DebitAdded(transactionPurpose, debitAmount, accountBalance);
    }

    function Credit(
        string memory transactionPurpose,
        uint256 creditAmount
    ) public {
        transactions.push(Transaction(transactionPurpose, creditAmount));
        accountBalance += creditAmount;
        transactionCount++;
        balances[transactionPurpose] = creditAmount;
        emit CreditAdded(transactionPurpose, creditAmount, accountBalance);
    }

    function getBalance() public view returns (uint256) {
        return accountBalance;
    }

    function getTransactionDetails(
        uint256 index
    ) public view returns (string memory, uint256) {
        require(index - 1 < transactionCount, "Invalid transaction index");
        Transaction memory txn = transactions[index - 1];
        return (txn.name, txn.amount);
    }

    function getTransactionAmountByPurpose(
        string memory transactionPurpose
    ) public view returns (uint256) {
        require(
            balances[transactionPurpose] != 0,
            "No transaction found for the given purpose"
        );
        return balances[transactionPurpose];
    }
}
