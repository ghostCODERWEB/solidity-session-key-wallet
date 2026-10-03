// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Scoped session key wallet
/// @notice Owner-controlled native wallet with target-scoped session keys, cumulative spending budgets, expiry and nonce sequencing.
/// @dev Reference implementation; independent audit required before production.

contract SessionWallet is SuiteBase {
    struct Session {
        uint256 limit;
        uint256 spent;
        uint64 expiry;
        uint256 nonce;
        bool enabled;
    }
    mapping(address => Session) public sessions;
    mapping(address => mapping(address => bool)) public allowedTargets;
    mapping(address => uint256) public generation;
    mapping(address => mapping(address => uint256)) private targetGeneration;
    event SessionConfigured(
        address indexed key,
        uint256 limit,
        uint64 expiry,
        uint256 generation
    );
    event TargetConfigured(
        address indexed key,
        address indexed target,
        bool allowed
    );
    event Executed(
        address indexed key,
        address indexed target,
        uint256 value,
        uint256 nonce,
        bytes result
    );
    constructor(address admin) SuiteBase(admin) {}
    receive() external payable {}
    function configureSession(
        address key,
        uint256 limit,
        uint64 expiry
    ) external onlyOwner {
        require(
            key != address(0) && key != owner() && expiry > block.timestamp,
            "session"
        );
        generation[key]++;
        sessions[key] = Session(limit, 0, expiry, 0, true);
        emit SessionConfigured(key, limit, expiry, generation[key]);
    }
    function setTarget(
        address key,
        address target,
        bool allowed
    ) external onlyOwner {
        require(
            sessions[key].enabled &&
                target != address(0) &&
                target != address(this),
            "target"
        );
        allowedTargets[key][target] = allowed;
        targetGeneration[key][target] = generation[key];
        emit TargetConfigured(key, target, allowed);
    }
    function revokeSession(address key) external onlyOwner {
        sessions[key].enabled = false;
    }
    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        uint256 nonce
    ) external nonReentrant whenNotPaused returns (bytes memory result) {
        Session storage s = sessions[msg.sender];
        require(
            s.enabled &&
                block.timestamp < s.expiry &&
                allowedTargets[msg.sender][target] &&
                targetGeneration[msg.sender][target] == generation[msg.sender],
            "session permission"
        );
        require(
            nonce == s.nonce && value <= s.limit - s.spent,
            "nonce or budget"
        );
        s.nonce++;
        s.spent += value;
        (bool ok, bytes memory returned) = target.call{value: value}(data);
        require(ok, "call failed");
        emit Executed(msg.sender, target, value, nonce, returned);
        return returned;
    }
    function ownerExecute(
        address target,
        uint256 value,
        bytes calldata data
    ) external onlyOwner nonReentrant returns (bytes memory result) {
        require(target != address(0), "target");
        (bool ok, bytes memory returned) = target.call{value: value}(data);
        require(ok, "call failed");
        return returned;
    }
}
