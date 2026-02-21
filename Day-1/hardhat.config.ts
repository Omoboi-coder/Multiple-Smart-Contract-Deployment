import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const { PRIVATE_KEY} = process.env;


const config: HardhatUserConfig = {
  solidity: "0.8.28",

  networks: {
    lisk: {
      url: "https://rpc.sepolia-api.lisk.com",
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
};

export default config;
