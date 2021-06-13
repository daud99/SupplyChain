pragma solidity ^0.4.0;


contract SupplyChain {

    enum State { FORSALE, NOTFORSALE, SOLD, SHIPPED, NOTFOUND }


    struct Item {
        uint Id;
        string name;
        uint price;
        State status;
        address owner;
    }

    Item[] public items;


    uint public nextId = 0;

    // Function to add new item

    function addItem(string memory name, uint price) public {
        items.push(Item(nextId, name, price, State.FORSALE, msg.sender));
        nextId++;
    }


    // Given the id of the item return it's all attributes
    function queryItem(uint id) public view returns (string memory, uint, string memory, address) {
        for(uint i=0; i < items.length; i++) {
            if(id == items[i].Id)
            {
                return (items[i].name, items[i].price, getEnumStringByValue(items[i].status), items[i].owner);
            }
        }
        return ("", 0, getEnumStringByValue(State.NOTFOUND),  0x0);
    }
    
    function buyItem(uint id) public returns (string memory) {
        int found =  findItem(id);
        if(found < 0)
        {
            return "The item with given id doesn't exist!";
        }
        uint ufound = uint(found);
        if(items[ufound].status != State.FORSALE)
        {
         return "The item with the given id is not for sale!";   
        }
        // This the way we can get the balance of account in latest truffle version
        // balance = await web3.eth.getBalance(msg.sender); 
        //  if (balance < items[ufound].price)
        //  {
        //      return "Insufficient balance to purchase the product. Sorry!";
        //  }

        // transferring amount from the buyer to seller
        items[ufound].owner.transfer(items[ufound].price);
        

        items[ufound].owner = msg.sender;
        items[ufound].status = State.SOLD;
        return strCat("The item ", items[ufound].name, " is successfully bought", "");
    }


    function shipItem(uint id, string memory _address) public returns (string memory) {
        int found =  findItem(id);
        if(found < 0)
        {
            return "The item with given id doesn't exist!";
        }
        uint ufound = uint(found);
        if(items[ufound].status != State.SOLD)
        {
         return "The item with the given id is sold, so how can we ship it. LOLz!";   
        }
        items[ufound].status = State.SHIPPED;

        return strCat("The item", items[ufound].name, "is shipped successfully to ", _address);
    }


    function receiveItem(uint id) public returns (string memory) {
        int found =  findItem(id);
        if(found < 0)
        {
            return "The item with given id doesn't exist!";
        }
        uint ufound = uint(found);
        if(items[ufound].status != State.SHIPPED)
        {
         return "The item with the given id is not shipped how can i receive it. kindly ship it!";   
        }

        items[ufound].status = State.NOTFORSALE;
        return strCat("The item", items[ufound].name, "is received successfully", "");
    }


    function findItem(uint id) internal view returns (int) {
         for(uint i=0; i < items.length; i++) {
            if(id == items[i].Id)
            {
                return int(i);
            }
        }
        return -1;
    }

    
    function getEnumStringByValue(State _state) internal pure returns (string memory) {
        
     // Error handling for input
     require(uint8(_state) <= 4);
        
     // Loop through possible options
     if (State.FORSALE == _state) return "FOR SALE";
     if (State.NOTFORSALE == _state) return "NOT FOR SALE";
     if (State.SOLD == _state) return "SOLD";
     if (State.SHIPPED == _state) return "SHIPPED";
     if (State.NOTFOUND == _state) return "NOT FOUND";
    }


    function strCat(string a, string b, string c, string d) internal pure returns (string) {
        return string(abi.encodePacked(a, b, c, d));
    }   

}