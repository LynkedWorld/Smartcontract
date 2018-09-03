pragma solidity 0.4.24;

import './zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import './zeppelin-solidity/contracts/math/SafeMath.sol';

/**
 *
 * Lynked World LYNK Token
 * Creation Date : 09-Aug-2018
 * by Saravana, TokenSafe.io
 *
 */

contract LYNKToken is StandardToken {

    string public constant name     = "Lynked.World Token"; 
    string public constant symbol   = "LYNK";              
    uint8  public constant decimals = 18;                  

    /*
    * test settings
    */
    uint public constant icoEndDate         = 1533859199;  // 09-Aug-2018 23:59:59 GMT 
    uint public constant SECONDS_IN_YEAR    = 172800;        //  60 * 60 * 24 * 2 = 2 days

    uint constant addressLock   = 1;   // founders, advisors and team
    uint constant addressNoLock = 2;   // marketing, ICO investors 


    // flag for emergency stop or start 
    bool  public halted      = false;              
    uint256  public tokenSold  = 0;
    uint256  public etherRaised = 0;


    uint256 public INITIAL_SUPPLY          = 500000000 * (10 ** uint256(decimals));  // 500,000,000 (500m)

    // tokens allocation details
    uint256  public tokensRewardsPool      = 300000000 * (10 ** uint256(decimals));   //300,000,000 - (300M) 

    uint256  public tokensAdvisorsTeam     =  10000000 * (10 ** uint256(decimals));   // 10,000,000 - (10M ) - lock 50% after 6 months
    uint256  public tokensSeedInvestors    =  10000000 * (10 ** uint256(decimals));   // 10,000,000 - (10M )
    uint256  public tokensMarketingBounty  =  10000000 * (10 ** uint256(decimals));   // 10,000,000 - (10M )
    
    uint256  public tokensFounders         =  20000000 * (10 ** uint256(decimals));   // 20,000,000 - (20M) - lock 50% after 6 months
    uint256  public tokensICO              = 150000000 * (10 ** uint256(decimals));  // 150,000,000 - (150M) 


    /*  
    *   the following are the testnet addresses
    *   should be updated with mainnet address
    *   before deploying the contract
    *   Note : rinkeby testnet addresses used here for testing
    */

  
    address public addressRewardsPool      = 0x50207268ed986ffc756de2fb509c902557e902b4;     
    address public addressAdvisorsTeam     = 0xdf7e584a74fff446a6141ae342078a828ae65d23;  
    address public addressSeedInvestors    = 0x0afe6ededb967c7e0b189d7ce9375772be5fe59b;      
    address public addressMarketingBounty  = 0x9fc1c2f53ebe62d481fb9a2a8a75b09ac7399781;  
	address public addressFounders         = 0x1c59788d7113bbfe04280e3b60c03646d9e449fe; 
    address public addressICOManager       = 0xe784a570e8aec7aab58eb23a7d4db257f11306ca; 
     

    /*
    * Contract Constructor
    */

    function LYNKToken() public {

                     totalSupply_ = INITIAL_SUPPLY;              

                     balances[addressRewardsPool]      = tokensRewardsPool;
   					 balances[addressAdvisorsTeam]     = tokensAdvisorsTeam;
                     balances[addressSeedInvestors]    = tokensSeedInvestors;
                     balances[addressMarketingBounty]  = tokensMarketingBounty;  
                     balances[addressFounders]         = tokensFounders;
                     balances[addressICOManager]       = tokensICO;

                     emit Transfer(this, addressRewardsPool,     tokensRewardsPool);
                     emit Transfer(this, addressAdvisorsTeam,    tokensAdvisorsTeam);
                     emit Transfer(this, addressSeedInvestors,   tokensSeedInvestors);
                     emit Transfer(this, addressMarketingBounty, tokensMarketingBounty);
                     emit Transfer(this, addressFounders,       tokensFounders);                     
                     emit Transfer(this, addressICOManager,     tokensICO);  
            }
    
    /**
    *   Emergency Stop or Start ICO.
    *
    */

    function halt() onlyManager public{
        require(msg.sender == addressICOManager);
        halted = true;
    }

    function unhalt() onlyManager public {
        require(msg.sender == addressICOManager);
        halted = false;
    }

    /*
    *   Check whether ICO running or not.
    */

    modifier onIcoRunning() {
        // Checks, if ICO is running and has not been stopped
        require( halted == false);
        _;
    }
   
    modifier onIcoStopped() {
        // Checks if ICO was stopped or deadline is reached
      require( halted == true);
        _;
    }

    modifier onlyManager() {
        // only ICO manager can do this action
        require(msg.sender == addressICOManager);
        _;
    }


     /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until ICO period is over.
     * 
     * Transfer 
     *    - Allow 50% after six months for Founders and Advisors
     *    - Allow Investors and Others after ICO end date 
     *
     * Applicable tests:
     *
     * - Test restricted early transfer
     * - Test transfer after restricted period
     */


   function transfer(address _to, uint256 _value) public returns (bool success) 
    {
           if ( msg.sender == addressICOManager) { return super.transfer(_to, _value); }           

           // Founders, Advisors and Team can transfer upto 50% of tokens after six months of ICO end date 
           if ( !halted &&  msg.sender == addressFounders &&  SafeMath.sub(balances[msg.sender], _value) >= tokensFounders/2 && (now > icoEndDate + SECONDS_IN_YEAR/2) ) 
                { return super.transfer(_to, _value); }         

           if ( !halted &&  msg.sender == addressAdvisorsTeam &&  SafeMath.sub(balances[msg.sender], _value) >= tokensAdvisorsTeam/2 && (now > icoEndDate + SECONDS_IN_YEAR/2) ) 
                { return super.transfer(_to, _value); }         

           
           // ICO investors can transfer after the ICO period
           if ( !halted && identifyAddress(msg.sender) == addressNoLock && now > icoEndDate ) { return super.transfer(_to, _value); }
           
           // All can transfer after a year from ICO end date 
           if ( !halted && now > icoEndDate + SECONDS_IN_YEAR) { return super.transfer(_to, _value); }

        return false;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) 
    {
           if ( msg.sender == addressICOManager) { return super.transferFrom(_from,_to, _value); }

           // Founders, Advisors and Team can transfer upto 50% of tokens after six months of ICO end date 

           if ( !halted &&  msg.sender == addressFounders &&  SafeMath.sub(balances[msg.sender], _value) >= tokensFounders/2 && (now > icoEndDate + SECONDS_IN_YEAR/2) )
                { return super.transferFrom(_from,_to, _value); }

           if ( !halted &&  msg.sender == addressAdvisorsTeam &&  SafeMath.sub(balances[msg.sender], _value) >= tokensAdvisorsTeam/2 && (now > icoEndDate + SECONDS_IN_YEAR/2) ) 
                { return super.transferFrom(_from,_to, _value); }

           
           // ICO investors can transfer after the ICO period
           if ( !halted && identifyAddress(msg.sender) == addressNoLock && now > icoEndDate ) { return super.transferFrom(_from,_to, _value); }

           // All can transfer after a year from ICO end date 
           if ( !halted && now > icoEndDate + SECONDS_IN_YEAR) { return super.transferFrom(_from,_to, _value); }

        return false;
    }


   function identifyAddress(address _buyer) constant public returns(uint) {
        if (_buyer == addressFounders    || _buyer == addressAdvisorsTeam) return addressLock;
            return addressNoLock;
    }


     /*
     *  default fall back function      
     */
    function () payable public {
              revert();
            }
}