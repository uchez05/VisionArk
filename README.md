# VisionArk

## Overview

VisionArk is a token-based loyalty program built on the Stacks blockchain using Clarity. It allows an owner to mint tokens, users to earn and redeem rewards, and track their token balances securely and transparently.

## Features

* Token minting by contract owner
* Secure token transfers between users
* Reward creation and redemption
* Balance and reward tracking

## Data Structures

* **balances:** Maps each user’s principal to their token balance
* **rewards:** Stores reward details including name, cost, and available quantity

## Functions

### Read-only

* **get-name:** Returns the token name
* **get-symbol:** Returns the token symbol
* **get-balance (account):** Returns the token balance of an account
* **get-reward (reward-id):** Fetches details of a specific reward

### Public

* **transfer (amount sender recipient):** Transfers tokens between accounts
* **mint (amount recipient):** Mints new tokens, owner-only
* **add-reward (name cost available):** Adds a new redeemable reward, owner-only
* **redeem-reward (reward-id):** Allows a user to redeem a reward if eligible

## Error Codes

* **u100:** Not authorized
* **u101:** Insufficient balance
* **u102:** Invalid amount
* **u103:** Reward not available

## Initialization

The deploying principal automatically becomes the contract owner.
