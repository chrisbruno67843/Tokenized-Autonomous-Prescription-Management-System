;; Medication Tracking Contract
;; Monitors prescription refills and dosage compliance

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PATIENT-NOT-FOUND (err u101))
(define-constant ERR-PRESCRIPTION-NOT-FOUND (err u102))
(define-constant ERR-INVALID-INPUT (err u103))

;; Data Variables
(define-data-var next-prescription-id uint u1)

;; Data Maps
(define-map patients
  { patient-id: (string-ascii 50) }
  {
    name: (string-ascii 100),
    age: uint,
    medical-conditions: (string-ascii 500),
    registered-at: uint,
    is-active: bool
  }
)

(define-map prescriptions
  { prescription-id: uint }
  {
    patient-id: (string-ascii 50),
    medication-name: (string-ascii 100),
    dosage: uint,
    frequency: uint,
    duration: uint,
    prescribed-at: uint,
    refills-remaining: uint,
    is-active: bool
  }
)

(define-map medication-logs
  { patient-id: (string-ascii 50), medication-name: (string-ascii 100) }
  {
    total-doses-taken: uint,
    missed-doses: uint,
    compliance-score: uint,
    last-taken: uint,
    next-due: uint
  }
)

(define-map patient-prescriptions
  { patient-id: (string-ascii 50) }
  { prescription-ids: (list 50 uint) }
)

;; Authorization Functions
(define-private (is-authorized (patient-id (string-ascii 50)))
  (is-eq tx-sender CONTRACT-OWNER)
)

;; Patient Management Functions
(define-public (register-patient
  (patient-id (string-ascii 50))
  (name (string-ascii 100))
  (age uint)
  (medical-conditions (string-ascii 500))
)
  (begin
    (asserts! (> age u0) ERR-INVALID-INPUT)
    (asserts! (< age u150) ERR-INVALID-INPUT)
    (map-set patients
      { patient-id: patient-id }
      {
        name: name,
        age: age,
        medical-conditions: medical-conditions,
        registered-at: block-height,
        is-active: true
      }
    )
    (map-set patient-prescriptions
      { patient-id: patient-id }
      { prescription-ids: (list) }
    )
    (ok patient-id)
  )
)

(define-public (update-patient-status (patient-id (string-ascii 50)) (is-active bool))
  (let ((patient (unwrap! (map-get? patients { patient-id: patient-id }) ERR-PATIENT-NOT-FOUND)))
    (asserts! (is-authorized patient-id) ERR-NOT-AUTHORIZED)
    (map-set patients
      { patient-id: patient-id }
      (merge patient { is-active: is-active })
    )
    (ok is-active)
  )
)

;; Prescription Management Functions
(define-public (add-prescription
  (patient-id (string-ascii 50))
  (medication-name (string-ascii 100))
  (dosage uint)
  (frequency uint)
  (duration uint)
  (refills uint)
)
  (let
    (
      (prescription-id (var-get next-prescription-id))
      (patient (unwrap! (map-get? patients { patient-id: patient-id }) ERR-PATIENT-NOT-FOUND))
      (current-prescriptions (default-to { prescription-ids: (list) }
        (map-get? patient-prescriptions { patient-id: patient-id })))
    )
    (asserts! (is-authorized patient-id) ERR-NOT-AUTHORIZED)
    (asserts! (> dosage u0) ERR-INVALID-INPUT)
    (asserts! (> frequency u0) ERR-INVALID-INPUT)
    (asserts! (> duration u0) ERR-INVALID-INPUT)
    (asserts! (<= refills u12) ERR-INVALID-INPUT)

    ;; Create prescription record
    (map-set prescriptions
      { prescription-id: prescription-id }
      {
        patient-id: patient-id,
        medication-name: medication-name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        prescribed-at: block-height,
        refills-remaining: refills,
        is-active: true
      }
    )

    ;; Initialize medication log
    (map-set medication-logs
      { patient-id: patient-id, medication-name: medication-name }
      {
        total-doses-taken: u0,
        missed-doses: u0,
        compliance-score: u100,
        last-taken: u0,
        next-due: (+ block-height (/ u1440 frequency))
      }
    )

    ;; Update patient prescriptions list
    (map-set patient-prescriptions
      { patient-id: patient-id }
      { prescription-ids: (unwrap-panic (as-max-len?
        (append (get prescription-ids current-prescriptions) prescription-id) u50)) }
    )

    (var-set next-prescription-id (+ prescription-id u1))
    (ok prescription-id)
  )
)

