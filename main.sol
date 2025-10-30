// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract main {
    // 合约内函数外的都是 state variable
    // 存储在链上
    uint256 public num = 123;
    
    // 构造函数
    constructor(){}
    // constructor(address initialOwner){
    //     owner = initialOwner;
    // }
    
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

    // 映射
    // key 只能用内置类型
    // 存储位置必须是 storage，可以用于【合约变量】、【函数中的 storage 变量】和【library 函数的参数】
    mapping (uint => address) public idToAddress;

    function testMapping() public returns(address) {
        idToAddress[1] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        return idToAddress[1];
    }

    // 修饰器，在函数调用前执行
    address owner;
    modifier onlyOwner(uint x) {
        x = 666;
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) external onlyOwner(12) {
        owner = newOwner;
    }

    // 事件
    // 事件声明，indexed 会被记录在 EVM 日志中
    event Transfer (address indexed from, address indexed to, uint256 value);
    
    mapping(address => uint256) public _balance;


    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    function _transfer (
        address from,
        address to,
        uint256 amount
    ) external {
        _balance[from] = 10000000;
        _balance[from] -= amount;
        _balance[to] += amount;

        // 释放事件
        emit Transfer(from, to, amount);
    }
}

// 继承
// 1. 普通继承，父合约要再函数上加 virtual，子合约要写 override
// 2. 多重继承，要按照顺序写，先写爷爷、再写爸爸；如果一个函数在爷爷和爸爸都存在，儿子必须重写，并且在 override 后面填进去爷爷和爸爸的名字
// 3. 菱形继承，super 会调用被一个被继承的合约里的函数

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

contract Baba is Yeye{
    // 继承两个function: hip()和pop()，输出改为Baba。
    function hip() public virtual override{
        emit Log("Baba");
    }

    function pop() public virtual override{
        emit Log("Baba");
    }

    function baba() public virtual{
        emit Log("Baba");
    }
}


contract God {
    event Log(string message);

    function foo() public virtual {
        emit Log("God.foo called");
    }

    function bar() public virtual {
        emit Log("God.bar called");
    }
}

contract Adam is God {
    function foo() public virtual override {
        emit Log("Adam.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Adam.bar called");
        super.bar();
    }
}

contract Eve is God {
    function foo() public virtual override {
        emit Log("Eve.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Eve.bar called");
        super.bar();
    }
}

contract people is Adam, Eve {
    function foo() public override(Adam, Eve) {
        super.foo();
    }

    function bar() public override(Adam, Eve) {
        super.bar();
    }
}

// 抽象合约
// 和 C++ 非常类似，如果合约内有一个函数没有 compound，那么这个合约必须用 abstarct 修饰，用来被人继承
abstract contract Base {
    string public name = "I am abstract contract.";
    function getAlias() public pure virtual returns(string memory);
}

contract BaseImpl is Base {
    function getAlias() public pure override returns(string memory) {
        return ("hello");
    } 
}


// 接口，和抽象合约类似，不实现任何功能
// 1. 不能包含状态变量、构造函数、不能继承非接口的合约、所有函数都是 external
// 2. 继承接口的合约必须实现所有函数
contract interactBAYC {
    // 利用BAYC地址创建接口合约变量（ETH主网）
    IERC721 BAYC = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);

    // 通过接口调用BAYC的balanceOf()查询持仓量
    function balanceOfBAYC(address owner) external view returns (uint256 balance){
        return BAYC.balanceOf(owner);
    }

    // 通过接口调用BAYC的safeTransferFrom()安全转账
    function safeTransferFromBAYC(address from, address to, uint256 tokenId) external{
        BAYC.safeTransferFrom(from, to, tokenId);
    }

    // library
    using Strings for uint256;
    function getString1(uint256 _number) external pure returns(string memory) {
        // 库合约中的函数被 using 之后可以直接被调
        return _number.toHexString();
    }
}

// 回调函数，用于 接收 ETH
contract CallbackFunction {
    // Solidity 支持两种回调用函数： receive 和 fallback
    // 接收 ETH 的时候这俩二选一
    /**
            触发fallback() 还是 receive()?
                接收ETH
                    |
                msg.data是空？
                    /  \
                是    否
                /      \
        receive()存在?   fallback()
                / \
            是  否
            /     \
        receive()   fallback()
    **/

    event Received(address Sender, uint256 Value);

    receive () external payable {
        emit Received(msg.sender, msg.value);
    }
    
    event fallbackCalled(address Sender, uint Value, bytes Data);
    
    fallback() external payable{
        emit fallbackCalled(msg.sender, msg.value, msg.data);
    }
}

// 接收 ETH
contract ReceiveETH {
    // 收到 ETH，记录 amount 和 gas
    event Log(uint256 amount, uint256 gas);

    // receive 函数，接收 ETH 时触发
    receive() external payable {
        emit Log(msg.value, gasleft());
    }

    // 返回合约的 ETH 余额
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}

// 发送 ETH
contract SendETH {
    // 构造函数，payable使得部署的时候可以转 eth 进去
    constructor() payable{}

    // receive 方法，接收eth时被触发
    receive() external payable{}

    // 三种发送方法
    // 1. transfer，gas 限制 2300，如果失败会 revert
    function transferETH(address payable _to, uint256 amount) external payable {
        _to.transfer(amount);
    }

    // 2. send，gas 限制 2300，对方的 receive/fallback 不能太复杂，失败不会 revert
    // 几乎没有人用
    
    // 用 send 发送 ETH 失败 error
    error SendFailed(); 

    function sendETH(address payable _to, uint256 amount) external payable {
        bool success = _to.send(amount);
        if (!success) {
            revert SendFailed();
        }
    }

    // 3. call，没有 gas 限制，支持对方合约的复杂 receive/fallback 实现，失败不会 revert
    // 最优选择
    function callETH(address payable _to, uint256 amount) external payable {
        
    }
}

