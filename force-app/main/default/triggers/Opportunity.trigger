/*****************************************************************
Name:  Opportunity Trigger
 
=================================================================
Purpose: 
                                                                                                                     
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        07/2018        Created         AMS:
*****************************************************************/

trigger Opportunity on Opportunity (before update, after update) {
    if(Trigger.isBefore) {
       	OpportunityTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);  
    }
    else if(Trigger.isAfter) {
       	OpportunityTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);  
    }
}