const NecoNFT = artifacts.require("NecoNFT");

contract("NecoNFT", ([Tom, Jerry, Rose]) => {
    it("should mint NFT correctly", async () => {
        const necoNft = await NecoNFT.deployed()
        let err = null;
        try {
            await necoNft.mint(1, Tom, '', 10, web3.utils.utf8ToHex('Neco Fishing'));
        } catch (error) {
            err = error;
        }
        assert.ok(err instanceof Error);
        await necoNft.addCreator(Tom);

        err = null
        try {
            await necoNft.mint(1, Tom, '', 10, web3.utils.utf8ToHex('Neco Fishing'));
        } catch (error) {
            err = error;
        }
        assert.ok(err instanceof Error);

        await necoNft.mint(1, Tom, 'ipfs://test.com', 10, web3.utils.utf8ToHex('Neco Fishing'));
        assert.equal(await necoNft.balanceOf(Tom, 1).valueOf(), 10);

        assert.equal(await necoNft.uri(1).valueOf(), "ipfs://test.com")

        await necoNft.mint(2, Tom, 'ipfs://test2.com', 10, web3.utils.utf8ToHex('Neco Fishing'));
        await necoNft.mint(3, Tom, 'ipfs://test3.com', 10, web3.utils.utf8ToHex('Neco Fishing'));

        err = null;
        try {
            await necoNft.mint(1, Tom, 'ipfs://test3.com', 10, web3.utils.utf8ToHex('Neco Fishing'));
        } catch (error) {
            err = error;
        }
        assert.ok(err instanceof Error);
    })

    it("can not transfer NFT when NFT is locked", async () => {
        const necoNft = await NecoNFT.deployed()
        await necoNft.addLockedNFT(1);
        let err = null;
        try {
            await necoNft.safeTransferFrom(Tom, Jerry, 1, 2, web3.utils.utf8ToHex('transfer'))
        } catch (error) {
            err = error;
        }
        assert.ok(err instanceof Error);
        await necoNft.addIntoTransferWhitelist(Tom);
        await necoNft.safeTransferFrom(Tom, Jerry, 1, 2, web3.utils.utf8ToHex('transfer'))
        assert.equal(await necoNft.balanceOf(Jerry, 1).valueOf(), 2)
    })

    it("can not transfer batch of NFT when some NFTs are locked", async () => {
        const necoNft = await NecoNFT.deployed()
        await necoNft.removeFromTransferWhitelist(Tom);
        let err = null;
        try {
            await necoNft.safeBatchTransferFrom(Tom, Jerry, [1, 2], [2, 2], web3.utils.utf8ToHex('transfer'))
        } catch (error) {
            err = error;
        }
        assert.ok(err instanceof Error);
        await necoNft.addIntoTransferWhitelist(Tom);
        await necoNft.safeBatchTransferFrom(Tom, Jerry, [1, 2], [2, 2], web3.utils.utf8ToHex('transfer'))
        assert.equal(await necoNft.balanceOf(Jerry, 2).valueOf(), 2)
        assert.equal(await necoNft.balanceOf(Jerry, 1).valueOf(), 4)
    })
})