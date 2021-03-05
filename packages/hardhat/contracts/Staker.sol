pragma solidity >=0.6.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping ( address => uint256 ) public balances;

  uint256 public constant threshold = 1 ether;

  uint256 public deadline = block.timestamp + 30 seconds;

  event Stake(address, uint256);
  event Execute(address,uint256);
  event Withdraw(address,uint256);

  modifier beforeDeadLine {
    require(block.timestamp < deadline, "PAST DEADLINE");
    _;
  }

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() payable public beforeDeadLine {
    emit Stake(msg.sender, msg.value);
    balances[msg.sender] += msg.value;
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public beforeDeadLine {
    require(balances[msg.sender] >= threshold, "LESS THAN OR EQUAL TO THRESHOLD");
    emit Execute(msg.sender, block.timestamp);
    exampleExternalContract.complete{value: balances[msg.sender]}();

  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public {
    require(block.timestamp > deadline, "STILL TIME TO MEET THRESHOLD");
    uint amount = balances[msg.sender];
    emit Withdraw(msg.sender, balances[msg.sender]);
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
  }



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256)  {
    if (block.timestamp < deadline) {
      return deadline - block.timestamp;
    } else {
      return 0;
    }

  }

}
