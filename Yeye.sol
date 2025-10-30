// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract Yeye {
    event Log(string msg);
    
    // 定义3个function: hip(), pop(), yeye()，Log值为Yeye。
    function hip() public virtual{
        emit Log("Yeye");
    }

    function pop() public virtual{
        emit Log("Yeye");
    }

    function yeye() public virtual {
        emit Log("Yeye");
    }
}