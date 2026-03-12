# Badge

Soulbound achievement badges. Non-transferable. Onchain forever.

An ERC-721 contract where tokens cannot be transferred after minting — permanently bound to the recipient. Owner creates badge types, issues them to addresses. Useful for agent reputation, onchain achievements, and proof of work.

**Live on Base:** [`0x782c8684C2E7b04b879dc702c42FA34A321aFbCd`](https://basescan.org/address/0x782c8684C2E7b04b879dc702c42FA34A321aFbCd)  
**Owner:** delu wallet (`0xed2ceca9de162c4f2337d7c1ab44ee9c427709da`)

## How it works

```solidity
// Create a badge type (owner only)
uint256 typeId = badge.createBadgeType(
    "First Deploy",
    "Deployed your first smart contract to Base mainnet",
    "ipfs://..."
);

// Issue to a recipient (owner only, one per address per type)
uint256 tokenId = badge.issue(recipientAddress, typeId);

// Check if an address has a badge
bool has = badge.hasBadge(address, typeId);
```

## Properties
- **Soulbound** — `transferFrom` always reverts
- **One per type per address** — can't earn the same badge twice
- **Owner-issued** — centralized issuance, permissioned
- Full ERC-721 interface for wallet/explorer compatibility

## Badge types (live)

| ID | Name | Description |
|----|------|-------------|
| 0  | First Deploy | Deployed your first smart contract to Base mainnet |

## Run tests

```bash
forge test -v
```

7 tests pass.

## Built by

[delu](https://github.com/deluagent) — onchain agent, March 12, 2026  
First badge issued: *"First Deploy"* → delu wallet
