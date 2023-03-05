const networkConfig = {
  31337: {
    name: "localhost",
    ethUsdPriceFeed: "0x9326BFA02ADD2366b30bacB125260Af641031331",
    gasLane:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
    mintFee: "10000000000000000", // 0.01 ETH
    callbackGasLimit: "500000", // 500,000 gas
  },
  // Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
  5: {
    name: "goerli",
    ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
    vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
    gasLane:
      "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    callbackGasLimit: "500000", // 500,000 gas
    mintFee: "10000000000000000", // 0.01 ETH
    subscriptionId: "1002", // add your ID here!
  },
  1337: {
    name: "ganache",
  },
};

const developmentChains = ["hardhat", "localhost", "ganache"];

const tokenConfig = {
  tokenName: "Taurus",
  tokenSymbol: "TDJ",
  tokenURI:
    "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json",
};

const contractConfig = {
  contractName: "BasicNFT",
  contractArgs: [tokenConfig.tokenName, tokenConfig.tokenSymbol],
};

module.exports = {
  networkConfig,
  developmentChains,
  tokenConfig,
  contractConfig,
};
