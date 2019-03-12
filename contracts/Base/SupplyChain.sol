pragma solidity ^0.5.1;

import '../AccessControl/AccessControl.sol';
import '../Core/Ownable.sol';

// Define a contract 'Supplychain'
contract SupplyChain is AccessControl, Ownable {

  // Define a variable called 'NFTID' to identify the token used to manage to engineering intellectual property managed between the designer and the verifier
  uint  NFTID;

  // Define a variable called 'FTI' for Fungible Token Inventory, the number of fungible tokens available to buy
  uint  FTI;

  // Define a public mapping 'items' that maps the NFTID to an FT.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the NFTID to an array of TxHash,
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;

  // Define enum 'State' with the following values:
  enum State
  {
    NFTMinted
    NFTAwaitingVerification,
    NFTSentForVerification,
    NFTVerified,
    FTCreated,
    FTForSale,
    FTSold,
    FTMinted
    }

  // And a Material State enum
    enum MaterialState {
        NFT,     // 1
        FT       // 2
    }

  State constant defaultState = State.NFTMinted;
  DesignState constant defaultDesignState = MaterialState.NFT;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    FTI;  // Fungible Token Inventory
    uint    NFTID; // The Unique Identifer of the Engineering IP NFT from which the Fungible game items are minted
    address payable ownerID;  // Metamask-Ethereum address of the current owner as the product moves through the stages
    address payable designerID; // Metamask-Ethereum address of the Designer
    string  designerName; // Designer Name
    string  designInformation;  // Designer Information (Link to competency platform eventually?)
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    MaterialState itemState2; // Material State of the product as represented by the enum above
    string  productNotesByVerifier; // Product notes that are added by the Verifier
    address payable verifierID;  // Metamask-Ethereum address of the Verifier
    address payable playerID; // Metamask-Ethereum address of the Player
  }

  // Define events with the same 18 state values and accept 'upc' as input argument
    // event createNFT??
    event NFTMinted (uint NFTID);
    event NFTSentForVerification (uint NFTID);
    event NFTAwaitingVerification (uint NFTID);
    event NFTVerificationRejected (uint NFTID);
    event NFTVerified (uint NFTID);
    event CreateFT  (uint NFTID);
    event FTForSale (uint NFTID);
    event FTSold (uint NFTID);
    event FTMinted (uint NFTID);

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address);
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) {
    require(msg.value >= _price);
    _;
  }

  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _NFTID) {
    _;
    uint _price = items[_NFTID].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_NFTID].ownerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of an NFTID is Minted
  modifier nftminded(uint _NFTID) {
    require(items[_NFTID].itemState == State.NFTMinted);
    _;
  }

  // Define a modifier that checks if an item.state of an NFTID is Awaiting Verification
  modifier nftsentforverification(uint _NFTID) {
      require(items[_upc].itemState == State.NFTSentForVerification);
    _;
  }

  // Define a modifier that checks if an item.state of an NFTID is Awaiting Verification
  modifier nftawaitingverification(uint _NFTID) {
      require(items[_NFTID].itemState == State.NFTAwaitingVerification);
    _;
  }

  // Define a modifier that checks if an item.state of an NFTID is Verified
  modifier nftverified(uint _NFTID) {
      require(items[_NFTID].itemState == State.NFTVerified);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier ftcreated(uint _NFTID) {
      require(items[_NFTID].itemState == State.FTCreated);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier ftforsale(uint _NFTID) {
      require(items[_NFTID].itemState == State.FTForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier ftsold(uint _NFTID) {
      require(items[_NFTID].itemState == State.FTSold);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier ftminted(uint _NFTID) {
      require(items[_NFTID].itemState == State.FTMinted);
    _;
  }



  // In the constructor
  // set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    FTI = 1;
    NFTID = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner()) {
      selfdestruct(msg.sender);
    }
  }


  // Define a function 'mintNFT' that allows a designer to mark an item 'NFTMinted'
  // Will need to be adjusted for production to emit an event that speaks to the Enjin Platform
  // Discuss with Witek
  function mintNFT(uint _NFTID,
    address _designerID,
    string memory _designerName,
    string memory _designerInformation,
    string memory _productNotes) public

  verifyCaller(_designerID) //VerifyCaller
  onlyDesigner() // onlyHarvester()
  {
    // Require that the NFTID does not already exist (presumeably all NFT will have a unique ID when created, how to call it?)
    require(_NFTID != 0 && items[_NFTID].NFTID == 0, "This NFTID already exists.");
    // Add the new item as part of NFT creation (how can we integrate minting event with this, call directly from the token? Mint custom NFT?)
    Item memory newItem;
    newItem.NFTID = NFTID;
    newItem.ownerID = msg.sender;
    newItem.designerID = msg.sender;
    newItem.designerName = _designerName;
    newItem.designInformation = _designInformation;
    newItem.productNotes = _productNotes;
    newItem.itemState = State.NFTMinted;
    newItem.itemState2 = MaterialState.NFT;

    // Add item to mapping using UFC
    items[_NFTID] = newItem;

    // Emit the appropriate event (speak to Witek about what ti actually needs to look like)
    emit NFTMinted(_NFTMinted);

  }

  // Define a function 'sendForVerification' which is qualitatively similar to making an item available for sale
  function sendForVerification(uint _NFTID) public
  // Call modifier to check if NFTID has passed previous supply chain stage
  nftminted(_NFTID)
  // Only designer
  onlyDesigner()
  // Call modifier to verify caller of this function
  verifyCaller(items[_NFTID].designerID)
  {
    // Update the appropriate fields
    items[_NFTID].itemState = State.SentForVerification;

    // Emit the appropriate event
    emit SentForVerification(_NFTID);
  }

  // Define a function 'acceptForVerification' that allows a verifier to accept a design for verification
  // Qualitivately similar to buying an item
  function acceptForVerification(uint _NFTID) public
  // Call modifier to check if upc has passed previous supply chain stage
  nftsentforverification(_NFTID)
  // Only manufacturer
  onlyVerifier()
  // Call modifer to send any excess ether back to buyer
  verifyCaller(items[_NFTID].verifierID)
  {

  // Update the appropriate fields - ownerID, distributorID, itemState
  items[_NFTID].itemState = State.NFTAwaitingVerification;
  // emit the appropriate event
  emit NFTAwaitingVerification(_NFTID);
}

  // Define a function 'rejectVerification' that allows a verifier to reject an engineering design
  function rejectVerification(uint _NFTID) public
  // Call modifier to check if upc has passed previous supply chain stage
  nftawaitingverification(_NFTID)
  // Only harvester
  onlyVerifier()
  // Call modifier to verify caller of this function
  verifyCaller(items[_NFTID].verifierID)
  {
    // Update the appropriate fields
    items[_NFTID].itemState = State.NFTMinted;

    // Emit the appropriate event
    emit NFTVerificationRejected(_NFTID);
  }

  // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough,
  // and any excess ether sent is refunded back to the buyer
  function verify(uint _NFTID) public
    // Call modifier to check if upc has passed previous supply chain stage
    awaitingverification(_NFTID)
    // Only manufacturer
    onlyVerifier()
    // Call modifer to send any excess ether back to buyer
    verifyCaller(items[_NFTID].verifierID)
    {
    // Update the appropriate fields - ownerID, distributorID, itemState
    items[_NFTID].itemState = State.NFTVerified;
    // emit the appropriate event
    emit NFTVerified(_NFTID);
  }

  // Define a function 'create' that allows the distributor to mark an item 'FTCreated'
  // Use the above modifers to check if the item is sold
  function createFT(uint _upc) public
    // Call modifier to check if upc has passed previous supply chain stage
    nftverified(_NFTID)
    // Only harvester
    onlyDesigner()
    // Call modifier to verify caller of this function
    verifyCaller(items[_NFTID].designerID)
    {
    // Update the appropriate fields (needs an asynchronous callback to enjin cloud somehow)
    items[_upc].itemState = State.FTCreated;

    // Emit the appropriate event
    emit CreateFT(_NFTID);
    // What is the callback sequence for this? Speak to Witek!
  }

  // Define a function 'ListForSale' that allows the manufacturer to mark an item 'FTListedForSale'
  // Use the above modifiers to check if the item is shipped
  function ListForSale(uint _NFTID, uint _price)) public
    // Call modifier to check if upc has passed previous supply chain stage
    ftcreated(_NFTID)
    // Only manufacturer
    onlyDesigner()
    // Access Control List enforced by calling Smart Contract / DApp
    verifyCaller(items[_NFTID].designerID)
    {
    // Update the appropriate fields
    items[_NFTID].productPrice = _price;
    items[_NFTID].itemState = State.FTForSale;

    // Emit the appropriate event
    emit FTForSale(_NFTID);
  }

  function buyFT(uint _upc) public payable
    // Call modifier to check if upc has passed previous supply chain stage
    FTForSale(_upc)
    // Only distributor
    onlyPlayer()
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_NFTID].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_NFT)
    {

    // Update the appropriate fields - ownerID, distributorID, itemState
    items[_NFTID].ownerID = msg.sender;
    items[_NFTID].playerID = msg.sender;
    items[_NFTID].itemState = State.FTSold;
    // Transfer money to farmer
    items[_NFTID].designerID.transfer(items[_NFTID].productPrice);
    // emit the appropriate event
    emit FTSold(_NFTID);
  }

  // Allow shipping of product by Manufacturer
  // Use the above modifers to check if the item is sold
  function MintFT(uint _NFTID) public
    // Call modifier to check if upc has passed previous supply chain stage
    FTSold(_NFTID)
    // Only manufacturer
    onlyDesigner()
    // Call modifier to verify caller of this function
    verifyCaller(items[_NFTID].designerID)
    {
    // Update the appropriate fields
    items[_upc].itemState = State.FTMinted;

    // Emit the appropriate event
    emit FTMinted(_NFTID);
  }

  // Work this out later
  function fetchItemBufferOne(uint _NFTID) public view returns
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originHarvesterID,
  string memory originHarvesterName,
  string memory originHarvesterInformation
  )
  {
  // Assign values to the 8 parameters
  Item memory returnItem = items[_upc];

  return
  (
  returnItem.sku,
  returnItem.upc,
  returnItem.ownerID,
  returnItem.originHarvesterID,
  returnItem.originHarvesterName,
  returnItem.originHarvesterInformation,
  returnItem.originHarvesterLatitude,
  returnItem.originHarvesterLongitude
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string memory productNotes,
  string memory productNotesByManufacturer,
  uint    productPrice,
  State   itemState,
  MaterialState    itemState2,
  address payable manufacturerID,
  address payable distributorID,
  address payable retailerID,
  address payable consumerID
  )
  {
    // Assign values to the 9 parameters
  Item memory returnItem = items[_upc];

  return
  (
  returnItem.sku,
  returnItem.upc,
  returnItem.productID,
  returnItem.productNotes,
  returnItem.productNotesByManufacturer,
  returnItem.productPrice,
  returnItem.itemState,
  returnItem.itemState2,
  returnItem.manufacturerID,
  returnItem.distributorID,
  returnItem.retailerID,
  returnItem.consumerID
  );
  }
}
