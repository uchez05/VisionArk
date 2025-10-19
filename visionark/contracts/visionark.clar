;; Token-based Loyalty Program Smart Contract

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-REWARD-NOT-AVAILABLE (err u103))

;; Data Maps
(define-map balances principal uint)
(define-map rewards uint {name: (string-ascii 50), cost: uint, available: uint})

;; Contract Variables
(define-data-var token-name (string-ascii 50) "LoyaltyToken")
(define-data-var token-symbol (string-ascii 10) "LYT")
(define-data-var owner principal tx-sender)
(define-data-var reward-counter uint u0)

;; Read-only functions
(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

(define-read-only (get-balance (account principal))
  (ok (default-to u0 (map-get? balances account)))
)

(define-read-only (get-reward (reward-id uint))
  (map-get? rewards reward-id)
)

;; Public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (let ((sender-balance (default-to u0 (map-get? balances sender))))
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (<= amount sender-balance) (err ERR-INSUFFICIENT-BALANCE))
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    
    (map-set balances sender (- sender-balance amount))
    (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
    (ok true)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (let ((current-balance (default-to u0 (map-get? balances recipient))))
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    
    (map-set balances recipient (+ current-balance amount))
    (ok true)
  )
)

(define-public (add-reward (name (string-ascii 50)) (cost uint) (available uint))
  (let ((reward-id (var-get reward-counter)))
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (> cost u0) (err ERR-INVALID-AMOUNT))
    (asserts! (> available u0) (err ERR-INVALID-AMOUNT))
    
    (map-set rewards reward-id {name: name, cost: cost, available: available})
    (var-set reward-counter (+ reward-id u1))
    (ok reward-id)
  )
)

(define-public (redeem-reward (reward-id uint))
  (let (
    (reward (unwrap! (map-get? rewards reward-id) (err ERR-REWARD-NOT-AVAILABLE)))
    (user-balance (default-to u0 (map-get? balances tx-sender)))
  )
    (asserts! (>= user-balance (get cost reward)) (err ERR-INSUFFICIENT-BALANCE))
    (asserts! (> (get available reward) u0) (err ERR-REWARD-NOT-AVAILABLE))
    
    (map-set balances tx-sender (- user-balance (get cost reward)))
    (map-set rewards reward-id 
      (merge reward {available: (- (get available reward) u1)})
    )
    (ok true)
  )
)

;; Initialize contract
(begin
  (var-set owner tx-sender)
)