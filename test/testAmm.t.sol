//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/week3Amm.sol";
import "../src/tokens.sol";

contract AmmTest is Test {
    amm public Amm;
    StudyPoint public studypoint;
    CanteenToken public canteentoken;
    
    address public user = address(2);
    
    function setUp() public {
        Amm = new amm();
        studypoint = Amm.studyPoint();
        canteentoken = Amm.canteenToken();
    }
    
    function testMint() public {
        vm.prank(msg.sender);
        Amm.mint();        
        uint256 balance = sp.balanceOf(msg.sender);
        assertEq(balance, 100 ether);
    }
    
    function testMintOnlyOnce() public {
        vm.startPrank(msg.sender);
        Amm.mint();        
        vm.expectRevert(amm.amm_onlyRecieveOnetime.selector);
        Amm.mint();
        vm.stopPrank();
    }
    
    function testSwapWithoutApproval() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        
        vm.expectRevert();
        Amm.swapSpwithCt(10 ether);
        vm.stopPrank();
    }
    
    function testSwapWithApproval() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        
        sp.approve(address(Amm), 10 ether);
        Amm.swapSpwithCt(10 ether);
        
        uint256 ctBalance = ct.balanceOf(msg.sender);
        assert(ctBalance > 0);
        vm.stopPrank();
    }
    
    function testSwapInsufficientBalance() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        
        sp.approve(address(Amm), 200 ether);
        
        vm.expectRevert(amm.amm_insufficientBalance.selector);
        Amm.swapSpwithCt(200 ether);
        vm.stopPrank();
    }
    
    function testMultipleUsersCanMint() public {
        vm.prank(msg.sender);
        Amm.mint();
        
        vm.prank(user);
        Amm.mint();
        
        assertEq(sp.balanceOf(msg.sender), 100 ether);
        assertEq(sp.balanceOf(user), 100 ether);
    }
    
    function testSwapReducesReserves() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        
        sp.approve(address(Amm), 50 ether);
        Amm.swapSpwithCt(50 ether);
        
        uint256 ctReceived = ct.balanceOf(msg.sender);
        assert(ctReceived > 0);
        vm.stopPrank();
    }
    
    function testGetOutputAmount() public {
        uint256 output = Amm.getOutputAmount(10 ether);
        assert(output > 0);
    }
    
    function testSwapWithSmallAmount() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        
        sp.approve(address(Amm), 1 ether);
        Amm.swapSpwithCt(1 ether);
        
        uint256 ctBalance = ct.balanceOf(msg.sender);
        assert(ctBalance > 0);
        vm.stopPrank();
    }
    
    function testMultipleSwaps() public {
        vm.startPrank(msg.sender);
        Amm.mint();
        
        sp.approve(address(Amm), 100 ether);
        
        Amm.swapSpwithCt(10 ether);
        uint256 firstSwap = ct.balanceOf(msg.sender);
        
        Amm.swapSpwithCt(10 ether);
        uint256 secondSwap = ct.balanceOf(msg.sender);
        
        assert(secondSwap > firstSwap);
        vm.stopPrank();
    }
    
    function testInitialTokenAmount() public view {
        assertEq(Amm.initialToken(), 100 ether);
    }
    
    function testLiquidityPool() public view {
        assertEq(Amm.liquidityPool(), 0);
    }
}