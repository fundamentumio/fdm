const FundamentumToken = artifacts.require('./contracts/fundamentum-1404/FundamentumToken');
const BN = web3.utils.BN;

contract('FundamentumToken', ([sender, recipient, ...accounts]) => {
    const initialAccount = sender;
    const transferValue = '10000000000000';
    const InitialSupply = '10000000000000000000';
    const TokenName = 'Fundamentum';
    const TokenSymbol = 'FDM';
    const Decimals = 18;

    let token;
    let tokenTotalSupply;
    let recipientEthBalanceBefore;
    let tokenBalanceBefore;
    let SUCCESS_CODE;
    let SUCCESS_MESSAGE;
    let NON_WHITELIST_CODE;
    let NON_WHITELIST_ERROR;

    before(async () => {
        token = await FundamentumToken.new(TokenName, TokenSymbol, InitialSupply);
        tokenTotalSupply = await token.totalSupply();
        SUCCESS_CODE = await token.SUCCESS_CODE();
        SUCCESS_MESSAGE = await token.SUCCESS_MESSAGE();
        NON_WHITELIST_CODE = await token.NON_WHITELIST_CODE();
        NON_WHITELIST_ERROR = await token.NON_WHITELIST_ERROR();
    });

    let senderBalanceBefore;
    let recipientBalanceBefore;
    beforeEach(async () => {
        senderBalanceBefore = await token.balanceOf(sender);
        recipientBalanceBefore = await token.balanceOf(recipient);
        recipientEthBalanceBefore = new BN(await web3.eth.getBalance(recipient));
        tokenBalanceBefore = await token.balanceOf(token.address);
    });

    it('should mint total supply of tokens to token account', async () => {
        const initialAccountBalance = await token.balanceOf(token.address);
        let initSupply = parseInt(InitialSupply) * 10 ** Decimals;
        assert(initialAccountBalance.eq(tokenTotalSupply))
    });

    it('should disallow illegal buying', async () => {
        let buyErr;
        try {
             await token.buy({ from: recipient, value: transferValue });
        } catch (err) {
            buyErr = err;
        }
        assert.notEqual(buyErr, undefined, 'Error must be thrown');
        assert.isAbove(buyErr.message.search(NON_WHITELIST_ERROR), -1,'invalid NON_WHITELIST_ERROR must be returned');
    });

    it('should add recipient to whitelist', async () => {
        await token.addAddressToWhitelist(recipient, { from: sender});
        let isWhitelisted = await token.whitelist(recipient);
        assert(isWhitelisted);
    });

    it('should buy to recipient', async () => {
        let sellPrice = await token.buyPrice();
        let res = await token.buy({ from: recipient, value: transferValue});
        let tx = await web3.eth.getTransaction(res.tx);
        let txCost = res.receipt.gasUsed * tx.gasPrice;
        let value = new BN(transferValue, 10);
        let amount = sellPrice.mul(value).div(new BN(10).pow(new BN(18))).add(new BN(txCost));
        let recipientBalanceAfter = await token.balanceOf(recipient);
        let tokenBalanceAfter = await token.balanceOf(token.address);

        let recipientEthBalanceAfter = new BN(await web3.eth.getBalance(recipient));
        assert(recipientBalanceBefore.add(value).eq(recipientBalanceAfter));
        assert(tokenBalanceBefore.sub(tokenBalanceAfter).eq(value));
        assert(recipientEthBalanceAfter.add(amount).eq(recipientEthBalanceBefore));
    });

    it('should allow valid transfer', async () => {
        await token.transfer(sender, transferValue, { from: recipient });
        let senderBalanceAfter = await token.balanceOf(sender);
        let recipientBalanceAfter = await token.balanceOf(recipient);
        let value = new BN(transferValue, 10);
        assert(senderBalanceAfter.eq(senderBalanceBefore.add(value)));
        assert(recipientBalanceAfter.eq(recipientBalanceBefore.sub(value)));
    });

    it('should allow valid transferFrom (after approval)', async () => {
        await token.approve(recipient, transferValue, { from: sender });
        await token.transferFrom(sender, recipient, transferValue, {
            from: recipient
        });
        let value = new BN(transferValue, 10);
        const senderBalanceAfter = await token.balanceOf(sender);
        const recipientBalanceAfter = await token.balanceOf(recipient);
        assert(senderBalanceAfter.eq(senderBalanceBefore.sub(value)));
        assert(recipientBalanceAfter.eq(recipientBalanceBefore.add(value)));
    });

    it('should mint tokens', async () => {
        await token.mint(token.address, transferValue, { from: sender });
        const tokenBalanceAfter = await token.balanceOf(token.address);
        let value = new BN(transferValue, 10);
        tokenTotalSupply = tokenTotalSupply.add(value);
        let totalSupply = await token.totalSupply();
        assert(tokenBalanceAfter.eq(tokenBalanceBefore.add(value)));
        assert(totalSupply.eq(tokenTotalSupply));
    });

    it('should detect success for valid transfer', async () => {
        const code = await token.detectTransferRestriction(sender, recipient, transferValue);
        assert(code.eq(SUCCESS_CODE))
    });

    it('should ensure success code is 0', async () => {
        assert.equal(SUCCESS_CODE, 0)
    });

    it('should return success message for success code', async () => {
        const message = await token.messageForTransferRestriction(SUCCESS_CODE);
        assert.equal(SUCCESS_MESSAGE, message)
    });

    it('should return error message for illegal buying to non whitelisted address', async () => {
        const message = await token.messageForTransferRestriction(NON_WHITELIST_CODE);
        assert.equal(NON_WHITELIST_ERROR, message);
    });


});