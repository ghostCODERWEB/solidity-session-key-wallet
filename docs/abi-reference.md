# ABI reference

Generated from the successfully compiled primary contract. Includes inherited OpenZeppelin methods. Authorization requirements and economic semantics are in the Solidity source and architecture guide.

| Signature | Type | Mutability | Return values |
|---|---|---|---|
| `constructor(address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `Executed(address key,address target,uint256 value,uint256 nonce,bytes result)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `SessionConfigured(address key,uint256 limit,uint64 expiry,uint256 generation)` | event |  |  |
| `TargetConfigured(address key,address target,bool allowed)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `allowedTargets(address ,address )` | function | view | bool  |
| `configureSession(address key,uint256 limit,uint64 expiry)` | function | nonpayable |  |
| `execute(address target,uint256 value,bytes data,uint256 nonce)` | function | nonpayable | bytes result |
| `generation(address )` | function | view | uint256  |
| `owner()` | function | view | address  |
| `ownerExecute(address target,uint256 value,bytes data)` | function | nonpayable | bytes result |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `renounceOwnership()` | function | nonpayable |  |
| `revokeSession(address key)` | function | nonpayable |  |
| `sessions(address )` | function | view | uint256 limit, uint256 spent, uint64 expiry, uint256 nonce, bool enabled |
| `setPaused(bool value)` | function | nonpayable |  |
| `setTarget(address key,address target,bool allowed)` | function | nonpayable |  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
