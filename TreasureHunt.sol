pragma solidity ^0.4.7;

contract TreasureHunt 
{
    struct Location
    {
        bool IsValid;
        bool IsFound;
        address Finder;
        string W3wLocationString;
        string FinderMessage;
    }
    
    address _owner;
    mapping (bytes32 => Location) _locations;
    mapping (address => uint) _winningsDueWeiByUser;
    uint _numFound;
    uint _payoutThreshold;
    uint _payoutPerLocationWei;
    
    event Payout;
    event LocationFound(string w3wLocationString, address user);
    
    function TreasureHunt(bytes32[] sha3HashedLocationStrings, uint payoutThreshold) payable
    {
        _owner = msg.sender;   
        _payoutPerLocationWei = msg.value / sha3HashedLocationStrings.length;
        _numFound = 0;
        _payoutThreshold = payoutThreshold;
        
        for(uint i = 0; i < sha3HashedLocationStrings.length; i++)
        {
            var hash = sha3HashedLocationStrings[i];
            var location = _locations[hash];
            location.IsValid = true;
            location.IsFound = false;
        }
    }
    
    function Disolve()
    {
        if(msg.sender != _owner) throw;
        
        suicide(msg.sender);
    }
    
    function TryFind(string w3wLocationString, string optionalMessage) returns(uint)
    {
        var hash = sha3(w3wLocationString);
        
        var location = _locations[hash];
        
        if(!location.IsValid) return 1;
        if(location.IsFound) return 2;
        
        // found! woop woop
        
        location.IsFound = true;
        location.Finder = msg.sender;
        location.W3wLocationString = w3wLocationString;
        location.FinderMessage = optionalMessage;
        
        _winningsDueWeiByUser[msg.sender] += _payoutPerLocationWei;
        
        _numFound++;
        
        LocationFound(w3wLocationString, msg.sender);
        
        if(_numFound == _payoutThreshold)
            Payout();
    }
    
    function ClaimWinnings() returns(uint)
    {
        if(_numFound < _payoutThreshold) return 1;
        
        uint payoutAmountWei = _winningsDueWeiByUser[msg.sender];
        _winningsDueWeiByUser[msg.sender] = 0;
        
        msg.sender.send(payoutAmountWei);
    }
}