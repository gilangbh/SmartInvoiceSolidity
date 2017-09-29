pragma solidity ^0.4.15;

import '../Utilities/Ownable.sol';

contract SmartInvoice is Ownable {

    Invoice[] invoiceList;
    uint invoiceCount;
    address[] invoiceSuppliers;
    address[] _listOfBuyers;
    uint[] _dateOfBuyers;

    event AddedInvoice(address operator, uint invoiceId, uint issueDate, address supplier, address currentBuyer);

    function SmartInvoice() {

    }

    function initializeDummy() onlyOwner {
        Invoice memory _invoice0;

        _invoice0.supplier = 0x826ac204372F51152EdfF31fA46E4cC5A31ECE5e;
        _invoice0.currentBuyer = 0xc72B6404e8417b65E8c3cbb51e55aB719C6A37CC;
        _invoice0.totalValue = 1500000;
        _invoice0.currentRiskRating = 5;
        _invoice0.dueDate = 0;

        invoiceList.push(_invoice0);

        invoiceSuppliers.push(0x826ac204372F51152EdfF31fA46E4cC5A31ECE5e);

        Invoice memory _invoice1;

        _invoice1.supplier = 0x18D54cca8608d90661244AF0FEb0A3D3Ad367aCD;
        _invoice1.currentBuyer = 0xf38157013B8E9AD41eE8092E6eA5D24fc38d928b;
        _invoice1.totalValue = 3000000;
        _invoice1.currentRiskRating = 2;
        _invoice1.dueDate = 0;

        invoiceList.push(_invoice1);

        invoiceSuppliers.push(0x18D54cca8608d90661244AF0FEb0A3D3Ad367aCD);

        Invoice memory _invoice2;

        _invoice2.supplier = 0x1605906e66a25EEc5ef206a1C8e2f99F24E6E253;
        _invoice2.currentBuyer = 0x18D54cca8608d90661244AF0FEb0A3D3Ad367aCD;
        _invoice2.totalValue = 2000000;
        _invoice2.currentRiskRating = 9;
        _invoice2.dueDate = 0;

        invoiceList.push(_invoice2);

        invoiceSuppliers.push(0x1605906e66a25EEc5ef206a1C8e2f99F24E6E253);
    }

    function getInvoiceLength() public constant returns (uint) {
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
        address _currentBuyer,
        uint _totalValue,
        uint _issueDate,
        uint _dueDate,
        uint _currentRiskRating,
        uint _dateRatingApplied,
        bool _isValid,
        uint _invalidDate) {
        
        Invoice _inn;
        _inn.supplier = msg.sender;
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
        //invoiceSuppliers[invoiceCount - 1] = _inn.supplier;
        invoiceSuppliers.push(msg.sender);

        AddedInvoice(msg.sender, invoiceCount, now,_inn.supplier,_currentBuyer);
    }

    function applyRiskRating(uint invoiceId, uint rating) onlyOwner {
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
        require (_invoice.currentBuyer == msg.sender);

        //invoiceList[invoiceId].listOfBuyers.push(newBuyer);
        invoiceList[invoiceId].currentBuyer = newBuyer;
        //invoiceList[invoiceId].dateOfBuyers.push(now);
    }

    function invalidateInvoice(uint invoiceId) {
        require(invoiceId != 0);
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);
        require (_invoice.supplier == msg.sender);

        invoiceList[invoiceId].isValid = false;
        invoiceList[invoiceId].invalidDate = now;
        invoiceList[invoiceId].invoiceState = State.Invalidated;
    }

    function finishInvoice(uint invoiceId) {
        require(invoiceId != 0);
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);
        require (_invoice.supplier == msg.sender);

        invoiceList[invoiceId].invoiceState = State.Finished;
    }

    function clear() {
        invoiceCount = 0;
    }

    enum State {
        Invoicing,
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
}
