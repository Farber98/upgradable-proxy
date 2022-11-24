// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import "../src/Counter.sol";

contract DeployCounter is Script {
    UUPSProxy proxy;
    CounterV1 wrappedProxyV1;
    CounterV2 wrappedProxyV2;

    function run() public {
        CounterV1 implementationV1 = new CounterV1();

        // deploy proxy contract and point it to implementation
        proxy = new UUPSProxy(address(implementationV1), "");

        // wrap in ABI to support easier calls
        wrappedProxyV1 = CounterV1(address(proxy));
        wrappedProxyV1.initialize();

        // expect 0
        console.log(wrappedProxyV1.count());
        wrappedProxyV1.inc();

        // expect 1
        console.log(wrappedProxyV1.count());

        // new implementation
        CounterV2 implementationV2 = new CounterV2();
        wrappedProxyV1.upgradeTo(address(implementationV2));

        wrappedProxyV2 = CounterV2(address(proxy));

        // expect 1
        console.log(wrappedProxyV2.count());
        wrappedProxyV2.inc();

        // expect 2
        console.log(wrappedProxyV2.count());
    }
}
