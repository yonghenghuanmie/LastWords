//SPDX-License-Identifier:996ICU AND apache-2.0
/**
 *	@author	huanmie<yonghenghuanmie@gmail.com>
 *	@date	2022.4.23
 */

pragma solidity ^0.8.0;

interface LastWordsInterface
{
	function SetLastWords(string calldata message) external;
	function GetLastWords(address who) external
		returns(string memory message);
	function SetArrangements(address who,uint120 when,bool only_execute_once,string calldata message,bytes calldata data) external;
	function SetExtra(address contract_address,bytes calldata condition_data,bytes calldata action_data) external;
	function ExecuteArrangements(address who) external
		returns(string memory message,bytes memory data);
	function ExecuteArrangementsWithExtra(address who) external
		returns(string memory message,bytes memory data);
	function ExecuteArrangementsOnce(address who) external
		returns(string memory message,bytes memory data);
}