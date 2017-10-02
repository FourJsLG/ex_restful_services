SCHEMA officestore

##############################################################################
#+
#+ CLASS "item" record types:
#+ - Complete table list
#+ - Include for types associated with the "item" object
#+

#
# Standard SQL statement CONSTANTs
#
CONSTANT _SELECTSQL = "SELECT * FROM item WHERE 1=1"
CONSTANT _UPDATESQL = "UPDATE item SET unitcost = ? WHERE itemid = ?" 
CONSTANT _INSERTSQL = "INSERT INTO item VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
CONSTANT _DELETESQL = "DELETE FROM item WHERE itemid = ?"

#
# User type definitions
#
TYPE recordType RECORD LIKE item.*
