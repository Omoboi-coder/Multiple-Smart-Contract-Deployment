import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MintOnchainNFTModule = buildModule("MintOnchainNFTModule", (m) => {
  const contractAddress = "0x4042d22d2774d2Ab5c975bcBc0C26Dbb2f917939";

  const nft = m.contractAt("OmoboiOnchainNFT", contractAddress);

  m.call(nft, "mint", [m.getAccount(0)]);

  return { nft };
});

export default MintOnchainNFTModule;