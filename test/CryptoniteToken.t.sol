// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CryptoniteToken} from "../src/CryptoniteToken.sol";
import {Test, console} from "forge-std/Test.sol";

contract CryptoniteTokenTest is Test {
    CryptoniteToken token;
    address liquidityAddress = address(0x1);
    address teamAddress = address(0x2);
    address treasuryAddress = address(0x3);
    address yieldFarmingAddress = address(0x4);
    address userAddress = address(0x5);

    function setUp() public {
        token = new CryptoniteToken(
            liquidityAddress,
            teamAddress,
            treasuryAddress,
            yieldFarmingAddress
        );
    }

    function testInitialAllocation() public view {
        assertEq(
            token.balanceOf(liquidityAddress),
            token.LIQUIDITY_ALLOCATION()
        );
        assertEq(token.balanceOf(teamAddress), token.TEAM_ALLOCATION());
        assertEq(token.balanceOf(treasuryAddress), token.TREASURY_ALLOCATION());
        assertEq(
            token.balanceOf(yieldFarmingAddress),
            token.YIELD_FARMING_ALLOCATION()
        );
        assertEq(
            token.balanceOf(address(this)),
            token.IN_GAME_REWARDS_ALLOCATION()
        );
    }

    function testTransferWithBurn() public {
        uint256 amount = 1000 * 10 ** 18;
        uint256 burnAmount = (amount * token.burnRate()) / 100;
        uint256 sendAmount = amount - burnAmount;

        token.transfer(userAddress, amount);

        assertEq(token.balanceOf(userAddress), sendAmount);
        assertEq(token.totalSupply(), token.MAX_SUPPLY() - burnAmount);
    }

    function testTransferFromWithBurn() public {
        uint256 amount = 1000 * 10 ** 18;
        uint256 burnAmount = (amount * token.burnRate()) / 100;
        uint256 sendAmount = amount - burnAmount;

        token.approve(address(this), amount);
        token.transferFrom(address(this), userAddress, amount);

        assertEq(token.balanceOf(userAddress), sendAmount);
        assertEq(token.totalSupply(), token.MAX_SUPPLY() - burnAmount);
    }

    function testSetBurnRate() public {
        uint256 newBurnRate = 5;
        token.setBurnRate(newBurnRate);

        assertEq(token.burnRate(), newBurnRate);
    }

    function testSetBurnRateFailsIfNotOwner() public {
        uint256 newBurnRate = 5;
        vm.prank(userAddress);
        vm.expectRevert();
        token.setBurnRate(newBurnRate);
    }

    function testOwnership() public {
        assertEq(token.owner(), address(this));
        token.transferOwnership(userAddress);
        assertEq(token.owner(), userAddress);
    }
}
