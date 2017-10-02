IMPORT util
IMPORT FGL orderItem


MAIN
    DEFINE rt INTEGER 
    DATABASE officestore

    WHENEVER ANY ERROR CONTINUE

    # Query test
    TRY
        CALL orderItem.setQueryID("2")
        CALL orderItem.getRecords()
    CATCH
        DISPLAY SFMT("QUERY of orderid '%1' has failed: %3: %4", mRecords[1].orderid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 

    # JSON encoding
    DISPLAY SFMT("QUERY JSONEncoding: %1", orderItem.getJSONEncoding())

    # Update test
    TRY 
        CALL orderItem.setQueryID("2")
        LET mRecords[2].unitprice  = 14.90
        
        CALL processRecordsUpdate(orderItem.getJSONEncoding()) RETURNING rt
        CALL orderItem.getRecords()
        DISPLAY SFMT("UPDATE JSONEncoding: %1", orderItem.getJSONEncoding())

        LET mRecords[2].unitprice  = 1490.00
        CALL processRecordsUpdate(orderItem.getJSONEncoding()) RETURNING rt
        CALL orderItem.getRecords()
        DISPLAY SFMT("UPDATE2 JSONEncoding: %1", orderItem.getJSONEncoding())
    CATCH
        DISPLAY SFMT("UPDATE of orderid '%1' linenum '%2' has failed: %3: %4", mRecords[2].orderid CLIPPED, mRecords[2].linenum, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY

    # Insert test
    TRY
        CALL orderItem.init()
        LET mRecords[1].orderid     = "8"
        LET mRecords[1].linenum     = "13" --> must preserve referencial integrity with product table
        LET mRecords[1].itemid      = "SU-009-A"
        LET mRecords[1].unitprice   = "1.00"
        LET mRecords[1].quantity    = "1"      

        CALL processRecordsInsert(orderItem.getJSONEncoding()) RETURNING rt
        CALL orderItem.setQueryID("8")
        CALL orderItem.getRecords()
        DISPLAY SFMT("INSERT JSONEncoding: %1", orderItem.getJSONEncoding())
    CATCH
        DISPLAY SFMT("INSERT of orderid '%1' has failed: %3: %4", mRecords[1].orderid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # Delete test
    TRY 
        DISPLAY SFMT("Deleting record: order %1 line %2", "8", "13")
        CALL orderItem.init()
        LET mRecords[1].orderid     = "8"
        LET mRecords[1].linenum     = "13" --> must preserve referencial integrity with product table
        CALL processRecordsDelete(orderItem.getJSONEncoding()) RETURNING rt
        CALL orderItem.setQueryid("8")
        CALL orderItem.getRecords()
        DISPLAY SFMT("JSONEncoding: %1 <-- orderid 8 linenum 13 should be missing after the delete of the inserted record", orderItem.getJSONEncoding())
    CATCH 
        DISPLAY SFMT("DELETE of orderid '%1' linenum '%2' has failed: %3: %4", mRecords[1].orderid CLIPPED, mRecords[1].linenum, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 
END MAIN
