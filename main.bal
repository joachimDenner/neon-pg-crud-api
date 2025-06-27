import ballerina/sql;
import ballerina/postgresql;
import ballerina/http;

postgresql:Client dbClient = check new ({
    host: "ep-twilight-darkness-a93wnhjw-pooler.gwc.azure.neon.tech", // t.ex. ep-red-example-db.neon.tech
    port: 5432,
    user: "neondb_owner",
    password: "npg_hgGofDq81sXy",
    database: "my_test_db_in_neon",
    options: "sslmode=require&channel_binding=require"
});

type anstalld record {
    integer id;
	string firstNamn;
    string lastName;
    string workTitle;
	date created;
	date updated;
	text comment;
};

service /anstalld on new http:Listener(0) {

    resource get .() returns json {
        stream<record {}, error?> result = dbClient->query("SELECT * FROM anstalld");
        return result.toArray();
    }

    resource post .(json input) returns string {
        check dbClient->execute(
            "INSERT INTO anstalld (firstNamn, lastName, workTitle, created, updated, comment) VALUES ($1, $2, $3, $4, $5, $6)",
            input.firstNamn, input.lastName, input.workTitle, input.created, input.updated, input.comment);
        return "Created";
    }

    resource put .(json input) returns string {
        check dbClient->execute(
            "UPDATE anstalld SET workTitle = $1 WHERE firstname = $2 AND lastname = $3",
            input.workTitle, input.firstNamn, input.lastName);
        return "Updated";
    }

    resource delete .(json input) returns string {
        check dbClient->execute(
            "DELETE FROM anstalld WHERE firstNamn = $1 AND lastName = $2",
            input.firstNamn, input.lastName);
        return "Deleted";
    }
}
