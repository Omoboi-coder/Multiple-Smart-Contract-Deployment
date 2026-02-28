import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OmoboiOnchainNFTModule = buildModule("OmoboiOnchainNFTModule", (m) => {
  const nft = m.contract("OmoboiOnchainNFT");
  return { nft };
});

export default OmoboiOnchainNFTModule;