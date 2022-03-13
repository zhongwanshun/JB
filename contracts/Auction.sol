// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//定义合约AuctionStore
contract AuctionStore {
    // enum ProductStatus {
    //     Open, //拍卖开始
    //     Sold, //已售出,交易成功
    //     Unsold //为售出，交易未成功
    // }
    //商品(分类)是否存在的记录
    mapping(string => bool) goodsChk;
    //定义商户结构体
    struct Bid {
        address bidder;
        uint256 value;
    }
    uint256 public productIndex;
    // 通过地址查找到对应的商品集合
    // mapping(address => mapping(uint256 => Product)) stores;

    //定义商品结构体
    struct Product {
        //商品id
        uint256 id;
        //商品名称
        string name;
        //商品分类
        string category;
        //开始竞标时间
        uint256 auctionStartTime;
        //竞标结束时间
        uint256 auctionEndTime;
        //拍卖价格
        uint256 startPrice;
        //商品所有者
        address ower;
        //商品状态
        bool status;
        //最终受益人(出价高者)
        address highestBidder;
        //最高价格
        uint256 highestprice;
        //出价人数
        uint256 totalBidders;
    }

    //初始化产品id，后面自增
    constructor() {
        productIndex = 0;
    }

    mapping(uint256 => Product) requests;

    //添加商品到区块链中
    function addProductToStore(
        string memory _name,
        string memory _category,
        uint256 _startPrice
    ) public returns (bool) {
        //商品ID自增
        // Product memory products = Product({
        Product storage r = requests[productIndex];
        r.id = productIndex;
        r.name = _name;
        r.category = _category;
        r.startPrice = _startPrice;
        r.ower = msg.sender;
        r.highestBidder = msg.sender;
        r.status = false;
        r.highestprice = _startPrice;
        productIndex = productIndex + 1;
        return true;
    }

    //通过商品ID读取商品信息(获取商品信息)
    function getProduct(uint256 _productId)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            uint256,
            address,
            bool
        )
    {
        //id数等于商品传进来的id
        uint256 idnumber = requests[_productId].id;
        string memory name = requests[_productId].name;
        string memory category = requests[_productId].category;
        // uint256 auctionStartTime = requests[_productId].auctionStartTime;
        // uint256 auctionEndTime = requests[_productId].auctionEndTime;
        uint256 startPrice = requests[_productId].startPrice;
        address ower = requests[_productId].ower;
        bool status = requests[_productId].status;
        return (
            idnumber,
            name,
            category,
            // auctionStartTime,
            // auctionEndTime,
            startPrice,
            ower,
            status
        );
    }

    //通过商品的类别显示商品的信息

    //设置拍卖开始
    function setAuctionStart(uint256 id, uint256 _timeLimit)
        public
        returns (bool)
    {
        //前提是拍卖还没开始
        //开始时间需要小于结束时间
        //
        require(requests[id].ower == msg.sender, "no ower");
        //合约开始(初始化的时候是flase,取反)
        require(!requests[id].status, "auction already start");
        // beneficiary = payable(address(uint160(msg.sender)));
        //对应商品的开始时间等于当前时间戳
        requests[id].auctionStartTime = block.timestamp;
        //设置拍卖期限
        //当前商品结束拍卖的时间等于初始化的时候的时间戳+传入的时间
        requests[id].auctionEndTime = block.timestamp + _timeLimit;
        //设置拍卖已开始
        requests[id].status = true;
        //拍卖开始事件
        // emit AuctionStartEvt(msg.sender);
        return true;
    }

    //获取目前最高的出价是多少
    function getMoney(uint256 id) public view returns (uint256) {
        require(requests[id].highestBidder == msg.sender, "no one to bid");
        return requests[id].highestprice;
    }

    //出价
    function tobid(uint256 id) public payable {
        //发出一个出价事件,出价人，和出价多少
        //拍卖需已经开始
        require(requests[id].status, "auction not yet start");
        //最高出价者不是当前出价竞标者（即已经是最高出价者没有再次出价太高自己的最高价格）
        require(requests[id].ower != msg.sender, "You can't yourself");
        //区块时间需早于拍卖期限
        require(
            block.timestamp <= requests[id].auctionEndTime,
            "auction ended"
        );
        //出价需高于最高金额
        require(msg.value > requests[id].startPrice, "less than highest bid");
        require(msg.value > requests[id].highestprice, "less than highest bid");
        payable(requests[id].highestBidder).transfer(requests[id].highestprice);
        requests[id].highestprice = msg.value;
        requests[id].highestBidder = msg.sender;
    }

    //违约(咋交易还没有结束之前毁约)
    function huiyue(uint256 id) public payable {
        //拍卖需已经开始
        require(requests[id].status, "auction not yet start");
        //最高出价者不是当前出价竞标者（即已经是最高出价者没有再次出价太高自己的最高价格）
        require(requests[id].ower != msg.sender, "You can't yourself");
        //区块时间需早于拍卖期限
        require(
            block.timestamp <= requests[id].auctionEndTime,
            "auction ended"
        );
        requests[id].highestprice = requests[id - 1].highestprice;
        requests[id].highestBidder = msg.sender;
    }

    //设置合约结束的时间
    function setAuctionEnd(uint256 id) public {
        //区块时间需大于拍卖期限
        require(block.timestamp >= requests[id].auctionStartTime, "notime");
        require(requests[id].status = true, "auction not yet ended");
        requests[id].status = false;
        requests[id].auctionStartTime = 0;
        requests[id].auctionEndTime = 0;
        requests[id].startPrice = requests[id].highestprice;
        requests[id].ower = requests[id].highestBidder;
    }

    //f方法一:查询余额
    function getBalance(address addr) public view returns (uint256) {
        return addr.balance;
    }

    //方法二:获取合约地址
    // function getCurrentBalance() public view returns (uint256) {
    //     return address(this).balance;
    // }

    //查询合约余额
    function queryBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //帮助方法
    //1. 获取竞标赢家信息
    function highestBidderInfo(uint256 id)
        public
        payable
        returns (address, uint256)
    {
        return (
            requests[id].highestBidder = msg.sender,
            requests[id].highestprice = msg.value
        );
    }

    // 获取参与竞标的总人数
    function totalBids(uint256 id) public view returns (uint256) {
        return requests[id].totalBidders;
    }
}
