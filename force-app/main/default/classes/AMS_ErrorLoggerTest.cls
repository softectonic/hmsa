@isTest
private class AMS_ErrorLoggerTest {
	
	@isTest static void testLogMessage() {

		Test.startTest();
		
		for (Integer i=0;i<5;i++) {
           AMS_ErrorLogger.logMessage('TestMethod', 'TestField', 'TestCode', 'ErrorMsg'+i, 'StackTrace'+i);
        }
        AMS_ErrorLogger.saveError();
        
        Test.stopTest();

        // Assert Error log records were created
        System.assert([SELECT COUNT() from AMS_Error_Log__c] > 0);

	}
	
}