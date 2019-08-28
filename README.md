

## WSO2 API Mirogateway 3 - On the fly message transformation through Interceptos

#### Description
Interceptors can be used to do request and response transformations and mediation. Request interceptors are engaged before sending the request to the back end and response interceptors are engaged before responding to the client. API developer can write his own request and response interceptors using ballerina and add it to the project and define them in the open API definition using extensions

In this screencast, We describe following scenarioes

To ellaborate the scenario, We deploy two different micro gateway services. 
nonInter, and bookstore

nonInter - Pieo API definition without interceptors.  HTTP 9020     HTTPS 9070
bookstore - with interceptors HTTP 9090     HTTPS 9095

1.) The backend expects the request payload to be in JSON content type. But your client application can only send messages in XML format. The backend may rejects the request and send an error response as it doesn’t support XML content type.
In such scenarioes, WSO2 micro-gateway supports request interceptor to transform the payload to JSON and pass it to the backend.
 
 Invoke the nonInter service

 TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5UQXhabU14TkRNeVpEZzNNVFUxWkdNME16RXpPREpoWldJNE5ETmxaRFUxT0dGa05qRmlNUSJ9.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbiIsImFwcGxpY2F0aW9uIjp7ImlkIjoyLCJuYW1lIjoiSldUX0FQUCIsInRpZXIiOiJVbmxpbWl0ZWQiLCJvd25lciI6ImFkbWluIn0sInNjb3BlIjoiYW1fYXBwbGljYXRpb25fc2NvcGUgZGVmYXVsdCIsImlzcyI6Imh0dHBzOlwvXC9sb2NhbGhvc3Q6OTQ0M1wvb2F1dGgyXC90b2tlbiIsImtleXR5cGUiOiJQUk9EVUNUSU9OIiwic3Vic2NyaWJlZEFQSXMiOltdLCJjb25zdW1lcktleSI6Ilg5TGJ1bm9oODNLcDhLUFAxbFNfcXF5QnRjY2EiLCJleHAiOjM3MDMzOTIzNTMsImlhdCI6MTU1NTkwODcwNjk2MSwianRpIjoiMjI0MTMxYzQtM2Q2MS00MjZkLTgyNzktOWYyYzg5MWI4MmEzIn0=.b_0E0ohoWpmX5C-M1fSYTkT9X4FN--_n7-bEdhC3YoEEk6v8So6gVsTe3gxC0VjdkwVyNPSFX6FFvJavsUvzTkq528mserS3ch-TFLYiquuzeaKAPrnsFMh0Hop6CFMOOiYGInWKSKPgI-VOBtKb1pJLEa3HvIxT-69X9CyAkwajJVssmo0rvn95IJLoiNiqzH8r7PRRgV_iu305WAT3cymtejVWH9dhaXqENwu879EVNFF9udMRlG4l57qa2AaeyrEguAyVtibAsO0Hd-DFy5MW14S6XSkZsis8aHHYBlcBhpy2RqcP51xRog12zOb-WcROy6uvhuCsv-hje_41WQ==

 curl -k -X POST "https://localhost:9070/bookstore/v1/book" -H "accept: application/xml" -H "Content-Type: application/xml" -H "Authorization: Bearer $TOKEN" -d "<?xml version="1.0" encoding="UTF-8"?><root><author>Samson E. Silverman</author><description>This pocket guide is the perfect on-the-job companion to Git, the distributed version control system. It provides a compact, readable introduction to Git for new users, as well as a reference to common commands and procedures for those of you with Git experience.</description><isbn>9981449325862</isbn><pages>234</pages><published>2013-08-02T00:00:00.000Z</published><publisher>O'Reilly Media</publisher><subtitle>A Working Introduction</subtitle><title>My dream</title><website>http://chimera.labs.oreilly.com/books/1230000000561/index.html</website></root>"

 Result : { "Error" : "Only json content is accepted" }

 Invoke the same resource through bookstore service

 curl -k -X POST "https://localhost:9095/bookstore/v1/book" -H "accept: application/xml" -H "Content-Type: application/xml" -H "Authorization: Bearer $TOKEN" -d "<?xml version="1.0" encoding="UTF-8"?><root><author>Samson E. Silverman</author><description>This pocket guide is the perfect on-the-job companion to Git, the distributed version control system. It provides a compact, readable introduction to Git for new users, as well as a reference to common commands and procedures for those of you with Git experience.</description><isbn>9981449325862</isbn><pages>234</pages><published>2013-08-02T00:00:00.000Z</published><publisher>O'Reilly Media</publisher><subtitle>A Working Introduction</subtitle><title>My dream</title><website>http://chimera.labs.oreilly.com/books/1230000000561/index.html</website></root>"

 Result : { "Status" : "Created" }

 You can see the XML request payload is transformed into json and resource is created successfully at the backend.

2.) We have taken a scenario like the the backend  resource directly connects to the databases hence the backend should be secured from the vulnerbale attacks.
If someone tries a sql injection attack, we want to interrupt the message and send back to the client with warining message.
In this scenario, we planned to intercept the request and check a security check through a request interceptor and If only the message passes it directs to the backend otherwise terminate.

Invoke through noninter service

curl -k -X POST "https://localhost:9095/bookstore/v1/book" -H "accept: application/xml" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"autho\":\"New State\", \"name\":\"My Town\"}"

 

curl -k -X POST "https://localhost:9070/bookstore/v1/book" -H "accept: application/xml" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"autho\":\"DROP DATABASE boostore\"}"

Result : { "Status" : "Created" }

Invoke through bookstore

curl -k -X POST "https://localhost:9095/bookstore/v1/book" -H "accept: application/xml" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"autho\":\"DROP DATABASE boostore\"}"

Result : {"fault":{"code":"Error", "message":"SQL Injection", "description":"Threat detected in payload"}}

3.) If there are multiple types of clients access the API deployed in the micro gateway. Each client use different type of message formats hence microgateway should change the response message formats accordingly. In such a scenarieos, We can use Response interceptors to transform messages by verifying the user-agent

invoke through noninter
curl -X GET "https://localhost:9070/bookstore/v1/book/ebooks/Dragon" -H "User-Agent: iPhone" -H "Authorization:Bearer $TOKEN" -k

Resule : {
         "isbn": "9780670921621",
         "title": "The Lean Startup",
         "subtitle": "How Constant Innovation Creates Radically Successful Businesses",
         "author": "Eric Ries",
         "published": "2017-10-12T00:00:00.000Z",
         "publisher": "Penguin",
         "pages": 490,
         "description": "The Lean Startup is a new approach to business that's being adopted around the world.It is changing the way companies are built and new products are launched.",
         "MobileURL": "www.stackmob.com",
         "MobileCode": "PENGUIN"
    };



curl -X GET "https://localhost:9095/bookstore/v1/book/ebooks/Dragon" -H "User-Agent: iPhone" -H "Authorization:Bearer $TOKEN" -k

Result :

{"isbn":"9780670921621", "title":"The Lean Startup", "subtitle":"How Constant Innovation Creates Radically Successful Businesses", "author":"Eric Ries", "published":"2017-10-12T00:00:00.000Z", "publisher":"Penguin", "pages":490, "description":"The Lean Startup is a new approach to business that's being adopted around the world.It is changing the way companies are built and new products are launched."}



