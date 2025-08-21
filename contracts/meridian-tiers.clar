;; Meridian Customer Tier Management Contract
;; Advanced tier system for customer segmentation and reward multipliers

;; Define constants
(define-constant contract-administrator tx-sender)
(define-constant err-admin-only (err u200))
(define-constant err-invalid-tier-level (err u201))
(define-constant err-invalid-threshold (err u202))
(define-constant err-tier-downgrade-forbidden (err u203))
(define-constant err-invalid-multiplier (err u204))

;; Tier configuration constants
(define-constant max-tier-level u7) ;; Diamond tier
(define-constant min-multiplier u100) ;; 1.0x base rate
(define-constant max-multiplier u300) ;; 3.0x maximum multiplier

;; Define data storage maps
(define-map customer-tier-levels principal uint)
(define-map tier-spending-thresholds uint uint)
(define-map tier-reward-multipliers uint uint)
(define-map tier-benefit-descriptions uint (string-ascii 100))
(define-map customer-tier-progress principal uint)
(define-map tier-upgrade-timestamps principal uint)

;; Tier configuration management
(define-public (configure-tier-threshold (tier-level uint) (spending-threshold uint))
  (begin
    (asserts! (is-eq tx-sender contract-administrator) err-admin-only)
    (asserts! (and (> tier-level u0) (<= tier-level max-tier-level)) err-invalid-tier-level)
    (asserts! (> spending-threshold u0) err-invalid-threshold)
    (ok (map-set tier-spending-thresholds tier-level spending-threshold))))

(define-public (configure-tier-multiplier (tier-level uint) (reward-multiplier uint))
  (begin
    (asserts! (is-eq tx-sender contract-administrator) err-admin-only)
    (asserts! (and (> tier-level u0) (<= tier-level max-tier-level)) err-invalid-tier-level)
    (asserts! (and (>= reward-multiplier min-multiplier) (<= reward-multiplier max-multiplier)) err-invalid-multiplier)
    (ok (map-set tier-reward-multipliers tier-level reward-multiplier))))

(define-public (set-tier-description (tier-level uint) (description (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender contract-administrator) err-admin-only)
    (asserts! (and (> tier-level u0) (<= tier-level max-tier-level)) err-invalid-tier-level)
    (ok (map-set tier-benefit-descriptions tier-level description))))

;; Customer tier progression system
(define-public (evaluate-customer-tier-upgrade (customer-address principal) (total-spending uint))
  (let ((current-tier (default-to u1 (map-get? customer-tier-levels customer-address)))
        (new-tier-level (determine-eligible-tier total-spending)))
    (begin
      (asserts! (>= new-tier-level current-tier) err-tier-downgrade-forbidden)
      (map-set customer-tier-levels customer-address new-tier-level)
      (map-set customer-tier-progress customer-address total-spending)
      (if (> new-tier-level current-tier)
        (map-set tier-upgrade-timestamps customer-address block-height)
        true)
      (ok new-tier-level))))

;; Enhanced reward calculation with tier multipliers
(define-public (calculate-tier-adjusted-rewards (customer-address principal) (base-reward-amount uint))
  (let ((customer-tier (default-to u1 (map-get? customer-tier-levels customer-address)))
        (tier-multiplier (default-to min-multiplier (map-get? tier-reward-multipliers customer-tier)))
        (boosted-reward (/ (* base-reward-amount tier-multiplier) u100)))
    (ok boosted-reward)))

;; Tier bonus rewards for milestones
(define-public (award-tier-milestone-bonus (customer-address principal))
  (let ((customer-tier (get-customer-tier-level customer-address))
        (milestone-bonus (calculate-milestone-bonus customer-tier)))
    (begin
      (asserts! (> milestone-bonus u0) err-invalid-tier-level)
      ;; This would typically call the main rewards contract to mint tokens
      (ok milestone-bonus))))

;; Read-only functions for tier information
(define-read-only (get-customer-tier-level (customer-address principal))
  (default-to u1 (map-get? customer-tier-levels customer-address)))

(define-read-only (get-tier-spending-threshold (tier-level uint))
  (default-to u0 (map-get? tier-spending-thresholds tier-level)))

(define-read-only (get-tier-reward-multiplier (tier-level uint))
  (default-to min-multiplier (map-get? tier-reward-multipliers tier-level)))

(define-read-only (get-tier-description (tier-level uint))
  (map-get? tier-benefit-descriptions tier-level))

(define-read-only (get-customer-progress (customer-address principal))
  (default-to u0 (map-get? customer-tier-progress customer-address)))

(define-read-only (get-next-tier-requirement (customer-address principal))
  (let ((current-tier (get-customer-tier-level customer-address))
        (next-tier (+ current-tier u1)))
    (if (<= next-tier max-tier-level)
      (get-tier-spending-threshold next-tier)
      u0)))

(define-read-only (get-tier-upgrade-timestamp (customer-address principal))
  (default-to u0 (map-get? tier-upgrade-timestamps customer-address)))

;; Advanced tier analytics
(define-read-only (calculate-tier-progress-percentage (customer-address principal))
  (let ((current-progress (get-customer-progress customer-address))
        (current-tier (get-customer-tier-level customer-address))
        (next-tier-threshold (get-next-tier-requirement customer-address)))
    (if (> next-tier-threshold u0)
      (/ (* current-progress u100) next-tier-threshold)
      u100)))

;; Private helper functions
(define-private (determine-eligible-tier (spending-amount uint))
  (if (>= spending-amount (get-tier-spending-threshold u7))
    u7  ;; Diamond
    (if (>= spending-amount (get-tier-spending-threshold u6))
      u6  ;; Platinum
      (if (>= spending-amount (get-tier-spending-threshold u5))
        u5  ;; Gold
        (if (>= spending-amount (get-tier-spending-threshold u4))
          u4  ;; Silver
          (if (>= spending-amount (get-tier-spending-threshold u3))
            u3  ;; Bronze
            (if (>= spending-amount (get-tier-spending-threshold u2))
              u2  ;; Member
              u1)))))))  ;; Starter

(define-private (calculate-milestone-bonus (tier-level uint))
  (if (is-eq tier-level u7) u10000  ;; Diamond: 10,000 tokens
    (if (is-eq tier-level u6) u5000   ;; Platinum: 5,000 tokens
      (if (is-eq tier-level u5) u2500  ;; Gold: 2,500 tokens
        (if (is-eq tier-level u4) u1000 ;; Silver: 1,000 tokens
          (if (is-eq tier-level u3) u500 ;; Bronze: 500 tokens
            (if (is-eq tier-level u2) u200 ;; Member: 200 tokens
              u0)))))))