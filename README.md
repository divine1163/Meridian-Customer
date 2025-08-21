# Meridian Customer Engagement Platform

A comprehensive blockchain-based customer rewards and tier management system built on the Stacks blockchain using Clarity smart contracts.

## Overview

The Meridian Platform revolutionizes customer engagement through a sophisticated rewards ecosystem that combines token-based incentives, progressive tier systems, and yield-generating staking mechanisms. This platform empowers businesses to create deeper customer relationships while providing customers with tangible value for their loyalty.

## Core Features

### **Token-Based Rewards System**
- Custom fungible token (Meridian Rewards Token) for seamless reward distribution
- Merchant-specific reward rates and multipliers
- Comprehensive tracking of customer lifetime value
- Secure redemption mechanism with built-in balance validation

### **Advanced Tier Management**
- Seven-tier progression system (Starter → Diamond)
- Dynamic reward multipliers based on customer tier
- Milestone bonus rewards for tier upgrades
- Real-time progress tracking and analytics

### **Yield-Generating Staking**
- Progressive yield rates based on staking duration
- Enhanced returns for longer commitment periods
- Emergency withdrawal options with yield forfeiture
- Automatic compound interest calculations

### **Enterprise Security**
- Role-based access control for administrators and merchants
- Comprehensive error handling and validation
- Audit-friendly transaction logging
- Protected merchant authorization system

## Smart Contract Architecture

### Core Contracts

1. **Customer Rewards Token Contract** (`customer-rewards.clar`)
   - Token minting and distribution
   - Staking and yield mechanisms
   - Merchant authorization and management

2. **Customer Tier Management Contract** (`meridian-tiers.clar`)
   - Tier progression logic
   - Reward multiplier calculations
   - Customer analytics and progress tracking

## Installation & Deployment

### Prerequisites
- Stacks blockchain node
- Clarinet development environment
- Node.js 16+ for testing utilities

### Local Development Setup
```bash
# Clone the repository
git clone https://github.com/divine1163/Meridian-Customer.git
cd Meridian-Customer

# Install Clarinet
npm install -g @hirosystems/clarinet-cli

# Initialize and test
clarinet check
clarinet test
```

### Deployment
```bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet (production)
clarinet deploy --mainnet
```

## Usage Examples

### For Business Integration

```clarity
;; Register your business as an authorized merchant
(contract-call? .meridian-rewards authorize-merchant 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
  u150) ;; 1.5x reward multiplier

;; Distribute rewards to customers
(contract-call? .meridian-rewards distribute-customer-rewards 
  'SP3X6QWWETNQZJZM1P5GEQ8FMVZ2WEVNS2YMNJ8BR 
  u1000) ;; Award 1000 base tokens
```

### For Customer Interaction

```clarity
;; Stake tokens for enhanced yield
(contract-call? .meridian-rewards stake-customer-tokens u5000)

;; Check tier status and upgrade eligibility
(contract-call? .meridian-tiers evaluate-customer-tier-upgrade 
  'SP3X6QWWETNQZJZM1P5GEQ8FMVZ2WEVNS2YMNJ8BR 
  u25000) ;; Total spending amount

;; Redeem tokens for rewards
(contract-call? .meridian-rewards redeem-customer-rewards u2500)
```

## Tier System Structure

| Tier Level | Name | Spending Threshold | Reward Multiplier | Milestone Bonus |
|------------|------|-------------------|-------------------|-----------------|
| 1 | Starter | 0 | 1.0x | 0 tokens |
| 2 | Member | 1,000 | 1.1x | 200 tokens |
| 3 | Bronze | 5,000 | 1.25x | 500 tokens |
| 4 | Silver | 15,000 | 1.5x | 1,000 tokens |
| 5 | Gold | 35,000 | 1.75x | 2,500 tokens |
| 6 | Platinum | 75,000 | 2.25x | 5,000 tokens |
| 7 | Diamond | 150,000 | 3.0x | 10,000 tokens |

## Staking Yield Structure

- **Base Rate**: 2% annual equivalent
- **Duration Multiplier**: Increases yield rate based on staking duration
- **Maximum Rate**: 5% annual equivalent for extended staking periods
- **Minimum Period**: 1,000 blocks (~7 days) for yield eligibility

## API Reference

### Key Functions

#### Rewards Contract
- `distribute-customer-rewards` - Award tokens to customers
- `stake-customer-tokens` - Stake tokens for yield generation
- `unstake-and-claim-yield` - Withdraw staked tokens with accumulated yield
- `redeem-customer-rewards` - Exchange tokens for business rewards

#### Tier Management Contract
- `evaluate-customer-tier-upgrade` - Assess and update customer tier
- `calculate-tier-adjusted-rewards` - Apply tier multipliers to base rewards
- `get-customer-tier-level` - Retrieve current customer tier
- `get-next-tier-requirement` - Check spending needed for next tier

## Security Considerations

- All administrative functions require contract owner privileges
- Merchant authorization prevents unauthorized token distribution
- Staking mechanisms include minimum period requirements
- Balance validations prevent double-spending attacks
- Emergency withdrawal options provide customer protection

## Contributing

We welcome contributions to the Meridian Platform!