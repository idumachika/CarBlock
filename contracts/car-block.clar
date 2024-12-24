
;; title: car-block
;; version:
;; summary:
;; description:

;; Error codes
(define-constant ERROR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERROR-VEHICLE-EXISTS (err u101))
(define-constant ERROR-VEHICLE-NOT-FOUND (err u102))
(define-constant ERROR-INVALID-VERIFICATION-PROOF (err u103))
(define-constant ERROR-RECORD-EXPIRED (err u104))
(define-constant ERROR-INVALID-INPUT (err u105))

;; Constants for validation
(define-constant MIN-TIMESTAMP u1)
(define-constant MAX-TIMESTAMP u9999999999)
(define-constant CURRENT-TIME u1703980800) ;; 


;; Data Maps
(define-map registered-vehicles
    principal
    {
        vehicle-hash: (buff 32),
        registration-timestamp: uint,
        vehicle-records: (list 10 (buff 32)),
        owner-public-key: (buff 33),
        vehicle-revoked: bool
    }
)

(define-map record-details
    (buff 32)  ;; record hash
    {
        record-issuer: principal,
        issuance-timestamp: uint,
        expiration-timestamp: uint,
        record-category: (string-utf8 64),
        record-revoked: bool
    }
)

(define-map transfer-requests
    (buff 32)  ;; transfer request ID
    {
        requesting-entity: principal,
        requested-attributes: (list 5 (string-utf8 64)),
        request-approved: bool,
        verification-proof: (buff 32)
    }
)

;; Private functions
(define-private (validate-verification-proof 
    (submitted-proof (buff 32)) 
    (stored-hash (buff 32)))
    (is-eq submitted-proof stored-hash)
)

(define-private (check-record-status 
    (record-hash (buff 32))
    (record-info {
        record-issuer: principal, 
        issuance-timestamp: uint, 
        expiration-timestamp: uint, 
        record-category: (string-utf8 64), 
        record-revoked: bool
    }))
    (and
        (< CURRENT-TIME (get expiration-timestamp record-info))
        (not (get record-revoked record-info))
    )
)

(define-private (validate-timestamp (timestamp uint))
    (and 
        (>= timestamp MIN-TIMESTAMP)
        (<= timestamp MAX-TIMESTAMP)
    )
)

(define-private (validate-buff32 (input (buff 32)))
    (is-eq (len input) u32)
)

(define-private (validate-buff33 (input (buff 33)))
    (is-eq (len input) u33)
)
(define-public (register-vehicle 
    (owner-public-key (buff 33)) 
    (vehicle-hash (buff 32)))
    (let
        ((current-user tx-sender))
        (asserts! (validate-buff33 owner-public-key) ERROR-INVALID-INPUT)
        (asserts! (validate-buff32 vehicle-hash) ERROR-INVALID-INPUT)
        (asserts! (is-none (map-get? registered-vehicles current-user)) ERROR-VEHICLE-EXISTS)
        (ok (map-set registered-vehicles
            current-user
            {
                vehicle-hash: vehicle-hash,
                registration-timestamp: CURRENT-TIME,
                vehicle-records: (list),
                owner-public-key: owner-public-key,
                vehicle-revoked: false
            }
        ))
    )
)
