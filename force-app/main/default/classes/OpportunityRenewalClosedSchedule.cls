global class OpportunityRenewalClosedSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		OpportunityRenewalClosedBatch opptyBatchObject = new OpportunityRenewalClosedBatch(); 
        Id batchId = Database.executeBatch(opptyBatchObject);
	}
}