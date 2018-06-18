global class OpportunityRenewalSchedule implements Schedulable {

    // Execute the batch process that Create Opportunities 60 days before renewal
    global void execute (SchedulableContext ctx) {
        OpportunityRenewalBatch opptyBatchObject = new OpportunityRenewalBatch(); 
        Id batchId = Database.executeBatch(opptyBatchObject);
    }
}