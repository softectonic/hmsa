/*****************************************************************
Name:  OpportunityRenewalTest
 
=================================================================
Purpose: 
Unit Test methods for Opportunity renewal use cases
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS:
*****************************************************************/

@isTest
private class OpportunityRenewalTest {
    
    
    static testmethod void testOpportunityRenewal() {

        TestDataFactory.setup();
        
        Test.startTest();
            
        // Run the schedule job that executes the Batch class OpportunityRenewalBatch
        OpportunityRenewalSchedule scheduleOppRenewal = new OpportunityRenewalSchedule();
        scheduleOppRenewal.execute(null);
            
        Test.stopTest();

        // Assert Renewal Opportunities were created
        System.assert([SELECT COUNT() from Opportunity] > 0);

        // Assert Renewal Opportunity Products were created
        System.assert([SELECT COUNT() from OpportunityLineItem] > 0);

        List<OpportunityLineItem> itemList = [SELECT Id, Med_Coverage_Code__c FROM OpportunityLineItem];

        System.assertEquals(itemList[0].Med_Coverage_Code__c, '005'); 
    }

    static testmethod void testOpportunityRenewalRatingClass() {

        TestDataFactory.setupOppsRatingClass();
        
        Test.startTest();
            
        // Run the schedule job that executes the Batch class OpportunityRenewalBatch
        OpportunityRenewalOfRatingClassSchedule scheduleOppRenewal = new OpportunityRenewalOfRatingClassSchedule();
        scheduleOppRenewal.execute(null);
            
        Test.stopTest();

        // Assert Renewal Opportunities were created
        System.assert([SELECT COUNT() from Opportunity] > 0);

        // Assert Renewal Opportunity Products were created
        System.assert([SELECT COUNT() from OpportunityLineItem] > 0);
        
        // Assert Coverage Code Updates
        List<OpportunityLineItem> items = [Select Id, Med_Coverage_Code__c, Drug_Coverage_Code__c from OpportunityLineItem];
        System.assertEquals(items[0].Med_Coverage_Code__c, '005');
        System.assertEquals(items[0].Drug_Coverage_Code__c, '001');
    }
    
     static testmethod void testOpportunityRenewalDupsRatingClass() {

        TestDataFactory.setupOppsDupsRatingClass();
        
        Test.startTest();
            
        // Run the schedule job that executes the Batch class OpportunityRenewalBatch
        OpportunityRenewalOfRatingClassSchedule scheduleOppRenewal = new OpportunityRenewalOfRatingClassSchedule();
        scheduleOppRenewal.execute(null);
            
        Test.stopTest();

        // Assert Only 1 Renewal Opportunities was created
        System.assert([SELECT COUNT() from Opportunity] == 1);
         
        List<Opportunity> opps = [SELECT Id, Name, CloseDate, Effective_Date__c From Opportunity]; 
       
        // Assert Earliest Effective Date was created
        //System.assertEquals(opps[0].Effective_Date__c, Date.today()); 

        // Assert Renewal Opportunity Products were created
        System.assert([SELECT COUNT() FROM OpportunityLineItem] == 3);
         
        // Assert Billing Group Opp Products were created
        System.assert([SELECT COUNT() FROM Billing_Group_Opp_Product__c] == 3);
        
    }

    static testmethod void testExistingOpportunityRenewalRatingClass() {

        TestDataFactory.setupOppsExistRatingClass();
        
        Test.startTest();
            
        // Run the schedule job that executes the Batch class OpportunityRenewalBatch
        OpportunityRenewalOfRatingClassSchedule scheduleOppRenewal = new OpportunityRenewalOfRatingClassSchedule();
        scheduleOppRenewal.execute(null);
            
        Test.stopTest();

        // Assert Renewal Opportunities were created
        System.assert([SELECT COUNT() from Opportunity] > 0);

        // Assert Renewal Opportunity Products were created
        System.assert([SELECT COUNT() from OpportunityLineItem] == 0);
    }

    static testmethod void testOpportunityRenewalClosed() {

        TestDataFactory.setupOpps();
        
        Test.startTest();

        OpportunityRenewalClosedSchedule scheduleOppRenewalClosed = new OpportunityRenewalClosedSchedule();
        scheduleOppRenewalClosed.execute(null);

        Test.stopTest();

        // Assert Renewal Opportunities were created
        System.assert([SELECT COUNT() from Opportunity] > 0);

        List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity];

        //System.assertEquals(oppList[0].StageName, 'Closed Won');  
    }
}