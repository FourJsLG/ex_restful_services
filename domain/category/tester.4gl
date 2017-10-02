IMPORT util
IMPORT FGL category


MAIN
    DEFINE rt INTEGER 
    DATABASE officestore

    WHENEVER ANY ERROR CONTINUE

    # Query test
    TRY
        CALL category.setQueryID("ART")
        CALL category.getRecords()
    CATCH
        DISPLAY SFMT("QUERY of category '%1' has failed: %2: %3", mRecords[1].catid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 

    # JSON encoding
    DISPLAY SFMT("QUERY JSONEncoding: %1", category.getJSONEncoding())

    # Update test
    TRY 
        LET mRecords[1].catdesc  = "Totally unrecognizable"
        
        CALL processRecordsUpdate(category.getJSONEncoding()) RETURNING rt
        CALL category.getRecords()
        DISPLAY SFMT("UPDATE JSONEncoding: %1", category.getJSONEncoding())

        LET mRecords[1].catdesc  = ""
        CALL processRecordsUpdate(category.getJSONEncoding()) RETURNING rt
        CALL category.getRecords()
        DISPLAY SFMT("UPDATE2 JSONEncoding: %1", category.getJSONEncoding())
    CATCH
        DISPLAY SFMT("UPDATE of category '%1' has failed: %2: %3", mRecords[1].catid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY

    # Insert test
    TRY
        CALL category.init()
        LET mRecords[1].catid      = "foobar"
        LET mRecords[1].catname    = "FOOBAR"
        LET mRecords[1].catdesc    = "Totally unrecognizable"
        LET mRecords[1].catorder   = "6"
        LET mRecords[1].catpic     = "foo-bar.ico"

        CALL processRecordsInsert(category.getJSONEncoding()) RETURNING rt
        CALL category.setQueryID("foobar")
        CALL category.getRecords()
        DISPLAY SFMT("INSERT JSONEncoding: %1", category.getJSONEncoding())
    CATCH
        DISPLAY SFMT("INSERT of category '%1' has failed: %2: %3", mRecords[1].catid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # Delete test
    TRY 
        DISPLAY SFMT("Deleting record: %1", "foobar")
        CALL category.init()
        LET mRecords[1].catid     = "foobar"
        CALL processRecordsDelete(category.getJSONEncoding()) RETURNING rt

        CALL category.setQueryid("foobar")
        CALL category.getRecords()
        DISPLAY SFMT("JSONEncoding: %1 <-- Should be the empty set '{}' after the delete of the inserted record", category.getJSONEncoding())
    CATCH 
        DISPLAY SFMT("DELETE of category '%1' has failed: %2: %3", mRecords[1].catid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 
END MAIN
