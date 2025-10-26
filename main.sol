// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract main {
    // 合约内函数外的都是 state variable
    // 存储在链上
    uint256 public num = 123;
    
    // 构造函数
    constructor(){}
    
    function add() external {
        num = num + 1;
    }

    // pure 函数
    // 不改变链上状态，不读也不写
    function addPure(uint256 number) external pure returns(uint256 viewNumber) {
        viewNumber = number + 1;
    }

    // internal 函数
    // 只能被合约内部的函数调用，相当于 private
    function minus() internal {
        num = num - 1;
    }

    // external 函数
    // 只能被合约外部调用
    // public 是合约内部和外部都可以
    function minusExternal() external {
        minus();
    }

    // payable 函数
    // 运行时能够转入 eth
    // this 指针能够直接引用本合约的地址
    // 命名式返回 balance，不用显式 return，并且这个变量可以直接用
    function minusPaybale() external payable returns(uint256 balance) {
        minus();
        balance = address(this).balance;
    }

    // returns 和 return

    // 1. returns 在函数签名中声明返回值类型
    // 2. return 在函数体内直接返回数据
    // [1, 2, 3] 默认是 uint8，所以需要第一个强转为 uint256 来声明后面的也都是 256
    function returnMultiple() public pure returns(uint256, bool, uint256[3] memory) {
        return (666, true, [uint256(777), 888, 999]);
    }

    function returnMultipleName() public pure returns(uint256 _number, bool _bool, uint256[3] memory) {
        return (666, true, [uint256(777), 888, 999]);
    }

    // 返回值解包
    function readReturn() public pure {
        bool flag;
        (, flag, ) = returnMultiple();
    }

    // 数据存消耗 gas 排序：storage（链上） > memory（临时内存，不上链） > calldata（临时内存，无法修改）
    // 目的是根据不同的存储类型，节省链上有限的存储空间和降低 gas 费用
    // reference type: array, struct
    
    // calldata
    // TypeError: Calldata arrays are read-only.
    function testCalldata(uint[] calldata _x) public pure returns(uint[] calldata) {
        // return _x; 似乎也可以
        return (_x);
    }

    uint[] y = [1, 2, 3];

    // 引用和副本
    function modifyVariable() public {
        uint256 x = 1;
        x = 2;
        
        // 会同步修改 y 内存地址的值
        uint[] storage yStorage = y;
        yStorage[1] = 999;
    }

    // 状态变量
    // state（上链）, local（函数执行期间）, global（全局）
    function globalVariable() external view returns(address, uint, bytes memory) {
        address sender = msg.sender;
        uint blockNum = block.number;
        bytes memory data = msg.data;
        return (sender, blockNum, data);
    }

    // 小数
    // solidity 不存在小数点，以 0 代替小数点
    // wei = 1
    // gwei = 1e9
    // ether = 1e18
    function testDecimal() external pure returns(uint, uint, uint) {
        assert(1 wei == 1e0);
        assert(1 wei == 1);

        assert(1 gwei == 1e9);
        assert(1 gwei == 1000000000);

        assert(1 ether == 1e18);
        assert(1 ether == 1000000000000000000);

        return (1 wei, 1 gwei, 1 ether);
    }

    // 时间单位
    // 可以执行很多定时任务
    function timeUnit() external pure returns(uint, uint, uint, uint, uint) {
        assert(1 seconds == 1);
        
        assert(1 minutes == 60);
        assert(1 minutes == 60 seconds);
        
        assert(1 hours == 3600);
        assert(1 hours == 60 minutes);

        assert(1 days == 86400);
        assert(1 days == 24 hours);

        assert(1 weeks == 604800);
        assert(1 weeks == 7 days);

        return (1 seconds, 1 minutes, 1 hours, 1 days, 1 weeks);
    }

    uint[] arrNotFixed;

    function arrayPush() external returns(uint[] memory, uint){
        // 定长数组
        uint[5] memory arr = [uint(1), 2, 3, 4, 5];
        
        arrNotFixed = arr;
        arrNotFixed.push(6);
        arrNotFixed.push(7);

        return (arrNotFixed, arrNotFixed.length);
    }

    // 结构体
    struct Student {
        uint256 id;
        uint256 score;
        bytes name;
    }

    Student student;

    function init_student_by_assign() external returns (Student memory){
        Student storage _student = student;
        _student.id = 123;
        _student.score = 99;
        _student.name = "Alice";
        return _student;
    }

    function init_student_by_direct() external {
        student.id = 456;
        student.score = 88;
        student.name = "Bob";
    }

    function init_student_by_constructor() external {
        student = Student(1, 2, "3");
    }

    function init_student_by_kv() external {
        student = Student({
            id: 0,
            score: 2,
            name: "-2"
        });
    }

}
