SCHEMA officestore

##############################################################################
#+
#+ CLASS "orders" record types:
#+ - Complete table list
#+ - Include for types associated with the "orders" object
#+

#
# Standard SQL statement CONSTANTs
#
CONSTANT _SELECTSQL = "SELECT * FROM orders WHERE 1=1"
CONSTANT _UPDATESQL = "UPDATE orders SET billfirstname = ?, billlastname = ? WHERE orderid = ?" 
CONSTANT _INSERTSQL = "INSERT INTO orders VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
CONSTANT _DELETESQL = "DELETE FROM orders WHERE orderid = ?"

#
# User type definitions
#
TYPE recordType RECORD LIKE orders.*