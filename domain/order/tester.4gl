IMPORT util
IMPORT FGL order


MAIN
    DEFINE rt INTEGER 
    DATABASE officestore

    WHENEVER ANY ERROR CONTINUE

    # Query test
    TRY
        CALL order.setQueryID("1")
        CALL order.getRecords()
    CATCH
        DISPLAY SFMT("QUERY of order '%1' has failed: %2: %3", mRecords[1].orderid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 

    # JSON encoding
    DISPLAY SFMT("QUERY JSONEncoding: %1", order.getJSONEncoding())

    # Update test
    TRY 
        LET mRecords[1].billfirstname  = "Four Js, Inc"
        
        CALL processRecordsUpdate(order.getJSONEncoding()) RETURNING rt
        CALL order.getRecords()
        DISPLAY SFMT("UPDATE JSONEncoding: %1", order.getJSONEncoding())

        LET mRecords[1].billfirstname  = "Jean"
        CALL processRecordsUpdate(order.getJSONEncoding()) RETURNING rt
        CALL order.getRecords()
        DISPLAY SFMT("UPDATE2 JSONEncoding: %1", order.getJSONEncoding())
    CATCH
        DISPLAY SFMT("UPDATE of order '%1' has failed: %2: %3", mRecords[1].orderid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY

    # Insert test
    TRY
        CALL order.init()
        LET mRecords[1].orderid       = "10"
        LET mRecords[1].userid        = "dupont"
        LET mRecords[1].orderdate     = 1000000
        LET mRecords[1].shipfirstname = "Teq"
        LET mRecords[1].shiplastname  = "SUPPORT"
        LET mRecords[1].shipaddr1     = "123 Easy Street"
        LET mRecords[1].shipaddr2     = ""
        LET mRecords[1].shipcity      = "Irving"
        LET mRecords[1].shipstate     = "TX"
        LET mRecords[1].shipcountry   = "USA"
        LET mRecords[1].shipzip       = "75038"
        LET mRecords[1].billfirstname = "Teq"
        LET mRecords[1].billlastname  = "SUPPORT"
        LET mRecords[1].billaddr1     = "123 Easy Street"
        LET mRecords[1].billaddr2     = ""
        LET mRecords[1].billcity      = "Irving"
        LET mRecords[1].billstate     = "TX"
        LET mRecords[1].billcountry   = "USA"
        LET mRecords[1].billzip       = "75038"
        LET mRecords[1].totalprice    = 1
        LET mRecords[1].sourceapp     = "MTC"
        
        CALL processRecordsInsert(order.getJSONEncoding()) RETURNING rt
        CALL order.setQueryID("10")
        CALL order.getRecords()
        DISPLAY SFMT("INSERT JSONEncoding: %1", order.getJSONEncoding())
    CATCH
        DISPLAY SFMT("INSERT of order '%1' has failed: %2: %3", mRecords[1].orderid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE )
    END TRY
    
    # Delete test
    TRY 
        DISPLAY SFMT("Deleting record: %1", "10")
        CALL order.init()
        LET mRecords[1].orderid = "10"
        CALL processRecordsDelete(order.getJSONEncoding()) RETURNING rt
        CALL order.setQueryid("10")
        CALL order.getRecords()
        DISPLAY SFMT("JSONEncoding: %1 <-- Should be the empty set '{}' after the delete of the inserted record", order.getJSONEncoding())
    CATCH 
        DISPLAY SFMT("DELETE of order '%1' has failed: %2: %3", mRecords[1].orderid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 
END MAIN
