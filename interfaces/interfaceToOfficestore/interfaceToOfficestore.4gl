###############################################################################
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
IMPORT util 
IMPORT FGL orderItem

DEFINE wrappedResponse RECORD
    code    INTEGER, # HTTP response code
    status  STRING,  # success, fail, or error
    message STRING,  # used for fail or error message
    data    STRING   # response body or error/fail cause or exception name
END RECORD 
################################################################################
#+
#+ Method: processQuery(request com.httpServiceRequest)
#+
#+ Description: Performs tasks to retrieve information, 1 or 1,000,000
#+
#+ Return: status          : HTTP status code
#+         wrappedResponse : JSON encoded string   
#+
FUNCTION processQuery(queryFilter STRING)
    DEFINE thisJSONArr  util.JSONArray
    DEFINE i, queryException INTEGER

    DEFINE query DYNAMIC ARRAY OF RECORD
          name STRING,
          value  STRING
    END RECORD

    WHENEVER ANY ERROR RAISE
    TRY
        LET thisJSONArr = util.JSONArray.parse(queryFilter)
        CALL thisJSONArr.toFGL(query)

        # Set the query filter values
        CALL orderItem.initQuery()
        FOR i = 1 TO query.getLength()
            CASE query[i].NAME
            WHEN "ordernum"
                CALL orderItem.setQueryID(query[i].value)
            OTHERWISE
                # Handle unkown/bad parameters
                LET wrappedResponse.code    = 400
                LET wrappedResponse.status  = "ERROR"
                LET wrappedResponse.message = "unkown/bad parameters"
                LET wrappedResponse.data    = queryFilter
                LET queryException = TRUE
            END CASE 
        END FOR

        IF NOT queryException THEN
            # Execute resource query
            CALL orderItem.getRecords()

            # Set response data
            LET wrappedResponse.data = orderItem.getJSONEncoding()
            LET wrappedResponse.code = 200
            LET wrappedResponse.status = "SUCCESS"
        END IF
        
    CATCH
        # Return some kind of error: must use STATUS before it is reset by next code statment
        LET wrappedResponse.data    = SFMT("%1: %2", STATUS, err_get(STATUS))
        LET wrappedResponse.code    = 500
        LET wrappedResponse.status  = "ERROR"
        LET wrappedResponse.message = "resource query failed"
        
    END TRY

    RETURN wrappedResponse.code, util.JSON.stringify(wrappedResponse)

END FUNCTION 
