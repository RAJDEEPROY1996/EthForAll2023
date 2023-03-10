// File: contracts\Context.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts\Ownable.sol

pragma solidity ^0.8.7;
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts\item.sol

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

// File: contracts\verifySignature.sol


pragma solidity ^0.8.7;


contract verifySignature{

	function getMessageHash(uint _identityNo , string memory ipfsCID, address _wallet) public pure returns(bytes32){
		return keccak256(abi.encodePacked(_identityNo, ipfsCID, _wallet));
	}

	function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message\n32",_messageHash));
	}

	function verify(address _signer, uint _identityNo , string memory ipfsCID, address _wallet, bytes memory _signature) public pure returns(bool){
		bytes32 messageHash = getMessageHash(_identityNo, ipfsCID, _wallet);
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
		return recoverSigner(ethSignedMessageHash , _signature) == _signer;
	}

	function getMessageHashForPurchase(uint256 _rationCardNo,uint256 _rationShopNo,string memory _itemName) public pure returns(bytes32){
		return keccak256(abi.encodePacked(_rationCardNo,_rationShopNo,_itemName));
	}

	function getEthSignedMessageHashForPurchase(bytes32 _messageHash) public pure returns(bytes32){
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message\n32",_messageHash));
	}

	function verifyPurchase(address _signer,uint256 _rationCardNo,uint256 _rationShopNo,string memory _itemName, bytes memory _signature)public pure returns(bool){
		bytes32 messageHash = getMessageHashForPurchase(_rationCardNo,_rationShopNo,_itemName);
		bytes32 ethSignedMessageHash = getEthSignedMessageHashForPurchase(messageHash);
		return recoverSigner(ethSignedMessageHash , _signature) == _signer;
	}
	function recoverSigner(bytes32 _ethSignedMessageHash , bytes memory _signature) public pure returns(address){
		(bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
		return ecrecover(_ethSignedMessageHash,v,r,s);
	}

	function splitSignature(bytes memory _sig) public pure returns(bytes32 r, bytes32 s, uint8 v){
		require(_sig.length == 65, "invalid signature length");
		assembly{
			r := mload(add(_sig,32))
			s := mload(add(_sig,64))
			v := byte(0, mload(add(_sig,96)))
		}
	}
}

// File: contracts\citizen.sol


pragma solidity ^0.8.7;

contract citizen is Ownable,verifySignature{

    struct citizenDetail{
        string citizenIPFSLinkEnc;
        address wallet;
        uint financialStatus;
    }

    mapping(uint => citizenDetail) public user;
    event BeneficiaryRegistration(uint indexed RationCardNo,address indexed wallet);

    function registerCitizen(uint _rationCardNo, string memory _citizenIPFSLinkEnc, address _wallet,uint _financialStatus, bytes memory _signature) public{
        (bool _status) = verify(owner(), _rationCardNo,_citizenIPFSLinkEnc,_wallet,_signature);
        require(_status == true,"signature doesnot match");
        citizenDetail memory _citizen = user[_rationCardNo];
        _citizen.citizenIPFSLinkEnc = _citizenIPFSLinkEnc;
        _citizen.wallet = _wallet;
        _citizen.financialStatus = _financialStatus;
        user[_rationCardNo] = _citizen;
        emit BeneficiaryRegistration(_rationCardNo,_wallet);
    }

    function updateCitizenDetail(uint _rationCardNo, string memory _citizenIPFSLinkEnc,uint _financialStatus)public{
        citizenDetail memory _citizen = user[_rationCardNo];
        require(_citizen.wallet != address(0),"this Ration Card No doesnot exist");
        _citizen.citizenIPFSLinkEnc = _citizenIPFSLinkEnc;
        _citizen.financialStatus = _financialStatus;
        user[_rationCardNo] = _citizen;
    }

    function removeCitizen(uint _rationCardNo, bytes memory _signature) public{
        citizenDetail memory _citizen = user[_rationCardNo];
        (bool _status) = verify(owner(), _rationCardNo,_citizen.citizenIPFSLinkEnc,_citizen.wallet,_signature);
        require(_status == true,"signature doesnot match");
        delete user[_rationCardNo];
    }    
}

// File: contracts\rationShop.sol


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

// File: contracts\dateTime.sol


pragma solidity ^0.8.0;
 
contract dateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) private pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) private pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) private pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) private pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) private pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

       function getDay(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }
        
       /* function getDay() public view returns (uint8) {
            uint timestamp=block.timestamp;
            return parseTimestamp(timestamp).day;
        }*/

        function getHour(uint timestamp) private pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) private pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) private pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) private pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }
}

// File: contracts\rationDistribution.sol

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
