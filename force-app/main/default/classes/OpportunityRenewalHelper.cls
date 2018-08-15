/*****************************************************************
Name:  OpportunityRenewalHelper
 
=================================================================
Purpose: 
Utility helper methods for Opportunity renewal use cases                                                                                                                    
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS:
*****************************************************************/

global with sharing class OpportunityRenewalHelper implements Comparable {

    public Billing_Group__c billGroup;

    public OpportunityRenewalHelper(Billing_Group__c bg) {
        billGroup = bg;
    }

    // Compare Billing Groups based on the Renewal date.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityRenewalHelper
        OpportunityRenewalHelper compareToGroup = (OpportunityRenewalHelper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (billGroup.Renewal_Date__c > compareToGroup.billGroup.Renewal_Date__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (billGroup.Renewal_Date__c < compareToGroup.billGroup.Renewal_Date__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
    
    global static Map<String, Integer> stringToIntegerMonthsMap = new Map<String, Integer> {
        'January' =>1, 'February'=>2, 'March'=>3, 'April'=>4, 'May'=>5, 'June'=>6,
        'July'=>7, 'August'=>8, 'September'=>9, 'October'=>10, 'November'=>11, 'December'=>12
    };

    global static Map<Integer, String> integerToStringMonthsMap = new Map<Integer, String> {
        1=>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June',
        7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'
    };

 	global static Date getDateRenewalRatingClass(String ratingClass, Integer ratingClassYear) {
		Date dt = Date.newInstance(Date.today().year(), stringToIntegerMonthsMap.get(ratingClass), 1);
        /*if(Test.isRunningTest()) {dt = Date.newInstance(ratingClassYear, stringToIntegerMonthsMap.get(ratingClass), Date.today().day()).addMonths(Integer.valueof(7));}*/
		return dt;
	}

    global static Map<String, Coverage_Code__c> getCurrentCoverageCode(Date renewalDate) {
        Map<String, Coverage_Code__c> currentCodeMap = new Map<String, Coverage_Code__c>();
        for(Coverage_Code__c code : [SELECT Coverage_Code_Type__c, 
                                            Current_Cov_Code__c, 
                                            New_Cov_Code__c, 
                                            Start_Date__c, 
                                            Active_Through__c
                                    FROM Coverage_Code__c 
                                    WHERE Start_Date__c <= :renewalDate 
                                    AND (Active_Through__c = Null OR Active_Through__c >= :renewalDate)
                                    AND Coverage_Code_Type__c != null
                                    AND Current_Cov_Code__c != null]) {

            currentCodeMap.put(code.Coverage_Code_Type__c+code.Current_Cov_Code__c, code);
        }
        return currentCodeMap;
    }

	global static void createOpportunityProducts(List<Billing_Group__c> groups, List<Opportunity> opps,  Set<String> accountIds) {
		
        Set<Id> productIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();

		Map<Id, Billing_Group__c> billingGroupMap = new Map<Id, Billing_Group__c>();
        for(Billing_Group__c billingGroup : groups) {   
            groupIds.add(billingGroup.Id); 
        	billingGroupMap.put(billingGroup.Account__c, billingGroup);                                    
        }
        
        List<Billing_Product__c> billingProdList = [SELECT Id, Name, Billing_Group__c, Account_ID__c, Product__c,
                                              Drug_Coverage_Code__c, Med_Coverage_Code__c, 
                                              Vision_Coverage_Code__c, Dental_Coverage_Code__c, Complementary_Coverage_Code__c 
                                              FROM Billing_Product__c 
                                              WHERE (Termination_Date__c = Null OR Termination_Date__c > TODAY)
                                              AND Billing_Group__c IN : groupIds
                                              AND Product__c != Null
                                              AND Account_ID__c IN : accountIds];
        
        for(Billing_Product__c bp : billingProdList) {
            productIds.add(bp.Product__c);
        }

		if(opps != null && !opps.IsEmpty()) {

			List<String> errors = new List<String>();  

            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();

            String pricebookId;
            PricebookEntry testPBE;
            if (!Test.isRunningTest()) {
                Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'HMSA'];
                pricebookId = pb.Id;
            } else {
                // This is used by Unit Test
                testPBE = [SELECT Id, UnitPrice FROM PricebookEntry];
            }
            
            Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
            for(PricebookEntry pbe : [SELECT Id, UnitPrice, Product2Id 
                                    FROM PricebookEntry 
                                    WHERE Product2Id IN :productIds 
                                    AND Pricebook2Id = :pricebookId]) {
                pbeMap.put(pbe.Product2Id, pbe);
            }
			Map<Id, Billing_Group__c> prodBillingGroupMap = new Map<Id, Billing_Group__c>();
            // Create a Save Point to rollback the DML operations if needed
         	//Savepoint sp = Database.setSavepoint();
            try{
                List<String> dmlErrors;
                System.debug('###opps: '+opps);
                // Insert Opportuntities
                dmlErrors = OpportunityTriggerHelper.saveRecords(opps, 'insert', 'OpportunityRenewalHelper.createOpportunityProducts');
                
            	if(dmlErrors == null || dmlErrors.isEmpty()) {
                	for(Opportunity opp: opps) {
                    	oppMap.put(opp.AccountId, opp);
                	}
                	for(Billing_Product__c billingProd : billingProdList) {

                        Map<String, Coverage_Code__c> currentCovCode = getCurrentCoverageCode(billingGroupMap.get(billingProd.Account_ID__c).Renewal_Date__c);
                        OpportunityLineItem oli = new OpportunityLineItem();

                        if(Test.isRunningTest() ) {
                            oli.UnitPrice = testPBE.UnitPrice;
                            oli.PricebookEntryId = testPBE.Id;
                        }
                        else {
   							oli.UnitPrice = 0.0;
                            oli.PricebookEntryId = pbeMap.get(billingProd.Product__c) != null ? pbeMap.get(billingProd.Product__c).Id : null;
                            oli.Product2Id = billingProd.Product__c;
                        } 
                        oli.OpportunityId=oppMap.get(billingProd.Account_ID__c) != null ? oppMap.get(billingProd.Account_ID__c).Id : null;
                        oli.Med_Coverage_Code__c=currentCovCode.get('Med Cov Code'+billingProd.Med_Coverage_Code__c) != null ? currentCovCode.get('Med Cov Code'+billingProd.Med_Coverage_Code__c).New_Cov_Code__c : billingProd.Med_Coverage_Code__c;
                        oli.Drug_Coverage_Code__c=currentCovCode.get('Drug Cov Code'+billingProd.Drug_Coverage_Code__c) != null ? currentCovCode.get('Drug Cov Code'+billingProd.Drug_Coverage_Code__c).New_Cov_Code__c : billingProd.Drug_Coverage_Code__c;       
                        oli.Vision_Coverage_Code__c=currentCovCode.get('Vision Cov Code'+billingProd.Vision_Coverage_Code__c) != null ? currentCovCode.get('Vision Cov Code'+billingProd.Vision_Coverage_Code__c).New_Cov_Code__c : billingProd.Vision_Coverage_Code__c;
                        oli.Dental_Coverage_Code__c=currentCovCode.get('Dental Cov Code'+billingProd.Dental_Coverage_Code__c) != null ? currentCovCode.get('Dental Cov Code'+billingProd.Dental_Coverage_Code__c).New_Cov_Code__c : billingProd.Dental_Coverage_Code__c;
                        oli.Complementary_Coverage_Code__c=currentCovCode.get('Complementary Cov Code'+billingProd.Complementary_Coverage_Code__c) != null ? currentCovCode.get('Complementary Cov Code'+billingProd.Complementary_Coverage_Code__c).New_Cov_Code__c : billingProd.Complementary_Coverage_Code__c;
                        oli.Product2Id=billingProd.Product__c;
                        oli.Billing_Group__c=billingProd.Billing_Group__c;
                        oli.Quantity=1;
                 	
                    	oppLineItems.add(oli);
                	}
                   
                	if(!oppLineItems.IsEmpty()) {
                        // Insert Opportunity Products
                        dmlErrors = OpportunityTriggerHelper.saveRecords(oppLineItems, 'insert', 'OpportunityRenewalHelper.createOpportunityProducts');
                    	
                        if(dmlErrors == null || dmlErrors.isEmpty()) {
                            List<Billing_Group_Opp_Product__c> groupOppProductsForInsert = new List<Billing_Group_Opp_Product__c>();	
                			for (OpportunityLineItem item : oppLineItems) {                                   
                   				// Create Billing_Group_Opp_Product__c (Junction object) records. 
                    			Billing_Group_Opp_Product__c groupOppProduct = new Billing_Group_Opp_Product__c();
                    			groupOppProduct.Billing_Group__c = item.Billing_Group__c;
                    			groupOppProduct.Opportunity_Product_ID__c = String.valueOf(item.Id);
                    			groupOppProduct.Opportunity__c = item.OpportunityId;
                    			groupOppProductsForInsert.add(groupOppProduct);
                			}
                			if(!groupOppProductsForInsert.isEmpty()) {
                    			OpportunityTriggerHelper.saveRecords(groupOppProductsForInsert, 'insert', 'OpportunityRenewalHelper.createOpportunityProducts');
                			}
                        }
                	}
            	}
        	}
        	catch (DMLException e) {
            	AMS_ErrorLogger.logMessage('OpportunityRenewalHelper.createOpportunityProducts','','', 
                                  			e.getMessage(), e.getStackTraceString());
                //Rollback, upsert operation failed
            	//Database.rollback(sp);
        	}
            finally {
                AMS_ErrorLogger.saveError();
           	}
        }
	}

}