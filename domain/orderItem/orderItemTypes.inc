SCHEMA officestore

##############################################################################
#+
#+ CLASS "lineitem" record types:
#+ - Complete table list
#+ - Include for types associated with the "lineitem" object
#+

#
# Standard SQL statement CONSTANTs
#
CONSTANT _SELECTSQL = "SELECT * FROM lineitem WHERE 1=1"
CONSTANT _UPDATESQL = "UPDATE lineitem SET unitprice = ? WHERE orderid = ? and linenum = ?" 
CONSTANT _INSERTSQL = "INSERT INTO lineitem VALUES (?, ?, ?, ?, ?)"
CONSTANT _DELETESQL = "DELETE FROM lineitem WHERE orderid = ? and linenum = ?"

#
# User type definitions
#
TYPE recordType RECORD LIKE lineitem.*
