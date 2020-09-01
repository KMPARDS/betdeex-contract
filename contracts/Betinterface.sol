pragma solidity ^0.6.6;
import './KYC.sol';
contract betInterface{
    IKycDapp kycDappContract;

    mapping(address => bool) public isBetValid; /// @dev Stores authentic bet contracts (only deployed through this contract)
    mapping(address => bool) public KYC; /// @dev Checks whether a particular user has a KYC or not
    
    modifier onlyBetContract{
    require(isBetValid[msg.sender], "Only bet contract can call");
        _;}
    
    modifier onlyKYC{
        require(KYC[msg.sender], "KYC needs to be completed");
        _;
    }
    
    modifier onlyKycApproved() {
        require(kycDappContract.isKycLevel1(msg.sender), 'KYC is not approved');
        _;
    }
    
    function setKYC(address user) public{
        KYC[user] = true;
    }
}