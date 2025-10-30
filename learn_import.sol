// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 通过文件相对位置
import './Yeye.sol';

// 全局符号
import {Yeye} from './Yeye.sol';

// 通过 url 引入，不知道为什么不行
// import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol';
import "@openzeppelin/contracts/utils/Address.sol";

// 通过 OpenZeppelin 引入
import '@openzeppelin/contracts/access/Ownable.sol';

contract Import {
    // 测 url 引入的 Address
    using Address for address;
    // 测试 Yeye
    Yeye yeye = new Yeye();

    function test() external returns(address, address, bool) {
        yeye.hip();

        // 检查当前地址是否为合约
        // bool isThisCOntract = address(this).isContract();

        return (address(this), msg.sender, true);
    }
}

