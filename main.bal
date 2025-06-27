import ballerina/sql;
import ballerina/postgresql;
import ballerina/http;

configurable string dbHost = ?;
configurable int dbPort = 5432;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;

postgresql:Client dbClient = check new ({
    host: dbHost,
    port: dbPort,
    user: dbUser,
    password: dbPassword,
    database: dbName,
    options: "sslmode=require&channel_binding=require"
});

type Anstalld record {
    int id;
    string firstNamn;
    string lastName;
    string workTitle;
    date created;
    date updated;
    string comment;
};

service /anstalld on new http:Listener(8080) {

    resource function get .() returns json|error {
        stream<record {}, error?> result = dbClient->query("SELECT * FROM anstalld");
        return result.toArray();
    }

    resource function post .(json input) returns string|error {
        check dbClient->execute(
            "INSERT INTO anstalld (firstNamn, lastName, workTitle, created, updated, comment) VALUES ($1, $2, $3, $4, $5, $6)",
            input.firstNamn, input.lastName, input.workTitle,
            input.created, input.updated, input.comment);
        return "Created";
    }

    resource function put .(json input) returns string|error {
        check dbClient->execute(
            "UPDATE anstalld SET workTitle = $1 WHERE firstNamn = $2 AND lastName = $3",
            input.workTitle, input.firstNamn, input.lastName);
        return "Updated";
    }

    resource function delete .(json input) returns string|error {
        check dbClient->execute(
            "DELETE FROM anstalld WHERE firstNamn = $1 AND lastName = $2",
            input.firstNamn, input.lastName);
        return "Deleted";
    }
}
