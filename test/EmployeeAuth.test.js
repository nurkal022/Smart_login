const { expect } = require("chai");
const { ethers } = require("hardhat");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("EmployeeAuth", function () {
  let contract, owner, addr1, addr2;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("EmployeeAuth");
    contract = await Factory.deploy();
  });

  it("owner is set on deploy", async () => {
    expect(await contract.owner()).to.equal(owner.address);
  });

  it("addEmployee adds an employee", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    expect(await contract.isEmployee(addr1.address)).to.be.true;
    expect(await contract.getEmployeeName(addr1.address)).to.equal("Alice");
  });

  it("addEmployee emits EmployeeAdded event", async () => {
    await expect(contract.addEmployee(addr1.address, "Alice"))
      .to.emit(contract, "EmployeeAdded")
      .withArgs(addr1.address, "Alice");
  });

  it("addEmployee reverts for non-owner", async () => {
    await expect(
      contract.connect(addr1).addEmployee(addr2.address, "Bob")
    ).to.be.revertedWith("Not owner");
  });

  it("addEmployee reverts for duplicate", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(
      contract.addEmployee(addr1.address, "Alice2")
    ).to.be.revertedWith("Already exists");
  });

  it("removeEmployee removes an employee", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await contract.removeEmployee(addr1.address);
    expect(await contract.isEmployee(addr1.address)).to.be.false;
  });

  it("removeEmployee emits EmployeeRemoved event", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(contract.removeEmployee(addr1.address))
      .to.emit(contract, "EmployeeRemoved")
      .withArgs(addr1.address);
  });

  it("removeEmployee reverts for non-owner", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(
      contract.connect(addr1).removeEmployee(addr1.address)
    ).to.be.revertedWith("Not owner");
  });

  it("logLogin records a login event and emits LoginRecorded", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(contract.logLogin(addr1.address))
      .to.emit(contract, "LoginRecorded")
      .withArgs(addr1.address, anyValue);
    const log = await contract.getLoginHistory();
    expect(log.length).to.equal(1);
    expect(log[0].employee).to.equal(addr1.address);
  });

  it("logLogin reverts for non-employee", async () => {
    await expect(
      contract.logLogin(addr1.address)
    ).to.be.revertedWith("Not an employee");
  });

  it("logLogin reverts for non-owner", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(
      contract.connect(addr1).logLogin(addr1.address)
    ).to.be.revertedWith("Not owner");
  });

  it("getEmployeeList returns all employees", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await contract.addEmployee(addr2.address, "Bob");
    const list = await contract.getEmployeeList();
    expect(list.length).to.equal(2);
    expect(list).to.include(addr1.address);
    expect(list).to.include(addr2.address);
  });
});
