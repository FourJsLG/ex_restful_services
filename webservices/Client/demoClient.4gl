################################################################################
#
# FOURJS_START_COPYRIGHT(U,2015)
# Property of Four Js*
# (c) Copyright Four Js 2015, 2017. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these samples
# are accurate and suitable for your purposes. Their inclusion is purely for
# information purposes only.
# FOURJS_END_COPYRIGHT
#
IMPORT com
IMPORT util

IMPORT FGL logger

#CONSTANT _ACCTSERVICE       = "http://odie.centos7/genero/ws/r/rest/accounts"     --> Make configurable?
#CONSTANT _ORDERSERVICE      = "http://odie.centos7/genero/ws/r/rest/orders"       --> Make configurable?
#CONSTANT _ORDERITEMSSERVICE = "http://odie.centos7/genero/ws/r/rest/orderitems"   --> Make configurable?

CONSTANT _ACCTSERVICE       = "http://localhost:8090/ws/r/rest/accounts"     --> Make configurable?
CONSTANT _ORDERSERVICE      = "http://localhost:8090/ws/r/rest/orders"       --> Make configurable?
CONSTANT _ORDERITEMSSERVICE = "http://localhost:8090/ws/r/rest/orderitems"   --> Make configurable?

SCHEMA officestore

TYPE custType RECORD LIKE account.*
TYPE orderType RECORD LIKE orders.*
TYPE orderItemType RECORD LIKE lineitem.*

DEFINE theseCustomers DYNAMIC ARRAY OF custType
DEFINE theseOrders DYNAMIC ARRAY OF orderType
DEFINE theseOrderItems DYNAMIC ARRAY OF orderItemType
DEFINE ordersJsonObj util.JSONArray

DEFINE wrappedResponse RECORD
    code    INTEGER, # HTTP response code
    status  STRING,  # success, fail, or error
    message STRING,  # used for fail or error message
    data    STRING   # response body or error/fail cause or exception name
END RECORD 

# Freeform error message; not raised by the runtime
& define APP_LOGGING
DEFINE applicationError STRING

################################################################################
#
# Guidelines shamelessly copied from DR. M. ELKSTEIN.  For more information:
# see: http://rest.elkstein.org/2008/02/what-is-rest.html
#
# Some soft guidelines for designing a REST architecture:
#     1) Do not use "physical" URLs. A physical URL points at something physical 
#       -- e.g., an XML file: "http://www.acme.com/inventory/product003.xml". 
#       A logical URL does not imply a physical file: "http://www.acme.com/inventory/product/003".
#       Sure, even with the .xml extension, the content could be dynamically generated. 
#       But it should be "humanly visible" that the URL is logical and not physical.
#     2) Queries should not return an overload of data. If needed, provide a paging mechanism. 
#       For example, a "product list" GET request should return the first n products (e.g., the first 10), 
#       with next/prev links.  
#     3) Even though the REST response can be anything, make sure it's well documented, 
#       and do not change the output format lightly (since it will break existing clients).
#       Remember, even if the output is human-readable, your clients aren't human users.
#       If the output is in XML, make sure you document it with a schema or a DTD.
#     4) Rather than letting clients construct URLs for additional actions, include 
#       the actual URLs with REST responses. For example, a "product list" request could 
#       return an ID per product, and the specification says that you should use 
#       http://www.acme.com/product/PRODUCT_ID to get additional details. That's bad design. 
#       Rather, the response should include the actual URL with each item: 
#       http://www.acme.com/product/001263, etc.  Yes, this means that the output is larger. 
#       But it also means that you can easily direct clients to new URLs as needed, 
#       without requiring a change in client code.
#     5) GET access requests should never cause a state change. Anything that changes 
#       the server state should be a POST request (or other HTTP verbs, such as DELETE).
#
MAIN
    DEFINE opt STRING
    DEFINE i   INTEGER 
    
    WHENEVER ANY ERROR CALL errorHandler 

    # Initialize log
    CALL logger.initializeLog(logger._LOGERROR,".","demoClient.log")  
    # Set custom display logger
    CALL logger.setLoggerFunction(FUNCTION consoleLogger)
    
    # Parse command line args
    IF NUM_ARGS() THEN 
        FOR i = 1 TO NUM_ARGS() STEP 2
            # Check output destination
            IF ARG_VAL(i) = "-o" THEN LET opt = ARG_VAL(i+1) END IF 
        END FOR
    ELSE
        # Default output destination to "screen"
        LET opt = "screen"
    END IF 

    # Get the customer data
    TRY 
        CALL retrieveCustomers()
    CATCH
        LET applicationError = "FAILURE retrieving customer data"
        # Error handler must be called due to RAISEd exception processing
        CALL errorHandler()
    END TRY

    # Get the order data
    TRY 
        CALL retrieveOrders()
    CATCH
        LET applicationError = "FAILURE retrieving order data"
        # Error handler must be called due to RAISEd exception processing
        CALL errorHandler()
    END TRY

    CALL logger.logEvent(logger._LOGMSG,ARG_VAL(0),SFMT("%1:%2",__FILE__,__LINE__),"Starting demoClient")

    # Produce client ouput to destination option
    CALL clientOutput(opt)
        
    
