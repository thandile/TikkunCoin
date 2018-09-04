pragma solidity ^0.4.23;
import "./SafeMath.sol";
import "./ERC621Interface.sol";
import "./Owned.sol";

// ----------------------------------------------------------------------------
// 'Tikkun' token contract
//
// Deployed to : 0xd62a88e4941a06bf35eaa19d1f898f45c9db080b
// Symbol      : TKK
// Name        : Tikkun Token
// Total supply: Flexible
// Decimals    : 2
//
//
// (c) by Moritz Neto & Daniel Bar with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// ERC621 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract TikkunToken is ERC621Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public totalSupply;
    uint public totalTokens;
    uint private marketCap;
    uint256 public interestRate;
    uint public withdrawalDay;
    uint private dailyWithdraw = 5000;
    address public minter;
    

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) interestDue;
    mapping(address => uint) amountSpent;

    event Withdraw(address _withdrawer, uint _amount);
    event LogBuyTikkun(address buyer, uint256 amount);
    event LogTotalSupplyIncreased(uint256 totalSupply);
    event LogBalanceIncreased(address buyer, uint256 balances);
    event InterestPaid(address to, uint256 interestDue);
    event InterestCleared(address to, uint256 interestDue);
    event InterestCalculated(address to, uint256 interestPayment);
    event LimtBreach(address owner, uint256 amount);
    event InsufficientFunds(address owner, uint256 amount);
    event InvalidAmount(address owner, uint256 amount);

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function TikkunToken() public {
        symbol = "TKK";
        name = "Tikkun Token";
        decimals = 8;
        totalSupply = 0;
        interestRate = 6;
        totalTokens = 0;
        marketCap = 10000000000;
        
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return totalSupply - balances[address(0)];
    }
    // ------------------------------------------------------------------------
    // This function is used to change the market cap
    // ------------------------------------------------------------------------
    function newMarketCap(uint _marketcap) public  returns (bool success) {
        marketCap = _marketcap;
        return true;
    }

    function getMarketCap() public view returns (uint) {
        return marketCap;
    }

    function totalTokens() public view returns (uint) {
        return totalTokens;
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function () public payable {
        require(totalSupply < marketCap,"Supply has reached market cap");
        uint tokens;
        tokens = msg.value;
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        totalSupply = safeAdd(totalSupply, tokens);
        emit Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }
    
    // -----------------------------------------------------------------------
    // when someone buys tokens the number of tokens is increased then 
    // they are transfered to the buyer's address
    // -----------------------------------------------------------------------
    function mint(uint value, address to) public returns (bool success) {
        require(totalSupply < marketCap,"Supply has reached market cap");
        totalSupply = safeAdd(totalSupply, value);
        totalTokens = safeAdd(totalTokens,value);
        balances[to] = safeAdd(balances[to], value);
        emit Transfer(address(0), to, value);
        emit LogBuyTikkun(to, value);
        emit LogTotalSupplyIncreased(totalSupply);
        emit LogBalanceIncreased(to, balances[to]);
        return true;
    }

    // -----------------------------------------------------------------------
    // when someone sells/withdraws tokens the number of tokens is decreased then 
    // they are withdrawn from the buyer's address
    // -----------------------------------------------------------------------
    function sellTKK(uint value) public returns (bool success) {
        if (msg.sender != owner) return;
        require(totalSupply < marketCap,"Supply has reached market cap");
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalTokens = safeSub(totalTokens,value);
        totalSupply = safeSub(totalSupply, value);  
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC621 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC621Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC621Interface(tokenAddress).transfer(owner, tokens);
    }

    //---------------------------------------------------------------------------
    //Calculating the daily interest that needs to be paid to account holder
    //---------------------------------------------------------------------------
    function calculateInterest(address to ) public returns (uint256 interest) {
        uint256 initBalance = balances[to];
        uint256 interestPayment = (initBalance*interestRate)/uint256(36500);
        interestDue[to] = safeAdd(interestDue[to], interestPayment);
        emit InterestCalculated(to, interestPayment);
        return interestPayment;
    }

    //----------------------------------------------------------------------
    // Pays the interest to account
    // Will implement scheduler for this in java script code
    //----------------------------------------------------------------------
    function payInterest(address to) public returns (uint256 interest){
        balances[to] = safeAdd(balances[to], interestDue[to]);
        totalSupply = safeAdd(totalSupply, interestDue[to]);
        emit Transfer(address(0), to, interestDue[to]);
        emit InterestPaid(to, interestDue[to]);
        clearInterest(to);
        return interestDue[to];
    }

   //----------------------------------------------------------------------
    // Clears interest due once it has been paid to account
    //----------------------------------------------------------------------
    function clearInterest(address to) public returns (uint256 interest){
        interestDue[to] = safeSub(interestDue[to], interestDue[to]);
        emit InterestCleared(to, interestDue[to]);
        return interestDue[to];
    }

    // ------------------------------------------------------------------------
    // Get the interest due for account `tokenOwner`
    // ------------------------------------------------------------------------
    function interestOf(address tokenOwner) public constant returns (uint interest) {
        return interestDue[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Interest rate
    // ------------------------------------------------------------------------
    function newInterestRate( uint _interest) public  returns (bool success) {
        interestRate = _interest;
        return true;
    }


    function getInterestRate() public view returns (uint) {
        return interestRate;
    }

    // ------------------------------------------------------------------------
    // Determines today's index at midnight.
    // ------------------------------------------------------------------------
    function today() public constant returns (uint) { return now - (now % 1 days); } 

    // ------------------------------------------------------------------------
    // Withdraws specified tokens from msg.sender's account
    // ------------------------------------------------------------------------
    function withDraw (address owner, uint _tokens) public returns (bool success){
        require(isUnderLimit(owner, _tokens), "You have reached your daily withdrawal limit");
        emit LimtBreach(owner, _tokens);
        require(_tokens>=0, "Invalid amount");
        emit InvalidAmount(owner, _tokens);
        require(balances[owner] >= _tokens, "Insufficient funds");
        emit InsufficientFunds(owner, _tokens);
        balances[owner] = safeSub(balances[owner], _tokens);
        totalSupply = safeSub(totalSupply, _tokens);  
        amountSpent[owner] = safeAdd(amountSpent[owner], _tokens);
        emit Withdraw(owner, _tokens);
        withdrawalDay = block.timestamp;
        return true;
    }

    // ------------------------------------------------------------------------
    // Checks if there is still enough tokens to withdraw within in that day
    // it also resets the amount tokens already withdrawn/spent if it is on a 
    // different day
    // ------------------------------------------------------------------------
    function isUnderLimit(address withdrawer, uint _tokens) internal returns (bool) {
        if (today() > withdrawalDay) {
            withdrawalDay = block.timestamp;
            amountSpent[withdrawer] = 0;
        }
        if (amountSpent[withdrawer] + _tokens <= dailyWithdraw)
            return true;
        return false;
    }
}