/*****************************************************************
Name:  OpportunityTriggerHandler
 
=================================================================
Purpose: 
Handles business logic for Opportunity triggers                                                                                                                       
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        07/2018        Created         AMS:
*****************************************************************/

public with sharing class OpportunityTriggerHandler {
    
	// After Update Handler
    public static void handleAfterUpdate (List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap) {
        OpportunityTriggerHelper.createBillingGroupForOpportunity(newOpps, oldOppsMap); 
    } 
    
    // Before Update Handler
    public static void handleBeforeUpdate (List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap) {
        OpportunityTriggerHelper.ValidateClosedOpportunity(newOpps, oldOppsMap);
    } 
}