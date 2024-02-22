// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ECommerce {
    address public owner;
    
    struct Item {
        uint256 id;
        string name;
        uint256 price;
        uint256 quantity;
        address seller;
    }
    
    mapping(uint256 => Item) public items;
    uint256 public itemCount;
    
    event ItemAdded(uint256 id, string name, uint256 price, uint256 quantity, address seller);
    event ItemPurchased(uint256 id, string name, uint256 price, uint256 quantity, address buyer);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function addItem(string memory _name, uint256 _price, uint256 _quantity) external onlyOwner {
        itemCount++;
        items[itemCount] = Item(itemCount, _name, _price, _quantity, msg.sender);
        emit ItemAdded(itemCount, _name, _price, _quantity, msg.sender);
    }
    
    function getAvailableItems() external view returns (Item[] memory) {
        Item[] memory availableItems = new Item[](itemCount);
        uint256 availableItemCount = 0;
        for (uint256 i = 1; i <= itemCount; i++) {
            if (items[i].quantity > 0) {
                availableItems[availableItemCount] = items[i];
                availableItemCount++;
            }
        }
        return availableItems;
    }
    
    function purchaseItem(uint256 _itemId, uint256 _quantity) external payable {
        require(_itemId <= itemCount && _itemId > 0, "Invalid item ID");
        require(_quantity > 0 && _quantity <= items[_itemId].quantity, "Invalid quantity");
        require(msg.value >= items[_itemId].price * _quantity, "Insufficient funds");

        items[_itemId].quantity -= _quantity;
        payable(items[_itemId].seller).transfer(msg.value);
        emit ItemPurchased(_itemId, items[_itemId].name, items[_itemId].price, _quantity, msg.sender);
    }
    
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
