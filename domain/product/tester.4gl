IMPORT util
IMPORT FGL product

MAIN
    DEFINE rt INTEGER 
    DATABASE officestore

    WHENEVER ANY ERROR CONTINUE

    # Query test
    TRY
        CALL product.setQueryID("AR-001")
        CALL product.getRecords()
    CATCH 
        DISPLAY SFMT("QUERY of order '%1' has failed: %2: %3", mRecords[1].productid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # JSON encoding
    DISPLAY SFMT("QUERY JSONEncoding: %1", product.getJSONEncoding())

    # Update test
    TRY
        LET mRecords[1].prodname = "UPDATED fossil"
        CALL processRecordsUpdate(product.getJSONEncoding()) RETURNING rt
        CALL product.getRecords()
        DISPLAY SFMT("UPDATE JSONEncoding: %1", product.getJSONEncoding())

        LET mRecords[1].prodname = "Ammonite fossil"
        CALL processRecordsUpdate(product.getJSONEncoding()) RETURNING rt
        CALL product.getRecords()
        DISPLAY SFMT("UPDATE2 JSONEncoding: %1", product.getJSONEncoding())
    CATCH
        DISPLAY SFMT("UPDATE of product '%1' has failed: %2: %3", mRecords[1].productid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # Insert test
    TRY 
    CALL product.init()
        LET mRecords[1].productid = "FOO-001"
        LET mRecords[1].catid     = "ART"
        LET mRecords[1].prodname  = "Foo stuff"
        LET mRecords[1].proddesc  = "Totally Un-recognizable"
        LET mRecords[1].prodpic   = "art/foo-bar.jpg"

        CALL processRecordsInsert(product.getJSONEncoding()) RETURNING rt
        CALL product.setQueryID("FOO-001")
        CALL product.getRecords()
        DISPLAY SFMT("INSERT JSONEncoding: %1", product.getJSONEncoding())
    CATCH
        DISPLAY SFMT("INSERT of product '%1' has failed: %2: %3", mRecords[1].productid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # Delete test
    TRY 
        DISPLAY SFMT("Deleting record: %1", "FOO-001")
        CALL product.init()
        LET mRecords[1].productid = "FOO-001"
        CALL processRecordsDelete(product.getJSONEncoding()) RETURNING rt
        CALL product.setQueryid("FOO-001")
        CALL product.getRecords()
        DISPLAY SFMT("JSONEncoding: %1 <-- Should be the empty set '{}' after the delete of the inserted record", product.getJSONEncoding())
    CATCH
        DISPLAY SFMT("DELETE of product '%1' has failed: %2: %3", mRecords[1].productid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 
END MAIN
