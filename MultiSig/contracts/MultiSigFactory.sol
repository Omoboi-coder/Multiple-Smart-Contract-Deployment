// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MultiSigWallet.sol";

contract MultiSigFactory {
    address[] public multisigs;

    event MultiSigCreated(address indexed multisig, address indexed creator);

    function create(address[] memory owners, uint256 required) external returns (address) {
        MultiSigWallet wallet = new MultiSigWallet(owners, required);
        multisigs.push(address(wallet));
        emit MultiSigCreated(address(wallet), msg.sender);
        return address(wallet);
    }

    function count() external view returns (uint256) {
        return multisigs.length;
    }
}
