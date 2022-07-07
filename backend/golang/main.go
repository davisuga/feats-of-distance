package main

import (
	"flag"
	"fmt"

	"github.com/neo4j/neo4j-go-driver/v4/neo4j"
)

func helloWorld(uri, username, password, command string) (string, error) {

	auth := neo4j.BasicAuth(username, password, "")

	driver, err := neo4j.NewDriver(uri, auth)
	if err != nil {
		return "", err
	}
	defer driver.Close()

	session := driver.NewSession(neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close()

	records, err := session.WriteTransaction(
		func(tx neo4j.Transaction) (interface{}, error) {

			// To learn more about the Cypher syntax, see https://neo4j.com/docs/cypher-manual/current/
			// The Reference Card is also a good resource for keywords https://neo4j.com/docs/cypher-refcard/current/
			createRelationshipBetweenPeopleQuery := command
			result, err := tx.Run(createRelationshipBetweenPeopleQuery, map[string]interface{}{})
			if err != nil {
				// Return the error received from driver here to indicate rollback,
				// the error is analyzed by the driver to determine if it should try again.
				return nil, err
			}

			// Collects all records and commits the transaction (as long as
			// Collect doesn't return an error).
			// Beware that Collect will buffer the records in memory.
			return result.Collect()
		})
	if err != nil {
		panic(err)
	}
	fmt.Print("[")
	for i, record := range records.([]*neo4j.Record) {

		if i != 0 {

			fmt.Print(",")
		}
		fmt.Print(record.Values[0])

	}
	fmt.Print("]")

	return "", nil
}

func main() {
	statementPtr := flag.String("statement", "", "a string for description")
	passwordPtr := flag.String("p", "", "a string for description")
	userPtr := flag.String("user", "", "a string for description")
	uriPtr := flag.String("uri", "", "a string for description")
	flag.Parse()
	result, err := helloWorld(*uriPtr, *userPtr, *passwordPtr, *statementPtr)
	if err != nil {
		fmt.Println("Error while running statement: ", err)
		return
	}
	fmt.Println(result)
}
