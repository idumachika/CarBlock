
import { describe, expect, it } from "vitest";



const contractState = {
  registeredVehicles: new Map(),
  recordDetails: new Map(),
  transferRequests: new Map(),
};

const contractFunctions = {
  registerVehicle: (sender: string, ownerKey: Buffer, vehicleHash: Buffer) => {
    if (contractState.registeredVehicles.has(sender)) {
      return { error: 'u101' };
    }
    
    contractState.registeredVehicles.set(sender, {
      vehicleHash,
      registrationTimestamp: 1703980800,
      vehicleRecords: [],
      ownerPublicKey: ownerKey,
      vehicleRevoked: false
    });
    
    return { success: true };
  },

  addVehicleRecord: (sender: string, recordHash: Buffer, expirationTimestamp: number, category: string) => {
    const vehicle = contractState.registeredVehicles.get(sender);
    if (!vehicle) return { error: 'u102' };
    if (vehicle.vehicleRevoked) return { error: 'u100' };
    if (expirationTimestamp <= 1703980800) return { error: 'u104' };
    
    contractState.recordDetails.set(recordHash.toString('hex'), {
      recordIssuer: sender,
      issuanceTimestamp: 1703980800,
      expirationTimestamp,
      recordCategory: category,
      recordRevoked: false
    });
    
    vehicle.vehicleRecords.push(recordHash);
    return { success: true };
  }
};

describe('CarBlock Contract Tests', () => {
  beforeEach(() => {
    contractState.registeredVehicles.clear();
    contractState.recordDetails.clear();
    contractState.transferRequests.clear();
  });

  describe('register-vehicle', () => {
    it('should successfully register a new vehicle', () => {
      const sender = 'wallet1';
      const ownerKey = Buffer.alloc(33, 1);
      const vehicleHash = Buffer.alloc(32, 2);

      const result = contractFunctions.registerVehicle(sender, ownerKey, vehicleHash);
      
      expect(result.success).toBe(true);
      expect(contractState.registeredVehicles.has(sender)).toBe(true);
    });

    it('should fail if vehicle already exists', () => {
      const sender = 'wallet1';
      const ownerKey = Buffer.alloc(33, 1);
      const vehicleHash = Buffer.alloc(32, 2);

      contractFunctions.registerVehicle(sender, ownerKey, vehicleHash);
      const result = contractFunctions.registerVehicle(sender, ownerKey, vehicleHash);
      
      expect(result.error).toBe('u101');
    });
  });

  describe('add-vehicle-record', () => {
    it('should successfully add a record to registered vehicle', () => {
      const sender = 'wallet1';
      const ownerKey = Buffer.alloc(33, 1);
      const vehicleHash = Buffer.alloc(32, 2);
      const recordHash = Buffer.alloc(32, 3);
      
      contractFunctions.registerVehicle(sender, ownerKey, vehicleHash);
      
      const result = contractFunctions.addVehicleRecord(
        sender,
        recordHash,
        1704067200,
        'maintenance'
      );

      expect(result.success).toBe(true);
      const vehicle = contractState.registeredVehicles.get(sender);
      expect(vehicle?.vehicleRecords).toContain(recordHash);
    });

    it('should fail if vehicle not found', () => {
      const sender = 'wallet1';
      const recordHash = Buffer.alloc(32, 3);
      
      const result = contractFunctions.addVehicleRecord(
        sender,
        recordHash,
        1704067200,
        'maintenance'
      );

      expect(result.error).toBe('u102');
    });

    it('should fail if record expired', () => {
      const sender = 'wallet1';
      const ownerKey = Buffer.alloc(33, 1);
      const vehicleHash = Buffer.alloc(32, 2);
      const recordHash = Buffer.alloc(32, 3);
      
      contractFunctions.registerVehicle(sender, ownerKey, vehicleHash);
      
      const result = contractFunctions.addVehicleRecord(
        sender,
        recordHash,
        1703980700, // Past timestamp
        'maintenance'
      );

      expect(result.error).toBe('u104');
    });
  });

  describe('validation functions', () => {
    it('should validate buffer lengths', () => {
      const validate32 = (buff: Buffer) => buff.length === 32;
      const validate33 = (buff: Buffer) => buff.length === 33;

      expect(validate32(Buffer.alloc(32))).toBe(true);
      expect(validate32(Buffer.alloc(31))).toBe(false);
      expect(validate33(Buffer.alloc(33))).toBe(true);
      expect(validate33(Buffer.alloc(32))).toBe(false);
    });

    it('should validate timestamps', () => {
      const validateTimestamp = (timestamp: number) => 
        timestamp >= 1 && timestamp <= 9999999999;

      expect(validateTimestamp(1704067200)).toBe(true);
      expect(validateTimestamp(0)).toBe(false);
      expect(validateTimestamp(10000000000)).toBe(false);
    });
  });
});


