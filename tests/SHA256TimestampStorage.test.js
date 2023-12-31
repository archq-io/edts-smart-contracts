/* eslint-disable no-undef */
// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

const SHA256_VALUE = '0x845fdfd603a41d731afca60ed34d459e6dca662e8570ab6a0c5d51038e648ba7';

describe("SHA256TimestampStorage", function () {
  it("test initial value", async function () {
    const SHA256TimestampStorage = await ethers.getContractFactory("SHA256TimestampStorage");
    const sha256TimestampStorage = await SHA256TimestampStorage.deploy();
    await sha256TimestampStorage.deployed();
    console.log("storage deployed at:" + sha256TimestampStorage.address);
    //expect((await sha256TimestampStorage.retrieve()).toNumber()).to.equal(0);
  });
  it("test updating and retrieving updated value", async function () {
    const SHA256TimestampStorage = await ethers.getContractFactory("SHA256TimestampStorage");
    const sha256TimestampStorage = await SHA256TimestampStorage.deploy();
    await sha256TimestampStorage.deployed();
    const sha256TimestampStorage2 = await ethers.getContractAt("SHA256TimestampStorage", sha256TimestampStorage.address);
    const setValue = await sha256TimestampStorage2.store(SHA256_VALUE);
    await setValue.wait();
    expect((await sha256TimestampStorage2.retrieve()).toNumber()).to.equal(SHA256_VALUE);
  });
});
