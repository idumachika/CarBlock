
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
