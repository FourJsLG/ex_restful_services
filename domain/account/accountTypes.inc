################################################################################
#
# FOURJS_START_COPYRIGHT(U,2015)
# Property of Four Js*
# (c) Copyright Four Js 2015, 2017. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these samples
# are accurate and suitable for your purposes. Their inclusion is purely for
# information purposes only.
# FOURJS_END_COPYRIGHT
#
SCHEMA officestore

##############################################################################
#+
#+ CLASS "account" record types:
#+ - Complete table list
#+ - Include for types associated with the "account" object
#+

#
# Standard SQL statement CONSTANTs
#
CONSTANT _SELECTSQL = "SELECT * FROM account WHERE 1=1"
CONSTANT _UPDATESQL = "UPDATE account SET firstname = ?, lastname = ? WHERE userid = ?" 
CONSTANT _INSERTSQL = "INSERT INTO account VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
CONSTANT _DELETESQL = "DELETE FROM account WHERE userid = ?"

#
# User type definitions
#
TYPE recordType RECORD LIKE account.*
