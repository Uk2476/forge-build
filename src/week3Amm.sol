//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "./week3studypoint.sol";

contract amm {
    error amm_onlyRecieveOnetime();
    error amm_insufficientBalance() ;

    uint256 public initialToken ;
    uint256 reserveSP ;
    uint256 reserveCt ;
    uint256 liquidityPool ;
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
        CtSwapped = 0 ;
        CtSwapped = reserveCt - (liquidityPool/(reserveSP + SpToBeSwappedWithCt)) ;
        reserveSP += SpToBeSwappedWithCt ;
        reserveCt -= CtSwapped ;
        canteenToken.mint(CtSwapped);
        studypoint.burn(SpToBeSwappedWithCt);
    }
}