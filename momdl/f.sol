// 指定编译环境版本的
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;
/**
 * owned 是合约的管理者
*/

contract owned {
    address public owner; // 变量账户地址

   /**
    * 初始化构造函数
    * 部署到以太坊节点会被执行一次
    * 把部署者的账户地址赋值给一个变量值
    * 这个变量值会被存储到区块链的账本中
   */
   contructor() public view {
       owner = msg.sender;
   }

   /**
    * 这里是一个函数修改器，用于限制方法的行为
    * 判断当前合约的调用者是否是合约的所有者
    * 必须使用当时部署合约的地址才可以调用
   */
    modifier onlyOwner {
        require(msg.sender == owner, "sender is not authorized");
        _;
    }

    /**
     * 合约的所有者指派一个新的管理员
     * 也就是更改管理员地址
     * @param newOwner address 新的管理账户地址
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

/** 接下来是业务逻辑的合约 **/

// 这里继承了前面权限管理的合约
contract Commodity is owned {

    // 这个结构体包含了商品的各个属性
    struct Comminfo {
        string account_name; // 商品名称
        string code; // 商品编号
        string number; // 商品数量
        uint8 status; // 1是上架，2是下架
    }

    // 商品信息不止登记一条
    // 所有商品信息保存在这个mapping这个映射中
    // 记录所有数据映射
    mapping(uint => Comminfo) commof;

    // 整个商品信息有多少条的统计
    uint[] lengths;

    // 表明有多少条商品信息登记了
    // 获取长度
    function getLength() public view returns (uint len) {
        return lengths.length;
    }

    // 这里是一个登记的方法，也是保存
    // 在这个方法里包含的各个参数属性
    // 相当于在mapping状态变量里面继续新增一条商品信息记录
    // 实现新增功能
    function saveinfo(
        string memory account_names,
        string memory codes,
        string memory numbers,
        uint8 status statusw
    ) public {
        uint les = lengths.length;

        commOf[les].account_name = account_names;
        commOf[les].code = codes;
        commOf[les].number = numbers;
        commOf[les].status = statusw;
        lengths.push(les);
    }

    // 查询数据
    function selectAll(uint key) public view returns (
        string memory account_name,
        string memory code,
        string memory number,
        uint8 status,
        uint id
    ) {
        account_name = commOf[key].account_name;
        code = commOf[key].code;
        number = commOf[key].number;
        status = commOf[key].status;
        id = key;

        return (account_name, code, number, status, id);
    }

    // 判断商品信息是否已经存在，重复性判断
    // 两个string比较
    function utilCompareInternal(string memory a, string memory b) internal pure returns (bool succ) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        }
        for (uint i = 0; i< bytes(a).length; i ++) {
            if(bytes(a)[i] != bytes(b)[i]) {
                return false;
            }
        }
        return true;
    }

    // 根据商品代码获取商品信息
    function selectOne(uint key, string memory code) public view returns (bool result) {
        return utilCompareInternal(commOf[key].code, code);
    }

    // 设置商品的上架、下架状态
    function update(uint key) public {
        if(commOf[key].status == 1) {
            commOf[key].status = 2;
        } else {
            commOf[key].status = 1;
        }
    }
}

