;; TrendHaven Marketplace Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-price (err u102))
(define-constant err-already-exists (err u103))

;; Data structures
(define-map products 
  uint 
  {
    seller: principal,
    name: (string-utf8 100),
    description: (string-utf8 500),
    price: uint,
    available: bool,
    rating: uint,
    review-count: uint
  }
)

(define-map purchases 
  { product-id: uint, buyer: principal }
  { timestamp: uint }
)

(define-map ratings
  { product-id: uint, rater: principal }
  { rating: uint }
)

;; Data variables
(define-data-var next-product-id uint u1)

;; Public functions
(define-public (list-product (name (string-utf8 100)) (description (string-utf8 500)) (price uint))
  (let ((product-id (var-get next-product-id)))
    (map-insert products product-id
      {
        seller: tx-sender,
        name: name,
        description: description, 
        price: price,
        available: true,
        rating: u0,
        review-count: u0
      }
    )
    (var-set next-product-id (+ product-id u1))
    (ok product-id)
  )
)

(define-public (purchase-product (product-id uint))
  (let ((product (unwrap! (map-get? products product-id) (err err-not-found))))
    (if (and 
      (get available product)
      (is-ok (stx-transfer? (get price product) tx-sender (get seller product)))
    )
      (begin
        (map-set purchases {product-id: product-id, buyer: tx-sender} {timestamp: block-height})
        (ok true)
      )
      (err u104)
    )
  )
)

;; Read only functions
(define-read-only (get-product (product-id uint))
  (map-get? products product-id)
)

(define-read-only (get-trending)
  (filter trending-criteria (map-get? products))
)
