// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//imports
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract DebtToken is ERC1155 {
    address immutable loanFactory;

    constructor(address _loanFactory) ERC1155("DEBT TOKEN") {
        loanFactory = _loanFactory;
    }

    function mint(address account, uint256 id, uint256 value) public {
        if (_msgSender() == loanFactory) {
            // Need to update error
            revert ERC1155MissingApprovalForAll(_msgSender(), account);
        }

        bytes memory emptyBytes = new bytes(0);
        _mint(account, id, value, emptyBytes);
    }

    function burn(address account, uint256 id, uint256 value) public {
        if (id != uint256(uint160(_msgSender()))) {
            // Need to update error
            revert ERC1155MissingApprovalForAll(_msgSender(), account);
        }

        _burn(account, id, value);
    }
}