END MAIN

################################################################################
#
# Method: retrieveCustomers
#
# Description: Requests customer data from REST server
#
# TODO: implementation according to REST principle #4 above...response should 
#       include the actual URL with each item: 
#          http://www.acme.com/product/001263, etc.
#       This means the customer list should be a list ID's and URI for detail.
#
FUNCTION retrieveCustomers()
    DEFINE resp com.HttpResponse
    DEFINE jsonText STRING

    TRY
        LET resp = doRESTRequest(_ACCTSERVICE)
        
        # Check request success
        IF resp.getStatusCode() = 200 THEN
            CALL theseCustomers.clear()

            # Parse the response into intelligent data
            LET jsonText = resp.getTextResponse()
            DISPLAY "Content-Length: ", resp.getHeader("Content-Length")

            # Parse wrapped response
            CALL util.JSON.parse(jsonText, wrappedResponse)
            
            # Parse wrapped response "data"
            IF ( wrappedResponse.status = "SUCCESS" ) THEN
                CALL util.JSON.parse(wrappedResponse.data, theseCustomers)
                CALL theseCustomers.deleteElement(theseCustomers.getLength())
            END IF 
            
        ELSE
           LET applicationError =  "ERROR [", resp.getStatusCode(), "]: ", resp.getStatusDescription()
            &ifdef APP_LOGGING
                CALL errorHandler()
            &endif
        END IF
    CATCH
        LET applicationError =  "ERROR [", resp.getStatusCode(), "]: ", resp.getStatusDescription()
        &ifdef APP_LOGGING
            CALL errorHandler()
        &endif
    
    END TRY

    RETURN
    
END FUNCTION 

################################################################################
#
# Method: retrieveOrders
#
# Description: Requests order data from REST server
#
# NOTES: Consider re-evaluating to receive minimal data and URI for detail.  See
#        guideline #3. 
#
# TODO: implementation according to REST principle #4 above...response should 
#       include the actual URL with each item: 
#          http://www.acme.com/product/001263, etc.
#
FUNCTION retrieveOrders()
    DEFINE resp com.HttpResponse
    DEFINE jsonText STRING

    TRY
        LET resp = doRESTRequest(_ORDERSERVICE)

        # Check request success
        IF resp.getStatusCode() = 200 THEN
            CALL theseOrders.clear()
            # Instead of parsing JSON to BDL, let's use JSON methods of access.
            # For the sake of the demo, let's create a JSON obj and show how to access
            # information.

            # Parse the response into intelligent data
            LET jsonText = resp.getTextResponse()
            
            # Parse wrapped response
            CALL util.JSON.parse(jsonText, wrappedResponse)
            
            # Parse wrapped response "data"
            IF ( wrappedResponse.status = "SUCCESS" ) THEN
                LET ordersJsonObj = util.JSONArray.parse(wrappedResponse.data)
            END IF

        ELSE
            LET applicationError =  "ERROR [", resp.getStatusCode(), "]: ", resp.getStatusDescription()
            CALL errorHandler()
        END IF
            
    CATCH
        LET applicationError =  "ERROR [", resp.getStatusCode(), "]: ", resp.getStatusDescription()
        &ifdef APP_LOGGING
            CALL errorHandler()
        &endif

    END TRY
    RETURN

