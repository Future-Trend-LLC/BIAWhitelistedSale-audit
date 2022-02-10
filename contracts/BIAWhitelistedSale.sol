pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/TokenTimelock.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/crowdsale/validation/WhitelistCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Burnable.sol";

contract BIAWhitelistedSale is TimedCrowdsale,CappedCrowdsale,WhitelistCrowdsale,Ownable
 {
    mapping(address => uint256) public contributions;
    ERC20Burnable tokenAddress;
    uint constant public investorMinCap =     100000000000000000; // 0.1BNB
    uint constant public investorHardCap = 350000000000000000000; // 350 BNB
    uint releaseTime1;
    uint releaseTime2;
    uint releaseTime3;
    uint closeTime;
    struct buyerDetails
    {
      address beneficiaryAddress;
      address timeLockAddress1;
      address timeLockAddress2;
      address timeLockAddress3;
    }
    buyerDetails[] buyer;

  constructor
  ( 
    uint rate,
    address payable _wallet,
    ERC20Burnable _token,
    uint _cap,
    uint _openingTime,
    uint _closingTime,
    uint _releaseTime1,
    uint _releaseTime2,
    uint _releaseTime3
  )
    Crowdsale(rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    CappedCrowdsale(_cap)
     
    public
    {
    tokenAddress    = _token;
    releaseTime1    = _releaseTime1;
    releaseTime2    = _releaseTime2;
    releaseTime3    = _releaseTime3;
    closeTime       = _closingTime;
  }
  
  function getBuyerDetails(uint index) public view 
   returns
   (
    address _beneficiaryAddress,
    address _timeLockAddress1,
    address _timeLockAddress2,
    address _timeLockAddress3
   )
  {
  return
    (
      buyer[index].beneficiaryAddress,
      buyer[index].timeLockAddress1,
      buyer[index].timeLockAddress2,
      buyer[index].timeLockAddress3
    );
  }
  function totalBuyers( ) public view 
   returns(uint count)
   {
     return buyer.length;
   }

  function _preValidatePurchase
  (
    address _beneficiary,
    uint256 _weiAmount
  )
  internal view 
  {  
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint256 _newContribution = contributions[_beneficiary].add(_weiAmount);
    require(_newContribution >= investorMinCap && _newContribution <= investorHardCap,"Investor CAP in not in a range "); 
  }
  function newTokenTimeLock
  (
    address _beneficiary,
    uint _amount
  )
  public
  {
    // Create new wallet.
    address wallet1 = address(new TokenTimelock(tokenAddress, _beneficiary,releaseTime1));
    address wallet2 = address(new TokenTimelock(tokenAddress, _beneficiary,releaseTime2));
    address wallet3 = address(new TokenTimelock(tokenAddress, _beneficiary,releaseTime3));
                     
    // Send ether from this transaction to the created contract.
    uint256 tempAmount1;
    uint256 tempAmount2;
    uint256 tempAmount3;
     
    // Token splitting for three timelocked contracts
    tempAmount1=_amount.div(4);
    tempAmount2=_amount.mul(30).div(100);
    tempAmount3=_amount.sub(tempAmount1.add(tempAmount2));
     
    // Token Tranfer to Timelocked Contracts
    tokenAddress.transfer(wallet1,tempAmount1);
    tokenAddress.transfer(wallet2,tempAmount2);
    tokenAddress.transfer(wallet3,tempAmount3);
      
    //updating buyerdetails 
    buyerDetails memory newBuyer = buyerDetails
    (
      _beneficiary,
      wallet1,
      wallet2,
      wallet3
    );
    buyer.push(newBuyer);
    emit Created(_beneficiary,wallet1,wallet2,wallet3);         
  }

  function _deliverTokens
  (
   address _beneficiary, 
   uint256 _tokenAmount
  )
    internal
  {
    contributions[_beneficiary] = contributions[_beneficiary].add(msg.value);
    newTokenTimeLock(_beneficiary,_tokenAmount);
  }
  function burnUnsold()
    public onlyOwner
  {
    require((block.timestamp > closeTime), "Crowdsate is still active");
    ERC20Burnable token = ERC20Burnable(tokenAddress);
    uint256 amount = token.balanceOf(address(this));
    token.burn(amount);
    emit Burn(msg.sender, amount);
  }
  event Burn
 (
   address From,
   uint burnValue
 );
 event Created
 (
   address _beneficiery,
   address _wallet1, 
   address _wallet2,
   address _wallet3
  );
}


