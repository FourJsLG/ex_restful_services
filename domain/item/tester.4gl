IMPORT util
IMPORT FGL item


MAIN
    DEFINE rt INTEGER 
    DATABASE officestore

    WHENEVER ANY ERROR CONTINUE

    # Query test
    TRY
        CALL item.setQueryID("AR-001-A")
        CALL item.getRecords()
    CATCH
        DISPLAY SFMT("QUERY of item '%1' has failed: %2: %3", mRecords[1].itemid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 

    # JSON encoding
    DISPLAY SFMT("QUERY JSONEncoding: %1", item.getJSONEncoding())

    # Update test
    TRY 
        LET mRecords[1].unitcost  = 100.00
        
        CALL processRecordsUpdate(item.getJSONEncoding()) RETURNING rt
        CALL item.getRecords()
        DISPLAY SFMT("UPDATE JSONEncoding: %1", item.getJSONEncoding())

        LET mRecords[1].unitcost  = 0.00
        CALL processRecordsUpdate(item.getJSONEncoding()) RETURNING rt
        CALL item.getRecords()
        DISPLAY SFMT("UPDATE2 JSONEncoding: %1", item.getJSONEncoding())
    CATCH
        DISPLAY SFMT("UPDATE of item '%1' has failed: %2: %3", mRecords[1].itemid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY

    # Insert test
    TRY
        CALL item.init()
        LET mRecords[1].itemid      = "FO-001-A"
        LET mRecords[1].productid   = "AR-001" --> must preserve referencial integrity with product table
        LET mRecords[1].listprice   = 1000000
        LET mRecords[1].unitcost    = "0.00"
        LET mRecords[1].supplier    = "1"
        LET mRecords[1].itstatus    = "P"
        LET mRecords[1].attr1       = "unit"
        

        CALL processRecordsInsert(item.getJSONEncoding()) RETURNING rt
        CALL item.setQueryID("FO-001-A")
        CALL item.getRecords()
        DISPLAY SFMT("INSERT JSONEncoding: %1", item.getJSONEncoding())
    CATCH
        DISPLAY SFMT("INSERT of item '%1' has failed: %2: %3", mRecords[1].itemid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # Delete test
    TRY 
        DISPLAY SFMT("Deleting record: %1", "FO-001-A")
        CALL item.init()
        LET mRecords[1].itemid = "FO-001-A"
        CALL processRecordsDelete(item.getJSONEncoding()) RETURNING rt
        CALL item.setQueryid("FO-001-A")
        CALL item.getRecords()
        DISPLAY SFMT("JSONEncoding: %1 <-- Should be the empty set '{}' after the delete of the inserted record", item.getJSONEncoding())
    CATCH 
        DISPLAY SFMT("DELETE of item '%1' has failed: %2: %3", mRecords[1].itemid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 
END MAIN
