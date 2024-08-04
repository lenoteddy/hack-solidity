// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
Contract deployed on Ropsten

Vulnerability
Storage layout
Setup
Code
Demo
Preventative technique
*/

contract Vault {
    // slot 0
    uint public count = 123; // 32 bytes (2**8) * 32
    // slot 1
    address public owner = msg.sender; // 20 bytes (2**8) * 20
    bool public isTrue = true; // 1 byte
    uint16 public u16 = 31; // 2 bytes (2**8) * 2
    // slot 2
    bytes32 private password;

    // constants do not use storage
    uint public constant someConst = 123;

    // slot 3, 4, 5 (one for each array element)
    bytes32[3] public data;

    struct User {
        uint id;
        bytes32 password;
    }

    // slot 6 - length of array
    // starting from slot keccak256(6) - array elements
    // slot where array element is stored - keccak256(slot) + (index * elementSize)
    // where slot = 6 and elementSize = 2 (1 (uint) + 1 (bytes32))
    User[] private users;

    // slot 7 - empty
    // entries are stored at keccak256(key, slot)
    // where slot = 7, key = map key
    mapping(uint => User) private idToUser;

    constructor(bytes32 _password) public {
        password = _password;
    }

    function addUser(bytes32 _paasword) public {
        User memory user = User({id: users.length, password: _paasword});

        users.push(user);
        idToUser[user.id] = user;
    }

    function getArrayLocation(
        uint slot,
        uint index,
        uint elementSize
    ) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(slot))) + (index * elementSize);
    }

    function getMapLocation(uint slot, uint key) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(key, slot)));
    }
}
