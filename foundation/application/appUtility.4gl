################################################################################
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

#+  Application Foundation Library
#+  - initialize() : boiler plate application initialization
#+  - programExit() : standardized program exit point
#+
IMPORT FGL logger

################################################################################
#+ Initializes applictaion at startup by conecting to the database
#+
#+ @code
#+ CALL application.initialize()
#+
#+ @param  NONE
#+
#+ @return NONE
#+
FUNCTION initialize()
    DEFINE debugLevel INTEGER
    
    WHENEVER ANY ERROR RAISE -- Let the application handle initialization failures

    # Initialize the logging file and connect to the database 
    # Check APPDEBUG for logging : _LOGMSG:3 is default; otherwise _LOGERROR:1, _LOGDEBUG:2, _LOGACCESS:4, _LOGSQLERROR:5
    LET debugLevel = IIF ( fgl_getenv("APPDEBUG"), fgl_getenv("APPDEBUG"), logger._LOGMSG) 
    CALL logger.initializeLog(debugLevel,".","RESTServer.log")  

    # Connect to the database
    IF ( fgl_getenv("FGLDBNAME") IS NOT NULL ) THEN
        CONNECT TO fgl_getenv("FGLDBNAME")
    ELSE
        CALL logger.logEvent(logger._LOGMSG,ARG_VAL(0),SFMT("%1:%2",__FILE__,__LINE__), "Application database(FGLDBNAME) is not specified.")
        CALL programExit(1)
    END IF 
    
END FUNCTION 

################################################################################
#+ Disconnect from database and gracefully exits application 
#+
#+ @code
#+ CALL programExit(exitCode)
#+
#+ @param  exitCode : INTEGER value 0=normal;1=fault
#+
#+ @return NONE
#+
FUNCTION programExit(stat INTEGER)
    WHENEVER ANY ERROR CONTINUE 
    DISCONNECT CURRENT
    EXIT PROGRAM stat
END FUNCTION

