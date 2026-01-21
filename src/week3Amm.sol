//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "./tokens.sol";

contract amm {
    error amm_onlyRecieveOnetime();
    error amm_insufficientBalance() ;
    error amm_InsufficientLiquidity();
    error amm_transactionFAiled();

    uint256 public initialToken ;
    uint256 reserveSP ;
    uint256 reserveCt ;
    uint256 public liquidityPool ;
    uint256 CtSwapped ;

    StudyPoint public studypoint;
    CanteenToken public canteenToken;

    mapping(address=> uint256) timesMinted;

    constructor () {
        initialToken = 100 ether ;
        reserveCt = 1500 ether ;
        reserveSP = 3000 ether ;
        studypoint = new StudyPoint(reserveSP + 1000 ether);
        canteenToken = new CanteenToken(reserveCt);
    }

    function mint() public {
        if(timesMinted[msg.sender] >= 1 ){
            revert amm_onlyRecieveOnetime();
        }
        bool firstTransaction = studypoint.transfer(msg.sender , initialToken);
        if( firstTransaction == true){
            timesMinted[msg.sender]++;
        }
    }
 
    function swapSpwithCt(uint256 SpToBeSwappedWithCt) public {
        if(studypoint.balanceOf(msg.sender) < SpToBeSwappedWithCt){
            revert amm_insufficientBalance() ;
        }
        liquidityPool = reserveCt * reserveSP ;
        CtSwapped = reserveCt - (liquidityPool/(reserveSP + SpToBeSwappedWithCt)) ;
        if(CtSwapped==0 || CtSwapped > reserveCt){
            revert amm_InsufficientLiquidity();
        }
        bool transaction1 = studypoint.transferFrom(msg.sender , address (this) , SpToBeSwappedWithCt);
        if (transaction1 == false){
            revert amm_transactionFAiled();
        }
        bool transaction2 = canteenToken.transfer(msg.sender , CtSwapped);
        if (transaction2 == false){
            revert amm_transactionFAiled();
        }
        reserveSP += SpToBeSwappedWithCt ;
        reserveCt -= CtSwapped ; 


    }

    function getOutputAmount(uint256 Sptoken) public view returns (uint256){
        uint256 Ctout ;
        Ctout = reserveCt - ((reserveCt * reserveSP)/(reserveSP + Sptoken)) ;
        require(Ctout != 0 && Ctout <= reserveCt, "Insufficient liquidity");        
        return Ctout;
    }
}