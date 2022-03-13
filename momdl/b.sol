//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//需求
// 实现一个类似闲鱼交易市场，用户可以发售商品，也可以购买商品。

// 思路
// 用户将自己要卖的物品发布到平台上面，定下展示期限。 由智能合约自动处理，到期之后就下架，用户从物品发布到下架或者卖出的过程中全程透明，所有人都可以看到。
// 用户可以点击展示详情页面购买物品， 购买物品需要一定的手续费。
// 用户可以自己发布物品
// 可以查看当前物品列表
// 可以查看指定物品详情
// 可以转让物品给其他用户

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Utils {
    function stringToBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 x) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        for (uint256 j = 0; j < 32; j++) {
            bytes1 char = bytes1(bytes32(uint256(x) * 2**(8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }
}

contract Store is Utils {
    using SafeMath for uint256;

    address owner;

    struct Customer {
        address customerAddr; //用户地址
        bytes32 username; //用户用户名
        bytes32 password; //用户密码
        bytes32[] customerGoods; //用户购买的商品
        bytes32[] merchantGoods; //用户发布的商品
    }

    struct Good {
        bytes32 goodID; //商品ID
        bytes32 goodname; //商品名
        uint256 price; //商品价格
        bool isBought; //商品是否已被购买
        uint256 showTime; //商品展示时间
        uint256 releaseTime; //发布时间
        address[] transferProcess; //商品流通过程
    }

    mapping(address => Customer) customers; //所有顾客

    mapping(bytes32 => Good) goods; //所有商品
    mapping(bytes32 => address) goodToOwner; //根据商品Id查找该件商品当前拥有者

    address[] customersAddr; //所有顾客的地址
    bytes32[] goodsID; //所有商品

    //约束条件——合约创建者
    modifier onlyOwner() {
        if (msg.sender == owner) _;
    }

    //约束条件——商品当前拥有者
    modifier onlyOwnerOf(bytes32 _goodID) {
        require(msg.sender == goodToOwner[_goodID]);
        _;
    }

    //合约构造函数
    constructor() public {
        owner = msg.sender;
    }

    //获得owner地址
    function getOwner() public view returns (address) {
        return owner;
    }

    //判断用户是否已注册
    function isCustomerRegistered(address _customerAddr)
        internal
        view
        returns (bool)
    {
        bool isRegistered = false;
        for (uint256 i = 0; i < customersAddr.length; i++) {
            if (customersAddr[i] == _customerAddr) {
                return isRegistered = true;
            }
        }
        return isRegistered;
    }

    //判断商品是否已存在
    function isGoodExisted(bytes32 _goodID) internal view returns (bool) {
        bool isExisted = false;
        for (uint256 i = 0; i < goodsID.length; i++) {
            if (goodsID[i] == _goodID) {
                return isExisted = true;
            }
        }
        return isExisted;
    }

    //判断商品是否到期
    function isTimeOut(bytes32 _goodID) public view returns (bool) {
        if (now > (goods[_goodID].showTime + goods[_goodID].releaseTime)) {
            return false;
        } else {
            return true;
        }
    }

    //用户注册
    event RegisterCustomer(
        address _customerAddr,
        bool isSuccess,
        string message
    );

    //用户地址 用户名  用户密码
    function registerCustomer(
        address _customerAddr,
        string _username,
        string _password
    ) public {
        if (!isCustomerRegistered(_customerAddr)) {
            customers[_customerAddr].customerAddr = _customerAddr;
            customers[_customerAddr].username = stringToBytes32(_username);
            customers[_customerAddr].password = stringToBytes32(_password);
            customersAddr.push(_customerAddr);
            emit RegisterCustomer(_customerAddr, true, "final"); //注册成功
            return;
        } else {
            emit RegisterCustomer(
                _customerAddr,
                false,
                "yijingzhuce" //地址已被注册，注册失败
            );
            return;
        }
    }

    //用户登录
    event CustomerLogin(address _customerAddr, bool isSuccess, string message);

    // 用户地址  用户密码
    function customerLogin(address _customerAddr, string _password) public {
        if (isCustomerRegistered(_customerAddr)) {
            if (
                customers[_customerAddr].password == stringToBytes32(_password)
            ) {
                emit CustomerLogin(_customerAddr, true, "denglucehnggong"); //登录成功
                return;
            } else {
                emit CustomerLogin(_customerAddr, false, "cuowu"); //密码错误，登录失败
                return;
            }
        } else {
            emit CustomerLogin(_customerAddr, false, "haiweizhuce"); //地址尚未注册，登录失败
            return;
        }
    }

    //用户发布商品
    event CustomerAddGood(
        address _customerAddr,
        bool isSuccess,
        string message
    );

    // 用户地址  商品ID  商品名 商品价格 商品展示时间
    function customerAddGood(
        address _customerAddr,
        string _goodID,
        string _goodname,
        uint256 _price,
        uint256 _showtime
    ) public {
        bytes32 id = stringToBytes32(_goodID);
        if (!isGoodExisted(id)) {
            goods[id].goodID = id;
            goods[id].releaseTime = now;
            goods[id].showTime = _showtime;
            goods[id].goodname = stringToBytes32(_goodname);
            goods[id].price = _price;
            goods[id].isBought = false;
            goods[id].transferProcess.push(_customerAddr);
            goodsID.push(id);
            customers[_customerAddr].merchantGoods.push(id);
            goodToOwner[id] = _customerAddr;
            emit CustomerAddGood(_customerAddr, true, "add good "); //添加商品成功
            return;
        } else {
            emit CustomerAddGood(
                _customerAddr,
                false,
                "yijinhgcunzai" //商品已存在，添加商品失败
            );
            return;
        }
    }

    //顾客购买商品
    event CustomerbuyGood(
        address _customerAddr,
        bool isSuccess,
        string message
    );

    function customerbuyGood(address _customerAddr, string _goodID)
        public
        payable
    {
        bytes32 id = stringToBytes32(_goodID);
        require(msg.value == goods[id].price);
        if (goodToOwner[id] != _customerAddr) {
            if (isGoodExisted(id)) {
                if (!goods[id].isBought) {
                    goodToOwner[id].transfer(msg.value);
                    goodToOwner[id] = _customerAddr;

                    goods[id].isBought = true;
                    goods[id].transferProcess.push(_customerAddr);

                    customers[_customerAddr].customerGoods.push(id);
                    emit CustomerbuyGood(_customerAddr, true, "good"); //购买成功
                    return;
                } else {
                    emit CustomerbuyGood(
                        _customerAddr,
                        false,
                        "" //商品已被购买，购买失败
                    );
                    return;
                }
            } else {
                emit CustomerbuyGood(_customerAddr, false, ""); //商品不存在
                return;
            }
        } else {
            emit CustomerbuyGood(_customerAddr, false, ""); //不能购买自己的商品
            return;
        }
    }

    //顾客转让商品
    event CustomerTransferGood(address _seller, bool isSuccess, string message);

    function customerTransferGood(
        address _seller,
        address _buyer,
        string _goodID
    ) public {
        bytes32 id = stringToBytes32(_goodID);
        if (goodToOwner[id] != _seller) {
            emit CustomerTransferGood(_seller, false, ""); //您不是该商品的拥有者
            return;
        } else {
            if (isCustomerRegistered(_buyer)) {
                goodToOwner[id] = _buyer;
                customers[_buyer].customerGoods.push(id);
                goods[id].transferProcess.push(_buyer);
                emit CustomerTransferGood(_seller, true, ""); //转让成功
                return;
            } else {
                emit CustomerTransferGood(
                    _seller,
                    false,
                    "" //您所要转让的地址尚未注册
                );
                return;
            }
        }
    }

    //查看商品流通过程
    function getGoodTransferProcess(string _goodID)
        public
        view
        returns (uint256, address[])
    {
        bytes32 id = stringToBytes32(_goodID);
        return (goods[id].transferProcess.length, goods[id].transferProcess);
    }

    //用户查看已发布商品
    function putCustomerGoods(address _customer)
        public
        view
        returns (
            uint256,
            bytes32[],
            bytes32[],
            uint256[],
            address[]
        )
    {
        uint256 length = customers[_customer].merchantGoods.length;
        bytes32[] memory goodsName = new bytes32[](length);
        uint256[] memory goodsPrice = new uint256[](length);
        address[] memory goodsOwner = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            goodsName[i] = goods[customers[_customer].merchantGoods[i]]
                .goodname;
            goodsPrice[i] = goods[customers[_customer].merchantGoods[i]].price;
            goodsOwner[i] = goodToOwner[customers[_customer].merchantGoods[i]];
        }

        return (
            length,
            customers[_customer].merchantGoods,
            goodsName,
            goodsPrice,
            goodsOwner
        );
    }

    //用户查看已购买商品
    function getCustomerGoods(address _customer)
        public
        view
        returns (
            uint256,
            bytes32[],
            bytes32[],
            uint256[],
            address[]
        )
    {
        uint256 length = customers[_customer].customerGoods.length;
        bytes32[] memory goodsName = new bytes32[](length);
        uint256[] memory goodsPrice = new uint256[](length);
        address[] memory goodsOwner = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            goodsName[i] = goods[customers[_customer].customerGoods[i]]
                .goodname;
            goodsPrice[i] = goods[customers[_customer].customerGoods[i]].price;
            goodsOwner[i] = goodToOwner[customers[_customer].customerGoods[i]];
        }

        return (
            length,
            customers[_customer].customerGoods,
            goodsName,
            goodsPrice,
            goodsOwner
        );
    }

    //查看所有商品
    function getAllGoods()
        public
        view
        returns (
            uint256,
            bytes32[],
            bytes32[],
            uint256[],
            address[]
        )
    {
        uint256 length = goodsID.length;
        bytes32[] memory goodsName = new bytes32[](length);
        uint256[] memory goodsPrice = new uint256[](length);
        address[] memory goodsOwner = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            goodsName[i] = goods[goodsID[i]].goodname;
            goodsPrice[i] = goods[goodsID[i]].price;
            goodsOwner[i] = goodToOwner[goodsID[i]];
        }

        return (length, goodsID, goodsName, goodsPrice, goodsOwner);
    }

    //获取商品价格
    function getPrice(string _goodID) public view returns (uint256) {
        return goods[stringToBytes32(_goodID)].price;
    }

    // 获取余额
    function getBalance(address addr) public view returns (uint256) {
        return addr.balance;
    }

    // 获取用户名
    function getCustomerUsername(address customer)
        public
        view
        returns (bytes32)
    {
        return customers[customer].username;
    }
}
