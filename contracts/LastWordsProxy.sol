//SPDX-License-Identifier:996ICU AND apache-2.0
/**
 *	@author	huanmie<yonghenghuanmie@gmail.com>
 *	@date	2022.4.23
 */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./LastWordsInterface.sol";

contract LastWordsProxy is ERC1967Proxy(0x7D6dd4EA5Ba9E28a113Bc91d86f58F6494Ea6758,new bytes(0)),LastWordsInterface
{
	function Forward() external
	{
		_delegate(_implementation());
	}

	function _Forward(bytes memory call_data,string memory message) internal
		returns (bytes memory return_data)
	{
		return Address.functionDelegateCall(_implementation(),call_data,message);
	}

	function UpgradeTo(address newImplementation) external
	{
		string memory signature="UpgradeTo(address)";
		_Forward(abi.encodeWithSignature(signature,newImplementation),signature);
	}

	function UpgradeToAndCall(address newImplementation, bytes memory data) external payable
	{
		string memory signature="UpgradeToAndCall(address,bytes)";
		_Forward(abi.encodeWithSignature(signature,newImplementation,data),signature);
	}

	function SetLastWords(string calldata message) external
	{
		string memory signature="SetLastWords(string)";
		_Forward(abi.encodeWithSignature(signature,message),signature);
	}

	function GetLastWords(address who) external
		returns(string memory message)
	{
		string memory signature="GetLastWords(address)";
		return abi.decode(_Forward(abi.encodeWithSignature(signature,who),signature),(string));
	}

	function SetArrangements(address who,uint120 when,bool only_execute_once,string calldata message,bytes calldata data) external
	{
		string memory signature="SetArrangements(address,uint120,bool,string,bytes)";
		_Forward(abi.encodeWithSignature(signature,who,when,only_execute_once,message,data),signature);
	}

	function SetExtra(address contract_address,bytes calldata condition_data,bytes calldata action_data) external
	{
		string memory signature="SetExtra(address,bytes,bytes)";
		_Forward(abi.encodeWithSignature(signature,contract_address,condition_data,action_data),signature);
	}

	function ExecuteArrangements(address who) public
		returns(string memory message,bytes memory data)
	{
		string memory signature="ExecuteArrangements(address)";
		(message,data)=abi.decode(_Forward(abi.encodeWithSignature(signature,who),signature),(string,bytes));
	}

	function ExecuteArrangementsWithExtra(address who) public
		returns(string memory message,bytes memory data)
	{
		string memory signature="ExecuteArrangementsWithExtra(address)";
		(message,data)=abi.decode(_Forward(abi.encodeWithSignature(signature,who),signature),(string,bytes));
	}

	function ExecuteArrangementsOnce(address who) external
		returns(string memory message,bytes memory data)
	{
		string memory signature="ExecuteArrangementsOnce(address)";
		(message,data)=abi.decode(_Forward(abi.encodeWithSignature(signature,who),signature),(string,bytes));
	}
}