END FUNCTION 

################################################################################
#
# Method: retrieveOrderItems
#
# Description: Requests order item data from REST server
#
# NOTES: Consider re-evaluating to receive minimal data and URI for detail.  See
#        guideline #3. 
#
# TODO: implementation according to REST principle #4 above...response should 
#       include the actual URL with each item: 
#          http://www.acme.com/product?id=001263, etc.
#
FUNCTION retrieveOrderItems(thisOrder)
    DEFINE resp com.HttpResponse
    DEFINE thisOrder STRING
    DEFINE jsonText STRING

    TRY
        LET resp = doRESTRequest(SFMT("%1?order=%2",_ORDERITEMSSERVICE,thisOrder))

        # Check request success    
        IF resp.getStatusCode() = 200 THEN
            CALL theseOrderItems.clear()
            # Instead of parsing JSON to BDL, let's use JSON methods of access.
            # For the sake of the demo, let's create a JSON obj and show how to access
            # information.

            # Parse the response into intelligent data
            LET jsonText = resp.getTextResponse()
            
            # Parse wrapped response
            CALL util.JSON.parse(jsonText, wrappedResponse)
            
            # Parse wrapped response "data"
            IF ( wrappedResponse.status = "SUCCESS" ) THEN
                CALL util.JSON.parse(wrappedResponse.data, theseOrderItems)
                CALL theseOrderItems.deleteElement(theseCustomers.getLength())
            END IF
               
        ELSE
            LET applicationError =  "ERROR [", resp.getStatusCode(), "]: ", resp.getStatusDescription()
            CALL errorHandler()
        END IF

    CATCH
        LET applicationError =  "ERROR [", resp.getStatusCode(), "]: ", resp.getStatusDescription()
        &ifdef APP_LOGGING
            CALL errorHandler()
        &endif
    
    END TRY
    RETURN
END FUNCTION 

################################################################################
#
# Method: doRESTRequest
#
# Description: Requests customer data from REST server
#
#
FUNCTION doRESTRequest(requestResource STRING)
    DEFINE req com.HttpRequest
    DEFINE resp com.HttpResponse

    WHENEVER ANY ERROR RAISE 
    # Request list of customers from REST server using HTTP text request
    LET req = com.HttpRequest.Create(requestResource)

    CALL req.setConnectionTimeout(10)
    CALL req.setTimeout(60)
    CALL req.setCharset("UTF-8")

    CALL req.setMethod("GET")
    CALL req.setHeader("Content-Type","application/json")  --> different for xml request

    CALL req.doRequest()
    LET resp = req.getResponse()

    # Check request success
    IF resp.getStatusCode() = 200 THEN
    ELSE
        CALL util.JSON.parse(resp.getTextResponse(), wrappedResponse)
        LET applicationError =  SFMT("ERROR[%1:%2] %3. URL:%4", 
                                     resp.getStatusCode(), 
                                     resp.getStatusDescription(),
                                     upshift(wrappedResponse.message),
                                     requestResource)

        &ifdef APP_LOGGING
            CALL errorHandler()
        &endif
    END IF
    
    RETURN resp
    
END FUNCTION 

