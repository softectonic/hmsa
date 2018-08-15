/*****************************************************************
Name:  OpportunityTriggerTest
 
=================================================================
Purpose: 
Unit Test methods for Opportunity triggers                                                                                                                       
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS:
*****************************************************************/

@isTest
private class OpportunityTriggerTest {
	
	@isTest static void testAcceptanceOppsWithoutBillingGroup() {
        User testUser = TestDataFactory.getTestUser();
        System.runAs(testUser) {
			TestDataFactory.setupProposalAcceptanceOpps();
        
        	Test.startTest();

        	List<Opportunity> oppList = [Select Id, StageName, Effective_End_Date__c From Opportunity];
        	for(Opportunity opp : oppList) {
                opp.Effective_Date__c=Date.today();
                opp.Funding_Type__c='Fully Insured';
                opp.Funding_Mechanism__c='Community Rated Group (CRG)';
        		opp.StageName = 'Post Proposal Acceptance';
        	}
        	update oppList;

        	Test.stopTest();

        	// Assert Billing Groups were created
        	List<Account> accList = [Select Id, Name From Account];
        	System.assert([SELECT COUNT() from Billing_Group__c Where Account__c = :accList[0].Id] == 1);

        	// Assert Billing Group Opportunity Products were created
        	System.assert([SELECT COUNT() from Billing_Group_Opp_Product__c Where Opportunity__c = :oppList[0].Id] == 1);	
        }
	}
    
    @isTest static void testAcceptanceOppsWithExistingBillingGroup() {
        User testUser = TestDataFactory.getTestUser();
        System.runAs(testUser) {
			TestDataFactory.setupAcceptanceOppsWithBillingGroup();
        
        	Test.startTest();

        	List<Opportunity> oppList = [Select Id, StageName, Effective_End_Date__c From Opportunity];
        	for(Opportunity opp : oppList) {
                opp.Effective_Date__c=Date.today();
                opp.Funding_Type__c='Fully Insured';
                opp.Funding_Mechanism__c='Community Rated Group (CRG)';
        		opp.StageName = 'Post Proposal Acceptance';
        	}
        	update oppList;

        	Test.stopTest();
            
            // Assert New Billing Group were not created
        	System.assert([SELECT COUNT() from Billing_Group__c] == 5);	

        	// Assert Billing Group Opportunity Products were created
        	System.assert([SELECT COUNT() from Billing_Group_Opp_Product__c Where Opportunity__c = :oppList[0].Id] == 1);	
        }
	}
    
    @isTest static void testOpportunityValidationWithMissingData() {
        User testUser = TestDataFactory.getTestUser();
        System.runAs(testUser) {

        	Test.startTest();
            try {
            	TestDataFactory.setupOpportunityWithMissingData('New');
        	
            	List<Opportunity> oppList = [Select Id, StageName From Opportunity];
        		for(Opportunity opp : oppList) {
        			opp.StageName='Closed Won';
        		}
        		update oppList;
                
                // We don't expect to get here as the insert should fail
            	System.Assert (false);
            }
			catch (DMLException e) {
            	// We expect the insert to fail
            	System.Assert (true);
        	}
        	Test.stopTest();	
        }
	}
    
    @isTest static void testOpportunityValidationWithCompleteData() {
        User testUser = TestDataFactory.getTestUser();
        
        System.runAs(testUser) {

        	Test.startTest();

            TestDataFactory.setupOpportunityWithCompleteData('New');
        		
            List<Opportunity> oppList = [Select Id, StageName From Opportunity];
            for(Opportunity opp : oppList) {
        		opp.StageName='Closed Won';
        	}
        	update oppList;
                
           	System.AssertEquals (true, OpportunityTriggerHelper.OpportunityValidator(oppList[0], null));
           	System.Assert(true);
            
            Test.stopTest();	
        }
        
	}
	
}