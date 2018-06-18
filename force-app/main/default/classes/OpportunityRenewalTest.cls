@isTest
private class OpportunityRenewalTest {
    
    
    static testmethod void testOpportunityRenewalSchedule() {

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

    static testmethod void testOpportunityRenewalOfRatingClassSchedule() {

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
        
    }

    static testmethod void testOpportunityRenewalClosedSchedule() {

        TestDataFactory.setupOpps();
        
        Test.startTest();

        OpportunityRenewalClosedSchedule scheduleOppRenewalClosed = new OpportunityRenewalClosedSchedule();
        scheduleOppRenewalClosed.execute(null);

        Test.stopTest();

        // Assert Renewal Opportunities were created
        System.assert([SELECT COUNT() from Opportunity] > 0);

        List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity];

        System.assertEquals(oppList[0].StageName, 'Closed Won');  
    }
}