################################################################################
#
# Method: clientOutput
#
# Description: Produces client output based on parameter 'opt'
#
# Parameters:  opt = display mode(screen, list, PDF)
#
FUNCTION clientOutput(opt)
    DEFINE opt, res   STRING
    DEFINE i, j  INTEGER

    DEFINE orderList DYNAMIC ARRAY OF RECORD
       orderid   LIKE orders.orderid,
       orderdate LIKE orders.orderdate,
       totalprice LIKE orders.totalprice
    END RECORD 
       
    CASE opt
    WHEN "screen"
        OPEN FORM f1 FROM "account2" 
        DISPLAY FORM f1

        DIALOG ATTRIBUTES(FIELD ORDER FORM, UNBUFFERED)

            DISPLAY ARRAY theseCustomers TO record1.*
                BEFORE ROW
                    LET i = arr_curr()

                    DISPLAY theseCustomers[i].userid   TO record2.userid
                    DISPLAY theseCustomers[i].addr1    TO record2.addr1
                    DISPLAY theseCustomers[i].addr2    TO record2.addr2
                    DISPLAY theseCustomers[i].city     TO record2.city
                    DISPLAY theseCustomers[i].state    TO record2.state
                    DISPLAY theseCustomers[i].zip      TO record2.zip
                    DISPLAY theseCustomers[i].country  TO record2.country
                    DISPLAY theseCustomers[i].langpref TO record2.langpref

                    CALL theseOrders.clear()
                    CALL dialog.deleteAllRows("record3")
                    CALL fillOrderData(theseCustomers[i].userid)
                    FOR j = 1 TO theseOrders.getLength()
                       LET orderlist[j].orderdate  = theseOrders[j].orderdate
                       LET orderlist[j].orderid    = theseOrders[j].orderid
                       LET orderlist[j].totalprice = theseOrders[j].totalprice
                    END FOR 
            END DISPLAY

            DISPLAY ARRAY orderList TO record3.*
                ON ACTION ACCEPT
                    CALL showOrderDetail(orderList[arr_curr()].orderid)
            END DISPLAY

        ON ACTION update
            INPUT 
                theseCustomers[i].addr1,
                theseCustomers[i].addr2,
                theseCustomers[i].city,
                theseCustomers[i].state,
                theseCustomers[i].zip,
                theseCustomers[i].country,
                theseCustomers[i].langpref WITHOUT DEFAULTS FROM 
                record2.addr1,
                record2.addr2,
                record2.city,
                record2.state,
                record2.zip,
                record2.country,
                record2.langpref

            ON ACTION ACCEPT 
                CALL putCustomer(theseCustomers[i].*)
                CONTINUE DIALOG

            ON ACTION CLOSE
                CONTINUE DIALOG 
            END INPUT

        ON ACTION reportprint
                       
        ON ACTION exit
            EXIT DIALOG

        ON ACTION ADD
            CALL theseCustomers.appendElement()
            LET j = theseCustomers.getLength()
            LET theseCustomers[j].userid = "deleteme"
            LET theseCustomers[j].email = "deleteMe@yoowho.com"
            LET theseCustomers[j].firstname = "Youcan"
            LET theseCustomers[j].lastname = "DELETEME"
            LET theseCustomers[j].acstatus = "OK"
            LET theseCustomers[j].addr1 = "123 Easy St"
            LET theseCustomers[j].city = "Anywhere"
            LET theseCustomers[j].state = "FL"
            LET theseCustomers[j].zip = "75038"
            LET theseCustomers[j].country = "USA"
            LET theseCustomers[j].phone = "+1 999 123 4567"
            LET theseCustomers[j].langpref = "English"
            LET theseCustomers[j].favcategory = "SUPPLIES"
            LET theseCustomers[j].mylistopt = "1"
            LET theseCustomers[j].banneropt = "1"
            LET theseCustomers[j].sourceapp = "WEB" 

            CALL postCustomer(theseCustomers[j].*)

        ON ACTION DELETE
            LET i = ARR_CURR()
            LET res = deleteCustomer(theseCustomers[i].userid)
            IF res IS NULL THEN 
                ERROR SFMT("Customer '%1' has been removed", theseCustomers[i].userid CLIPPED)
                CALL theseCustomers.deleteElement(i)
                #CALL DIALOG.deleteROW('record1', i)
                LET i = theseCustomers.getLength()
                
                DISPLAY theseCustomers[i].userid   TO record2.userid
                DISPLAY theseCustomers[i].addr1    TO record2.addr1
                DISPLAY theseCustomers[i].addr2    TO record2.addr2
                DISPLAY theseCustomers[i].city     TO record2.city
                DISPLAY theseCustomers[i].state    TO record2.state
                DISPLAY theseCustomers[i].zip      TO record2.zip
                DISPLAY theseCustomers[i].country  TO record2.country
                DISPLAY theseCustomers[i].langpref TO record2.langpref                
            END IF 
        END DIALOG

    WHEN "list"
        FOR i= 1 TO theseCustomers.getLength()
            DISPLAY "Customer #",i USING "<< ", theseCustomers[i].firstname CLIPPED, " ", theseCustomers[i].lastname CLIPPED
        END FOR

    OTHERWISE
        # call a report function(GRE?...PDF, SVG, HTML)
        CALL report(opt)
    END CASE
    RETURN

