import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const DeployModule = buildModule("DeployModule", (m) => {
  const erc20 = m.contract("ERC20");
 
  const saveAsset = m.contract("SaveAsset", [erc20]);

 const schoolManagement = m.contract("SchoolManagement", [erc20, "0x6223E0ac6b6482058A18Faa5Ccdfe8F3EBe9AD0f"]);
  
  return { erc20, saveAsset, schoolManagement };
});

export default DeployModule;
