// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Hiding Malicious Code
- Contract hiding malicious code walkthrough
- Coding an exploit
- Demo on Remix
*/

contract Bar {
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}

contract Foo {
    Bar bar;

    constructor(address _bar) public {
        bar = Bar(_bar);
    }

    function callBar() public {
        bar.log();
    }
}

// In a separate file
contract Mal {
    event Log(string message);

    function log() public {
        emit Log("Mal was called");
    }
}
