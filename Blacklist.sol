// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    address public owner;
    uint256 public totalTokenSupply;
    mapping(address => bool) public isWhitelisted;
    mapping(address => address[]) private interactions;
    mapping(address => uint256) public balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event getToken(address indexed to, uint256 value);
    event Mint(address, uint256 value);
    event Blacklisted(address indexed wallet);
    event Whitelisted(address indexed wallet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalTokenSupply = 1e8 * 10 ** 18;
        balances[msg.sender] = totalTokenSupply;

        // Whitelisting owner and 4 other address by default
        whitelistAddress(msg.sender);
        whitelistAddress(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        whitelistAddress(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        whitelistAddress(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        whitelistAddress(0x617F2E2fD72FD9D5503197092aC168c91465E7f2);
    }

    function blacklistAddress(address _address) public onlyOwner {
        require(_address != address(0), "Invalid address");
        require(_address != owner, "Cannot blacklist the owner");
        require(isWhitelisted[_address], "Address is already blacklisted");
        isWhitelisted[_address] = false;
        emit Blacklisted(_address);

        // Blacklist all peers
        address[] memory peers = interactions[_address];
        for (uint256 i=0; i < peers.length; i++) {
            if (peers[i] != owner) {
                isWhitelisted[peers[i]] = false;
                emit Blacklisted(peers[i]);
            }
        }
    }

    function whitelistAddress(address _address) public onlyOwner {
        require(_address != address(0), "Invalid address");
        require(!isWhitelisted[_address], "Address is already whitelisted");
        isWhitelisted[_address] = true;
        emit Whitelisted(_address);

        // Whitelist all peers
        address[] memory peers = interactions[_address];
        for (uint256 i=0; i < peers.length; i++) {
            isWhitelisted[peers[i]] = true;
            emit Whitelisted(peers[i]);
        }
    }

    function transfer(address _to, uint256 _value) public {
        require(_to != address(0), "Invalid recipient address");
        require(msg.sender != _to, "Sender can't be same as receiver");
        require(msg.sender != address(0), "Invalid sender address");
        require(isWhitelisted[msg.sender], "Sender is blacklisted");
        require(isWhitelisted[_to], "Recipient is blacklisted");
        require(balances[msg.sender] >= _value, "Insufficient balance");
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        // Update interaction record
        interactions[msg.sender].push(_to);
        interactions[_to].push(msg.sender);
    }

    function mint(uint256 _value) public onlyOwner {
        totalTokenSupply += _value;
        balances[owner] += _value;
        emit Mint(owner, _value);
    }

    function getTokens(address _to, uint256 _value) public {
        require(isWhitelisted[_to], "Recipient is blacklisted");
        require(_to != address(0), "Invalid recipient address");
        require(_value > 0, "Value must be greater than zero");
        require(_value < 1000, "Value must be less than thousand per transaction"); // Just to regulate our contract's token supply. Not a necessary constraint.
        require(balances[owner] >= _value, "Insufficient tokens in supply");

        balances[_to] += _value;
        emit Transfer(owner, _to, _value);
    }

}
