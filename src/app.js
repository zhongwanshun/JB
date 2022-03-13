// // var fs = require("fs");
// var Web3 = require("web3");
// //连接到Ganache
// var web3 = new Web3(new Web3.providers.HttpProvider('HTTP://127.0.0.1:7850'));
// console.log(web3);


// // In Node.js
// const Web3 = require('web3');

let web3 = new Web3('HTTP://127.0.0.1:7850');
console.log(web3);

var data = readFileSync("../build/contracts/AuctionStore.json", "utf-8");

//创建合约对象
var contract = new web3.eth.Contract(JSON.parse(data), '0xc8b522331e8A2369e87Cb4be6bE7C74Be86f1AAB');

//调用合约的方法
//我们可以在Remix中设置，在这里读取，或者反过来。交叉验证更加直观。
contract.methods.retreive().call().then(console.log);
contract.methods.store(200).send({ from: '0x51BF497D8B47C5754220be9256F0Cb9E2Cd688B8' }).then(console.log);



// const address = "0xcD2A77901dF6c89166A2B2eFBeF2436F72F1B569"

// // 读取address中的余额，余额单位是wei
// web3.eth.getBalance(address, (err, wei) => {
//     // 余额单位从wei转换为ether
//     balance = web3.utils.fromWei(wei, 'ether')
//     console.log("balance: " + balance)
// });

//存储所有地址
// let wsaccounts = [];

// web3.eth.getBalance("0xFC34093114242317EFe87e2f5AD159F2002E1d62")
//     .then(console.log);





// //1.获取账户地址
// const ethereumButton = document.querySelector('.enableEthereumButton');




// ethereumButton.addEventListener('click', () => {
//     //Will Start the metamask extension
//     ethereum.request({ method: 'eth_requestAccounts' });
//     getAccount();
//     console.log("eth_requestAccounts");
// });
// // //1.1获取账户地址
// async function getAccount() {
//     wsaccounts = await ethereum.request({ method: 'eth_requestAccounts' });
//     const account = wsaccounts[0];
//     // We currently only ever provide a single account,
//     // but the array gives us some room to grow.
//     console.log("account=>", account);
//     $(".showAccount").html(account);
// }

//GetAccount
// web3.eth.getAccounts()
//     .then(console.log);

// //方法二：
// let zwsaccounts = [];
// web3.eth.getAccounts().then(function(accounts) {
//     zwsaccounts = accounts
//     console.log(zwsaccounts[0])

// });
//Send Eth
// const sendEthButton = document.querySelector('.sendEthButton');
//sendTransaction
// sendEthButton.addEventListener('click', () => {
//     web3.eth.sendTransaction({
//             from: zwsaccounts[0], //从哪个账号进行转账(当前账号转出)
//             to: '0x1006Cd35e5A3d25f8c056f680794C5E9D5E61a96', //给第二个账号
//             value: '10000000000000000'
//         })
//         .then(function(receipt) {
//             console.log("send finished")
//         });
// });

// //getBalance
// /*
// web3.eth.getBalance(address [, defaultBlock] [, callback])
// */
// //需要传入一个地址
// web3.eth.getBalance("0x5f69fA6e5e694965C5ADdB50670C29eBE07f3901")
//     .then(console.log);

// //订阅事件
// var subscription = web3.eth.subscribe('logs', {
//     address: '0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8', //ERC20部署的合约地址
//     // topics: ['0x12345...']//过滤器
// }, function(error, result) {
//     if (!error)
//         console.log(result);
// });