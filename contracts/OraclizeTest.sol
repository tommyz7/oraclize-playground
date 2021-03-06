pragma solidity ^0.4.21;


import "../installed_contracts/oraclize-api/contracts/usingOraclize.sol";


contract OraclizeTest is usingOraclize {

    address owner;
    string public ETHUSD;

    event LogInfo(string description);
    event LogPriceUpdate(string price, uint balance);
    event LogUpdate(address indexed _owner, uint indexed _balance);

    // Constructor
    constructor() public payable {
        owner = msg.sender;

        emit LogUpdate(owner, address(this).balance);

        // Replace the next line with your version:
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
    }

    function __callback(bytes32 id, string result, bytes proof) public {
        require(msg.sender == oraclize_cbAddress());

        ETHUSD = result;
        emit LogPriceUpdate(ETHUSD, this.balance);
        update();
    }

    function getBalance() public view returns (uint _balance) {
        return address(this).balance;
    }

    function update() public payable {
        // Check if we have enough remaining funds
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogInfo("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogInfo("Oraclize query was sent, standing by for the answer..");

            // Using XPath to to fetch the right element in the JSON response
            oraclize_query("URL", "json(https://api.coinbase.com/v2/prices/ETH-USD/spot).data.amount");
        }
    }

    function() public payable {}

}