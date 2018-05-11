pragma solidity ^0.4.23;


contract EncryptionInterface {
    function recieveMessage(string _message) public;
    function saveFriendPublicKey(string _key) public;
}

contract Encryption {
    
    string public publicKey = "";
    string[] chats;
    address public friendContractAddress;
    string public friendPublicKey;

    function setMyPublicKey(string _publicKey) public  {
        publicKey = _publicKey;
    }
    
    function getLastMessage() public constant returns (string) {
        return chats[chats.length - 1];
    }
    
    function setFriend(address _friendContractAddress) public {
        friendContractAddress = _friendContractAddress;
    }
    
    function sendMessageToFriend(string _message) public {
        EncryptionInterface encryptionTestInterface = EncryptionInterface(friendContractAddress);
        encryptionTestInterface.recieveMessage(_message);
    }
    
    function recieveMessage(string _message) public {
        chats.push(_message);
    }
    
    function sendMyPublicKeyToFriend() public {
        EncryptionInterface encryptionTestInterface = EncryptionInterface(friendContractAddress);
        encryptionTestInterface.saveFriendPublicKey(publicKey);
    }
    
    function returnMyPublicKey() public constant returns (string) {
        return publicKey;
    }
    
    function saveFriendPublicKey(string _key) public {
        friendPublicKey = _key;
    }
    
}


