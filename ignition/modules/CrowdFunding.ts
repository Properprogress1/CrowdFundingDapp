import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";



const CrowdFundingModule = buildModule("CrowdFundingModule", (m) => {
 

  const funding = m.contract("CrowdFunding", []);

  return { funding };
});

export default CrowdFundingModule;