(define-public (record-dose-taken
  (patient-id (string-ascii 50))
  (medication-name (string-ascii 100))
)
  (let
    (
      (log (unwrap! (map-get? medication-logs
        { patient-id: patient-id, medication-name: medication-name }) ERR-PRESCRIPTION-NOT-FOUND))
    )
    (asserts! (is-authorized patient-id) ERR-NOT-AUTHORIZED)

    (map-set medication-logs
      { patient-id: patient-id, medication-name: medication-name }
      (merge log {
        total-doses-taken: (+ (get total-doses-taken log) u1),
        last-taken: block-height,
        next-due: (+ block-height u1440)
      })
    )
    (ok true)
  )
)

(define-public (record-missed-dose
  (patient-id (string-ascii 50))
  (medication-name (string-ascii 100))
)
  (let
    (
      (log (unwrap! (map-get? medication-logs
        { patient-id: patient-id, medication-name: medication-name }) ERR-PRESCRIPTION-NOT-FOUND))
      (new-missed (+ (get missed-doses log) u1))
      (total-doses (+ (get total-doses-taken log) new-missed))
      (new-compliance (if (> total-doses u0)
        (/ (* (get total-doses-taken log) u100) total-doses)
        u100))
    )
    (asserts! (is-authorized patient-id) ERR-NOT-AUTHORIZED)

    (map-set medication-logs
      { patient-id: patient-id, medication-name: medication-name }
      (merge log {
        missed-doses: new-missed,
        compliance-score: new-compliance
      })
    )
    (ok new-compliance)
  )
)

(define-public (process-refill
  (prescription-id uint)
  (patient-id (string-ascii 50))
)
  (let
    (
      (prescription (unwrap! (map-get? prescriptions { prescription-id: prescription-id })
        ERR-PRESCRIPTION-NOT-FOUND))
    )
    (asserts! (is-authorized patient-id) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get patient-id prescription) patient-id) ERR-NOT-AUTHORIZED)
    (asserts! (> (get refills-remaining prescription) u0) ERR-INVALID-INPUT)

    (map-set prescriptions
      { prescription-id: prescription-id }
      (merge prescription {
        refills-remaining: (- (get refills-remaining prescription) u1)
      })
    )
    (ok (- (get refills-remaining prescription) u1))
  )
)

;; Read-only Functions
(define-read-only (get-patient (patient-id (string-ascii 50)))
  (map-get? patients { patient-id: patient-id })
)

(define-read-only (get-prescription (prescription-id uint))
  (map-get? prescriptions { prescription-id: prescription-id })
)

(define-read-only (get-medication-log
  (patient-id (string-ascii 50))
  (medication-name (string-ascii 100))
)
  (map-get? medication-logs { patient-id: patient-id, medication-name: medication-name })
)

(define-read-only (get-patient-prescriptions (patient-id (string-ascii 50)))
  (map-get? patient-prescriptions { patient-id: patient-id })
)

(define-read-only (calculate-compliance-score
  (patient-id (string-ascii 50))
  (medication-name (string-ascii 100))
)
  (match (map-get? medication-logs { patient-id: patient-id, medication-name: medication-name })
    log (ok (get compliance-score log))
    ERR-PRESCRIPTION-NOT-FOUND
  )
)

(define-read-only (is-dose-due
  (patient-id (string-ascii 50))
  (medication-name (string-ascii 100))
)
  (match (map-get? medication-logs { patient-id: patient-id, medication-name: medication-name })
    log (ok (<= (get next-due log) block-height))
    ERR-PRESCRIPTION-NOT-FOUND
  )
)
