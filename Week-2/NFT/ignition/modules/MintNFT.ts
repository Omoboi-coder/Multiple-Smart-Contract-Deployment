import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MintNFTModule = buildModule("MintNFTModule", (m) => {
  const contractAddress = "0x42dA23c3d7e98Bb3608e6bDf5d712Ee605f8FFA0";
  const metadataCID = "ipfs://bafkreihd6v27ozyoxajcy57zxdgmc5xcqqhjbkvhgegw25rbrbbnfeqipy";

  const nft = m.contractAt("OmoboiNFT", contractAddress);

  m.call(nft, "mint", [m.getAccount(0), metadataCID]);

  return { nft };
});

export default MintNFTModule;