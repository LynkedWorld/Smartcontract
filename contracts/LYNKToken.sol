pragma solidity 0.4.25;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 *
 * Lynked World LYNK Token
 *
 */

contract LYNKToken is StandardToken {

	string public constant name     = "Lynked.World Token"; 
	string public constant symbol   = "LYNK";              
	uint8  public constant decimals = 18;                  

	/*
	* mainnet settings
	*/
	uint public constant icoEndDate         = 1549796400;  // 10-Feb-2019 11:00:00 GMT 
	uint public constant rewardStartDate    = 1559347200;  // 01-Jun-2019 00:00:00 GMT
	uint public constant SECONDS_IN_YEAR    = 31536000;    //  60 * 60 * 24 * 365 


	uint constant addressLock   = 1;   // founders, rewards
	uint constant addressNoLock = 2;   // marketing, ICO investors, advisors  
	bool  public halted      = false;  // flag for emergency stop or start 

	uint256 public INITIAL_SUPPLY          = 500000000 * (10 ** uint256(decimals));  // 500,000,000 (500m)

	// tokens allocation details
	uint256  public tokensRewardsPool      = 300000000 * (10 ** uint256(decimals));   //300,000,000 - (300M) 
	uint256  public tokensAdvisorsTeam     =  10000000 * (10 ** uint256(decimals));   // 10,000,000 - (10M ) 
	uint256  public tokensSeedInvestors    =  10000000 * (10 ** uint256(decimals));   // 10,000,000 - (10M )
	uint256  public tokensMarketingBounty  =  10000000 * (10 ** uint256(decimals));   // 10,000,000 - (10M )   
	uint256  public tokensFounders         =  20000000 * (10 ** uint256(decimals));   // 20,000,000 - (20M) - lock 50% after 6 months
	uint256  public tokensICO              = 150000000 * (10 ** uint256(decimals));  // 150,000,000 - (150M) 

	uint256  public tokensYear1Reward      =   5000000 * (10 ** uint256(decimals));     //   5,000,000.00  (5m)	 
	uint256  public tokensYear2Reward	   =  16000000 * (10 ** uint256(decimals)); //  16,000,000.00  (16m)	 
	uint256  public tokensYear3Reward	   =  33500000 * (10 ** uint256(decimals)); //  33,500,000.00  (33.5m)
	uint256  public tokensYear4Reward	   =  59000000 * (10 ** uint256(decimals)); //  59,000,000.00  (59m)	 
	uint256  public tokensYear5Reward	   =  95500000 * (10 ** uint256(decimals)); //  95,500,000.00  (95m)	 
	uint256  public tokensYear6Reward	   = 132000000 * (10 ** uint256(decimals)); //  132,000,000.00 (132m) 
	uint256  public tokensYear7Reward	   = 168500000 * (10 ** uint256(decimals)); //  168,500,000.00 (168.5m)	 
	uint256  public tokensYear8Reward	   = 205000000 * (10 ** uint256(decimals)); //  205,000,000.00 (205m) 	 
	uint256  public tokensYear9Reward	   = 241000000 * (10 ** uint256(decimals)); //  241,000,000.00 (241m)	 
	uint256  public tokensYear10Reward	   = 266500000 * (10 ** uint256(decimals)); //  266,500,000.00 (246.5m)	 
	uint256  public tokensYear11Reward	   = 284000000 * (10 ** uint256(decimals)); //  284,000,000.00 (284m) 	 
	uint256  public tokensYear12Reward	   = 295000000 * (10 ** uint256(decimals)); //  295,000,000.00 (295m)  	 
	uint256  public tokensYear13Reward	   = 300000000 * (10 ** uint256(decimals)); //  300,000,000.00 (300m) 	 

	/*  
	*   mainnet multi-sign addresses
	*/

	/*
	address public addressRewardsPool      = 0x0339fbc9d643f9f8857b78d09646b65a68137ee1;     
	address public addressAdvisorsTeam     = 0xa80f2667a7579b5b89da3fe5786325ce42af0fb1;  
	address public addressSeedInvestors    = 0x48a174c654e11b690cc61102d6e37672ecf1501f;      
	address public addressMarketingBounty  = 0xef91ff38abef1bcfa52e072cf31d2e0ac48de395;  
	address public addressFounders         = 0x18d9c67e6c2f75ab55e2a81b09411f52e69d28aa; 
	address public addressICOManager       = 0xcb0698cdb6b6ddcea7f52d6b36f3af90ac576760;    
	*/

	address public addressICOAdmin	       = 0x4edfbbc02bbdfda94b225622cc77cd4826cd4bd6;    

	/*  
	*   testnet multi-sign addresses
	*/

	address public addressRewardsPool      = 0x5221382588accb5f26ba1b3a2892ddb0cd3f855c;     
	address public addressAdvisorsTeam     = 0x3524e3dadbaae2d0da1084a0c40545d5726b80f5;  
	address public addressSeedInvestors    = 0x4435fe6748e01c2f001af24997c3ee76fba5498e;      
	address public addressMarketingBounty  = 0x16d43c6a63a83d3138200f73927c6f72c2f4aff4;  
	address public addressFounders         = 0x00872d6ed50537f760047d7494f2d4471b0dfc15; 
	address public addressICOManager       = 0x69e99d71e42933296122f4d3693871925c883df9; 

    /*
    * Contract Constructor
    */

    constructor() public {

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
                     emit Transfer(this, addressFounders,        tokensFounders);                     
                     emit Transfer(this, addressICOManager,      tokensICO);  
            }
    
    /**
    *   Emergency Stop or Start ICO.
    *
    */

    function halt() onlyAdmin public{
        require(msg.sender == addressICOAdmin);
        halted = true;
    }

    function unhalt() onlyAdmin public {
        require(msg.sender == addressICOAdmin);
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

    modifier onlyAdmin() {
        // only ICO manager can do this action
        require(msg.sender == addressICOAdmin);
        _;
    }


     /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until ICO period is over.
     * 
     * Transfer 
     *    - Allow 50% after six months for Founders
     *    - Allow Investors and Others after ICO end date 
     */


   function transfer(address _to, uint256 _value) public returns (bool success) 
    {
           // ICO mgr can transfer to ICO investors anytime
           if ( msg.sender == addressICOManager) { return super.transfer(_to, _value); }           

           // ICO investors can transfer anytime
           if ( !halted && identifyAddress(msg.sender) == addressNoLock  ) { return super.transfer(_to, _value); }

           // Founders can transfer upto 50% of tokens after six months of ICO end date 
           if ( !halted &&  msg.sender == addressFounders &&  
                 SafeMath.sub(balances[msg.sender], _value) >= SafeMath.div(tokensFounders,2) && 
                 (now > SafeMath.add(icoEndDate, SafeMath.div(SECONDS_IN_YEAR,2)) )) 
                { return super.transfer(_to, _value); }         
           
           // Transfers from RewardPool
		   if ( !halted && msg.sender == addressRewardsPool && now > rewardStartDate ){
		   		if ( yearsFromICO() == 1  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear1Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 2  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear2Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 3  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear3Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 4  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear4Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 5  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear5Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 6  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear6Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 7  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear7Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 8  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear8Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 9  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear9Reward  )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 10 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear10Reward )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 11 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear11Reward )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() == 12 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear12Reward )  { return super.transfer(_to, _value); }   
		   		if ( yearsFromICO() >= 13 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear13Reward )  { return super.transfer(_to, _value); }   
		     } else if (!halted && now > icoEndDate + SECONDS_IN_YEAR && msg.sender != addressRewardsPool) 
		   			{ 
		   				return super.transfer(_to, _value); 
		   			}
        return false;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) 
    {
           if ( msg.sender == addressICOManager) { return super.transferFrom(_from,_to, _value); }

           // ICO investors can transfer anytime
           if ( !halted && identifyAddress(msg.sender) == addressNoLock ) { return super.transferFrom(_from,_to, _value); }

           // Founders can transfer upto 50% of tokens after six months of ICO end date 
           if ( !halted &&  msg.sender == addressFounders &&  
                 SafeMath.sub(balances[msg.sender], _value) >= SafeMath.div(tokensFounders,2) && 
                 (now > SafeMath.add(icoEndDate, SafeMath.div(SECONDS_IN_YEAR,2)) ))
                   { return super.transferFrom(_from,_to, _value); }

		   if ( !halted && msg.sender == addressRewardsPool  && now > rewardStartDate ){
		   		if ( yearsFromICO() == 1  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear1Reward  )  { return super.transferFrom(_from,_to, _value); }  
		   		if ( yearsFromICO() == 2  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear2Reward  )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 3  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear3Reward  )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 4  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear4Reward  )  { return super.transferFrom(_from,_to, _value); }  
		   		if ( yearsFromICO() == 5  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear5Reward  )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 6  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear6Reward  )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 7  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear7Reward  )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 8  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear8Reward  )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 9  && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear9Reward  )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 10 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear10Reward )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 11 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear11Reward )  { return super.transferFrom(_from,_to, _value); }   
		   		if ( yearsFromICO() == 12 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear12Reward )  { return super.transferFrom(_from,_to, _value); }  
		   		if ( yearsFromICO() >= 13 && SafeMath.sub(balances[msg.sender], _value) >= tokensRewardsPool - tokensYear13Reward )  { return super.transferFrom(_from,_to, _value); }   
		     } else if (!halted && now > icoEndDate + SECONDS_IN_YEAR && msg.sender != addressRewardsPool) 
		   			{ 
		   				 return super.transferFrom(_from,_to, _value);  
		   			}
        return false;
    }


   function identifyAddress(address _buyer) constant internal returns(uint) {
        if (_buyer == addressFounders    || _buyer == addressRewardsPool) return addressLock;
            return addressNoLock;
    }

    //
    // function to return the current year
    //

    function yearsFromICO() internal constant returns(uint)
    {
        uint yrs = SafeMath.div((now - rewardStartDate), SECONDS_IN_YEAR) + 1; 
        return yrs;
    }


     /*
     *  default fall back function      
     */
    function () payable public { 
            revert();
    }
}
