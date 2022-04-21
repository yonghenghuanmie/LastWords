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
	let available_time;
	let weis = function (num) {
		return web3.utils.toWei(String(num), "ether");
	}
	before(async () => {
		instance = await LastWords.deployed();
		instanceOfC = await c.deployed();
		console.log("contract:" + instance.address);
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
		available_time = (await web3.eth.getBlock("latest")).timestamp + wait_time;
		let result = await instance.SetArrangements(nobody, available_time, false, message, new Uint8Array(), { from: alice });
		expect(result.receipt.status).to.equal(true);
	});
	it("test SetArrangements(only_once)", async () => {
		let result = await instance.SetArrangements(bob, available_time, true, message, new Uint8Array(), { from: alice });
		expect(result.receipt.status).to.equal(true);
	});
	it("test unavailable time through ExecuteArrangementsOnce", async () => {
		try {
			let result = await instance.ExecuteArrangementsOnce(alice, { from: bob });
			assert(false);
		}
		catch { }
	});
	it("test SetExtra", async () => {
		let result = await instance.SetExtra(instanceOfC.address, new Uint8Array(),new Uint8Array(), { from: alice });
		expect(result.receipt.status).to.equal(true);
	});

	it("test ExecuteArrangementsOnce calling by wrong person", async () => {
		try {
			let result = await instance.ExecuteArrangementsOnce(alice, { from: alice });
			assert(false);
		}
		catch { }
	});
	it("test ExecuteArrangementsOnce with right condition", async () => {
		await new Promise(r => setTimeout(r, 10000));
		let result = await instance.ExecuteArrangementsOnce(alice, { from: bob });
		expect(result.receipt.status).to.equal(true);
		expect(result.logs[0].args[0]).to.equal(message);
	});
	it("test calling ExecuteArrangementsOnce more than once after succeed", async () => {
		try {
			let result = await instance.ExecuteArrangementsOnce(alice, { from: bob });
			assert(false);
		}
		catch { }
	});
	it("test ExecuteArrangements", async () => {
		// nobody
		let [arrangement_message,] = await instance.ExecuteArrangements.call(alice);
		expect(arrangement_message).to.equal(message);
	});
});