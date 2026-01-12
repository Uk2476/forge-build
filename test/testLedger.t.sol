//SPDX_License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Ledger} from "../src/Ledger.sol";

contract LedgerTest is Test {
    Ledger private ledger;

    function setUp() public {
        ledger = new Ledger();
    }

    function testCredit() public {
        ledger.Credit("Initial Deposit", 1000);
        uint256 balance = ledger.getBalance();
        assertEq(balance, 1000);
    }

    function testDebit() public {
        ledger.Credit("Initial Deposit", 1000);
        ledger.Debit("Bill Payment", 300);
        uint256 balance = ledger.getBalance();
        assertEq(balance, 700);
    }

    function testTransactionDetails() public {
        ledger.Credit("Initial Deposit", 1000);
        ledger.Debit("Bill Payment", 300);
        (string memory name, uint256 amount) = ledger.getTransactionDetails(1);
        assertEq(name, "Initial Deposit");
        assertEq(amount, 1000);
        (name, amount) = ledger.getTransactionDetails(2);
        assertEq(name, "Bill Payment");
        assertEq(amount, 300);
    }

    function testGetTransactionAmountByPurpose() public {
        ledger.Credit("Initial Deposit", 1000);
        uint256 amount = ledger.getTransactionAmountByPurpose(
            "Initial Deposit"
        );
        assertEq(amount, 1000);
    }

    function testInitialBalance() public {
        uint256 amount = ledger.getBalance();
        assertEq(amount, 0);
    }

    function testInvalidTransactionIndex() public {
        vm.expectRevert("Invalid transaction index");
        ledger.getTransactionDetails(1);
    }

    function testGetTransactionAmountByPurposeNonExistent() public {
        ledger.Credit("Initial Deposit", 1000);
        ledger.Debit("Bill Payment", 300);
        vm.expectRevert("No transaction found for the given purpose");
        ledger.getTransactionAmountByPurpose("Groceries");
    }
}
