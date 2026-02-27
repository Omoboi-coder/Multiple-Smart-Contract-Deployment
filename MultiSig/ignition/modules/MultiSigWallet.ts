// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MultiSigWalletModule = buildModule("MultiSigWalletModule", (m) => {
  const owners = [m.getAccount(0), m.getAccount(1), m.getAccount(2)];
  const required = m.getParameter("required", 2);

  const multisigwallet = m.contract("MultiSigWallet", [owners, required]);

  return { multisigwallet };
});

export default MultiSigWalletModule;
