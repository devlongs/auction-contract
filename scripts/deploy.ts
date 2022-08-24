import { ethers } from "hardhat";

async function main() {
  const Auction = await ethers.getContractFactory("Auction");
  const auction = await Auction.deploy();

  await auction.deployed();

  console.log(`Auction contract is deployed to this address: ${auction.address}`); // 0x510Aad698Fb69502715A69f593f1754F4eD9C7FB
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});