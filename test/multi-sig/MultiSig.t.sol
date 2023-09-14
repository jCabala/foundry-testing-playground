pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {MultiSigWallet} from "../../src/multi-sig/MultiSig.sol";

contract MultiSig is Test {
    MultiSigWallet public multiSig;
    address[4] public users;
    Counter counter;

    function setUp() public {
        _createUsers();
        address[] memory owners = new address[](3);

        owners[0] = users[0];
        owners[1] = users[1];
        owners[2] = users[2];

        multiSig = new MultiSigWallet(owners, owners.length - 1);

        // Deploy helper contracts
        counter = new Counter();

        assertEq(
            counter.count(),
            uint256(0),
            "Counter should start with 0 count"
        );
    }

    function testOwners() public {
        address[] memory owners = multiSig.getOwners();

        for (uint256 i = 0; i < owners.length; i++) {
            assertEq(owners[i], users[i]);
        }
    }

    function testCounterTransaction() public {
        // User 0 proposes the transaction and confirms it
        vm.startPrank(users[0]);
        multiSig.submitTransaction(
            address(counter),
            0,
            abi.encodeWithSelector(Counter.add.selector)
        );
        assertEq(multiSig.getTransactionCount(), 1, "Transaction not added");

        multiSig.confirmTransaction(0);
        vm.stopPrank();

        // User 1 confirms the transaction and executes it
        vm.startPrank(users[1]);
        multiSig.confirmTransaction(0);
        multiSig.executeTransaction(0);

        assertEq(counter.count(), uint256(1));
        (, , , bool executed, ) = multiSig.getTransaction(0);
        assertEq(executed, true);

        //Check if we cannot run the transaction for the second time
        vm.expectRevert();
        multiSig.executeTransaction(0);
        vm.stopPrank();
    }

    function testNotOwnerCannotProposeTransactions() public {
        vm.startPrank(users[3]);
        vm.expectRevert();
        multiSig.submitTransaction(
            address(counter),
            0,
            abi.encodeWithSelector(Counter.add.selector)
        );
        vm.stopPrank();
    }

    function testTransactionRevertsIfNotEnoughApprovals() public {
        // User 0 proposes the transaction, confirms it and tries to execute
        vm.startPrank(users[0]);
        multiSig.submitTransaction(
            address(counter),
            0,
            abi.encodeWithSelector(Counter.add.selector)
        );
        assertEq(multiSig.getTransactionCount(), 1, "Transaction not added");

        multiSig.confirmTransaction(0);

        vm.expectRevert();
        multiSig.executeTransaction(0);

        assertEq(counter.count(), uint256(0));
        (, , , bool executed, ) = multiSig.getTransaction(0);
        assertEq(executed, false);

        vm.stopPrank();
    }

    // --- Internal Functions ---
    function _createUsers() internal {
        users[0] = address(1);
        users[1] = address(2);
        users[2] = address(3);
        users[3] = address(4);
    }
}

contract Counter {
    uint256 public count;

    function add() external {
        count++;
    }
}
