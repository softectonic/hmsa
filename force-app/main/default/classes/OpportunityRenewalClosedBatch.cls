global class OpportunityRenewalClosedBatch implements Database.Batchable<sObject> {
    
    String query;
    List<String> errors;
    private final String appConfig;  
    private final String oppRecTypeId;
    
    global OpportunityRenewalClosedBatch() {
          // Get App Config custom settings
        this.appConfig = AMS_App_Config__c.getOrgDefaults().Days_Post_Oppty_Renewal__c;
        
        // Get Record Type ID
        this.oppRecTypeId = Schema.getGlobalDescribe()
            .get('Opportunity').getDescribe()
            .getRecordTypeInfosByName()
            .get('Assumptive Renewal')
            .getRecordTypeId();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        // collect the batches of records to be passed to execute
        // Select all Billing Groups due for renewal in 60 days
        query = 'SELECT Id, Account__c, Renewal_Date__c, Agent_Code__c ' +
                'FROM Billing_Group__c ' +
                'WHERE Renewal_Date__c = NEXT_N_DAYS:' + this.appConfig + 
                ' AND Agent_Code__c IN (\'C000\', \'C900\')';

        System.debug('###SOQL: '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Billing_Group__c> groups) {

        errors = new List<String>(); 
        Set<String> accountIds = new Set<String>();
        for (Billing_Group__c iterGroup : groups) {
            accountIds.add(iterGroup.Account__c);
        }
        if(!accountIds.IsEmpty()) {
            List<Opportunity> opps = [SELECT Id, Name, AccountId, StageName, RecordType.Name FROM Opportunity];
            System.debug('###Opps: '+opps);
            System.debug('###RecordType Name: '+opps[0].RecordType.Name);
            System.debug('###oppRecTypeId: '+oppRecTypeId);
            System.debug('###accountIds: '+accountIds);

            List<Opportunity> oppList = [SELECT Id, Name, AccountId, StageName, RecordTypeId 
                                            FROM Opportunity 
                                            WHERE StageName <> 'Closed Won'
                                            AND RecordType.Name = : 'Assumptive Renewal'
                                            AND AccountId IN : accountIds];

            System.debug('###oppList: '+oppList);
            if(oppList != null && !oppList.isEmpty()) {

                for(Opportunity opp : oppList) {
                    opp.StageName = 'Closed Won';
                }
                // Create a Save Point to rollback the DML operations if needed
                Savepoint sp = Database.setSavepoint();
                
                try{
                    List<Database.SaveResult> srList = Database.update(oppList, false);
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors               
                            for(Database.Error err : sr.getErrors()) {
                            errors.add('The following error has occurred. ' + 
                                err.getStatusCode() + ': ' + 
                                err.getMessage() + ' : Fields that affected this error: ' + 
                                err.getFields());
                            }
                        }
                    }
                }
                catch (DMLException e) {
                    errors.add('Error: ' + e.getMessage() + '; Stack Trace: ' + e.getStackTraceString());
                    System.debug('Error: ' + e.getMessage() + '; Stack Trace: ' + e.getStackTraceString());
            
                    // Rollback, upsert operation failed
                    Database.rollback(sp);
                }
                if(!errors.IsEmpty()) {
                    System.debug('###Errors: '+errors);
                }
            }                               

        }
    
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}