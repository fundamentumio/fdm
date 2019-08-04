const Fundamentum = artifacts.require("./FundamentumToken.sol");
const MessagesAndCodes = artifacts.require("./MessagesAndCodes.sol");
const InitialSupply = 100000000;
const TokenName = 'Fundamentum';
const TokenSymbol = 'FDM';


module.exports = function(deployer) {
    deployer.deploy(MessagesAndCodes).then(() => {
        deployer.deploy(Fundamentum, TokenName, TokenSymbol, InitialSupply)
    });
    deployer.link(MessagesAndCodes, Fundamentum);
};