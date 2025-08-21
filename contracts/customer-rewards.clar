;; Meridian Customer Rewards Token Contract
;; A comprehensive customer engagement and rewards distribution system

;; Define the fungible token for customer rewards
(define-fungible-token meridian-rewards-token)

;; Define constants
(define-constant contract-administrator tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-unauthorized-merchant (err u101))
(define-constant err-insufficient-token-balance (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-staking-not-found (err u104))
(define-constant err-minimum-staking-period (err u105))

;; Define data storage maps
(define-map authorized-merchants principal bool)
(define-map customer-staked-amounts principal uint)
(define-map staking-initiation-block principal uint)
(define-map merchant-reward-rates principal uint)
(define-map customer-total-earned principal uint)

;; Configuration constants
(define-constant minimum-staking-blocks u1000) ;; Minimum blocks to stake
(define-constant base-staking-yield-rate u200) ;; 2% base yield rate (200/10000)
(define-constant max-staking-multiplier u500) ;; 5% maximum yield rate

;; Merchant registration and management
(define-public (authorize-merchant (merchant-address principal) (reward-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-administrator) err-admin-only)
    (asserts! (and (>= reward-rate u50) (<= reward-rate u1000)) err-invalid-amount)
    (map-set authorized-merchants merchant-address true)
    (ok (map-set merchant-reward-rates merchant-address reward-rate))))

(define-public (revoke-merchant-authorization (merchant-address principal))
  (begin
    (asserts! (is-eq tx-sender contract-administrator) err-admin-only)
    (map-delete authorized-merchants merchant-address)
    (ok (map-delete merchant-reward-rates merchant-address))))

;; Token distribution to customers
(define-public (distribute-customer-rewards (customer-address principal) (reward-amount uint))
  (let ((merchant-multiplier (default-to u100 (map-get? merchant-reward-rates tx-sender)))
        (adjusted-reward (/ (* reward-amount merchant-multiplier) u100))
        (customer-lifetime-total (default-to u0 (map-get? customer-total-earned customer-address))))
    (begin
      (asserts! (is-authorized-merchant tx-sender) err-unauthorized-merchant)
      (asserts! (> reward-amount u0) err-invalid-amount)
      (map-set customer-total-earned customer-address (+ customer-lifetime-total adjusted-reward))
      (ft-mint? meridian-rewards-token adjusted-reward customer-address))))

;; Token redemption functionality
(define-public (redeem-customer-rewards (redemption-amount uint))
  (begin
    (asserts! (> redemption-amount u0) err-invalid-amount)
    (asserts! (>= (ft-get-balance meridian-rewards-token tx-sender) redemption-amount) err-insufficient-token-balance)
    (ft-burn? meridian-rewards-token redemption-amount tx-sender)))

;; Staking mechanism for enhanced rewards
(define-public (stake-customer-tokens (stake-amount uint))
  (let ((existing-stake (default-to u0 (map-get? customer-staked-amounts tx-sender))))
    (begin
      (asserts! (> stake-amount u0) err-invalid-amount)
      (asserts! (>= (ft-get-balance meridian-rewards-token tx-sender) stake-amount) err-insufficient-token-balance)
      (map-set customer-staked-amounts tx-sender (+ existing-stake stake-amount))
      (map-set staking-initiation-block tx-sender block-height)
      (ft-burn? meridian-rewards-token stake-amount tx-sender))))

;; Enhanced unstaking with yield calculation
(define-public (unstake-and-claim-yield)
  (let ((staked-principal (default-to u0 (map-get? customer-staked-amounts tx-sender)))
        (stake-start-block (default-to u0 (map-get? staking-initiation-block tx-sender)))
        (staking-duration (- block-height stake-start-block))
        (yield-multiplier (calculate-yield-rate staking-duration))
        (total-yield (/ (* staked-principal yield-multiplier staking-duration) u1000000))
        (total-return (+ staked-principal total-yield)))
    (begin
      (asserts! (> staked-principal u0) err-staking-not-found)
      (asserts! (>= staking-duration minimum-staking-blocks) err-minimum-staking-period)
      (map-delete customer-staked-amounts tx-sender)
      (map-delete staking-initiation-block tx-sender)
      (ft-mint? meridian-rewards-token total-return tx-sender))))

;; Emergency withdrawal (forfeit yield)
(define-public (emergency-unstake)
  (let ((staked-amount (default-to u0 (map-get? customer-staked-amounts tx-sender))))
    (begin
      (asserts! (> staked-amount u0) err-staking-not-found)
      (map-delete customer-staked-amounts tx-sender)
      (map-delete staking-initiation-block tx-sender)
      (ft-mint? meridian-rewards-token staked-amount tx-sender))))

;; Read-only utility functions
(define-read-only (is-authorized-merchant (merchant-address principal))
  (default-to false (map-get? authorized-merchants merchant-address)))

(define-read-only (get-customer-staked-balance (customer-address principal))
  (default-to u0 (map-get? customer-staked-amounts customer-address)))

(define-read-only (get-staking-start-block (customer-address principal))
  (default-to u0 (map-get? staking-initiation-block customer-address)))

(define-read-only (get-merchant-reward-rate (merchant-address principal))
  (default-to u100 (map-get? merchant-reward-rates merchant-address)))

(define-read-only (get-customer-lifetime-rewards (customer-address principal))
  (default-to u0 (map-get? customer-total-earned customer-address)))

(define-read-only (calculate-projected-yield (customer-address principal))
  (let ((staked-amount (get-customer-staked-balance customer-address))
        (stake-start (get-staking-start-block customer-address))
        (current-duration (- block-height stake-start))
        (yield-rate (calculate-yield-rate current-duration)))
    (if (> staked-amount u0)
      (/ (* staked-amount yield-rate current-duration) u1000000)
      u0)))

;; Private helper functions
(define-private (calculate-yield-rate (duration uint))
  (let ((duration-multiplier (if (<= (/ duration u100) u5) (/ duration u100) u5)) ;; Max 5x multiplier after 500 blocks
        (calculated-rate (+ base-staking-yield-rate (* duration-multiplier u60))))
    (if (<= calculated-rate max-staking-multiplier) calculated-rate max-staking-multiplier)))