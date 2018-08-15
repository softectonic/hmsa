/*****************************************************************
Name:  OpportunityRenewalOfRatingClassSchedule
 
=================================================================
Purpose: 
Job Scheduler for auto Opportunity Renewal Batch process	                                                                                                                     
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS: 
*****************************************************************/

global class OpportunityRenewalOfRatingClassSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        OpportunityRenewalOfRatingClassBatch opptyBatchObject = new OpportunityRenewalOfRatingClassBatch(); 
        Id batchId = Database.executeBatch(opptyBatchObject);
    }
}