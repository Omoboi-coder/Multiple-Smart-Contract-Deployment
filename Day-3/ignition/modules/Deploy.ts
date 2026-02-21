import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const DeployModule = buildModule("DeployModule", (m) => {
  const erc20 = m.contract("ERC20");
 
  const saveAsset = m.contract("SaveAsset", [erc20]);

  const schoolManagement = m.contract("SchoolManagement");
  
  return { erc20, saveAsset, schoolManagement };
});

export default DeployModule;