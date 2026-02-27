// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/MultiSigFactory.sol";
import "../contracts/MultiSigWallet.sol";

contract MultiSigFactoryTest is Test {
    MultiSigFactory factory;
    address owner1 = address(0x1111);
    address owner2 = address(0x2222);
    address owner3 = address(0x3333);
    address recipient = address(0x4444);

    function setUp() public {
        factory = new MultiSigFactory();
    }

    function testCreateMultisigAndExecute() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        address multisigAddr = factory.create(owners, 2);
        assertEq(factory.count(), 1);

        MultiSigWallet multisig = MultiSigWallet(payable(multisigAddr));

        vm.deal(multisigAddr, 1 ether);

        vm.prank(owner1);
        multisig.withdrawReq(recipient, 0.1 ether, "");

        vm.prank(owner1);
        multisig.approve(0);

        vm.prank(owner2);
        multisig.approve(0);

        uint256 recipientBalanceBefore = recipient.balance;

        vm.prank(owner1);
        multisig.execute(0);

        assertEq(recipient.balance, recipientBalanceBefore + 0.1 ether);
    }

    function testOnlyOwnersCanApprove() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        address multisigAddr = factory.create(owners, 2);
        MultiSigWallet multisig = MultiSigWallet(payable(multisigAddr));

        vm.prank(owner1);
        multisig.withdrawReq(recipient, 1, "");

        vm.expectRevert("not owner");
        multisig.approve(0);
    }
}
