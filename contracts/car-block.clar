
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

(define-public (add-vehicle-record 
    (record-hash (buff 32))
    (expiration-timestamp uint)
    (record-category (string-utf8 64)))
    (let
        ((current-user tx-sender)
         (vehicle-record (unwrap! (map-get? registered-vehicles current-user) ERROR-VEHICLE-NOT-FOUND)))
        (asserts! (validate-buff32 record-hash) ERROR-INVALID-INPUT)
        (asserts! (validate-timestamp expiration-timestamp) ERROR-INVALID-INPUT)
        (asserts! (> expiration-timestamp CURRENT-TIME) ERROR-RECORD-EXPIRED)
        (asserts! (not (get vehicle-revoked vehicle-record)) ERROR-UNAUTHORIZED-ACCESS)
        (map-set record-details
            record-hash
            {
                record-issuer: current-user,
                issuance-timestamp: CURRENT-TIME,
                expiration-timestamp: expiration-timestamp,
                record-category: record-category,
                record-revoked: false
            }
        )
        (ok (map-set registered-vehicles
            current-user
            (merge vehicle-record
                {vehicle-records: (unwrap! (as-max-len? (append (get vehicle-records vehicle-record) record-hash) u10)
                    ERROR-UNAUTHORIZED-ACCESS)}
            )
        ))
    )
)


(define-public (initiate-transfer-request
    (request-identifier (buff 32))
    (required-attributes (list 5 (string-utf8 64))))
    (let
        ((requesting-user tx-sender))
        (asserts! (validate-buff32 request-identifier) ERROR-INVALID-INPUT)
        (asserts! (is-none (map-get? transfer-requests request-identifier)) ERROR-INVALID-INPUT)
        (ok (map-set transfer-requests
            request-identifier
            {
                requesting-entity: requesting-user,
                requested-attributes: required-attributes,
                request-approved: false,
                verification-proof: 0x00
            }
        ))
    )
)
