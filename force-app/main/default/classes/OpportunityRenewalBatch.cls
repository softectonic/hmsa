global class OpportunityRenewalBatch implements 
	Database.Batchable<sObject> {
        
    String query;
    private final String appConfig;  
    private final String oppRecTypeId;
        
    global OpportunityRenewalBatch() {
        // Get App Config custom settings
    	this.appConfig = AMS_App_Config__c.getOrgDefaults().Days_Before_Oppty_Renewal__c;
        
        // Get Record Type ID
        this.oppRecTypeId = Schema.getGlobalDescribe()
        	.get('Opportunity').getDescribe()
        	.getRecordTypeInfosByName()
        	.get('Assumptive Renewal')
        	.getRecordTypeId();
  	}
          
    global Database.QueryLocator start(Database.BatchableContext bc) {        
      System.debug('###appConfig: '+appConfig);
        
      // collect the batches of records to be passed to execute
      // Select all Billing Groups due for renewal in 60 days
      query = 'SELECT Id, Account__c, Account__r.Name, Account__r.OwnerId, ' +
                        'Rating_Class__c, Renewal_Date__c, Agent_Code__c ' +
                        'FROM Billing_Group__c ' +
            			      'WHERE Renewal_Date__c = NEXT_N_DAYS:' + this.appConfig + 
                        ' AND Agent_Code__c IN (\'C000\', \'C900\')';
        
      System.debug('###SOQL: '+query);
        
      return Database.getQueryLocator(query);
    }
    
 	  global void execute(Database.BatchableContext bc, List<Billing_Group__c> groups){
        
      System.debug('###Billing Groups: '+groups);
        
      // process each batch of records, populate Set with the Group's Ids
      List<Opportunity> assRenewalOpps = new List<Opportunity>();
      Set<String> accountIds = new Set<String>();
      List<Billing_Group__c> assRenewalGroups = new List<Billing_Group__c>();
       
      for (Billing_Group__c iterGroup : groups) {
          Date renewalDate = iterGroup.Renewal_Date__c;
          if(renewalDate.isSameDay(Date.today().addDays(Integer.valueOf(this.appConfig)))) {
              accountIds.add(iterGroup.Account__c);
              assRenewalGroups.add(iterGroup);
              Opportunity opp = new Opportunity(Name='Assumptive Renewal for '+ iterGroup.Account__r.Name, 
                                             CloseDate=Date.today().addDays(30),
                                             RecordTypeId=oppRecTypeId,
                                             Expected_Member_Percent__c=100,
                                             OwnerId=iterGroup.Account__r.OwnerId,
                                             AccountId=iterGroup.Account__c,
                                             StageName='New');
          assRenewalOpps.add(opp); 
        }
      }
      System.debug('###Renewal Opportunities: '+assRenewalOpps);

      // Create Opportunity Products
      if(!assRenewalGroups.isEmpty() && !assRenewalOpps.isEmpty()) {
        OpportunityRenewalHelper.createOpportunityProducts(assRenewalGroups, assRenewalOpps, accountIds);
      }
    }   
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}