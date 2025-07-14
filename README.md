# Tokenized Autonomous Prescription Management System

A comprehensive blockchain-based prescription management system built on Stacks using Clarity smart contracts. This system provides autonomous medication tracking, drug interaction detection, pharmacy coordination, reminder automation, and cost optimization.

## System Overview

The system consists of five interconnected smart contracts that work together to provide a complete prescription management solution:

### 1. Medication Tracking Contract (`medication-tracker.clar`)
- Monitors prescription refills and dosage compliance
- Tracks medication inventory and usage patterns
- Records adherence metrics and compliance scores
- Manages prescription renewal schedules

### 2. Drug Interaction Contract (`drug-interactions.clar`)
- Identifies potential medication conflicts and side effects
- Maintains a database of known drug interactions
- Provides severity ratings for interaction risks
- Alerts users and healthcare providers of dangerous combinations

### 3. Pharmacy Coordination Contract (`pharmacy-coordinator.clar`)
- Manages prescription transfers between pharmacies
- Handles insurance coverage verification
- Coordinates with multiple pharmacy networks
- Tracks prescription fulfillment status

### 4. Reminder Automation Contract (`reminder-automation.clar`)
- Provides medication timing and dosage notifications
- Manages personalized reminder schedules
- Tracks reminder effectiveness and user response
- Supports multiple notification channels

### 5. Cost Optimization Contract (`cost-optimizer.clar`)
- Identifies generic alternatives and insurance savings
- Compares prices across different pharmacies
- Calculates potential cost savings
- Provides recommendations for cost-effective alternatives

## Key Features

- **Decentralized**: No single point of failure
- **Autonomous**: Smart contracts execute automatically
- **Secure**: Blockchain-based data integrity
- **Transparent**: All transactions are auditable
- **Privacy-Focused**: Patient data is encrypted and controlled
- **Cost-Effective**: Optimizes medication costs automatically

## Technical Architecture

### Data Structures
- Patient profiles with encrypted medical data
- Prescription records with dosage and timing information
- Drug interaction database with severity ratings
- Pharmacy network with pricing and availability
- Insurance coverage with benefit calculations

### Security Features
- Multi-signature authorization for sensitive operations
- Role-based access control (patients, doctors, pharmacists)
- Encrypted storage of sensitive medical information
- Audit trails for all prescription-related activities

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js 18+ for testing
- Stacks wallet for deployment

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd prescription-management-system

# Install dependencies
npm install

# Run tests
npm test

# Deploy contracts
clarinet deploy
\`\`\`

### Usage Examples

#### Register a New Patient
\`\`\`clarity
(contract-call? .medication-tracker register-patient
"patient-id-123"
"encrypted-medical-data")
\`\`\`

#### Add a Prescription
\`\`\`clarity
(contract-call? .medication-tracker add-prescription
"patient-id-123"
"medication-name"
u30
u2
u1440)
\`\`\`

#### Check Drug Interactions
\`\`\`clarity
(contract-call? .drug-interactions check-interaction
"medication-a"
"medication-b")
\`\`\`

## Contract Specifications

### Error Codes
- `ERR-NOT-AUTHORIZED (u100)`: Unauthorized access attempt
- `ERR-PATIENT-NOT-FOUND (u101)`: Patient record not found
- `ERR-PRESCRIPTION-NOT-FOUND (u102)`: Prescription not found
- `ERR-INVALID-INPUT (u103)`: Invalid input parameters
- `ERR-INTERACTION-FOUND (u104)`: Dangerous drug interaction detected
- `ERR-INSUFFICIENT-BALANCE (u105)`: Insufficient token balance
- `ERR-PHARMACY-NOT-FOUND (u106)`: Pharmacy not registered
- `ERR-INSURANCE-DENIED (u107)`: Insurance coverage denied

### Data Types
- `patient-id`: String identifier for patients
- `medication-name`: String name of medication
- `dosage`: Unsigned integer representing dosage amount
- `frequency`: Unsigned integer for daily frequency
- `duration`: Unsigned integer for prescription duration in minutes

## Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific contract tests
npm test medication-tracker
npm test drug-interactions
npm test pharmacy-coordinator
npm test reminder-automation
npm test cost-optimizer
\`\`\`

## Deployment

### Local Development
\`\`\`bash
clarinet console
\`\`\`

### Testnet Deployment
\`\`\`bash
clarinet deploy --testnet
\`\`\`

### Mainnet Deployment
\`\`\`bash
clarinet deploy --mainnet
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For support and questions, please open an issue in the repository or contact the development team.
