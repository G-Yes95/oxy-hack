// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//imports
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract DebtToken is ERC1155 {
    error ER1155NonApprovedMinter();
    error ER1155NonApprovedBurner();

    address immutable loanFactory;

    // Used to track the totalSupply for each ID
    mapping(uint256 => uint256) public totalSupply;
    constructor(address _loanFactory) ERC1155("DEBT TOKEN") {
        loanFactory = _loanFactory;
    }

    function mint(address account, uint256 id, uint256 value) public {
        if (_msgSender() != loanFactory) {
            revert ER1155NonApprovedMinter();
        }

        bytes memory emptyBytes = new bytes(0);
        _mint(account, id, value, emptyBytes);
        totalSupply[id] += value;
    }

    function burn(address account, uint256 id, uint256 value) public {
        if (id != uint256(uint160(_msgSender()))) {
            revert ER1155NonApprovedBurner();
        }

        _burn(account, id, value);
        totalSupply[id] -= value;
    }
}
