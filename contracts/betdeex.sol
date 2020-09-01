pragma solidity ^0.6.6;

import './ERC1167.sol'; /// @dev also contains safeMath
import './ERC173.sol';
import './safemath.sol';
import './Bet.sol';
import './Betinterface.sol';
import './KYC.sol';

/// @title BetDeEx Smart Contract - The Decentralized Prediction Platform of Era Swap Ecosystem
/// @author The EraSwap Team
/// @notice This contract is used by manager to deploy new Bet contracts
/// @dev This contract also acts as treasurer
  
contract BetDeEx is CloneFactory, Ownable, betInterface {
    using SafeMath for uint256;
    //IKycDapp KycDappContract;

    address public implementation; /// @dev stores the address of implementation contract
    address[] public clonedContracts; /// @dev returns the address of cloned contracts 
    //address public owner; /// @dev Required to be public because ES needs to be sent transaparently.
    address private _owner;

    // Remove betBalanceInExaEs
    //mapping(address => uint256) public betBalanceInExaEs; /// @dev All ES tokens are transfered to main BetDeEx address for common allowance in ERC20 so this mapping stores total ES tokens betted in each bet.
    /*mapping(address => bool) public isBetValid; /// @dev Stores authentic bet contracts (only deployed through this contract)
    mapping(address => bool) public KYC; /// @dev Checks whether a particular user has a KYC or not*/ 
    
    event NewBetEvent (
        address indexed _deployer, //Show the bets of deployer 
        address _contractAddress,
        uint8 indexed _category,
        uint8 indexed _subCategory,
        string _description
    );
    
    event NewBetting (
        address indexed _betAddress,
        address indexed _bettorAddress,
        uint8 indexed _choice,
        uint256 _betTokensInExaEs
    );

    event EndBetContract (
        address indexed _ender,
        address indexed _contractAddress,
        uint8 _result,
        uint256 _platformFee
    );


    /// @dev This event is for indexing ES withdrawl transactions to winner bettors from this contract
   
    //Add owner
    /*modifier onlyOwner() {
        require(msg.sender == owner, "only superManager can call");
        _;
    }*/


   /* modifier onlyBetContract() {
        require(isBetValid[msg.sender], "Only bet contract can call");
        _;
    }
    
    modifier onlyKYC{
        require(KYC[msg.sender], "KYC needs to be completed");
        _;
    }*/
    

    /// @notice Sets up BetDeEx smart contract when deployed
    
    constructor() public {
        _owner = msg.sender;
        
    }

    /*function setKYC(address user) public{
        KYC[user] = true;
    }*/
    
    //Add onlyowner
    function storageFactory(address _implementation) public onlyOwner{
        implementation = _implementation;
    }
    
    function createBet (
        string memory _description,
        uint8 _category,
        uint8 _subCategory,
        uint256 _minimumBetInExaEs,
        uint256 _prizePercentPerThousand,
        bool _isDrawPossible,
        uint256 _pauseTimestamp
    ) public onlyKYC{
        // Add KYC check 
        // Add upvote and downvote
        // Add a feature to sort by volume
        address clone = createClone(implementation);
        clonedContracts.push(clone);
        Bet(clone).initialize(
        _owner,    
        _description,
        _category,
        _subCategory,
        _minimumBetInExaEs,
        _prizePercentPerThousand,
        _isDrawPossible,
        _pauseTimestamp
    );
    isBetValid[address(clone)] = true;
        emit NewBetEvent(
          msg.sender,
          address(clone),
          _category,
          _subCategory,
          _description
        );
    }

    /// @notice this function is used for getting total number of bets
    /// @return number of Bet contracts deployed by BetDeEx
    function getNumberOfBets() public view returns (uint256) {
        return clonedContracts.length;
    }
    
    /// @notice this is an internal functionality that is only for bet contracts to emit a event when a new bet is placed so that front end can get the information by subscribing to  contract
    function emitNewBettingEvent(address _bettorAddress, uint8 _choice, uint256 _betTokensInExaEs) public onlyBetContract {
        emit NewBetting(msg.sender, _bettorAddress, _choice, _betTokensInExaEs);
    }

    /// @notice this is an internal functionality that is only for bet contracts to emit event when a bet is ended so that front end can get the information by subscribing to  contract
    function emitEndBetEvent(address _ender, uint8 _result, uint256 _gasFee) public onlyBetContract {
        emit EndBetContract(_ender, msg.sender, _result, _gasFee);
    }

}