// SPDX-License-Identifier: MIT
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
