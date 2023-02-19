// SPDX-License-Identifier: MIT

import "./Ownable.sol";

pragma solidity ^0.8.7;

contract item is Ownable{

    struct registerItem{
        uint bplPrice;
        uint aplPrice;
        uint weight;
    }

    mapping(string => registerItem) public items;
    event itemDetail(string itemName,uint indexed aplPrice,uint indexed bplPrice,uint weight);

    function registerItems(string[] calldata _itemName,uint[] calldata _bplPrice, uint[] calldata _aplPrice,uint[] calldata _weight) public onlyOwner{
        uint len = _itemName.length;
        require(len == _bplPrice.length && len == _aplPrice.length && len == _weight.length,"all data are not provide");
        for(uint i; i<len;i++){
            registerItem memory goods = items[_itemName[i]];
            goods.bplPrice = _bplPrice[i];
            goods.aplPrice = _aplPrice[i];
            goods.weight = _weight[i];
            items[_itemName[i]] = goods;
            emit itemDetail(_itemName[i],_bplPrice[i],_aplPrice[i],_weight[i]);
        }
    }

    //status 0 -> change and 1 -> remove
    function editRegisteredItem(string calldata _itemName,uint _bplPrice, uint _aplPrice,uint _weight, uint _status) public onlyOwner{
        registerItem memory goods = items[_itemName];
        require(goods.weight != 0, "please register this item");
        if(_status == 1){
            delete items[_itemName];
        }
        else{
           goods.bplPrice = _bplPrice;
           goods.aplPrice = _aplPrice;
           goods.weight = _weight;
           items[_itemName] = goods;
           emit itemDetail(_itemName,_bplPrice,_aplPrice,_weight); 
        }
    }
}
