// SPDX-License-Identifier: MIT

import "./verifySignature.sol";
import "./Ownable.sol";

pragma solidity ^0.8.7;

contract rationShop is Ownable,verifySignature{

    struct rationShopDetail{
        string rationIPFSLink;
        address wallet;
    }

    mapping(uint => rationShopDetail) public shop;
    event rationShopRegistration(uint indexed RationShopNo,address indexed wallet);
    function registerRationShop(uint _rationShopNo, string memory _rationIPFSLink, address _wallet, bytes memory _signature) public{
        (bool _status) = verify(owner(), _rationShopNo,_rationIPFSLink,_wallet,_signature);
        require(_status == true,"signature doesnot match");
        rationShopDetail memory _shop = shop[_rationShopNo];
        _shop.rationIPFSLink = _rationIPFSLink;
        _shop.wallet = _wallet;
        shop[_rationShopNo] = _shop;
        emit rationShopRegistration(_rationShopNo,_wallet);
    }

    function updateRationShopDetail(uint _rationShopNo, string memory _rationIPFSLink)public{
        rationShopDetail memory _shop = shop[_rationShopNo];
        require(_shop.wallet != address(0),"this Ration Card No doesnot exist");
        _shop.rationIPFSLink = _rationIPFSLink;
        shop[_rationShopNo] = _shop;
    }

    function removeRationShop(uint _rationShopNo, bytes memory _signature) public{
        rationShopDetail memory _shop = shop[_rationShopNo];
        (bool _status) = verify(owner(), _rationShopNo,_shop.rationIPFSLink,_shop.wallet,_signature);
        require(_status == true,"signature doesnot match");
        delete shop[_rationShopNo];
    }
}