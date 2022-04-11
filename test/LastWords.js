/**
 * 	@author huanmie<yonghenghuanmie@gmail.com>
 * 	@date 2022.4.11
 */
const assert = require("assert");
const Web3 = require("web3");
const expect = require("chai").expect;
const LastWords = artifacts.require("LastWords");
const c = artifacts.require("c");


contract("LastWords test", async (accounts) => {
	let [nobody, alice, bob, charlie] = accounts;
	let [alice_lastwords, wait_time, message] = ["last words from alice.", 10, "arrangement message"];
	let instance;
	let instanceOfC;
	let web3;
	let weis = function (num) {
		return web3.utils.toWei(String(num), "ether");
	}
	before(async () => {
		instance = await LastWords.deployed();
		instanceOfC = await c.deployed();
		console.log("contract:" + instance.address);
		console.log("alice:" + alice + "\nbob:" + bob);
		web3 = new Web3(Web3.givenProvider || 'ws://127.0.0.1:7545');
	});

	it("test SetLastWords", async () => {
		let result = await instance.SetLastWords(alice_lastwords, { from: alice });
		expect(result.receipt.status).to.equal(true);
	});
	it("test GetLastWords", async () => {
		let result = await instance.GetLastWords.call(alice);
		expect(result).to.equal(alice_lastwords);
	});
	it("test SetArrangements", async () => {
		let available_time = (await web3.eth.getBlock("latest")).timestamp + wait_time;
		let result = await instance.SetArrangements(nobody, available_time, true, message, new Uint8Array(), { from: alice });
		expect(result.receipt.status).to.equal(true);
	});
	it("test unavailable time through ExecuteArrangements", async () => {
		try {
			let result = await instance.ExecuteArrangements(alice, { from: nobody });
			assert(false);
		}
		catch { }
	});
	it("test SetExtraConditions", async () => {
		let result = await instance.SetExtraConditions(instanceOfC.address, new Uint8Array(), { from: alice });
		expect(result.receipt.status).to.equal(true);
	});

	it("test SetExtraActions", async () => {
		let result = await instance.SetExtraActions(instanceOfC.address, new Uint8Array(), { from: alice });
		expect(result.receipt.status).to.equal(true);
	});
	it("test ExecuteArrangements calling by wrong person", async () => {
		try {
			let result = await instance.ExecuteArrangements(alice, { from: alice });
			assert(false);
		}
		catch { }
	});
	it("test ExecuteArrangements with right condition", async () => {
		await new Promise(r => setTimeout(r, 10000));
		let result = await instance.ExecuteArrangements(alice, { from: nobody });
		expect(result.receipt.status).to.equal(true);
		expect(result.logs[0].args[0]).to.equal(message);
	});
	it("test calling ExecuteArrangements more than once after succeed", async () => {
		try {
			let result = await instance.ExecuteArrangements(alice, { from: nobody });
			assert(false);
		}
		catch { }
	});
});