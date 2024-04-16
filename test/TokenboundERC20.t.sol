// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {ERC6551Registry} from "../lib/erc6551/src/ERC6551Registry.sol";
import {AccountV3} from "../lib/tba/src/AccountV3.sol";
import {AccountGuardian} from "../lib/tba/src/AccountGuardian.sol";
import {Multicall3} from "../lib/tba/lib/multicall-authenticated/src/Multicall3.sol";


contract CounterTest is Test {
    ERC6551Registry private registry;
    AccountV3 private accountImplementation;

    function setUp() public {
        registry = new ERC6551Registry();

        accountImplementation = new AccountV3();
    }
    // Counter public counter;

    // function setUp() public {
    //     counter = new Counter();
    //     counter.setNumber(0);
    // }

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
