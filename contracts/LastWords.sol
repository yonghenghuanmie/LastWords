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

	struct Extra
	{
		address contract_address;
		bytes condition_data;
		bytes action_data;
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
	/// Should use ExecuteArrangementsOnce instead.
	error RestrictedCall(string suggest_method);

	/// @notice extra condition check and extra process.
	/// @dev check(bytes) signature for extra condition check and only if it returns true ExecuteArrangements will allow continue execution.
	/// process(bytes) signature for extra action.
	mapping (address=>bool) has_extra;
	mapping (address=>Extra) extra;

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

	function SetExtra(address contract_address,bytes calldata condition_data,bytes calldata action_data) external
	{
		has_extra[msg.sender]=true;
		extra[msg.sender]=Extra(contract_address,condition_data,action_data);
	}

	function ExecuteArrangements(address who) public view returns(string memory message,bytes memory data)
	{
		Arrangements storage arrangement=arrangements[who][msg.sender];
		//check conditions
		if(arrangement.only_execute_once)
			revert RestrictedCall("ExecuteArrangementsOnce");
		if(has_extra[who])
			revert RestrictedCall("ExecuteArrangementsWithExtra");
		if(!has_arrangements[who][msg.sender])
			revert DontHaveArrangements(who,msg.sender);
		if(block.timestamp<arrangement.when)
			revert NotEnoughTime(arrangement.when);

		return (arrangement.message,arrangement.data);
	}

	function ExecuteArrangementsWithExtra(address who) public returns(string memory message,bytes memory data)
	{
		if(arrangements[who][msg.sender].only_execute_once)
			revert RestrictedCall("ExecuteArrangementsOnce");

		if(has_extra[who])
		{
			bytes memory payload=abi.encodeWithSignature("check(bytes)",extra[who].condition_data);
			bytes memory stream=extra[who].contract_address.functionCall(payload);
			if(!abi.decode(stream,(bool)))
				revert ExtraConditionCheckFailed();
			
			//temporarily remove flag
			has_extra[who]=false;
			(message,data)=ExecuteArrangements(who);
			has_extra[who]=true;

			payload=abi.encodeWithSignature("process(bytes)",extra[who].action_data);
			extra[who].contract_address.functionCall(payload);
		}
		else
			(message,data)=ExecuteArrangements(who);
	}

	function ExecuteArrangementsOnce(address who) external returns(string memory message,bytes memory data)
	{
		if(arrangements[who][msg.sender].only_execute_once)
		{
			arrangements[who][msg.sender].only_execute_once=false;
			(message,data)=has_extra[who]?ExecuteArrangementsWithExtra(who):ExecuteArrangements(who);
			//ensure only execute once.
			has_arrangements[who][msg.sender]=false;
		}
		else
			(message,data)=has_extra[who]?ExecuteArrangementsWithExtra(who):ExecuteArrangements(who);
	}
}