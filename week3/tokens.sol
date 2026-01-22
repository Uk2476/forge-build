//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StudyPoint is ERC20 {
    error tokens_transactionFailed();

    constructor(uint256 initialSupply) ERC20("StudyPoint", "SP") {
        _mint(msg.sender, initialSupply);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender , amount);
    }

    function approval(address to ,uint256 amount) public {
        bool transaction = approve(to , amount);
        if (transaction == false){
            revert tokens_transactionFailed();
        }
    }
}

contract CanteenToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("CanteenToken", "CT") {
         _mint(msg.sender, initialSupply);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender , amount);
    }
}