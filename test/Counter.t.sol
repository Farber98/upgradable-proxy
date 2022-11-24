// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {PRBTest} from "prb-test/PRBTest.sol";
import "forge-std/console.sol";
import "../src/Counter.sol";

contract CounterTest is PRBTest {
    CounterV1 implementationV1;
    UUPSProxy proxy;
    CounterV1 wrappedProxyV1;
    CounterV2 wrappedProxyV2;

    function setUp() public {
        implementationV1 = new CounterV1();
        // deploy proxy contract and point it to implementation

        proxy = new UUPSProxy(address(implementationV1), "");

        // wrap in ABI to support easier calls
        wrappedProxyV1 = CounterV1(address(proxy));

        wrappedProxyV1.initialize();
    }

    function testInitialValueIsZero() public {
        assertEq(wrappedProxyV1.count(), 0);
    }

    function testIncrementIs1() public {
        wrappedProxyV1.inc();
        assertEq(wrappedProxyV1.count(), 1);
    }

    function testCanUpgrade() public {
        CounterV2 implementationV2 = new CounterV2();
        wrappedProxyV1.upgradeTo(address(implementationV2));

        // re-wrap the proxy
        wrappedProxyV2 = CounterV2(address(proxy));

        assertEq(wrappedProxyV2.count(), 1);

        wrappedProxyV2.inc();
        assertEq(wrappedProxyV2.count(), 2);
    }
}