END FUNCTION

################################################################################
#
# Method: fillOrderData
#
# Description: Fill order list data array from retrieved order array
#
# Parameters:  opt = display mode(screen, list, PDF)
#
FUNCTION fillOrderData(thisUser)
    DEFINE thisUser   STRING 
    DEFINE thisOrder  util.JSONObject  
    DEFINE i, j   INTEGER

    FOR i = 1 TO ordersJsonObj.getLength()
        LET thisOrder = ordersJsonObj.get(i)
        IF ( thisOrder.get("userid") = thisUser ) THEN
            CALL logger.logEvent(logger._LOGMSG,ARG_VAL(0),SFMT("%1:%2",__FILE__,__LINE__),SFMT("orderstring: %1", thisOrder.toString()))
            LET j=j+1
            CALL thisOrder.toFGL(theseOrders[j])
        END IF 
    END FOR
    RETURN
    
END FUNCTION

################################################################################
#
# Method: showOrderDetail
#
# Description: Show order detail data for selected order
#
# Parameters:  thisOrder = selected order
FUNCTION showOrderDetail(thisOrder)
    DEFINE thisOrder   STRING 
    DEFINE i, j        INTEGER
    DEFINE thisOrderItem  util.JSONObject
    DEFINE orderItemList DYNAMIC ARRAY OF RECORD
       itemid   LIKE lineitem.itemid,
       quantity LIKE lineitem.quantity,
       unitprice LIKE lineitem.unitprice
    END RECORD 

    OPEN FORM f2 FROM "order1"
    DISPLAY FORM f2

    FOR i = 1 TO theseOrders.getLength()
        IF ( theseOrders[i].orderid == thisOrder ) THEN
            DISPLAY BY NAME theseOrders[i].*
            # Make REST call for order items
            EXIT FOR
        END IF
    END FOR

    # Fill order items
    CALL retrieveOrderItems(theseOrders[i].orderid)
    FOR j = 1 TO theseOrderItems.getLength()
       LET orderItemList[j].itemid    = theseOrderItems[j].itemid
       LET orderItemList[j].quantity  = theseOrderItems[j].quantity
       LET orderItemList[j].unitprice = theseOrderItems[j].unitprice
    END FOR 

    # Display order item list
    DISPLAY ARRAY orderItemList TO record2.*
    END DISPLAY 
    
    CLOSE FORM f2
    
    RETURN
    
END FUNCTION

################################################################################
#
# Method: fillOrderItemData
#
# Description: Fill order item list data array from retrieved order item array
#
# Parameters:  NONE
#
FUNCTION fillOrderItemData()
    DEFINE thisUser   STRING 
    DEFINE thisOrder  util.JSONObject  
    DEFINE i, j   INTEGER

    FOR i = 1 TO ordersJsonObj.getLength()
        LET thisOrder = ordersJsonObj.get(i)
        IF ( thisOrder.get("userid") = thisUser ) THEN 
            CALL logger.logEvent(logger._LOGMSG,ARG_VAL(0),SFMT("%1:%2",__FILE__,__LINE__),SFMT("orderstring: %1", thisOrder.toString()))
            LET j=j+1
            CALL thisOrder.toFGL(theseOrders[j])
        END IF 
    END FOR
    RETURN
    
END FUNCTION

################################################################################
#
# Method: consoleLogger()
#
# Description: Redirettion the default logging to the console
#
FUNCTION consoleLogger(logCategory INTEGER, logClass STRING, logEvent STRING, logMessage STRING)
    DISPLAY "Local debugger: "||SFMT(" %1 - [%2] '%3' %4", logCategory, logClass, logEvent, logMessage)
