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

#+  Generic Logging Library
#+  - Create Log file if doesn't exist
#+  - Adds simple practical info with type (Error, Message, ...)
#+

IMPORT com
IMPORT xml
IMPORT os

PUBLIC CONSTANT _LOGERROR      = 1
PUBLIC CONSTANT _LOGDEBUG      = 2
PUBLIC CONSTANT _LOGMSG        = 3
PUBLIC CONSTANT _LOGACCESS     = 4
PUBLIC CONSTANT _LOGSQLERROR   = 5

PRIVATE DEFINE mPid  INTEGER
PRIVATE DEFINE mLevel STRING 

# Logger function type definition
TYPE loggerType FUNCTION(logCategory INTEGER, logClass STRING, logEvent STRING, logMessage STRING)
# Logger function reference
PUBLIC DEFINE loggerFunction loggerType

# Register logger function
PUBLIC FUNCTION setLoggerFunction(functionName loggerType)
    LET loggerFunction = functionName
END FUNCTION

# BUG:FGL-4665 This is a temporary workaround for 
PUBLIC FUNCTION logEvent(logCategory INTEGER, logClass STRING, logEvent STRING, logMessage STRING)
    CALL loggerFunction(logCategory, logClass, logEvent, logMessage)
END FUNCTION

################################################################################
#+ Checks path recursively
#+
#+ @code
#+ IF NOT checkPath(fullpath) THEN
#+
#+ @param path:STRING path to check
#+
#+ @returnType BOOLEAN
#+ @return os.Path.mkdir(path) If path exists or not and is valid
#+
PRIVATE FUNCTION checkPath(path STRING)
    DEFINE directoryName STRING, returnCode INTEGER

    # Check if path exists
    LET returnCode = os.Path.exists(path)

    # Check directory name
    IF returnCode = FALSE THEN
        LET directoryName = os.Path.dirname(path)

        IF directoryName == path THEN
          LET returnCode = TRUE # no dirname to extract anymore
        END IF    
    END IF

    # Recursively check directory name
    IF returnCode = FALSE THEN
        IF NOT checkPath(directoryName) THEN
           LET returnCode = TRUE
        END IF
    END IF 

    # If path doesn't exist, create it
    IF returnCode = FALSE THEN
       LET returnCode = os.Path.mkdir(path)
    END IF

    RETURN returnCode
END FUNCTION

################################################################################
#+
#+ Start log file and set logging function reference
#+
#+ @code
#+ CALL logs.initializeLog("DEBUG",".","RESTServer.log")  
#+
#+ @param thisLevel:STRING  debug level
#+ @param thisPath:STRING   valid path where log needs to be created (or if exist, logs need to be added to)
#+ @param thisFile:STRING   logfile name
#+
#+ @returnType
#+ @return NONE
#+
PUBLIC FUNCTION initializeLog(logLevel STRING, logPath STRING, logFile STRING)
    DEFINE  fullPath  STRING

    LET mPid   = fgl_getpid()
    CASE logLevel
    WHEN ( _LOGDEBUG )
        LET mLevel = "DEBUG"
    WHEN ( _LOGMSG )
        LET mLevel = "MSG"
    WHEN ( _LOGERROR )
        LET mLevel = "ERROR"
    END CASE

    IF logPath IS NOT NULL THEN
        LET fullPath = logPath || "/log"
        IF NOT checkPath(fullPath) THEN
            DISPLAY "ERROR: Unable to create log file in ",fullPath
            EXIT PROGRAM(1)
        END IF
        CALL startlog(fullPath||"/"||logFile)
    ELSE
        CALL startlog(logFile)
    END IF

    # Register default event logger
    CALL setLoggerFunction(FUNCTION defaultLogger)
    CALL errorLog(SFMT("MSG  : %1 - [Logs] 'INIT' done", mPid))

    RETURN
END FUNCTION

################################################################################
#+ 
#+ Default event logger function used by function reference pointer
#+
#+ @code
#+ CALL setLoggerFunction(FUNCTION defaultLogger)
#+ CALL logger.logEvent(logger._LOGMSG,"Server","Main","Started")
#+
#+ @param logCategory:INTEGER  LOG category
#+                    By default : _LOGERROR and _LOGACCESS messages are logged
#+                       _LOGMSG : logs messages
#+                     _LOGDEBUG : logs everything
#+
#+ @param logClass:STRING   library/4gl module name
#+ @param logEvent:STRING   function name
#+ @param logMessage:STRING additional log message
#+
#+ @returnType
#+ @return NONE
#+
PRIVATE FUNCTION defaultLogger(logCategory INTEGER, logClass STRING, logEvent STRING, logMessage STRING)

    # Indicate the message was NULL
    IF logMessage IS NULL THEN LET logMessage = "(null)" END IF

    CASE logCategory

    WHEN _LOGERROR
        CALL errorLog(SFMT("ERROR  : %1 - [%2] '%3' %4", mPid, logClass, logEvent, logMessage))

    WHEN _LOGDEBUG
        IF mLevel=="DEBUG" THEN
            CALL errorLog(SFMT("DEBUG  : %1 - [%2] '%3' %4", mPid, logClass, logEvent, logMessage))
        END IF
        
    WHEN _LOGSQLERROR
        CALL errorLog(SFMT("SQLERR  : %1 - [%2] '%3' %4", mPid, logClass, logEvent, logMessage))  
        
    WHEN _LOGMSG
        IF mLevel=="MSG" OR mLevel=="DEBUG" THEN 
            CALL errorLog(SFMT("MSGLOG  : %1 - [%2] '%3' %4", mPid, logClass, logEvent, logMessage))
        END IF
        
    WHEN _LOGACCESS
        CALL errorLog(SFMT("ACCESS  : %1 - [%2] '%3' %4", mPid, logClass, logEvent, logMessage))
            
    OTHERWISE
    
    END CASE 
  
    RETURN
END FUNCTION
