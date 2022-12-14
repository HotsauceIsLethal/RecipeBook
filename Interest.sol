pragma solidity ^0.5.0;

// This contract allows someone to let another person know that they are interested in them.

contract Interest {
  // The address of the person who is interested in the other person
  address public sender;

  // The address of the person who is being told that they are interested in
  address public recipient;

  // The message that the sender wants to send to the recipient
  string public message;

  // The constructor sets the sender and recipient addresses and the message
  constructor(address _sender, address _recipient, string memory _message) public {
    sender = _sender;
    recipient = _recipient;
    message = _message;
  }

  // This function allows the recipient to retrieve the message from the sender
  function getMessage() public view returns (string memory) {
    return message;
  }
}
