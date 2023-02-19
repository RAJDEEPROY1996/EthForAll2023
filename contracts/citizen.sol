// SPDX-License-Identifier: MIT

import "./Ownable.sol";
import "./verifySignature.sol";

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