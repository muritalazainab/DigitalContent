

// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// Digital Content Copyright Registry - Create a contract for
// registering digital content, where creators can log ownership
// details and buyers can purchase rights or licenses.

contract DigitalContent {
    address public owner;
    address public nextOwner;

    struct Work {
        string title;
        string description;
        uint256 licensePrice;
        bool isSold;
        address buyer;
    }

    Work[] public works;

    event ContentCreated(string title, string description, uint256 licensePrice);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContentSold(uint256 indexed index, address buyer);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function createContent(
        string memory _title,
        string memory _desc,
        uint256 _licensePrice
    ) external onlyOwner {
        require(msg.sender != address(0), "Zero Address is not allowed");

        Work memory newWork = Work({
            title: _title,
            description: _desc,
            licensePrice: _licensePrice,
            isSold: false,
            buyer: address(0)
        });
        
        works.push(newWork);
        emit ContentCreated(_title, _desc, _licensePrice);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        nextOwner = _newOwner;
    }

    function claimOwnership() external {
        require(msg.sender == nextOwner, "Not next owner");
        emit OwnershipTransferred(owner, nextOwner);
        owner = msg.sender;
        nextOwner = address(0);
    }

    function buyContent(uint256 _index) external payable {
        require(msg.sender != address(0), "Zero address is not allowed");
        require(_index < works.length, "Index out of bound");
        Work storage selectedWork = works[_index];
        require(!selectedWork.isSold, "Content already sold");
        require(msg.value == selectedWork.licensePrice, "Incorrect payment amount");

        selectedWork.isSold = true;
        selectedWork.buyer = msg.sender;
        payable(owner).transfer(msg.value);

        emit ContentSold(_index, msg.sender);
    }

   
}


