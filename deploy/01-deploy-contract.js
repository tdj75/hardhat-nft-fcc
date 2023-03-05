const {
  developmentChains,
  contractConfig,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = async (hre) => {
  const { deployments, getNamedAccounts, network } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log("Deploying contract...");

  const contract = await deploy(contractConfig.contractName, {
    from: deployer,
    args: contractConfig.contractArgs,
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`Contract deployed at ${contract.address}`);

  if (!developmentChains.includes(network.name) && ETHERSCAN_API_KEY) {
    await verify(contract.address, contractConfig.contractArgs);
  }
};

module.exports.tags = [contractConfig.contractName, "all"];
