public class AMS_ErrorLogger{

    public class AMSException extends Exception {
    }
    
    static List<AMS_Error_Log__c> errorLogs = new List<AMS_Error_Log__c>();
    
    public static void logMessage(String Operation, 
                                  	String fields, 
                                  	String statusCode, 
                                  	String errorMsg, 
                                  	String stackTrace) {
                                                       	
        //This if block ensures that INSERT that we are doing shouldn't disturb the GOVERNOR LIMITS
		//and hence prevent the other Business Logic from execution.
    	if ((Limits.getDMLRows() < Limits.getLimitDMLRows()) && 
            (Limits.getDMLStatements() < Limits.getLimitDMLStatements())){              
      		AMS_Error_Log__c errorLog = new AMS_Error_Log__c(
      										Operation__c = Operation,
      										Fields__c = fields,
      										Status_Code__c = statusCode,
      										Error_Message__c = errorMsg,
      										Stack_Trace__c = stackTrace);
     		errorLogs.add(errorLog);
                                              
   		}
    	else {
        	System.debug('Failed to insert the Debug Log record. ' +
					'Error: The APEX RUNTIME GOVERNOR LIMITS has been exhausted.');
    	}
   }
    
    public static void saveError() {
        if(!errorLogs.isEmpty()) {
            try {
                insert errorLogs;
                errorLogs.clear();
            }
            catch (Exception ex) {
                System.debug(
                    'Failed to insert the Debug Log record. ' + 'Error: ' + ex.getMessage()
                );
            }
        }   
    }    
}