END FUNCTION

################################################################################
#
# Method: report()
#
# Description: Creates a simple report output
#
FUNCTION report(opt)
    DEFINE handler om.SaxDocumentHandler
    DEFINE opt   STRING
    LET handler = configureOutput(opt)
    
    IF handler IS NULL THEN
        EXIT PROGRAM
    END IF

    CALL runReportFromDatabase(HANDLER)
    RETURN
END FUNCTION

################################################################################
#
# Method: configureOutput()
#
# Description: Configures reporting output for GRE
#
FUNCTION configureOutput(opt)
    DEFINE opt  STRING 
    IF NOT fgl_report_loadCurrentSettings(NULL) THEN
        RETURN NULL
    END IF
    --CALL fgl_report_selectLogicalPageMapping("multipage")
    --CALL fgl_report_configureMultipageOutput(2, 4, TRUE)
    --CALL fgl_report_setPageMargins("4.5cm","0.5cm","2.5cm","0.5cm")
    --CALL fgl_report_selectDevice("XLS")
    CALL fgl_report_selectDevice(opt)
    CALL fgl_report_selectPreview(TRUE)
    RETURN fgl_report_commitCurrentSettings()
    
END FUNCTION

################################################################################
#
# Method: getPreviewDevice()
#
# Description: Returns report preview device for GRE
#
FUNCTION getPreviewDevice()
    DEFINE fename String
    CALL ui.interface.frontcall("standard", "feinfo", ["fename"],[fename])
    RETURN iif(fename=="Genero Desktop Client","SVG","PDF")     
END FUNCTION

################################################################################
#
# Method: runReportFromDatabase()
#
# Description: Executes current report from database query
#
FUNCTION runReportFromDatabase(handler)
    DEFINE handler om.SaxDocumentHandler
    DEFINE i  INTEGER
    
    -- The DVM text output is ignored when XML is output
    START REPORT report_all_customers TO XML HANDLER HANDLER
    FOR i = 1 TO theseCustomers.getLength()
        OUTPUT TO REPORT report_all_customers(theseCustomers[i].*)  --> simulate query using current customer array
    END FOR
    FINISH REPORT report_all_customers
    RETURN
    
END FUNCTION

################################################################################
#
# Method: report_all_customers()
#
# Description: Report output 
#
REPORT report_all_customers( accountData )
    DEFINE
        accountData  custType,
        pagenum INTEGER,
        char30  CHAR(30),
        state STRING,
        newGroup SMALLINT

    OUTPUT
        LEFT MARGIN    0
        #RIGHT MARGIN   86
        TOP MARGIN     0
        BOTTOM MARGIN  0
        PAGE LENGTH    66

    FORMAT

    PAGE HEADER
        PRINT "Frist                    Last                      Email                         Phone"
        PRINT "-------------------------------------------------------------------------------------------------------"

    ON EVERY ROW

        PRINT COLUMN 1, accountData.firstname[1, 25], 
              COLUMN 26, accountData.lastname[1, 25], 
              COLUMN 52, accountData.email[1, 25], 
              COLUMN 82, accountData.phone

    ON LAST ROW 
        PRINT "-------------------------------------------------------------------------------------------------------"


END REPORT

################################################################################
#
# Method: errorHandler()
#
# Description:: Standard error function to handle error display
#
FUNCTION errorHandler()
   DISPLAY "STATUS                : ", STATUS using "<<<<&"
   DISPLAY "SQLERRM               : ", SQLCA.SQLERRM
   DISPLAY "SQLCODE               : ", SQLCA.SQLCODE USING "<<<<&"
   DISPLAY "SQLERRM               : ", SQLCA.SQLCODE USING "<<<<&"
   DISPLAY "SQLERRD[2]            : ", SQLCA.SQLERRD[2] USING "<<<<&"
   DISPLAY "SQLERRD[3]            : ", SQLCA.SQLERRD[3] USING "<<<<&"
   DISPLAY "OFFSET TO ERROR IN SQL: ", SQLCA.SQLERRD[5] USING "<<<<&"
   DISPLAY "ROWID FOR LAST INSERT : ", SQLCA.SQLERRD[6] USING "<<<<&"
   DISPLAY "SQLERRMESSAGE         : ", SQLERRMESSAGE
   DISPLAY "SQLSTATE              : ", SQLSTATE USING "<<<<&"
