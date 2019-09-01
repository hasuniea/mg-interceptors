import ballerina/io;
import ballerina/http;
import ballerina/config;

string USER_AGENT = "User-Agent";
public function validateRequest (http:Caller caller, http:Request req) {
    string contentType= req.getHeader("Content-Type");
    json value = {};
    if !(contentType.equalsIgnoreCase("application/json")) {
        var payload = req.getXmlPayload();
        if (payload is xml) {
           value = payload.toJSON({});
        }
    } 
  req.setHeader("Content-Type", "application/json");
  req.setJsonPayload(untaint value);
}

public function sqlInjectionIntercept (http:Caller caller, http:Request req) {
   string regEx = ".*'.*|.*ALTER.*|.*ALTER TABLE.*|.*ALTER VIEW.*|
.*CREATE DATABASE.*|.*CREATE PROCEDURE.*|.*CREATE SCHEMA.*|.*create table.*|.*CREATE VIEW.*|.*DELETE.*|.*DROP DATABASE.*|.*DROP PROCEDURE.*|.*DROP.*|.*SELECT.*";
   json|error payload = req.getJsonPayload();
   string request = "";
   json newPayload = { fault: {
                        code: "Error",
                        message: "SQL Injection",
                        description: "Threat detected in payload"
                    } };
   if (payload is json) {
      request = payload.toString();
   }
    boolean | error isMatch = request.matches(regEx);
    if (isMatch is boolean) {
       if (isMatch) {
          http:Response response = new;
          response.setJsonPayload(newPayload, contentType = "application/json");
          var result = caller->respond(response); 
        }
    } 
}

public function validateResponse (http:Caller caller, http:Response res) {
    json|error resp = res.getJsonPayload();
    if (resp is json) {
       if(resp.toString().equalsIgnoreCase("{}")) {
          http:Response response = new;
          response.setHeader("ResponseHeader","header");
          json payload = {"status" : "No results for the title"};
          response.setJsonPayload(payload, contentType = "application/json");
          var result = caller->respond(response);
       }
    }
}

public function extractAgent(http:Caller caller, http:Request req) {
    string header = req.getHeader(USER_AGENT);
    config:setConfig(USER_AGENT, header);
}

public function transformResponse(http:Caller caller, http:Response res) {
    string userAgent = "";
    json | error body = {};
    if (res.statusCode == 200) {
        if (config:contains(USER_AGENT)) {
           userAgent = config:getAsString(USER_AGENT);
        }
        if (userAgent == "iPhone") {
          body = res.getJsonPayload();
           if (body is json) {
                body.remove("MobileURL");
                res.setPayload(untaint body);
           }
        } 
    }
}