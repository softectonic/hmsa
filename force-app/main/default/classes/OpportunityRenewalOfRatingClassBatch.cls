/*****************************************************************
Name:  OpportunityRenewalOfRatingClassBatch
 
=================================================================
Purpose: 
Apex batch process for auto renewal Opportunities based on 
specified rating class controlled by custom settings.
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS:
*****************************************************************/

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
                        'FROM Billing_Group__c ' +
                        'WHERE Rating_Class__c != Null ' +
                        'AND Renewal_Date__c != Null ' +
                        'AND (Group_Status__c = \'Active\' ' +
                        'OR Group_Status__c = \'Pending\')';
        
		return Database.getQueryLocator(query);
	}

  	global void execute(Database.BatchableContext BC, List<Billing_Group__c> groups) {	

   		List<Billing_Group__c> groupsForRenewal = new List<Billing_Group__c>();
     
 		// Iterate and assemble groups that are 7 months prior to rating class 
   		for (Billing_Group__c iterGroup : groups) {
            String monthsPriorRatingClass = !Test.isRunningTest() ? this.appConfig : '7';
          	if(OpportunityRenewalHelper.getDateRenewalRatingClass(
                                            iterGroup.Rating_Class__c,
                                            iterGroup.Renewal_Date__c.year()).month() == Date.today().addMonths(Integer.valueof(monthsPriorRatingClass)).month()) {
   				groupsForRenewal.add(iterGroup);
   			}
   		}
   		List<Opportunity> opps = new List<Opportunity>();
   		
      	Set<String> qualifyAccountsForRenewal = new Set<String>();
      	for (Billing_Group__c iterGroup2 : groupsForRenewal) {
        	qualifyAccountsForRenewal.add(iterGroup2.Account__c);
      	}

      	Map<Id, List<Opportunity>> renewalOppMap = new  Map<Id, List<Opportunity>>();
      	for(Opportunity opp : [Select Id, RecordTypeId, CloseDate, StageName, AccountId, OwnerId From Opportunity Where 
                              RecordTypeId = :oppRecTypeId And AccountId IN :qualifyAccountsForRenewal]) {
        	List<Opportunity> oppList = renewalOppMap.get(opp.AccountId) != null ? 
                                      renewalOppMap.get(opp.AccountId) : new List<Opportunity>();
        	oppList.add(opp);
        	renewalOppMap.put(opp.AccountId, oppList);
      	}
        
      	Set<String> accountForRenewal = new Set<String>();
      	Map<Id, List<Billing_Group__c>> dupRatingClassMap = new Map<Id, List<Billing_Group__c>>(); 
        List<Billing_Group__c> dupGroupList;
        integer counter = 1;   
   		for (Billing_Group__c iterGroup2 : groupsForRenewal) {
        	Boolean dupRatingClassExists = false;    
            if(counter == 1) {
                dupGroupList = new List<Billing_Group__c>();
                dupGroupList.add(iterGroup2);
                dupRatingClassMap.put(iterGroup2.Account__c, dupGroupList);
          	}
          	else {
            	dupGroupList = dupRatingClassMap.get(iterGroup2.Account__c); 
                if(dupGroupList != null) {
                	for(Billing_Group__c grp : dupGroupList) {
               			if(grp.Rating_Class__c == iterGroup2.Rating_Class__c) {
            				dupRatingClassExists = true;
                    	}
                 	}
                    if(dupRatingClassExists) {
                		dupGroupList.add(iterGroup2);
                		dupRatingClassMap.put(iterGroup2.Account__c, dupGroupList);
          				continue;
        			} 
                }
                else {
                    dupGroupList = new List<Billing_Group__c>();
                    dupGroupList.add(iterGroup2);
                	dupRatingClassMap.put(iterGroup2.Account__c, dupGroupList);
                }
          	}
            counter++; 
            if(dupRatingClassExists) {
          		continue;
        	} 
         
        	List<Opportunity> oppList2 = renewalOppMap.get(iterGroup2.Account__c);
        	Boolean renewalOppExists = false;
        	if(oppList2 != null && !oppList2.isEmpty()) {
          		for(Opportunity opp2 : oppList2) {
            		if((opp2.CloseDate == iterGroup2.Renewal_Date__c && opp2.OwnerId == iterGroup2.Account__r.OwnerId)
                  		|| (opp2.StageName != 'Closed Won' && opp2.StageName != 'Closed Lost')) {
              			renewalOppExists = true;
            		}
          		}
        	}
        	if(oppList2 == null || !renewalOppExists) {
          		accountForRenewal.add(iterGroup2.Account__c);

          		Opportunity opp = new Opportunity(Name='Renewal for '+ iterGroup2.Account__r.Name, 
                                             CloseDate=iterGroup2.Renewal_Date__c,
                                             Effective_Date__c=iterGroup2.Renewal_Date__c,
                                             RecordTypeId=oppRecTypeId, 
                                             Expected_Member_Percent__c=100,
                                             OwnerId=iterGroup2.Account__r.OwnerId,
                                             AccountId=iterGroup2.Account__c,
                                             Initiating_Billing_Group__c=iterGroup2.Id,      
                                             StageName='Planning');
          		opps.add(opp); 
        	}
      	}
        
        //Determine earliest renewal date 
        for(Opportunity op : opps) {
            List<Billing_Group__c> renGroupList = dupRatingClassMap.get(op.AccountId);
            if(renGroupList != Null && renGroupList.size() > 1) {
                // Sort group list
            	OpportunityRenewalHelper[] renewalGroupList = new List<OpportunityRenewalHelper>();
            	for (Billing_Group__c renGroup : renGroupList) {
              		renewalGroupList.add(new OpportunityRenewalHelper(renGroup));
            	}
            	renewalGroupList.sort();
            	op.Effective_Date__c = renewalGroupList[0].billGroup.Renewal_Date__c;
              op.CloseDate = renewalGroupList[0].billGroup.Renewal_Date__c;
            }  
        }
      	
        // Create Opportunity Products
      	OpportunityRenewalHelper.createOpportunityProducts(groupsForRenewal, opps, accountForRenewal);
	
	}
	
	global void finish(Database.BatchableContext BC) {
	}
	
}