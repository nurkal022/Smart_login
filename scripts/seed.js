const { ethers } = require("hardhat");

async function main() {
  const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const [deployer] = await ethers.getSigners();

  const contract = await ethers.getContractAt("EmployeeAuth", CONTRACT_ADDRESS);

  // Проверяем, не добавлен ли уже
  const isEmp = await contract.isEmployee(deployer.address);
  if (isEmp) {
    console.log("Admin already registered:", deployer.address);
    return;
  }

  const tx = await contract.addEmployee(deployer.address, "Admin");
  await tx.wait();
  console.log("Admin registered:", deployer.address);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
