pragma solidity ^0.4.15;

import '../Utilities/Ownable.sol';

contract SmartInvoice is Ownable {

    Invoice[] invoiceList;
    uint invoiceCount;
    address[] _listOfBuyers;
    uint[] _dateOfBuyers;

    event AddedInvoice(address operator, uint invoiceId, uint issueDate, address supplier, address currentBuyer);

    function SmartInvoice() {

        _listOfBuyers.push(0x0);
        _dateOfBuyers.push(now);

        //Invoice memory _invoice = Invoice(0x0,_listOfBuyers,_dateOfBuyers);
        Invoice memory _invoice = Invoice(0x0,_listOfBuyers,_dateOfBuyers,0x0,0,0,0,0,0,true,0,State.Invoicing);

        invoiceList.push(_invoice);
    }

    function getInvoiceList() public constant returns (uint) {
        return invoiceList.length;
    }

    function getInvoice(uint invoiceId) public constant returns (address,address,uint,uint,uint,bool,uint) {
        address _supplier = invoiceList[invoiceId].supplier;
        address _currentBuyer = invoiceList[invoiceId].currentBuyer;
        uint _totalValue = invoiceList[invoiceId].totalValue;
        uint _issueDate = invoiceList[invoiceId].issueDate;
        uint _dueDate = invoiceList[invoiceId].dueDate;
        bool _isValid = invoiceList[invoiceId].isValid;
        uint _invalidDate = invoiceList[invoiceId].invalidDate;
        return (_supplier,_currentBuyer,_totalValue,_issueDate,_dueDate,_isValid,_invalidDate);
    }

    function getInvoiceRiskRating(uint invoiceId) public constant returns(uint,uint) {
        uint _currentRiskRating = invoiceList[invoiceId].currentRiskRating;
        uint _dateRatingApplied = invoiceList[invoiceId].dateRatingApplied;
        return (_currentRiskRating,_dateRatingApplied);
    }

    function addInvoice(
        address _supplier,
        address _currentBuyer,
        uint _totalValue,
        uint _issueDate,
        uint _dueDate,
        uint _currentRiskRating,
        uint _dateRatingApplied,
        bool _isValid,
        uint _invalidDate) {
        
        Invoice _inn;
        _inn.supplier = _supplier;
        _inn.listOfBuyers.push(_currentBuyer);
        _inn.dateOfBuyers.push(now);
        _inn.currentBuyer = _currentBuyer;
        _inn.totalValue = _totalValue;
        _inn.issueDate = _issueDate;
        _inn.dueDate = _dueDate;
        _inn.currentRiskRating = _currentRiskRating;
        _inn.dateRatingApplied = now;
        _inn.isValid = _isValid;
        _inn.invalidDate = _invalidDate;
        _inn.invoiceState = State.Invoicing;

        invoiceList.push(_inn);
        invoiceCount = invoiceCount + 1;
        AddedInvoice(msg.sender, invoiceCount, now,_supplier,_currentBuyer);
    }

    function applyRiskRating(uint invoiceId, uint rating) {
        require(invoiceId != 0);
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);

        invoiceList[invoiceId].currentRiskRating = rating;
        invoiceList[invoiceId].dateRatingApplied = now;
    }

    function sellInvoice(uint invoiceId, address newBuyer) {
        require(invoiceId != 0);
        require(newBuyer != 0x0);
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);

        invoiceList[invoiceId].listOfBuyers.push(newBuyer);
        invoiceList[invoiceId].currentBuyer = newBuyer;
        invoiceList[invoiceId].dateOfBuyers.push(now);
    }

    function invalidateInvoice(uint invoiceId) {
        require(invoiceId != 0);
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);

        invoiceList[invoiceId].isValid = false;
        invoiceList[invoiceId].invalidDate = now;
        invoiceList[invoiceId].invoiceState = State.Invalidated;
    }

    function clear() {
        invoiceCount = 0;
    }

    enum State {
        Invoicing,
        Payable,
        Invalidated,
        Finished
    }
    
    struct Invoice {
        address supplier;
        address[] listOfBuyers;
        uint[] dateOfBuyers;
        address currentBuyer;
        uint totalValue;
        uint issueDate;
        uint dueDate;
        uint currentRiskRating;
        uint dateRatingApplied;
        bool isValid;
        uint invalidDate;
        State invoiceState;
    }

    //State: (1) Invoicing, (2) Payable, (3) Invalidated, (4) Finished

}
