// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {HopeToken} from "src/HopeToken.sol";
import {DeployHopeToken} from "script/DeployHopeToken.s.sol";

contract HopeTokenTest is Test {
    HopeToken public hopeToken;
    DeployHopeToken public deployer;

    address scott = makeAddr("scott");
    address nick = makeAddr("nick");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant STANDARD_TRANSFER_AMOUNT = 100;

    // Events declared for testing event emission
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        deployer = new DeployHopeToken();
        hopeToken = deployer.run();

        vm.prank(msg.sender);
        hopeToken.transfer(scott, STARTING_BALANCE);
    }

    function testScottBalance() public view {
        assertEq(hopeToken.balanceOf(scott), STARTING_BALANCE);
    }

    function testTransferFromAfterApprovingAllowance() public {
        uint256 initialAllowance = 1000; // greater than 100 (STANDARD_TRANSFER_AMOUNT)

        vm.prank(scott);
        hopeToken.approve(nick, initialAllowance);

        vm.prank(nick);
        hopeToken.transferFrom(scott, nick, STANDARD_TRANSFER_AMOUNT);

        assertEq(hopeToken.balanceOf(scott), STARTING_BALANCE - STANDARD_TRANSFER_AMOUNT);
        assertEq(hopeToken.balanceOf(nick), STANDARD_TRANSFER_AMOUNT);
    }

    function testTransferFromRevertsIfAllowanceIsNotApproved() public {
        vm.prank(nick);
        vm.expectRevert();
        hopeToken.transferFrom(scott, nick, STANDARD_TRANSFER_AMOUNT);
    }

    function testTransfer() public {
        vm.prank(scott);
        hopeToken.transfer(nick, STANDARD_TRANSFER_AMOUNT);

        assertEq(hopeToken.balanceOf(scott), STARTING_BALANCE - STANDARD_TRANSFER_AMOUNT);
        assertEq(hopeToken.balanceOf(nick), STANDARD_TRANSFER_AMOUNT);
    }

    function testTransferRevertsDueToInsufficientBalance() public {
        vm.prank(nick);
        vm.expectRevert();
        hopeToken.transfer(scott, STANDARD_TRANSFER_AMOUNT);
    }

    function testTransferFromRevertsDueToInsufficientAllowance() public {
        uint256 approvedAmount = 50; // less than 100 (STANDARD_TRANSFER_AMOUNT)

        vm.prank(scott);
        hopeToken.approve(nick, approvedAmount);

        vm.prank(nick);
        vm.expectRevert();
        hopeToken.transferFrom(scott, nick, STANDARD_TRANSFER_AMOUNT);
    }

    // function testIncreaseAllowance() public {
    //     uint256 initialApproval = 10 ether;
    //     uint256 increaseAmount = 5 ether;

    //     vm.prank(scott);
    //     hopeToken.approve(nick, initialApproval);
    //     uint256 oldAllowance = hopeToken.allowance(scott, nick);

    //     vm.prank(scott);
    //     hopeToken.increaseAllowance(nick, increaseAmount);
    //     uint256 newAllowance = hopeToken.allowance(scott, nick);

    //     assertEq(newAllowance, oldAllowance + increaseAmount);
    // }

    // Test decreasing allowance using decreaseAllowance()
    // function testDecreaseAllowance() public {
    //     uint256 initialApproval = 10 ether;
    //     uint256 decreaseAmount = 4 ether;

    //     vm.prank(scott);
    //     hopeToken.approve(nick, initialApproval);
    //     uint256 oldAllowance = hopeToken.allowance(scott, nick);

    //     vm.prank(scott);
    //     hopeToken.decreaseAllowance(nick, decreaseAmount);
    //     uint256 newAllowance = hopeToken.allowance(scott, nick);

    //     assertEq(newAllowance, oldAllowance - decreaseAmount);
    // }

    function testTransferToZeroAddressReverts() public {
        vm.prank(scott);
        vm.expectRevert();
        hopeToken.transfer(address(0), STANDARD_TRANSFER_AMOUNT);
    }

    function testApproveEventEmitted() public {
        uint256 approvalAmount = 1000;
        vm.prank(scott);
        vm.expectEmit(true, true, false, true);
        emit Approval(scott, nick, approvalAmount);
        hopeToken.approve(nick, approvalAmount);
    }

    function testTransferEventEmitted() public {
        uint256 transferAmount = 20 ether;
        vm.prank(scott);
        vm.expectEmit(true, true, false, true);
        emit Transfer(scott, nick, transferAmount);
        hopeToken.transfer(nick, transferAmount);
    }
}
