// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AdvancedVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public owner;
    
    event Deposit(address indexed sender, uint256 amount);
    event TokenDeposit(address indexed sender, address indexed token, uint256 amount);
    event NFTDeposit(address indexed sender, address indexed token, uint256 tokenId);
    event Withdrawal(address indexed recipient, uint256 amount);
    event TokenWithdrawal(address indexed recipient, address indexed token, uint256 amount);
    event NFTWithdrawal(address indexed recipient, address indexed token, uint256 tokenId);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // 允许任何人存入 ETH
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    // 允许任何人存入 ERC20 代币
    function depositERC20(address tokenAddress, uint256 amount) public {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit TokenDeposit(msg.sender, tokenAddress, amount);
    }

    // 允许任何人存入 ERC721 代币
    function depositERC721(address tokenAddress, uint256 tokenId) public {
        IERC721 token = IERC721(tokenAddress);
        token.transferFrom(msg.sender, address(this), tokenId);
        emit NFTDeposit(msg.sender, tokenAddress, tokenId);
    }

    // 只允许 owner 提取所有 ETH
    function withdrawAllETH() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "ETH transfer failed");
        emit Withdrawal(owner, balance);
    }

    // 提取指定的 ERC20 代币
    function withdrawERC20(address tokenAddress) public onlyOwner nonReentrant {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        token.safeTransfer(owner, balance);
        emit TokenWithdrawal(owner, tokenAddress, balance);
    }

    // 提取指定的 ERC721 代币
    function withdrawERC721(address tokenAddress, uint256 tokenId) public onlyOwner nonReentrant {
        IERC721 token = IERC721(tokenAddress);
        require(token.ownerOf(tokenId) == address(this), "This NFT is not owned by the contract");
        token.transferFrom(address(this), owner, tokenId);
        emit NFTWithdrawal(owner, tokenAddress, tokenId);
    }

    // 获取合约 ETH 余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 获取合约 ERC20 代币余额
    function getERC20Balance(address tokenAddress) public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    // 检查合约是否拥有特定的 ERC721 代币
    function hasERC721(address tokenAddress, uint256 tokenId) public view returns (bool) {
        return IERC721(tokenAddress).ownerOf(tokenId) == address(this);
    }
}
