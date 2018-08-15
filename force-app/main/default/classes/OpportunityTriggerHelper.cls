/*****************************************************************
 Name:  OpportunityTriggerHelper
 
=================================================================
 Purpose: 
 Utility helper methods                                                                                                                     
=================================================================
 History                                                            
 -------                                                            
 VERSION  AUTHOR         DATE           DETAIL          Description
 1.0   	  aashiru         06/2018       Created         AMS:
*****************************************************************/

public with sharing class OpportunityTriggerHelper {
	private static boolean run = true;
    public static boolean runOnce(){
    	if(run){
     		run=false;
     		return true;
    	}else{
        	return run;
    	}
    }
    
    public static void createBillingGroupForOpportunity(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap) {
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>();
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppsMap.get(newOpp.Id);
            // Check if the Opportunity Stage is Post Proposal Acceptance
            if ((oldOppsMap != null && newOpp.StageName != oldOpp.StageName && newOpp.StageName == 'Post Proposal Acceptance')
                || (newOpp.StageName == 'Post Proposal Acceptance'))  {
                    oppIds.add(newOpp.Id);
                    accountIds.add(newOpp.AccountId);
                    oppsMap.put(newOpp.AccountId, newOpp);
            } 
        }
        if(!accountIds.isEmpty() && runOnce()) {
            
            List<Billing_Group__c> billingGroups = [Select Id, Account__c, Group_Status__c 
                                                    From Billing_Group__c 
                                                    Where (Group_Status__c = 'Active' 
                                                           OR  Group_Status__c = 'Pending') 
                                                    And Account__c IN :accountIds];
            
            billingGroups =  billingGroups == Null? new List<Billing_Group__c>() : billingGroups;
            //System.debug('###billingGroups.size: '+billingGroups.size());															
            Set<Id> billingGroupAccountIds = new Set<Id>();
            Map<Id, List<Billing_Group__c>> tempBillingGroupsMap = new Map<Id, List<Billing_Group__c>>();
            for(Billing_Group__c bg : billingGroups) {
                billingGroupAccountIds.add(bg.Account__c);
                List<Billing_Group__c> bgList = tempBillingGroupsMap.get(bg.Account__c) == null ? 
                    new List<Billing_Group__c>() : tempBillingGroupsMap.get(bg.Account__c); 
                bgList.add(bg);
                tempBillingGroupsMap.put(bg.Account__c, bgList);
            }
            List<Billing_Group__c> billingGroupsForInsert = new List<Billing_Group__c>();
            List<Billing_Group__c> existingBillingGroups = new List<Billing_Group__c>();
            Map<Id, Account> accountsMap = new Map<Id, Account>([Select Id, Name From Account Where Id IN :accountIds]);
            for (Id accountId : accountIds){
                if(!billingGroupAccountIds.contains(accountId)) {
                    Billing_Group__c billingGroup = new Billing_Group__c();
                    billingGroup.Account__c = accountId;
                    billingGroup.Renewal_Date__c = oppsMap.get(accountId).Effective_End_Date__c != Null ? 
                        oppsMap.get(accountId).Effective_End_Date__c.addDays(1) : Null;
                    billingGroup.Name = 'Billing Group 1 for ' + accountsMap.get(accountId).Name;
                    billingGroup.Group_Status__c = 'Pending';
                    billingGroupsForInsert.add(billingGroup);
                } 
                else if(tempBillingGroupsMap.get(accountId) != null &&
                   tempBillingGroupsMap.get(accountId).size() == 1) {
                   existingBillingGroups.add(tempBillingGroupsMap.get(accountId)[0]);           
                }
            }
            if(!billingGroupsForInsert.isEmpty() || !existingBillingGroups.isEmpty()) {
                Map<Id, Billing_Group__c> billingGroupsMap = new Map<Id, Billing_Group__c>();
                if(!billingGroupsForInsert.isEmpty()) {
                    List<String> errors;
                    errors = OpportunityTriggerHelper.saveRecords(billingGroupsForInsert, 'insert', 'OpportunityTriggerHelper.createBillingGroupForOpportunity');
                    if(errors.isEmpty()) {  			
                        for(Billing_Group__c billingGroup : billingGroupsForInsert) {
                            billingGroupsMap.put(billingGroup.Account__c, billingGroup);
                        }
                    }
                } 
                if(!existingBillingGroups.isEmpty()) {
                    for(Billing_Group__c billingGroup2 : existingBillingGroups) {
                        billingGroupsMap.put(billingGroup2.Account__c, billingGroup2);
                    }
                }
                List<OpportunityLineItem> opportunityProducts = [Select Id, OpportunityId, Opportunity.AccountId From OpportunityLineItem
                                                   Where Opportunity.AccountId IN :billingGroupsMap.keySet()
                                                   And OpportunityId IN : oppIds];
                
                List<Billing_Group_Opp_Product__c> groupOppProductsForInsert = new List<Billing_Group_Opp_Product__c>();	
                
                for (OpportunityLineItem item : opportunityProducts) {                                   
                   	// Create Billing_Group_Opp_Product__c (Junction object) records. 
                    Billing_Group_Opp_Product__c groupOppProduct = new Billing_Group_Opp_Product__c();
                    groupOppProduct.Billing_Group__c = billingGroupsMap.get(item.Opportunity.AccountId).Id;
                    groupOppProduct.Opportunity_Product_ID__c = String.valueOf(item.Id);
                    groupOppProduct.Opportunity__c = item.OpportunityId;
                    groupOppProductsForInsert.add(groupOppProduct);
                }
                if(!groupOppProductsForInsert.isEmpty()) {
                    OpportunityTriggerHelper.saveRecords(groupOppProductsForInsert, 'insert', 'OpportunityTriggerHelper.createBillingGroupForOpportunity');
                }
            }																
        }
    }

	public static List<String> saveRecords(List<SObject> records, String operation, String procedure) {
		List<String> errors = new List<String>();
		List<Database.SaveResult> srList;
		try{
			if(operation == 'insert') {
            	srList = Database.insert(records, false);
			} 
			else if(operation == 'update') {
				srList = Database.update(records, false);
			}
            for (Database.SaveResult sr : srList) {
    			if (!sr.isSuccess()) {
                    // Operation failed, so get all errors               
        			for(Database.Error err : sr.getErrors()) {
                 	 	errors.add('The following error has occurred. ' + 
                            err.getStatusCode() + ': ' + 
                            err.getMessage() + ' : Fields that affected this error: ' + 
                            err.getFields());
                         
                        AMS_ErrorLogger.logMessage(procedure, 
                                  					!err.getFields().isEmpty()?String.join(err.getFields(), ','):'', 
                                  					''+err.getStatusCode(), 
                                  					err.getMessage(),'');
                    }
        		}
            }
        }
        catch (DMLException e) {
            errors.add('Error: ' + e.getMessage() + '; Stack Trace: ' + e.getStackTraceString());
            
            AMS_ErrorLogger.logMessage('OpportunityTriggerHelper.saveRecords','','', 
                                  			e.getMessage(), e.getStackTraceString());
        }
        finally {
          	AMS_ErrorLogger.saveError();
        }
        return errors;
	}	
    
    public static boolean OpportunityValidator (Opportunity newOpp, Map<Id, Opportunity> oldOppMap)
    {
        Opportunity oldOpp = oldOppMap != null ? oldOppMap.get(newOpp.Id) : null;
        // Check if the Opportunity Stage is Closed Won
        if ((oldOppMap != null && newOpp.StageName != oldOpp.StageName && newOpp.StageName == 'Closed Won')
                || (newOpp.StageName == 'Closed Won'))  {
              if(runOnce()) {
                    Map<Id, OpportunityLineItem> itemsMap = new Map<Id, OpportunityLineItem>(
                        [SELECT Id, Opportunity.AccountId, OpportunityId, Selected_By_Customer__c
                         FROM OpportunityLineItem
                         WHERE OpportunityId = :newOpp.id 
                         AND Selected_By_Customer__c = true]);
                    System.debug('###itemsMap: '+itemsMap);
                    if (itemsMap == null || itemsMap.isEmpty())
                        return false;
                  
                  	else {
                        
                      List<Billing_Group__c> groupList = new List<Billing_Group__c>();
                      List<Billing_Group_Opp_Product__c> groupPrdList;
                      
                      groupPrdList = [SELECT Id, Opportunity_Product_ID__c, Billing_Group__c 
                                      FROM Billing_Group_Opp_Product__c
                                      WHERE Opportunity_Product_ID__c IN :itemsMap.keySet()];
                      
                        if(groupPrdList == null ||  groupPrdList.isEmpty()) {
                           return false;
                        }
                        else {
                           	Set<Id> groupIds = new Set<Id>();
                            for(Billing_Group_Opp_Product__c bgp :  groupPrdList) {
                                groupIds.add(bgp.Billing_Group__c);
                            }
                            
                            groupList = [SELECT Id, 
                                     Account__c, 
                                     Requested_Agent_Code__c, 
                                     Requested_Rating_Class__c,
                                     Retro_Cancellation_Allowance__c,
                                     Domestic_Partnership_Allowed__c
                                     FROM Billing_Group__c 
                                     WHERE Id IN :groupIds];
                            
                            for(Billing_Group__c grp : groupList){
                                if(grp.Requested_Agent_Code__c == null 
                                    || grp.Requested_Rating_Class__c == null 
                                    || grp.Retro_Cancellation_Allowance__c == null 
                                    || grp.Domestic_Partnership_Allowed__c == null) {
                                        return false;       
                                }
                            }
                        }   
                  }
             }
        }
       	return true;
    }
    
    public static void ValidateClosedOpportunity(List<Opportunity> newOpp, Map<Id, Opportunity> oldOppMap) {
         // Only validate single-row updates. The code is triggered from the UI and not bulk-safe
        if (newOpp.size() > 1)     
            return;
        
    	Opportunity opp = newOpp[0];
    	if (!OpportunityValidator(opp, oldOppMap)) {
        	opp.AddError (System.Label.Validation_Rules_Opportunity_Closed_Won);
    	}
    }
}