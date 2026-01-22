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

    StudyPoint public studyPoint;
    CanteenToken public canteenToken;

    

    constructor () {
        initialToken = 100 ether ;
        reserveCt = 2500 ether ;
        reserveSP = 4000 ether ;
        studyPoint = new StudyPoint(reserveSP + 2000 ether);
        canteenToken = new CanteenToken(reserveCt);
    }

    function mint() public {
        studyPoint.transfer(msg.sender , initialToken);
    }
 
    function swapSpwithCt(uint256 SpToBeSwappedWithCt) public {
        if(studyPoint.balanceOf(msg.sender) < SpToBeSwappedWithCt){
            revert amm_insufficientBalance() ;
        }
        liquidityPool = reserveCt * reserveSP ;
        CtSwapped = reserveCt - (liquidityPool/(reserveSP + SpToBeSwappedWithCt)) ;
        if(CtSwapped==0 || CtSwapped > reserveCt){
            revert amm_InsufficientLiquidity();
        }
    //first approve the transaction in contract studypoints 
        bool transaction1 = studyPoint.transferFrom(msg.sender , address (this) , SpToBeSwappedWithCt);
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

    function balanceOfCt() public view returns (uint256) {
        return canteenToken.balanceOf(msg.sender);
    }

    function balanceOfSp() public view returns (uint256) {
        return studyPoint.balanceOf(msg.sender);
    }


}