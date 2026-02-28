import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OmoboiNFTModule = buildModule("OmoboiNFTModule", (m) => {
  const nft = m.contract("OmoboiNFT");

  return { nft };
});

export default OmoboiNFTModule;