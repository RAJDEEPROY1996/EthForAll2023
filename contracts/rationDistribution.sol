// SPDX-License-Identifier: MIT

import "./item.sol";
import "./citizen.sol";
import "./rationShop.sol";
import "./dateTime.sol";

pragma solidity ^0.8.7;

contract rationDistribution is item,citizen,rationShop,dateTime{
    
    struct rationDistributionToPublic{
        uint rationCardNo;
        uint rationShopNo;
        string purchasedItem;
        uint deliveryTime;
        uint price;
        uint receiptNo;
    }
    
    mapping(uint => mapping(string => uint))public goods;
    rationDistributionToPublic[] public rationDelivery;
    event StoreItemToRationShop(uint indexed rationShopId,string itemName,uint weight);
    event RationDelivery(uint indexed rationCardNo,uint indexed ReceiptNo);

    function addItemToRationShop(uint _rationShopNo, string[] calldata _itemName,uint[] calldata _weight) public onlyOwner{
        uint len = _weight.length;
        require(_itemName.length == len,"No of item name is not equal to no of Weight");
        for(uint i; i<len ; i++){
            goods[_rationShopNo][_itemName[i]] += _weight[i];
            emit StoreItemToRationShop(_rationShopNo,_itemName[i],_weight[i]);
        }
    }
    function deleteRationDetails() public onlyOwner{
	    uint Todaydate;	    
	    Todaydate=getDay(block.timestamp);
        require(Todaydate==1,"Today is not the first Day of the Month");
            delete rationDelivery;
	} 

    function rationDeliveryToCitizen(uint _rationCardNo,uint _rationShopNo,string calldata _itemName,bytes memory _signature)public {
        citizenDetail memory _citizen = user[_rationCardNo];
        rationShopDetail memory _shop = shop[_rationShopNo];
        //registerItem memory buying = items[_itemName];
        uint Todaydate=getDay(block.timestamp);
	    require(Todaydate!=1,"Today Ration will not be provided... Kindly Visit Tomorrow to Last day of the Month For Ration");
        require(_citizen.wallet != address(0),"this Ration Card No doesnot exist");        
        require(_shop.wallet != address(0),"this Ration Card No doesnot exist");
        (bool _status) = verifyPurchase(_citizen.wallet, _rationCardNo,_rationShopNo,_itemName,_signature);
        require(_status == true,"signature doesnot match");
        uint _financialStatus = _citizen.financialStatus;
        uint availableGoods = goods[_rationShopNo][_itemName];
        uint _weight = items[_itemName].weight;
        require(availableGoods >= _weight,"Purchased Item not available in this Ration Shop");
        uint len = rationDelivery.length;      
        for(uint i; i<len; i++){
            if(rationDelivery[i].rationCardNo == _rationCardNo){
                require(uint(keccak256(abi.encodePacked(rationDelivery[i].purchasedItem))) != uint(keccak256(abi.encodePacked(_itemName))),"Already purchased Item");
            }  
        }
        if(_financialStatus == 0){            
            rationDelivery.push(rationDistributionToPublic(_rationCardNo, _rationShopNo,_itemName,block.timestamp,items[_itemName].bplPrice * _weight,len));
        }
        else{
            rationDelivery.push(rationDistributionToPublic(_rationCardNo, _rationShopNo,_itemName,block.timestamp,items[_itemName].aplPrice * _weight,len));
        }
        goods[_rationCardNo][_itemName] -= _weight;
        emit RationDelivery(_rationCardNo,len);
    }
    
}