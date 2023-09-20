// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;



contract Marketplace {

    struct Item {

        bytes32   itemId;
        string    name;
        string    description;
        string    image;
        uint256   price;
        uint256   stock;
        address   ownerId;
        uint256   createdAt;
    }


    struct Transaction {

        bytes32   transactionId;
        bytes32   itemId;
        string    name;
        string    description;
        string    image;
        uint256   price;
        uint256   qty;
        address   buyer;
        uint256   createdAt;
    }


    // list stores
    address[] public stores;

    // list item
    mapping(address => Item[]) items;

    // list transaction
    mapping(address => Transaction[]) transactions;

    // list wallet store
    mapping(address => uint256) public wallets;


    // untuk melakukan validasi bahwa telah terdaftar menjadi store
    modifier onlyStore () {

        require(checkStore() == true, "Anda harus mendaftar terlebih dahulu");
        _;
    }


    // untuk melakukan pemeriksaan apakah sudah mendaftar menjadi store / belum
    function checkStore() public view returns(bool) {

        for (uint256 indexStores = 0; indexStores < stores.length; indexStores++) {
            
            if(stores[indexStores] == msg.sender) return true;
        }

        return false;
    }


    // unuk membuat store
    function createStore() public {

        require(checkStore() == false, "Anda sudah mendaftar");
        
        stores.push(msg.sender);
    }


    //  untuk mendapatkan list store
    function getStore() public view returns(address[] memory) { return stores; }


    // untuk mendapatkan detail item dari store
    function getItemByIdAndStoreId(address address_, bytes32 itemId_) public view returns(Item memory) {

        for (uint256 indexItem = 0; indexItem < items[address_].length; indexItem++) {
            
            if(items[address_][indexItem].itemId == itemId_) return items[address_][indexItem];
        }

        revert("Item not found");
    }


    // untuk melakukan update stock item
    function updateItemStock(address address_, bytes32 itemId_, uint256 qty_ ) internal {

        for (uint256 indexItem = 0; indexItem < items[address_].length; indexItem++) {

            if(items[address_][indexItem].itemId == itemId_) items[address_][indexItem].stock -= qty_;
        }
    }


    // untuk mendapatkan list item dari store
    function getItemStoreByAddress(address address_) public view returns(Item[] memory) {

        return items[address_];
    }


    // untuk mendapatkan list history dari transaction bedasarkan address
    function getTransactionByAddress() public view returns(Transaction[] memory) {

        return transactions[msg.sender];
    }



    // untuk menjual barang
    function sell(

        string calldata name_,
        string calldata description_,
        string calldata image_,
        uint256 price_,
        uint256 qty_
    ) public onlyStore() {

        bytes32 itemId = keccak256(
            abi.encodePacked(msg.sender, block.timestamp)
        );


        Item memory item = Item(

            itemId,
            name_,
            description_,
            image_,
            price_,
            qty_,
            msg.sender,
            block.timestamp
        );

        items[msg.sender].push(item);
    }


    // untuk melakukan pembelian barang
    function buy(

        address addressSeller_,
        bytes32 itemId_,
        uint256 qty_
    ) external payable {

        Item memory item = getItemByIdAndStoreId(addressSeller_, itemId_);
        require(item.stock >= qty_, "Stok tidak tersedia");
        require(msg.value == item.price * qty_, "Harga tidak sesuai");


        bytes32 transactionId = keccak256(
            abi.encodePacked(
                msg.sender,
                itemId_,
                block.timestamp
            )
        );

        Transaction memory transaction = Transaction(

            transactionId,
            itemId_,
            item.name,
            item.description,
            item.image,
            item.price,
            qty_,
            msg.sender,
            block.timestamp
        );

        wallets[item.ownerId] += msg.value;
        updateItemStock(addressSeller_, itemId_, qty_);

        transactions[msg.sender].push(transaction );
    }



    // withdraw 
    function withdrawMoney() external {

        (bool success,) = msg.sender.call{value : wallets[msg.sender]}("");

        require(success, "transfer failed");
        wallets[msg.sender] = 0;
    }

}