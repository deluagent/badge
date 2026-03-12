// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Badge} from "../src/Badge.sol";

contract BadgeTest is Test {
    Badge badge;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        vm.prank(owner);
        badge = new Badge(owner);
    }

    function test_CreateBadgeType() public {
        vm.prank(owner);
        uint256 typeId = badge.createBadgeType("First Deploy", "Deployed first contract onchain", "ipfs://Qm...");
        assertEq(typeId, 0);
        (string memory name,,, uint256 total) = badge.badgeTypes(0);
        assertEq(name, "First Deploy");
        assertEq(total, 0);
    }

    function test_Issue() public {
        vm.prank(owner);
        badge.createBadgeType("Builder", "Built something real", "ipfs://Qm...");

        vm.prank(owner);
        uint256 tokenId = badge.issue(alice, 0);

        assertEq(tokenId, 0);
        assertEq(badge.ownerOf(0), alice);
        assertTrue(badge.hasBadge(alice, 0));
        (,,, uint256 total) = badge.badgeTypes(0);
        assertEq(total, 1);
    }

    function test_Soulbound() public {
        vm.prank(owner);
        badge.createBadgeType("Builder", "Built something real", "ipfs://Qm...");

        vm.prank(owner);
        badge.issue(alice, 0);

        vm.prank(alice);
        vm.expectRevert(Badge.Soulbound.selector);
        badge.transferFrom(alice, bob, 0);
    }

    function test_Revert_AlreadyHasBadge() public {
        vm.prank(owner);
        badge.createBadgeType("Builder", "Built something real", "ipfs://Qm...");

        vm.prank(owner);
        badge.issue(alice, 0);

        vm.prank(owner);
        vm.expectRevert(Badge.AlreadyHasBadge.selector);
        badge.issue(alice, 0);
    }

    function test_Revert_BadgeTypeNotFound() public {
        vm.prank(owner);
        vm.expectRevert(Badge.BadgeTypeNotFound.selector);
        badge.issue(alice, 99);
    }

    function test_Revert_OnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        badge.createBadgeType("Hacker", "Unauthorized", "ipfs://");
    }

    function test_MultipleTypes() public {
        vm.startPrank(owner);
        badge.createBadgeType("First Deploy", "First deploy", "ipfs://1");
        badge.createBadgeType("Shipped Mainnet", "Live on mainnet", "ipfs://2");
        badge.issue(alice, 0);
        badge.issue(alice, 1);
        badge.issue(bob, 0);
        vm.stopPrank();

        assertTrue(badge.hasBadge(alice, 0));
        assertTrue(badge.hasBadge(alice, 1));
        assertTrue(badge.hasBadge(bob, 0));
        assertFalse(badge.hasBadge(bob, 1));
        assertEq(badge.nextTokenId(), 3);
    }
}
