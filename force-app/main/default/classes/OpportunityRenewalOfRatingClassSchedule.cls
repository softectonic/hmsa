global class OpportunityRenewalOfRatingClassSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		OpportunityRenewalOfRatingClassBatch opptyBatchObject = new OpportunityRenewalOfRatingClassBatch(); 
        Id batchId = Database.executeBatch(opptyBatchObject);
	}
}