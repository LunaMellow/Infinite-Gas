// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract HelloName {

    event Hello(string _name);

    // Function uses 2856 gas 🔥
    function hello(string memory _name) public {
        emit Hello(_name);
    }

}