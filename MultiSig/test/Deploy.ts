import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("MultiSigWallet", function () {
  async function deployFixture() {
    const [owner1, owner2, owner3, nonOwner, recipient] =
      await hre.ethers.getSigners();

    const owners = [owner1.address, owner2.address, owner3.address];
    const required = 2;

    const MultiSig = await hre.ethers.getContractFactory("MultiSigWallet");
    const multisig = await MultiSig.deploy(owners, required);

    return {
      multisig,
      owners,
      required,
      owner1,
      owner2,
      owner3,
      nonOwner,
      recipient,
    };
  }

  async function setBalance(address: string, amountWei: bigint) {
    await hre.network.provider.send("hardhat_setBalance", [
      address,
      "0x" + amountWei.toString(16),
    ]);
  }

  describe("Deployment", function () {
    it("stores owners and required", async function () {
      const { multisig, owners, required } = await loadFixture(deployFixture);

      expect(await multisig.required()).to.equal(required);
      expect(await multisig.owners(0)).to.equal(owners[0]);
      expect(await multisig.owners(1)).to.equal(owners[1]);
      expect(await multisig.owners(2)).to.equal(owners[2]);
      expect(await multisig.isOwner(owners[0])).to.equal(true);
      expect(await multisig.isOwner(owners[1])).to.equal(true);
      expect(await multisig.isOwner(owners[2])).to.equal(true);
    });
  });

  describe("withdrawReq", function () {
    it("allows owners to submit a transaction", async function () {
      const { multisig, owner1, recipient } = await loadFixture(deployFixture);

      await multisig
        .connect(owner1)
        .withdrawReq(recipient.address, 123n, "0x");

      const tx = await multisig.transactions(0);
      expect(tx.to).to.equal(recipient.address);
      expect(tx.value).to.equal(123n);
      expect(tx.data).to.equal("0x");
      expect(tx.executed).to.equal(false);
    });

    it("reverts for non-owners", async function () {
      const { multisig, nonOwner, recipient } = await loadFixture(deployFixture);

      await expect(
        multisig.connect(nonOwner).withdrawReq(recipient.address, 1n, "0x")
      ).to.be.revertedWith("not owner");
    });
  });

  describe("approve", function () {
    it("allows owners to approve once", async function () {
      const { multisig, owner1, owner2, recipient } = await loadFixture(
        deployFixture
      );

      await multisig
        .connect(owner1)
        .withdrawReq(recipient.address, 1n, "0x");

      await multisig.connect(owner1).approve(0);
      await expect(multisig.connect(owner1).approve(0)).to.be.revertedWith(
        "tx already approved"
      );

      expect(await multisig.approved(0, owner1.address)).to.equal(true);
      expect(await multisig.approved(0, owner2.address)).to.equal(false);
    });

    it("reverts for non-owners", async function () {
      const { multisig, nonOwner, recipient } = await loadFixture(deployFixture);

      await multisig
        .connect(nonOwner)
        .withdrawReq(recipient.address, 1n, "0x")
        .catch(() => {});

      await expect(multisig.connect(nonOwner).approve(0)).to.be.revertedWith(
        "not owner"
      );
    });
  });

  describe("execute", function () {
    it("executes after required approvals and transfers funds", async function () {
      const { multisig, owner1, owner2, recipient } = await loadFixture(
        deployFixture
      );

      await setBalance(multisig.target as string, 1_000_000_000_000_000_000n);

      await multisig
        .connect(owner1)
        .withdrawReq(recipient.address, 1000n, "0x");
      await multisig.connect(owner1).approve(0);
      await multisig.connect(owner2).approve(0);

      await expect(multisig.connect(owner1).execute(0)).to.changeEtherBalances(
        [multisig, recipient],
        [-1000n, 1000n]
      );

      const tx = await multisig.transactions(0);
      expect(tx.executed).to.equal(true);
    });

    it("reverts if approvals are insufficient", async function () {
      const { multisig, owner1, recipient } = await loadFixture(deployFixture);

      await multisig
        .connect(owner1)
        .withdrawReq(recipient.address, 1n, "0x");

      await multisig.connect(owner1).approve(0);

      await expect(multisig.connect(owner1).execute(0)).to.be.revertedWith(
        "approvals < required"
      );
    });

    it("reverts if executed twice", async function () {
      const { multisig, owner1, owner2, recipient } = await loadFixture(
        deployFixture
      );

      await setBalance(multisig.target as string, 1_000_000_000_000_000_000n);

      await multisig
        .connect(owner1)
        .withdrawReq(recipient.address, 1000n, "0x");
      await multisig.connect(owner1).approve(0);
      await multisig.connect(owner2).approve(0);
      await multisig.connect(owner1).execute(0);

      await expect(multisig.connect(owner1).execute(0)).to.be.revertedWith(
        "tx already excuted"
      );
    });
  });

  describe("revoke", function () {
    it("allows an owner to revoke approval", async function () {
      const { multisig, owner1, recipient } = await loadFixture(deployFixture);

      await multisig
        .connect(owner1)
        .withdrawReq(recipient.address, 1n, "0x");
      await multisig.connect(owner1).approve(0);

      await multisig.connect(owner1).revoke(0);
      expect(await multisig.approved(0, owner1.address)).to.equal(false);
    });

    it("reverts if not approved", async function () {
      const { multisig, owner1, recipient } = await loadFixture(deployFixture);

      await multisig
        .connect(owner1)
        .withdrawReq(recipient.address, 1n, "0x");

      await expect(multisig.connect(owner1).revoke(0)).to.be.revertedWith(
        "tx not approved"
      );
    });
  });
});
