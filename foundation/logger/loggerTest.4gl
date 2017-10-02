IMPORT FGL logger
MAIN

    # Initialize default logging
    CALL logger.initializelog("DEBUG", "./", "test.log")

    # Use default logger(log to file)
    CALL logger.logEvent(_LOGDEBUG, "ERROR", "Log success", "Default logging message")

    # Register and use local logger
    CALL logger.setLoggerFunction(FUNCTION localLogger)
    CALL logger.logEvent(_LOGDEBUG, "STATUS", "Log success", "Local logging message") 
    
END MAIN 

FUNCTION localLogger(logCategory INTEGER, logClass STRING, logEvent STRING, logMessage STRING)
    DISPLAY "Using local: "||SFMT("DEBUG  : %1 - [%2] '%3' %4", logCategory, logClass, logEvent, logMessage)
END FUNCTION