import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerinax/docker;

@docker:Expose{}
listener http:Listener storeEP = new(8000, config = {
    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
});
@docker:Config {
    name:"backend",
    tag:"v2"
}
@http:ServiceConfig {
    basePath:"/"
}

service store on storeEP {

    @http:ResourceConfig {
        methods:["GET"],
        path: "/book"
    }
    resource function getBook(http:Caller caller, http:Request req) {
      json val = {
  "books": [
    {
      "isbn": "9781593275846",
      "title": "Eloquent JavaScript, Second Edition",
      "subtitle": "A Modern Introduction to Programming",
      "author": "Marijn Haverbeke",
      "published": "2014-12-14T00:00:00.000Z",
      "publisher": "No Starch Press",
      "pages": 472,
      "description": "JavaScript lies at the heart of almost every modern web application, from social apps to the newest browser-based games. Though simple for beginners to pick up and play with, JavaScript is a flexible, complex language that you can use to build full-scale applications.",
      "website": "http://eloquentjavascript.net/"
    },
    {
      "isbn": "9781449331818",
      "title": "Learning JavaScript Design Patterns",
      "subtitle": "A JavaScript and jQuery Developer's Guide",
      "author": "Addy Osmani",
      "published": "2012-07-01T00:00:00.000Z",
      "publisher": "O'Reilly Media",
      "pages": 254,
      "description": "With Learning JavaScript Design Patterns, you'll learn how to write beautiful, structured, and maintainable JavaScript by applying classical and modern design patterns to the language. If you want to keep your code efficient, more manageable, and up-to-date with the latest best practices, this book is for you.",
      "website": "http://www.addyosmani.com/resources/essentialjsdesignpatterns/book/"
    },
    {
      "isbn": "9781449337711",
      "title": "Designing Evolvable Web APIs with ASP.NET",
      "subtitle": "Harnessing the Power of the Web",
      "author": "Glenn Block, et al.",
      "published": "2014-04-07T00:00:00.000Z",
      "publisher": "O'Reilly Media",
      "pages": 538,
      "description": "Design and build Web APIs for a broad range of clients—including browsers and mobile devices—that can adapt to change over time. This practical, hands-on guide takes you through the theory and tools you need to build evolvable HTTP services with Microsoft’s ASP.NET Web API framework. In the process, you’ll learn how design and implement a real-world Web API.",
      "website": "http://chimera.labs.oreilly.com/books/1234000001708/index.html"
    },
    {
      "isbn": "9781449325862",
      "title": "Git Pocket Guide",
      "subtitle": "A Working Introduction",
      "author": "Richard E. Silverman",
      "published": "2013-08-02T00:00:00.000Z",
      "publisher": "O'Reilly Media",
      "pages": 234,
      "description": "This pocket guide is the perfect on-the-job companion to Git, the distributed version control system. It provides a compact, readable introduction to Git for new users, as well as a reference to common commands and procedures for those of you with Git experience.",
      "website": "http://chimera.labs.oreilly.com/books/1230000000561/index.html"
    },
     {
      "isbn": "9781449365035",
      "title": "Speaking JavaScript",
      "subtitle": "An In-Depth Guide for Programmers",
      "author": "Axel Rauschmayer",
      "published": "2014-02-01T00:00:00.000Z",
      "publisher": "O'Reilly Media",
      "pages": 460,
      "description": "Like it or not, JavaScript is everywhere these days-from browser to server to mobile-and now you, too, need to learn the language or dive deeper than you have. This concise book guides you into and through JavaScript, written by a veteran programmer who once found himself in the same position.",
      "website": "http://speakingjs.com/"
    },
    {
      "isbn": "9781491950296",
      "title": "Programming JavaScript Applications",
      "subtitle": "Robust Web Architecture with Node, HTML5, and Modern JS Libraries",
      "author": "Eric Elliott",
      "published": "2014-07-01T00:00:00.000Z",
      "publisher": "O'Reilly Media",
      "pages": 254,
      "description": "Take advantage of JavaScript's power to build robust web-scale or enterprise applications that are easy to extend and maintain. By applying the design patterns outlined in this practical book, experienced JavaScript developers will learn how to write flexible and resilient code that's easier-yes, easier-to work with as your code base grows.",
      "website": "http://chimera.labs.oreilly.com/books/1234000000262/index.html"
    }
  ]
};
        var result = caller->respond(val);

        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/book/{bookId}"
    
    }
    resource function searchBook(http:Caller caller, http:Request req) {
        json book = {
      "isbn": "9781449325862",
      "title": "Git Pocket Guide",
      "subtitle": "A Working Introduction",
      "author": "Richard E. Silverman",
      "published": "2013-08-02T00:00:00.000Z",
      "publisher": "O'Reilly Media",
      "pages": 234,
      "description": "This pocket guide is the perfect on-the-job companion to Git, the distributed version control system. It provides a compact, readable introduction to Git for new users, as well as a reference to common commands and procedures for those of you with Git experience.",
      "website": "http://chimera.labs.oreilly.com/books/1230000000561/index.html"
    };
        var result = caller->respond(book);

        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    } 

    @http:ResourceConfig {
        methods:["GET"],
        path:"/book/title/{title}"
    
    }
    resource function searchfromTitle(http:Caller caller, http:Request req) {
        json book = {};
        var result = caller->respond(book);

        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/book"
    
    }
    resource function addBook(http:Caller caller, http:Request req) {
      json value = {};
      string contentType = req.getHeader("Content-Type");
      if (contentType.equalsIgnoreCase("application/json")) {
        value = { "Status" : "Created" };
      } else {
         value = { "Error" : "Only json content is accepted" };
      }
    
      var result = caller->respond(value);

        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/book/ebooks/{title}"
    
    }
    resource function searcheBooks(http:Caller caller, http:Request req) {
         json eBook = {
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
     
        var result = caller->respond(eBook);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }
}