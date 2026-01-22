//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "lib/forge-std/src/Test.sol";
import "./week3Amm.sol";
import "./tokens.sol";
import "./DeployWeek3Amm.s.sol";

contract AmmTest is Test {
    amm public Amm;
    StudyPoint public studypoint;
    CanteenToken public canteentoken;
    DeployAmmScript public deployer;
    
    address public user = address(2);
    
    function setUp() public {
        deployer = new DeployAmmScript() ;  
        Amm = deployer.run();
        studypoint = Amm.studyPoint();
        canteentoken = Amm.canteenToken();
    }
    
    function testMint() public {
        vm.prank(msg.sender);
        Amm.mint();        
        uint256 balance = studypoint.balanceOf(msg.sender);
        assertEq(balance, 100 ether);
    }
    
    function testSwapWithoutApproval() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        vm.expectRevert();
        Amm.swapSpwithCt(25 ether);
        vm.stopPrank();
    }
    
    function testSwapWithApproval() public {
        vm.startPrank(msg.sender);
        Amm.mint();        
        studypoint.approve(address(Amm), 25 ether);
        Amm.swapSpwithCt(25 ether);        
        uint256 ctBalance = canteentoken.balanceOf(msg.sender);
        assert(ctBalance > 0);
        vm.stopPrank();
    }
    
    function testSwapInsufficientBalance() public {
        vm.startPrank(msg.sender);
        Amm.mint();        
        studypoint.approve(address(Amm), 200 ether);        
        vm.expectRevert(amm.amm_insufficientBalance.selector);
        Amm.swapSpwithCt(200 ether);
        vm.stopPrank();
    }
    
    function testMultipleUsersCanMint() public {
        vm.prank(msg.sender);
        Amm.mint();        
        vm.prank(user);
        Amm.mint();
        assertEq(studypoint.balanceOf(msg.sender), 100 ether);
        assertEq(studypoint.balanceOf(user), 100 ether);
    }
    
    function testchangedNoOfCtOutput() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        studypoint.approve(address(Amm), 50 ether);
        Amm.swapSpwithCt(50 ether);       
        uint256 ctReceived = canteentoken.balanceOf(msg.sender);
        vm.stopPrank() ;       
        vm.startPrank(user);
        Amm.mint();
        studypoint.approve(address(Amm), 50 ether);
        Amm.swapSpwithCt(50 ether);       
        uint256 ctReceivedUser = canteentoken.balanceOf(user);
        vm.stopPrank() ;
        assert(ctReceived > ctReceivedUser);

    }
    
    function testSwapReducesReserves() public {
        vm.startPrank(msg.sender);
        Amm.mint();       
        studypoint.approve(address(Amm), 50 ether);
        Amm.swapSpwithCt(50 ether);       
        uint256 ctReceived = canteentoken.balanceOf(msg.sender);
        assert(ctReceived > 0);
        vm.stopPrank();
    }
    
    function testGetOutputAmount() public {
        uint256 output = Amm.getOutputAmount(10 ether);
        assert(output > 0);
    }
    
    function testMultipleSwaps() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        studypoint.approve(address(Amm), 100 ether);       
        Amm.swapSpwithCt(10 ether);
        uint256 firstSwap = canteentoken.balanceOf(msg.sender);       
        Amm.swapSpwithCt(10 ether);
        uint256 secondSwap = canteentoken.balanceOf(msg.sender);        
        assert(secondSwap > firstSwap);
        vm.stopPrank();
    }
    
    function testInitialTokenAmount() public view {
        assertEq(Amm.initialToken(), 100 ether);
    }

    function testBalanceOfCt() public { vm.startPrank(msg.sender);
        vm.startPrank();
        uint256 expectedAmount =  Amm.getOutputAmount(50 ether);
        Amm.mint();
        studypoint.approve(address(Amm), 100 ether);       
        Amm.swapSpwithCt(50 ether);
        uint256 actualAmount = canteentoken.balanceOfCt(msg.sender);  
        assert (expectedAmount == actualAmount)     ;
    }
    
    function testBalanceOfSp() public { vm.startPrank(msg.sender);
    vm.startPrank();
    Amm.mint();
    studypoint.approve(address(Amm), 100 ether);       
    Amm.swapSpwithCt(50 ether);
    uint256 actualAmount = canteentoken.balanceOfSp(msg.sender);  
    assert (50 ether == actualAmount)     ;
    }
}