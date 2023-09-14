pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {IterableMapping} from "../../src/iterable-mapping/Map.sol";

contract MapTest is Test {
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private map;
    address[] private keys;

    function setUp(address[] memory _keys) public {
        // Checking if keys are different and no longer than 200
        vm.assume(keys.length < 200);

        for (uint i = 0; i < keys.length; i++) {
            for (uint j = i + 1; j < keys.length; j++) {
                vm.assume(keys[i] != keys[j]);
            }
        }

        keys = _keys;

        address[] memory mapKeys = map.keys;
        for (uint i = 0; i < mapKeys.length; i++) {
            map.remove(mapKeys[i]);
        }

        for (uint i = 0; i < keys.length; i++) {
            map.set(keys[i], i);
        }
    }

    function testGet() public {
        for (uint i = 0; i < keys.length; i++) {
            uint val = map.get(keys[i]);
            assertEq(val, i);
        }
    }
}
