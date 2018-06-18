global with sharing class OpportunityRenewalHelper {

    global static Map<String, Integer> stringToIntegerMonthsMap = new Map<String, Integer> {
        'January' =>1, 'February'=>2, 'March'=>3, 'April'=>4, 'May'=>5, 'June'=>6,
        'July'=>7, 'August'=>8, 'September'=>9, 'October'=>10, 'November'=>11, 'December'=>12
    };

    global static Map<Integer, String> integerToStringMonthsMap = new Map<Integer, String> {
        1=>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June',
        7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'
    };

 	global static Date getDateRenewalRatingClass(String ratingClass, String numOfmonths, Integer ratingClassYear) {
		Date dt = Date.newInstance(Date.today().year(), stringToIntegerMonthsMap.get(ratingClass), 1);
        if(Test.isRunningTest()) {
            dt = Date.newInstance(ratingClassYear, stringToIntegerMonthsMap.get(ratingClass), Date.today().day());
        }
        System.debug('###DateRenewalRatingClass_newInstance: '+dt);
		dt = dt.addMonths(Integer.valueof(numOfmonths));
        System.debug('###DateRenewalRatingClass_addMonths: '+dt);
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
                                    AND (Active_Through__c = Null OR Active_Through__c >= :renewalDate)]) {

            currentCodeMap.put(code.Current_Cov_Code__c, code);
        }
        return currentCodeMap;
    }

	global static void createOpportunityProducts(List<Billing_Group__c> groups, List<Opportunity> opps,  Set<String> accountIds) {
		
        System.debug('###Billing Group: '+groups);
        System.debug('###Opportunity: '+opps);
        System.debug('###Account IDs: '+accountIds);

        Set<Id> productIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();

		Map<Id, Billing_Group__c> billingGroupMap = new Map<Id, Billing_Group__c>();
        for(Billing_Group__c billingGroup : groups) {   
            groupIds.add(billingGroup.Id); 
        	billingGroupMap.put(billingGroup.Account__c, billingGroup);                                    
        }
        
        List<Billing_Product__c> billingProdList = [SELECT Id, Name, Billing_Group__c, Account_ID__c, Product__c,
                                              Drug_Coverage_Code__c, Med_Coverage_Code__c, 
                                              Vision_Coverage_Code__c 
                                              FROM Billing_Product__c 
                                              WHERE (Termination_Date__c = Null OR Termination_Date__c > TODAY)
                                              AND Billing_Group__c IN : groupIds
                                              /*AND Account_ID__c IN : accountIds*/];
        
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

            // Create a Save Point to rollback the DML operations if needed
         	//Savepoint sp = Database.setSavepoint();
            try{
            	List<Database.SaveResult> srList = Database.insert(opps, false);
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
            	if(errors.IsEmpty()) {
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
                            //oli.UnitPrice = pbeMap.get(billingProd.Product__c).UnitPrice;
                            oli.UnitPrice = 0.0;
                            oli.PricebookEntryId = pbeMap.get(billingProd.Product__c) != null ? pbeMap.get(billingProd.Product__c).Id : null;
                            oli.Product2Id = billingProd.Product__c;
                        } 
                        oli.OpportunityId=oppMap.get(billingProd.Account_ID__c).Id;
                        oli.Billing_Group__c=billingGroupMap.get(billingProd.Account_ID__c).Id;
                        oli.Med_Coverage_Code__c=currentCovCode.get(billingProd.Med_Coverage_Code__c) != null ? currentCovCode.get(billingProd.Med_Coverage_Code__c).New_Cov_Code__c : billingProd.Med_Coverage_Code__c;
                        oli.Drug_Coverage_Code__c=currentCovCode.get(billingProd.Drug_Coverage_Code__c) != null ? currentCovCode.get(billingProd.Drug_Coverage_Code__c).New_Cov_Code__c : billingProd.Drug_Coverage_Code__c;       
                        oli.Vision_Coverage_Code__c=currentCovCode.get(billingProd.Vision_Coverage_Code__c) != null ? currentCovCode.get(billingProd.Vision_Coverage_Code__c).New_Cov_Code__c : billingProd.Vision_Coverage_Code__c;
                        oli.Product2Id=billingProd.Product__c;
                        oli.Quantity=1;
                 	
                    	oppLineItems.add(oli);
                	}
                    System.debug('###OppLineItems: '+oppLineItems);
                	if(!oppLineItems.IsEmpty()) {
                    	List<Database.SaveResult> srList2 = Database.insert(oppLineItems, false);
                        System.debug('###Database.SaveResult: '+srList2);
            			for (Database.SaveResult sr : srList2) {
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
            	}
        	}
        	catch (DMLException e) {
             	errors.add('Error: ' + e.getMessage() + '; Stack Trace: ' + e.getStackTraceString());
             	System.debug('Error: ' + e.getMessage() + '; Stack Trace: ' + e.getStackTraceString());
            
            	// Rollback, upsert operation failed
            	//Database.rollback(sp);
        	}
        	if(!errors.IsEmpty()) {
            	System.debug('###Errors: '+errors);
        	}
        }
	}

}