const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const Factory = await ethers.getContractFactory("EmployeeAuth");
  const contract = await Factory.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("EmployeeAuth deployed to:", address);
  console.log("Deployer (admin) address:", deployer.address);
  console.log("\nAdd to backend/.env:");
  console.log(`CONTRACT_ADDRESS=${address}`);
  console.log("PRIVATE_KEY=<copy Account #0 private key from `npx hardhat node` output>");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
