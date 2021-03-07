// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;


interface IEncryption {
    function recieveMessage(string memory _message) external;
    function saveFriendPublicKey(string memory _key) external;
}

contract Encryption {
    
    string public publicKey = "";
    string[] chats;
    address public friendContractAddress;
    string public friendPublicKey;

    function setMyPublicKey(string memory _publicKey) public  {
        publicKey = _publicKey;
    }
    
    function getLastMessage() public view returns (string memory) {
        return chats[chats.length - 1];
    }
    
    function setFriend(address _friendContractAddress) public {
        friendContractAddress = _friendContractAddress;
    }
    
    function sendMessageToFriend(string memory _message) public {
        IEncryption encryptionTest = IEncryption(friendContractAddress);
        encryptionTest.recieveMessage(_message);
    }
    
    function recieveMessage(string memory _message) public {
        chats.push(_message);
    }
    
    function sendMyPublicKeyToFriend() public {
        IEncryption encryptionTest = IEncryption(friendContractAddress);
        encryptionTest.saveFriendPublicKey(publicKey);
    }
    
    function returnMyPublicKey() public view returns (string memory) {
        return publicKey;
    }
    
    function saveFriendPublicKey(string memory _key) public {
        friendPublicKey = _key;
    }
    
}


