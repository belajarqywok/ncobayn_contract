const { except } = require("chai")
const { ethers } = require("hardhat")
const { utils }  = require("ethers")

describe("Marketplace Contract Testing", () => {

    beforeEach(async() => {

        const Marketplace = await ethers.getContractFactory("Marketplace");
        [owner, addr1, addr2, ...addrrs] = await ethers.getSigners();

        marketplace = await Marketplace.deploy();
    })


    it("test contract", async () => {

        // create store
        await marketplace.createStore()

        // sell item
        await marketplace.sell(
            "Steyr AUG A3", 
            "cal 5.56 NATO, range 2900m, silencer",
            "http://192.168.137.1/images/cjeiwjedjwcijweddwedwecw.jpg",
            ethers.utils.parseEther(`${0.5}`),
            100
        )

        // get item store
        const itemStores = await marketplace.getItemStoreByAddress(owner.address)

        // get item
        const item = await marketplace.getItemByIdAndStoreId(owner.address, itemStores[0].itemId)
        console.log(item)

        // buy item
        const qty = 10
        const total = `${qty * 0.5}`
        await marketplace.connect(addr1).buy(owner.address, item.itemId, qty, {
            value : ethers.utils.parseEther(total)
        })

        // get transaction 
        const transactionHistory = await marketplace.connect(addr1).getTransactionByAddress()
        console.log(transactionHistory)


        // check owner balance
        let balance = await ethers.provider.getBalance(owner.address)
        console.log(ethers.utils.formatEther(balance))


        // withdraw money
        await marketplace.withdrawMoney()

        // check owner balance
        balance = await ethers.provider.getBalance(owner.address)
        console.log(ethers.utils.formatEther(balance))
    })

    
})