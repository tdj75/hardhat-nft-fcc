const { assert } = require("chai");
const { deployments, ethers } = require("hardhat");
const {
  developmentChains,
  contractConfig,
  tokenConfig,
} = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip("On-chain network detected: skipping test...", function () {})
  : describe("Local network detected: executing tests...", function () {
      let accounts, contract;

      before(async function () {
        await deployments.fixture([contractConfig.contractName]);
        accounts = await ethers.getSigners();
        contract = await ethers.getContract(contractConfig.contractName);
      });

      describe("Checking constructor...", function () {
        it("Is the contract name correctly initialized?", async function () {
          const tokenName = await contract.name();
          assert.equal(tokenName, tokenConfig.tokenName);
        });
        it("Is the contract symbol correctly initialized?", async function () {
          const tokenSymbol = await contract.symbol();
          assert.equal(tokenSymbol, tokenConfig.tokenSymbol);
        });
      });

      describe("Minting the NFT items...", function () {
        before(async function () {
          for (let i = 0; i < accounts.length; i++) {
            const tx = await contract.mintItem(
              accounts[i].address,
              tokenConfig.tokenURI
            );
            const rc = await tx.wait();
            const event = rc.events.find((item) => item.event === "Transfer");
            const { to, tokenId } = event.args;
            console.log(`Token ID ${tokenId} minted to address ${to}`);
          }
        });

        describe("Testing the minted NFT items...", async function () {
          it("Has the item ID counter been correctly incremented?", async function () {
            const currentItemID = await contract.getCurrentItemID();
            assert.equal(currentItemID.toString(), accounts.length.toString());
          });

          it("Are the account balances equal to 1 minted NFT?", async function () {
            for (let i = 0; i < accounts.length; i++) {
              const accountBalance = await contract.balanceOf(
                accounts[i].address
              );
              assert.equal(accountBalance.toString(), "1");
            }
          });

          it("Are the token URIs correctly set?", async function () {
            for (let i = 0; i < accounts.length; i++) {
              const tokenURI = await contract.tokenURI(i);
              assert.equal(tokenURI, tokenConfig.tokenURI);
            }
          });

          it("Have the NFTs been minted to the correct addresses?", async function () {
            for (let i = 0; i < accounts.length; i++) {
              const tokenAddress = await contract.ownerOf(i);
              assert.equal(tokenAddress, accounts[i].address);
            }
          });
        });
      });
    });
