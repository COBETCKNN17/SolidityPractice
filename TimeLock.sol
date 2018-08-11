pragma solidity ^0.4.24; // only complier from this version to 0.5

/** one function will allow you to send ether to the contract
and the second will lock ether in the contract for a certain period of time **/

contract TimeLock {
    // owner of contract
        address public owner; // compiler automatically creates getter for this owner

    // lock period (time funds will be locked in seconds)
        uint public lockPeriod;

    // struct: 3 members (participants) , block start, active and amount
        struct Participant {
            uint lockPeriodStart;
            bool active;
            /** active true means funds are locked in the contract,
            false means not locked **/
            // unint is unit256 - the biggest we can use
            uint amount;
        }

    mapping (address => Participant) public participants;

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // constructor - pass in initial lock period - always explicitly define visibility
    constructor(uint _initialLockPeriod)  public {
        // set owner
        owner = msg.sender;
        // set initial lock period
        lockPeriod = _initialLockPeriod;
    }

    function () public {
        revert();
    }

    function lockFunds() public payable{
        // key is address. pass in address to get the detail of the Participant
        Participant _p = participants[msg.sender]; // retrieve sender and assign to participant

        // if whatever value we retrieve from struct is true, it will stop the contract
        require(_p.active == false, "Sender already has funds locked");

        // record what values are being passed in are. First, mark struct as active
        _p.active = true;
        // set the lock period start to now
        _p.lockPeriodStart = now;
        _p.amount = msg.value; // value in wei
    }

    function releaseFunds() public {
        Participant _p = participants[msg.sender];
        require(_p.active == true, "No locked funds for this address"); // we want a participant to have funds in the account
        require(now >= _p.lockPeriodStart + lockPeriod, "Lock period has not yet expired");

        uint _amountToUnlock = _p.amount;
        delete participants[msg.sender];

        msg.sender.transfer(_amountToUnlock); //  transfer the original value in the struct
    }

    function updateLockPeriod (uint _newPeriod) public onlyOwner{
        // function will call modifier first. This check is an example of inheritance
        lockPeriod = _newPeriod;
    }
}
