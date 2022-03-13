//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
// import "http://47.99.87.207:8080/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    //constructor是用于构造函数的
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        //铸造
        _mint(msg.sender, 100 * 10**uint256(decimals()));
    }

    function getDEctmals() public view returns (uint256) {
        return decimals();
    }
}
