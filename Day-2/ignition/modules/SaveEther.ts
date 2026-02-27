
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const SaveEtherModule = buildModule("SaveEtherModule", (m) => {

  const saveEther = m.contract("SaveEther")
  return { saveEther };
});

export default SaveEtherModule;
