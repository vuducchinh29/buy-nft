// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BoxNFT is Ownable, ERC721 {
    using SafeMath for uint256;

    address public receiver;

    address public paymentToken;

    uint256 public price;

    uint256 private _latestTokenId;

    event BoxMint(uint256 tokenId, address indexed user, uint256 timestamp);

    constructor(address _receiver, address _paymentToken, uint256 _price) ERC721("Box NFT", "BOXNFT") {
        receiver = _receiver;
        paymentToken = _paymentToken;
        price = _price;
    }

    function _mint(address to, uint256 tokenId) internal override(ERC721) {
        super._mint(to, tokenId);
        _incrementTokenId();
    }

    function _getNextTokenId() private view returns (uint256) {
        return _latestTokenId.add(1);
    }

    function _incrementTokenId() private {
        _latestTokenId++;
    }

    function buy(uint8 _amount) external {
        require(_amount >= 1, "require: at least 1");
        IERC20(paymentToken).transferFrom(_msgSender(), receiver, price.mul(_amount));
        uint8 time = 0;
        while (time < _amount) {
            uint256 nextTokenId = _getNextTokenId();
            _mint(_msgSender(), nextTokenId);
            emit BoxMint(nextTokenId, _msgSender(), block.timestamp);
            time++;
        }
    }

    function setReceiver(address _receiver) external onlyOwner {
        receiver = _receiver;
    }

    function setPaymentToken(address _paymentToken) external onlyOwner {
        paymentToken = _paymentToken;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }
}
