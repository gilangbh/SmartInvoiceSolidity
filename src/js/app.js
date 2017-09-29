App = {
  web3Provider: null,
  contracts: {},

  init: function() {

    // Load pets.
    $.getJSON('../invoices.json', function(data) {
      var invoiceRow = $('#invoiceRow');
      var invoiceTemplate = $('#invoiceTemplate');

      for (i = 0; i < data.length; i ++) {

        invoiceTemplate.find('.invoice-id').text(data[i].id);
        invoiceTemplate.find('.invoice-supplier').text(data[i].supplier);
        invoiceTemplate.find('.invoice-buyer').text(data[i].currentBuyer);
        invoiceTemplate.find('.invoice-value').text(data[i].totalValue);
        invoiceTemplate.find('.invoice-duedate').text(data[i].dueDate);
        invoiceTemplate.find('.invoice-riskrating').text(data[i].riskRating);
        invoiceTemplate.find('.btn-applyrating').attr('data-id', data[i].id);

        invoiceRow.append(invoiceTemplate.html());
      }
    });

    return App.initWeb3();
  },

  initWeb3: function() {
    // Is there is an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // If no injected web3 instance is detected, fallback to the TestRPC.
      App.web3Provider = new web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('SmartInvoice.json',function(data) {
      var invoiceArtifact = data;
      App.contracts.SmartInvoice = TruffleContract(invoiceArtifact);

      App.contracts.SmartInvoice.setProvider(App.web3Provider);

      return App.fillInvoiceData();
    })

    // $.getJSON('Adoption.json', function(data) {
    //   // Get the necessary contract artifact file and instantiate it with truffle-contract.
    //   var AdoptionArtifact = data;
    //   App.contracts.Adoption = TruffleContract(AdoptionArtifact);

    //   // Set the provider for our contract.
    //   App.contracts.Adoption.setProvider(App.web3Provider);

    //   // Use our contract to retieve and mark the adopted pets.
    //   return App.markAdopted();
    // });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
    $(document).on('click', '.btn-addInvoice', App.addInvoice);
    $(document).on('click', '.btn-sell', App.sellInvoice);
    $(document).on('click', '.btn-applyrating', App.applyrating);
  },

  addInvoice: function() {
    event.preventDefault();
    
    var supplierAddress = $('#supplierAddress').val();
    alert(supplierAddress);
  },

  sellInvoice: function() {
    event.preventDefault();

    var invoiceId = parseInt($(event.target).data('id'));
    var invoiceInstance;

    bootbox.prompt("Please input the new address", function(result){

      var newBuyer = result;

      web3.eth.getAccounts(function(error,accounts){
        if (error) {
          console.log(error);
        }

        var account = accounts[0];

        App.contracts.SmartInvoice.deployed().then(function(instance) {
          invoiceInstance = instance;

          return invoiceInstance.sellInvoice(invoiceId, newBuyer, {from: account});

        }).then(function(result) {
          console.log(result);
          return App.fillInvoiceData();
        }).catch(function(err) {
        console.log(err.message);
        });
      });
    });
  },

  applyrating: function() {
    event.preventDefault();

    var invoiceId = parseInt($(event.target).data('id'));
    var invoiceInstance;

    bootbox.prompt("Please input the new rating", function(result){

      var newRating = result;

      web3.eth.getAccounts(function(error,accounts){
        if (error) {
          console.log(error);
        }

        var account = accounts[0];

        App.contracts.SmartInvoice.deployed().then(function(instance) {
          invoiceInstance = instance;

          return invoiceInstance.applyRiskRating(invoiceId,newRating);

        }).then(function(result) {
          console.log(result);
          //  return App.fillInvoiceData();
        }).catch(function(err) {
          console.log(err.message);
        });
      });
    });
  },

  fillInvoiceData: function(suppliers, account) {
    // var smartInvoiceInstance;

    // App.contracts.SmartInvoice.deployed().then(function(instance) {
    //   smartInvoiceInstance = instance;

    //   return smartInvoiceInstance.getInvoiceSuppliers.call();
    // }).then(function(suppliers) {
    //     var invoiceRow = $('#invoiceRow');
    //     var invoiceTemplate = $('#invoiceTemplate');

    //   for (i = 0; i < suppliers.length; i++) {
    //     invoiceTemplate.find('.invoice-supplier').text(suppliers[i]);
    //     invoiceRow.append(invoiceTemplate.html());
    //   }
    // }).catch(function(err) {
    //   console.log(err.message);
    // });

  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
