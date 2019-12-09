pragma solidity >= 0.5.13;


contract EncryptionInterface {
    function recieveMessage(string memory _message) public;
    function saveFriendPublicKey(string memory _key) public;
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
        EncryptionInterface encryptionTestInterface = EncryptionInterface(friendContractAddress);
        encryptionTestInterface.recieveMessage(_message);
    }
    
    function recieveMessage(string memory _message) public {
        chats.push(_message);
    }
    
    function sendMyPublicKeyToFriend() public {
        EncryptionInterface encryptionTestInterface = EncryptionInterface(friendContractAddress);
        encryptionTestInterface.saveFriendPublicKey(publicKey);
    }
    
    function returnMyPublicKey() public view returns (string memory) {
        return publicKey;
    }
    
    function saveFriendPublicKey(string memory _key) public {
        friendPublicKey = _key;
    }
    
}


