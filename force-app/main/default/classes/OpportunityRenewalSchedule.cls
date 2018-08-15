/*****************************************************************
Name:  OpportunityRenewalSchedule
 
=================================================================
Purpose: 
Job Scheduler for auto Opportunity Renewal Batch process	                                                                                                                     
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS: 
*****************************************************************/

global class OpportunityRenewalSchedule implements Schedulable {

    // Execute the batch process that Create Opportunities 60 days before renewal
    global void execute (SchedulableContext ctx) {
        OpportunityRenewalBatch opptyBatchObject = new OpportunityRenewalBatch(); 
        Id batchId = Database.executeBatch(opptyBatchObject);
    }
}