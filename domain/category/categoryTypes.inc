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
#+ CLASS "category" record types:
#+ - Complete table list
#+ - Include for types associated with the "category" object
#+

#
# Standard SQL statement CONSTANTs
#
CONSTANT _SELECTSQL = "SELECT * FROM category WHERE 1=1"
CONSTANT _UPDATESQL = "UPDATE category SET catdesc = ? WHERE catid = ?" 
CONSTANT _INSERTSQL = "INSERT INTO category VALUES (?, ?, ?, ?, ?)"
CONSTANT _DELETESQL = "DELETE FROM category WHERE catid = ?"

#
# User type definitions
#
TYPE recordType RECORD LIKE category.*
