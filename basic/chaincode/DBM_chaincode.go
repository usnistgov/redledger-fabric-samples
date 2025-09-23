package main

// Import statements - these bring in external libraries we need
import (
	"encoding/json" // For converting JSON strings to Go objects and vice versa
	"fmt"           // For string formatting and printing
	"log"           // For logging errors and information

	"github.com/hyperledger/fabric-contract-api-go/contractapi" // Hyperledger Fabric's contract API for Go
)

// Pairs struct - defines the structure for key-value pairs
// This struct is used when we want to store both a key and its value
type Pairs struct {
	Key   string // The key name (like "product1")
	Value string // The value to store (like "electronics")
}

// KeyOnly struct - defines the structure for operations that only need keys
// This struct is used for delete operations where we only need the key name
type KeyOnly struct {
	Key string // The key name to delete (like "product1")
}

// main function - the entry point of the chaincode application
func main() {
	// Create a new chaincode instance using our SmartContract struct
	// &SmartContract{} creates a pointer to a new SmartContract instance
	assetChaincode, err := contractapi.NewChaincode(&SmartContract{})

	// Check if creating the chaincode failed
	if err != nil {
		// log.Panicf stops the program and prints an error message
		log.Panicf("Error creating asset-transfer-basic chaincode: %v", err)
	}

	// Start the chaincode - this makes it available to receive transactions
	if err := assetChaincode.Start(); err != nil {
		// If starting fails, stop the program with an error message
		log.Panicf("Error starting asset-transfer-basic chaincode: %v", err)
	}
}

// SmartContract struct - embeds the contractapi.Contract
// This struct will contain all our chaincode functions (Put, Get, Delete)
type SmartContract struct {
	contractapi.Contract // Embedding this gives us access to Fabric contract functionality
}

// Put function - stores key-value pairs in the blockchain ledger

func (s *SmartContract) Put(ctx contractapi.TransactionContextInterface, pairsJson string) error {
	// Create a slice (dynamic array) to hold the parsed key-value pairs
	var pairs []Pairs

	// Convert the JSON string into Go objects (unmarshal)
	// json.Unmarshal parses the JSON and fills the pairs slice
	if err := json.Unmarshal([]byte(pairsJson), &pairs); err != nil {

		return fmt.Errorf("failed to unmarshal pairs JSON: %v", err)
	}

	for _, pair := range pairs {
		// Store the key-value pair in the blockchain state
		// PutState stores the value (converted to bytes) with the given key
		if err := ctx.GetStub().PutState(pair.Key, []byte(pair.Value)); err != nil {

			return fmt.Errorf("failed to put state for key %s: %v", pair.Key, err)
		}
	}
	return nil
}

// Get function - retrieves a value from the blockchain ledger using a key

func (s *SmartContract) Get(ctx contractapi.TransactionContextInterface, key string) (string, error) {
	// GetState retrieves the value associated with the key from blockchain state
	// It returns the value as a byte array
	bytes, err := ctx.GetStub().GetState(key)

	// Convert the byte array to a string and return it along with any error
	// If the key doesn't exist, bytes will be nil and string(bytes) will be empty string
	return string(bytes), err
}

// Delete function - removes keys from the blockchain ledger

func (s *SmartContract) Delete(ctx contractapi.TransactionContextInterface, keysJson string) error {
	// Create a slice to hold the parsed key objects
	var keys []KeyOnly

	// Convert the JSON string into Go objects (unmarshal)
	// This parses the JSON array of key objects
	if err := json.Unmarshal([]byte(keysJson), &keys); err != nil {

		return fmt.Errorf("failed to unmarshal keys JSON: %v", err)
	}

	// Loop through each key object in the parsed array
	for _, keyObj := range keys {
		// SAFETY CHECK: Check if the key exists before trying to delete it
		// GetState returns the current value for the key (or nil if it doesn't exist)
		existing, err := ctx.GetStub().GetState(keyObj.Key)

		// If there was an error reading the key, return an error
		if err != nil {
			return fmt.Errorf("failed to check existence of key %s: %v", keyObj.Key, err)
		}

		// If the key doesn't exist (existing is nil), skip deletion
		// This prevents errors when trying to delete non-existent keys
		if existing == nil {
			// Print a warning message and continue to the next key
			fmt.Printf("Warning: key %s does not exist, skipping deletion\n", keyObj.Key)
			continue // Skip to the next iteration of the loop
		}

		// If the key exists, it's safe to delete it
		// DelState removes the key-value pair from the blockchain state
		if err := ctx.GetStub().DelState(keyObj.Key); err != nil {

			return fmt.Errorf("failed to delete key %s: %v", keyObj.Key, err)
		}

		fmt.Printf("Successfully deleted key: %s\n", keyObj.Key)
	}

	return nil
}
