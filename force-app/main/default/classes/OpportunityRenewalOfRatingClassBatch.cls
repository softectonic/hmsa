global class OpportunityRenewalOfRatingClassBatch implements Database.Batchable<sObject> {
	
	String query;
    private final String appConfig;  
    private final String oppRecTypeId;
	
	global OpportunityRenewalOfRatingClassBatch() {
		 // Get App Config custom settings
    	this.appConfig = AMS_App_Config__c.getOrgDefaults().Months_Post_Rating_Class__c;
        
        // Get Record Type ID
        this.oppRecTypeId = Schema.getGlobalDescribe()
        	.get('Opportunity').getDescribe()
        	.getRecordTypeInfosByName()
        	.get('Renewal')
        	.getRecordTypeId();
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		query = 'SELECT Id, Account__c, Account__r.Name, Account__r.OwnerId, ' +
                        'Rating_Class__c, Renewal_Date__c, Agent_Code__c ' +
                        'FROM Billing_Group__c';

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Billing_Group__c> groups) {	

   		List<Billing_Group__c> groupsForRenewal = new List<Billing_Group__c>();

 		  // Iterate and assemble groups that are 7 months after the rating class 
   		for (Billing_Group__c iterGroup : groups) {
        System.debug('###RenewalRatingClass: '+OpportunityRenewalHelper.getDateRenewalRatingClass(iterGroup.Rating_Class__c, this.appConfig, iterGroup.Renewal_Date__c.year()));
   			if(OpportunityRenewalHelper.getDateRenewalRatingClass(iterGroup.Rating_Class__c, this.appConfig, iterGroup.Renewal_Date__c.year()) == Date.today()) {
   				groupsForRenewal.add(iterGroup);
   			}
   		}

   		List<Opportunity> opps = new List<Opportunity>();
   		Set<String> accountIds = new Set<String>();

   		for (Billing_Group__c iterGroup2 : groupsForRenewal) {
            accountIds.add(iterGroup2.Account__c);
            Opportunity opp = new Opportunity(Name='Renewal for '+ iterGroup2.Account__r.Name, 
                                             CloseDate=iterGroup2.Renewal_Date__c,
                                             RecordTypeId=oppRecTypeId,
                                             Expected_Member_Percent__c=100,
                                             OwnerId=iterGroup2.Account__r.OwnerId,
                                             AccountId=iterGroup2.Account__c,
                                             //Jeopardy_Status__c='None',
                                             StageName='Planning');
           opps.add(opp); 
        }

        // Create Opportunity Products
        OpportunityRenewalHelper.createOpportunityProducts(groupsForRenewal, opps, accountIds);
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}