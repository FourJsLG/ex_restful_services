IMPORT util
IMPORT FGL account


MAIN
    DEFINE rt INTEGER 
    DATABASE officestore

    WHENEVER ANY ERROR CONTINUE

    # Query test
    TRY
        CALL account.setQueryID("bloggs")
        CALL account.getRecords()
    CATCH
        DISPLAY SFMT("QUERY of account '%1' has failed: %2: %3", mRecords[1].userid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 

    # JSON encoding
    DISPLAY SFMT("QUERY JSONEncoding: %1", account.getJSONEncoding())

    # Update test
    TRY 
        LET mRecords[1].firstname  = "Teq"
        LET mRecords[1].lastname   = "Supp"
        
        CALL processRecordsUpdate(account.getJSONEncoding()) RETURNING rt
        CALL account.getRecords()
        DISPLAY SFMT("UPDATE JSONEncoding: %1", account.getJSONEncoding())

        LET mRecords[1].firstname  = "Fred"
        LET mRecords[1].lastname   = "Bloggs"
        CALL processRecordsUpdate(account.getJSONEncoding()) RETURNING rt
        CALL account.getRecords()
        DISPLAY SFMT("UPDATE2 JSONEncoding: %1", account.getJSONEncoding())
    CATCH
        DISPLAY SFMT("UPDATE of account '%1' has failed: %2: %3", mRecords[1].userid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY

    # Insert test
    TRY
        CALL account.init()
        LET mRecords[1].userid      = "teqsupp"
        LET mRecords[1].email       = "teq@supp.com" 
        LET mRecords[1].firstname   = "Teq"
        LET mRecords[1].lastname    = "Supp"
        LET mRecords[1].acstatus    = "OK"
        LET mRecords[1].addr1       = "123 Easy Street"
        LET mRecords[1].city        = "Anywhere"
        LET mRecords[1].state       = "Restful"
        LET mRecords[1].country     = "USA"
        LET mRecords[1].zip         = "00000-0000"
        LET mRecords[1].phone       = "COCONUT EXPRESS"
        LET mRecords[1].favcategory = "SUPPLIES"
        LET mRecords[1].langpref    = "Piglat"
        LET mRecords[1].mylistopt   = 1
        LET mRecords[1].banneropt   = 1
        LET mRecords[1].sourceapp   = "WEB"
        
        CALL processRecordsInsert(account.getJSONEncoding()) RETURNING rt
        CALL account.setQueryID("teqsupp")
        CALL account.getRecords()
        DISPLAY SFMT("INSERT JSONEncoding: %1", account.getJSONEncoding())
    CATCH
        DISPLAY SFMT("INSERT of account '%1' has failed: %2: %3", mRecords[1].userid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY
    
    # Delete test
    TRY 
        DISPLAY SFMT("Deleting record: %1", "teqsupp")
        CALL account.init()
        LET mRecords[1].userid     = "teqsupp"
        CALL processRecordsDelete(account.getJSONEncoding()) RETURNING rt
        CALL account.setQueryid("teqsupp")
        CALL account.getRecords()
        DISPLAY SFMT("JSONEncoding: %1 <-- Should be the empty set '{}' after the delete of the inserted record", account.getJSONEncoding())
    CATCH 
        DISPLAY SFMT("DELETE of account '%1' has failed: %2: %3", mRecords[1].userid CLIPPED, SQLCA.sqlcode, SQLERRMESSAGE)
    END TRY 
END MAIN
