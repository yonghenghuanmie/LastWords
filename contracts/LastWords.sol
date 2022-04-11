//SPDX-License-Identifier:996ICU AND apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/// @title A contract for these who prepared for their last words and arrange business after their death.
/// @author huanmie<yonghenghuanmie@gmail.com>
/// @notice IMPORTANT: Do not save any important data direct to blockchain cause anyone can see it.
/// For any message private you should encryption it first.
contract LastWords
{
	using Address for address;

	struct Arrangements
	{
		uint120 when;
		bool only_execute_once;
		string message;
		bytes data;
	}

	struct ExtraConditions
	{
		address contract_address;
		bytes call_data;
	}

	struct ExtraActions
	{
		address contract_address;
		bytes call_data;
	}

	// Last words for public.
	mapping (address=>string) public last_words;
	mapping (address=>mapping (address=>bool)) has_arrangements;
	mapping (address=>mapping (address=>Arrangements)) arrangements;

	event Arrangement(string message,bytes data);
	/// @param who doesn't have any arrangements for @param you.
	error DontHaveArrangements(address who,address you);
	/// After @param time (unix timestamp) you can execute arrangements.
	error NotEnoughTime(uint120 time);
	/// Failed to pass extra condition check.
	error ExtraConditionCheckFailed();

	/// @notice @param extra_conditions is about extra condition check and @param extra_actions is about extra action.
	/// @dev check(bytes) signature for extra condition check and only if it returns true ExecuteArrangements will allow continue execution.
	/// process(bytes) signature for extra action.
	mapping (address=>bool) has_extra_conditions;
	mapping (address=>ExtraConditions) extra_conditions;
	mapping (address=>bool) has_extra_actions;
	mapping (address=>ExtraActions) extra_actions;

	function SetLastWords(string calldata message) external
	{
		last_words[msg.sender]=message;
	}

	function GetLastWords(address who) external view returns(string memory)
	{
		return last_words[who];
	}

	/// @notice SetArrangements
	/// @param only_execute_once allow only success execute ExecuteArrangements once. Default value is false means you can execute any times if only you passed all the checks.
	function SetArrangements(address who,uint120 when,bool only_execute_once,string calldata message,bytes calldata data) external
	{
		has_arrangements[msg.sender][who]=true;
		arrangements[msg.sender][who]=Arrangements(when,only_execute_once,message,data);
	}

	function SetExtraConditions(address contract_address,bytes calldata call_data) external
	{
		has_extra_conditions[msg.sender]=true;
		extra_conditions[msg.sender]=ExtraConditions(contract_address,call_data);
	}

	function SetExtraActions(address contract_address,bytes calldata call_data) external
	{
		has_extra_actions[msg.sender]=true;
		extra_actions[msg.sender]=ExtraActions(contract_address,call_data);
	}

	function ExecuteArrangements(address who) external returns(string memory message,bytes memory data)
	{
		//check conditions
		if(!has_arrangements[who][msg.sender])
			revert DontHaveArrangements(who,msg.sender);
		Arrangements storage arrangement=arrangements[who][msg.sender];
		if(block.timestamp<arrangement.when)
			revert NotEnoughTime(arrangement.when);
		if(has_extra_conditions[who])
		{
			bytes memory payload=abi.encodeWithSignature("check(bytes)",extra_conditions[who].call_data);
			bytes memory stream=extra_conditions[who].contract_address.functionCall(payload);
			if(!abi.decode(stream,(bool)))
				revert ExtraConditionCheckFailed();
		}

		//do arrangements
		message=arrangement.message;
		data=arrangement.data;
		emit Arrangement(message,data);
		if(has_extra_actions[who])
		{
			bytes memory payload=abi.encodeWithSignature("process(bytes)",extra_actions[who].call_data);
			extra_actions[who].contract_address.functionCall(payload);
		}

		//ensure only execute once.
		if(arrangement.only_execute_once)
			has_arrangements[who][msg.sender]=false;
	}
}