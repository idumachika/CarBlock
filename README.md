Summary:
CarBlock is a decentralized application for securely registering vehicles, transferring ownership, and verifying vehicle details on the blockchain. It ensures transparency and eliminates the risk of fraud in vehicle ownership by leveraging Clarity smart contracts.

Features:
Vehicle Registration: Register vehicles securely with unique identifiers and owner public keys.
Ownership Management: Transfer ownership through verified requests and approvals.
Record Management: Add, update, revoke, and validate vehicle-related records with time-based validity.
Fraud Prevention: Use cryptographic proofs to prevent unauthorized access or invalid updates.
Transparency: All actions and statuses are logged on the blockchain for easy auditability.

Key Functions:
Public Functions:
register-vehicle
Register a vehicle with the owner’s public key and vehicle hash.

add-vehicle-record
Add a record for a registered vehicle, specifying details like expiration and category.

initiate-transfer-request
Create a transfer request for vehicle ownership.

approve-transfer
Approve ownership transfer by verifying the request and providing cryptographic proof.

revoke-vehicle-record
Revoke a previously issued record for a vehicle.

update-vehicle-record
Update vehicle details (e.g., vehicle hash or owner public key).

Read-Only Functions:
get-vehicle-details
Retrieve details of a registered vehicle.

get-record-details
Retrieve details of a specific vehicle record.

verify-transfer-request
Validate the authenticity of a transfer request using cryptographic proofs.

check-record-validity
Check if a record is valid based on its expiration and revocation status.

Data Models:
registered-vehicles:
Tracks registered vehicles and their associated data (e.g., hash, timestamp, records, owner public key).

record-details:
Manages individual records linked to vehicles, including their issuance, expiration, and category.

transfer-requests:
Logs requests for ownership transfers, storing the requester’s details and cryptographic proofs.
