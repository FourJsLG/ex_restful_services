IMPORT util
IMPORT FGL supplier


MAIN
    DEFINE rt INTEGER 
    DATABASE officestore

    WHENEVER ANY ERROR CONTINUE

    # Query test
    TRY
        CALL supplier.setQueryID("1")
        CALL supplier.getRecords()
    CATCH
        DISPLAY SFMT("QUERY of supplier '%1' has failed: %2: %3", mRecords[1].suppid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # JSON encoding
    DISPLAY SFMT("QUERY JSONEncoding: %1", supplier.getJSONEncoding())

    # Update test
    TRY 
        LET mRecords[1].name  = "TEQ-SUP"
        
        CALL processRecordsUpdate(supplier.getJSONEncoding()) RETURNING rt
        CALL supplier.getRecords()
        DISPLAY SFMT("UPDATE JSONEncoding: %1", supplier.getJSONEncoding())

        LET mRecords[1].name  = "ABC Office Store"
        CALL processRecordsUpdate(supplier.getJSONEncoding()) RETURNING rt
        CALL supplier.getRecords()
        DISPLAY SFMT("UPDATE2 JSONEncoding: %1", supplier.getJSONEncoding())
    CATCH
        DISPLAY SFMT("UPDATE of supplier '%1' has failed: %2: %3", mRecords[1].suppid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY

    # Insert test
    TRY
        CALL supplier.init()
        LET mRecords[1].suppid      = "3"
        LET mRecords[1].NAME        = "TEQ-SUP"
        LET mRecords[1].sustatus    = "AC"
        LET mRecords[1].addr1       = "123 Easy Street"
        LET mRecords[1].city        = "Anywhere"
        LET mRecords[1].state       = "XX"
        LET mRecords[1].zip         = "90210"
        LET mRecords[1].phone       = "999-555-1212"

        CALL processRecordsInsert(supplier.getJSONEncoding()) RETURNING rt
        CALL supplier.setQueryID("3")
        CALL supplier.getRecords()
        DISPLAY SFMT("INSERT JSONEncoding: %1", supplier.getJSONEncoding())
    CATCH
        DISPLAY SFMT("INSERT of supplier '%1' has failed: %2: %3", mRecords[1].suppid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # Delete test
    TRY 
        DISPLAY SFMT("Deleting record: %1", "3")
        CALL supplier.init()
        LET mRecords[1].suppid = "3"
        CALL processRecordsDelete(supplier.getJSONEncoding()) RETURNING rt

        CALL supplier.setQueryid("3")
        CALL supplier.getRecords()
        DISPLAY SFMT("JSONEncoding: %1 <-- Should be the empty set '{}' after the delete of the inserted record", supplier.getJSONEncoding())
    CATCH 
        DISPLAY SFMT("DELETE of supplier '%1' has failed: %2: %3", mRecords[1].suppid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
END MAIN