&ifdef APP_LOGGING
   DISPLAY "APPERROR : ", applicationError
&endif
   EXIT PROGRAM 
END FUNCTION

FUNCTION putCustomer(cust_rec custType)
    DEFINE err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code INTEGER,
           obj  util.JSONObject,
           updatePayload STRING

    TRY
         # Create a JSON object with data
         LET obj = util.JSONObject.fromFGL(cust_rec)

         LET req = com.HTTPRequest.Create(_ACCTSERVICE)
         CALL req.setConnectionTimeout(10)
         CALL req.setTimeout(60)
         CALL req.setCharset("UTF-8")

         CALL req.setMethod("PUT")
         CALL req.setHeader("Content-Type","application/json")  --> different for xml request
         LET updatePayload = SFMT("[%1,{}]", obj.toString()) 
         CALL req.doTextRequest(updatePayload)

         LET resp=req.getResponse()
         LET code = resp.getStatusCode()
         IF code>=200 AND code<=299 THEN
            LET result = resp.getTextResponse()
            LET err = NULL
         ELSE
            LET err = SFMT("(%1) : HTTP request status description: %2 ", code, resp.getStatusDescription())
         END IF
     CATCH
        LET err = SFMT("HTTP request error: STATUS=%1 (%2)",STATUS,SQLCA.SQLERRM)
     END TRY

     RETURN
     
END FUNCTION

FUNCTION postCustomer(thisCustomer custType)
    DEFINE err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           obj  util.JSONObject,
           insertPayload STRING,
           code INTEGER
    
    TRY
         # Create a JSON object with data
         LET obj = util.JSONObject.fromFGL(thisCustomer)

         LET req = com.HTTPRequest.Create(_ACCTSERVICE)
         CALL req.setConnectionTimeout(10)
         CALL req.setTimeout(60)
         CALL req.setCharset("UTF-8")

         CALL req.setMethod("POST")
         CALL req.setHeader("Content-Type","application/json")  --> different for xml request
         LET insertPayload = SFMT("[%1,{}]", obj.toString()) 
         CALL req.doTextRequest(insertPayload)

         LET resp=req.getResponse()
         LET code = resp.getStatusCode()
         IF code>=200 AND code<=299 THEN
            LET result = resp.getTextResponse()
            LET err = NULL
         ELSE
            LET err = SFMT("(%1) : HTTP request status description: %2 ", code, resp.getStatusDescription())
         END IF
     CATCH
        LET err = SFMT("HTTP request error: STATUS=%1 (%2)",STATUS,SQLCA.SQLERRM)
     END TRY
END FUNCTION

FUNCTION deleteCustomer(thisCustomer STRING)
    DEFINE resrce, err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code INTEGER

    TRY
         LET resrce = _ACCTSERVICE||"?user="||thisCustomer CLIPPED
         LET req = com.HTTPRequest.Create(resrce)
         CALL req.setConnectionTimeout(10)
         CALL req.setTimeout(60)
         CALL req.setCharset("UTF-8")

         CALL req.setMethod("DELETE")
         CALL req.setHeader("Content-Type","application/json")  --> different for xml request
         CALL req.doRequest()

         LET resp=req.getResponse()
         LET code = resp.getStatusCode()
         IF code>=200 AND code<=299 THEN
            LET result = resp.getTextResponse()
            LET err = NULL
         ELSE
            LET err = SFMT("(%1) : HTTP request status description: %2 ", code, resp.getStatusDescription())
         END IF
     CATCH
        LET err = SFMT("HTTP request error: STATUS=%1 (%2)",STATUS,SQLCA.SQLERRM)
     END TRY

     RETURN err
     
END FUNCTION 
