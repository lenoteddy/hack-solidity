// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Block timestamp manipulation

Basic idea of the exploit
- Miners can manipulate block.timestamp with some constraints

Constraints
- it must be after the previous block timestamp
- it cannot be too far in the future
*/

contract Roulette {
    constructor() public payable {}

    function spin() external payable {
        require(msg.value >= 1 ether); // must send 1 ether to play

        if (block.timestamp % 7 == 0) {
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }
}
