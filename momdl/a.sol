//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract EthPump {
    //合约主持人EOA
    address private host;

    //物品信息
    struct Goods {
        address owner; //出借人EOA
        address borrower; //借用人EOA
        uint256 ethPledge; //押金
        bool available; //是否已上架
        bool isBorrow; //是否已借出
        bool exist;
    }

    //存储所有贴纸(分类)信息
    mapping(string => mapping(uint256 => Goods)) goodsData;

    //所有贴纸(分类)物品笔数
    mapping(string => uint256) goodsInx;

    //贴纸(分类)是否存在的记录
    mapping(string => bool) goodsChk;

    //记录合约主持人
    constructor() {
        host = msg.sender;
    }

    //只有主持人才可执行
    modifier onlyHost() {
        require(msg.sender == host, "only host can do this");
        _;
    }

    //查询贴纸(分类)是否已经存在
    function isStickExist(string memory stickName) public view returns (bool) {
        return goodsChk[stickName];
    }

    //添加一种贴纸(分类)
    function addSticker(string memory stickName) public onlyHost {
        //贴纸(分类)不存在，才可以添加
        require(!isStickExist(stickName), "stick already exist");

        //设置可以使用此类贴纸
        goodsChk[stickName] = true;

        //触发添加贴纸的事件
        emit addStickerEvnt("addSticker", stickName);
    }

    //添加贴纸(分类)事件
    event addStickerEvnt(string indexed eventType, string stickName);

    //添加物品
    function addGoods(
        string memory stickName,
        uint256 ethPledge,
        bool available
    ) public returns (uint256) {
        //贴纸(分类)必须存在
        require(isStickExist(stickName), "stick not exist");

        //物品序号加1
        goodsInx[stickName] += 1;
        uint256 inx = goodsInx[stickName];

        //新的物品信息
        Goods memory goods = Goods({
            owner: msg.sender, //出借人EOA
            borrower: address(0), //借用人EOA
            ethPledge: ethPledge, //押金
            available: available, //是否已上架
            isBorrow: false, //是否已借出
            exist: true //确认信息存在
        });

        //数据存储至映射结构
        goodsData[stickName][inx] = goods;

        //触发添加物品事件
        emit addGoodsEvnt("addGoods", stickName, inx);

        //返回数据索引
        return inx;
    }

    //添加物品事件
    event addGoodsEvnt(string indexed eventType, string stickName, uint256 inx);

    //判断物品是否存在
    function isGoodExist(string memory stickName, uint256 inx)
        public
        view
        returns (bool)
    {
        //贴纸(分类)必须存在
        require(isStickExist(stickName), "stick not exist");

        return goodsData[stickName][inx].exist;
    }

    //设置物品上下架
    function setGoodsStatus(
        string memory stickName,
        uint256 inx,
        bool available
    ) public {
        //物品必须存在
        require(isGoodExist(stickName, inx), "goods not exist");

        //必须是出借人才可以改变状态
        require(
            goodsData[stickName][inx].owner == msg.sender,
            "not goods owner"
        );

        //物品必须没被借出
        require(!goodsData[stickName][inx].isBorrow, "goods already lend");

        //改变上下架状态
        goodsData[stickName][inx].available = available;
    }

    //查询物品是否上下架
    function isGoodsAvailable(string memory stickName, uint256 inx)
        public
        view
        returns (bool)
    {
        //物品必须存在
        require(isGoodExist(stickName, inx), "goods not exist");

        //返回上下架状态
        return goodsData[stickName][inx].available;
    }

    //查询物品借出状态
    function isGoodsLend(string memory stickName, uint256 inx)
        public
        view
        returns (bool)
    {
        //物品必须存在
        require(isGoodExist(stickName, inx), "goods not exist");

        //返回借出状态
        return goodsData[stickName][inx].isBorrow;
    }

    //借出物品
    function borrowGoods(string memory stickName, uint256 inx) public payable {
        //物品必须存在
        require(isGoodExist(stickName, inx), "goods not exist");

        //物品必须是可用状态
        require(goodsData[stickName][inx].available, "goods not available");

        //物品必须没被借出
        require(!goodsData[stickName][inx].isBorrow, "goods already lend");

        //押金必要符合设置
        require(
            goodsData[stickName][inx].ethPledge == msg.value,
            "eth pledge not match"
        );

        //设置借用人EOA
        goodsData[stickName][inx].borrower = msg.sender;

        //设置为已借出
        goodsData[stickName][inx].isBorrow = true;

        //触发借出事件
        emit borrowGoodsEvnt("borrowEvn", stickName, inx, msg.sender);
    }

    //物品借出事件
    event borrowGoodsEvnt(
        string indexed eventType,
        string stickName,
        uint256 inx,
        address borrower
    );

    //查询物品借出人
    function queryBorrower(string memory stickName, uint256 inx)
        public
        view
        returns (address)
    {
        //物品必须存在
        require(isGoodExist(stickName, inx), "goods not exist");

        //物品必须已被借出
        require(goodsData[stickName][inx].isBorrow, "goods not lend");

        //返回借出人
        return goodsData[stickName][inx].borrower;
    }

    //设置物品已归还
    function doGoodsReturn(string memory stickName, uint256 inx) public {
        //物品必须存在
        require(isGoodExist(stickName, inx), "goods not exist");

        //必须是出借人才可以改变状态
        require(
            goodsData[stickName][inx].owner == msg.sender,
            "not goods owner"
        );

        //物品必须已被借出
        require(goodsData[stickName][inx].isBorrow, "goods not lend");

        //将押金返还借用人
        uint256 pledge = goodsData[stickName][inx].ethPledge;
        payable(goodsData[stickName][inx].borrower).transfer(pledge);

        //触发归还事件
        emit returnGoodsEvnt(
            "returnEvn",
            stickName,
            inx,
            goodsData[stickName][inx].borrower
        );

        //设置借用人EOA
        goodsData[stickName][inx].borrower = address(0);

        //设置为未借出
        goodsData[stickName][inx].isBorrow = false;
    }

    //物品归还事件
    event returnGoodsEvnt(
        string indexed eventType,
        string stickName,
        uint256 inx,
        address borrower
    );

    //查询合约余额
    function queryBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
