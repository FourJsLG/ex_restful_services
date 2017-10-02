SCHEMA officestore

##############################################################################
#
# CLASS "product" record types:
# - Complete table list
# - Include for types associated with the "product" object
#

#
# Standard SQL statement CONSTANTs
#
CONSTANT _SELECTSQL = "SELECT * FROM product WHERE 1=1"
CONSTANT _UPDATESQL = "UPDATE product SET prodname = ?, proddesc = ? WHERE productid = ?" 
CONSTANT _INSERTSQL = "INSERT INTO product VALUES (?, ?, ?, ?, ?)"
CONSTANT _DELETESQL = "DELETE FROM product WHERE productid = ?"

#
# User type definitions
#
TYPE recordType RECORD LIKE product.*
