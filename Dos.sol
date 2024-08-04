// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Denial of Service
Denial of service by rejecting to accept Ether
Code and demo
Preventative technique (Push vs Pull)
*/

/* contract A {
    function foo() public {
        (bool sent, ) = msg.sender.call{value: 1 ether}("");
        require(sent, "Failed to send Ether");
        // do something else
    }
}

contract B {
    function callFoo(A a) public {
        a.foo();
    }
} */

contract KingOfEther {
    address public king;
    uint public balance;
    mapping(address => uint) public balances;

    // Alice sends 1 Ether (king = alice, balance = 1 ether)
    // Bob   sends 2 Ether

    function claimTherone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        // (bool sent, ) = king.call{value: balance}("");
        // require(sent, "Failed to send Ether");
        balances[king] += balance;

        balance = msg.value;
        king = msg.sender;
    }

    function withdraw() public {
        require(msg.sender != king, "Current king cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    function attack(KingOfEther kingOfEther) public payable {
        kingOfEther.claimTherone{value: msg.value}();
    }
}
