//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;
contract BlindAuction {
  // 定义一个出价对象
  struct Bid {
    bytes32 blindedBid;
    uint deposit;
  }

  // 定义状态变量：受益人、开始时间、拍卖结束时间、公示结束时间
  address public beneficiary;
  uint public auctionStart;
  uint public biddingEnd;
  uint public revealEnd;

  // 拍卖结束后，设置这个值为true，不允许被修改。
  bool public ended;

  // 存储拍卖信息的集合
  mapping(address => Bid[]) public bids;

  // 最高的出价者
  address public highestBidder;
  // 最高出价
  uint public highestBid;

  // 拍卖结束时调用事件
  event AuctionEnded(address winner, uint highestBid);

  // modifier可以方便的验证输入信息
  modifier onlyBefore(uint _time) { if (now >= _time) throw; 
  modifier onlyAfter(uint _time) { if (now <= _time) throw; 

  // 创建一个拍卖对象，初始化参数值：受益人、开始时间、
  // 拍卖持续时间、公示时间 
  function BlindAuction(
    uint _biddingTime, 
    uint _revealTime, 
    address _beneficiary
  ) {
    beneficiary = _beneficiary;
    auctionStart = now;
    biddingEnd = now + _biddingTime;
    revealEnd = biddingEnd + _revealTime;
  }

  // 把出价信息用sha3加密后发送给拍卖系统，确保原始数据不被暴露
  // 同一个地址可以多次出价
  function bid(bytes32 _blindedBid) 
    onlyBefore(biddingEnd) 
  {
    bids[msg.sender].push(Bid({
      blindedBid: _blindedBid, 
      deposit: msg.value
    }));
  }

  /// 拍卖结束后，显示所有出价信息。
  /// 除了最高价之外的所有正常出价会被退款
  function reveal(
    uint[] _values,
    bool[] _fake,
    bytes32[] _secret
  )
    onlyAfter(biddingEnd)
    onlyBefore(revealEnd)
  {
    uint length = bids[msg.sender].length;
    if (
      _values.length != length ||
      _fake.length != length ||
      _secret.length != length

    ) {
      throw;
    }

    uint refund;
    for (uint i = 0; i < length; i++) {
      var bid = bids[msg.sender][i];
      var (value, fake, secret) = (_values[i], _fake[i], _secret[i]);
      if (bid.blindedBid != sha3(value, fake, secret)) {
        continue;
      }
      refund += bid.deposit;
      if (!fake && bid.deposit >= value) {
        if (placeBid(msg.sender, value))
          refund -= value;
      }

      bid.blindedBid = 0;
    }
    msg.sender.sent(refund);
  }

  // 这是个内部函数，内部出价逻辑。只能被合约本身调用
  function placeBid(address bidder, uint value) internal
    returns (bool success)
  {
    if (value <= highestBid) {
      return false;
    }
    if (highestBidder != 0) {
      highestBidder.sender(highestBid);
    }
    highestBid = value;
    highestBidder = bidder;
    return true;
  }

  // 结束拍卖，发送最高出价给商品所有者
  function auctionEnd()
    onlyAfter(revealEnd)
  {
    if (ended)
      throw;
    AuctionEnded(highestBidder, highestBid);
    beneficiary.send(this.balance);
    ended = true;
  }

  // 当交易没有数据或者数据不对时，触发此函数，
  // 重置出价操作，确保出价者不会丢失资金
  function () {
    throw;
  }
}