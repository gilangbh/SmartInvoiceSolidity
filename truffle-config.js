module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    azure: {
      host: "kartoonh7.eastus.cloudapp.azure.com",
      port: 8545,
      from: "0xec7c1e944532f31eae8a7699b2f9bd8710bcd2b1",
      network_id: "*" // Match any network id
    }
  }
};
