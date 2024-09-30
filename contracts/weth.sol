// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract WETH {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst,uint wad);
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    uint public totalSupply;

    // 存款
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 提款
    function withdrawal(uint wad) public {
        require(balanceOf[msg.sender] >= wad, "Insufficient balance");
        balanceOf[msg.sender] = balanceOf[msg.sender] - wad;
        totalSupply -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    // 转账
    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    // 从一个地址转到另一个地址
    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        require(balanceOf[src]>=wad,"insufficient balance");
        if (src != msg.sender && allowance[src][msg.sender] != type(uint).max){
            require(allowance[src][msg.sender] >= wad, "Insufficient allowance");
            allowance[src][msg.sender] -= wad;
        }
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        return true;
     }

     // 授权
     function approve(address guy, uint wad) public returns (bool)  {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true ;
     }
}