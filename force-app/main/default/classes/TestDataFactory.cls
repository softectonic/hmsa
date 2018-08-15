/*****************************************************************
Name:  TestDataFactory
 
=================================================================
Purpose: 
Common unit test suites
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS:
*****************************************************************/

@isTest
public class TestDataFactory implements HttpCalloutMock {

    static List<Account> accounts; 
    static List<Contact> contacts; 
    static List<Billing_Group__c> groups; 
    static List<Billing_Product__c> products;
    static List<Opportunity> opps;  
    static List<OpportunityLineItem> oppProducts; 
    static List<Billing_Group_Opp_Product__c> grpOppProducts; 
    static Product2 product;

    static String oppRecTypeId = Schema.getGlobalDescribe()
                                        .get('Opportunity').getDescribe()
                                        .getRecordTypeInfosByName()
                                        .get('Assumptive Renewal')
                                        .getRecordTypeId();

    static String oppRenewalTypeId = Schema.getGlobalDescribe()
                                            .get('Opportunity').getDescribe()
                                            .getRecordTypeInfosByName()
                                            .get('Renewal')
                                            .getRecordTypeId();
        
    static String prospectRecTypeId = Schema.getGlobalDescribe()
                                            .get('Account').getDescribe()
                                            .getRecordTypeInfosByName()
                                            .get('Prospect')
                                            .getRecordTypeId();

    static Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                                                            .get('Customer')
                                                            .getRecordTypeId();  


    static public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        return res;
    }
    
    public static void setupCommon() {

        product = new Product2(Name='Test', ProductCode='BPE');
        insert product;

        insert new PriceBookEntry(UnitPrice = 100,
                                    PriceBook2Id = Test.getStandardPricebookId(),
                                    Product2Id = product.Id,
                                    IsActive = true);

        insert new AMS_App_Config__c(Days_Before_Oppty_Renewal__c='60',
                                    Days_Post_Oppty_Renewal__c='30',
                                    Months_Post_Rating_Class__c='7');
		
        List<Coverage_Code__c> covCodes = new List<Coverage_Code__c>();
        covCodes.add(new Coverage_Code__c(Coverage_Code_Type__c='Med Cov Code', 
                                    Current_Cov_Code__c='008', 
                                    New_Cov_Code__c='005',
                                    Start_Date__c=Date.today(), 
                                    Active_Through__c=Date.today().addMonths(12)));
         covCodes.add(new Coverage_Code__c(Coverage_Code_Type__c='Drug Cov Code', 
                                    Current_Cov_Code__c='008', 
                                    New_Cov_Code__c='001',
                                    Start_Date__c=Date.today(), 
                                    Active_Through__c=Date.today().addMonths(12)));
        insert covCodes;
        
    }

    
    //@testSetup 
    public static void setup() {

        setupCommon();

        accounts = new List<Account>();
        groups = new List<Billing_Group__c>();
        products = new List<Billing_Product__c>();
        
        for (Integer i=0;i<5;i++) {
            accounts.add(new Account(name='Account '+i, 
                billingcity='New York', billingcountry='USA',
                RecordTypeId=prospectRecTypeId));
        }
        insert accounts;
        
        // find the account just inserted. Add billing group and billing product for each
        for (Account account : [select id from account]) {
            groups.add(new Billing_Group__c(Rating_Class__c='June', 
                Renewal_Date__c=Date.today().addDays(60), 
                account__c=account.id, Agent_Code__c='C000'));
        }
        insert groups;

        for (Billing_Group__c grp : [select id, account__c from Billing_Group__c]) {
            products.add(new Billing_Product__c(name='Test', 
                                                Billing_Group__c =  grp.Id,
                                                Product__c=product.Id,
                                                Drug_Coverage_Code__c='008',
                                                Med_Coverage_Code__c='008',
                                                Vision_Coverage_Code__c='007'));
        }
        insert products;
    }

    public static void setupOpps() {

        setupCommon();

        accounts = new List<Account>();
        groups = new List<Billing_Group__c>();
        opps = new  List<Opportunity>();

        for (Integer i=0;i<5;i++) {
            accounts.add(new Account(name='Account '+i, 
                billingcity='New York', billingcountry='USA',
                RecordTypeId=prospectRecTypeId));
        }
        insert accounts;

        // find the account just inserted. Add billing group for each
        for (Account account : [select id from account]) {
            groups.add(new Billing_Group__c(Rating_Class__c='June', 
                Renewal_Date__c=Date.today().addDays(30), 
                account__c=account.id, Agent_Code__c='C000'));
        }
        insert groups;

        for (Account account : [select Id, Name from account]) {
            opps.add(new Opportunity(Name='Assumptive Renewal for '+ account.Name, 
                                    CloseDate=Date.today().addDays(30),
                                    Effective_Date__c=Date.today().addDays(30),
                                    RecordTypeId=oppRecTypeId,
                                    Expected_Member_Percent__c=100,
                                    AccountId=account.Id,
                                    Rate_Benefit_info_with_confirmation__c='N/A',
                                    Contract_Type__c='Evergreen',
                                    Jeopardy_Status__c='Not in Jeopardy',
                                    StageName='New'));
        }
        insert opps;
    }

    public static void setupOppsRatingClass() {

       setupCommon();
        
        accounts = new List<Account>();
        groups = new List<Billing_Group__c>();
        products = new List<Billing_Product__c>();
        
        for (Integer i=0;i<5;i++) {
            accounts.add(new Account(name='Account '+i, 
                billingcity='New York', billingcountry='USA',
                RecordTypeId=prospectRecTypeId));
        }
        insert accounts;
        
        // find the account just inserted. Add billing group and billing product for each
        for (Account account : [select id from account]) {
            Integer ratingClass = Date.today().addMonths(7).month();
  			Date renewalDate = Date.today();
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                Renewal_Date__c=renewalDate, account__c=account.id, Agent_Code__c='C900'));
        }
        insert groups;

        for (Billing_Group__c grp : [select id, account__c from Billing_Group__c]) {
            products.add(new Billing_Product__c(name='Test', 
                                                Billing_Group__c =  grp.Id,
                                                Product__c=product.Id,
                                                Drug_Coverage_Code__c='008',
                                                Med_Coverage_Code__c='008',
                                                Vision_Coverage_Code__c='007'));
        }
        insert products;
    }
    
     public static void setupOppsDupsRatingClass() {

       setupCommon();
        
        accounts = new List<Account>();
        groups = new List<Billing_Group__c>();
        products = new List<Billing_Product__c>();
        
        for (Integer i=0;i<1;i++) {
            accounts.add(new Account(name='Account '+i, 
                billingcity='New York', billingcountry='USA',
                RecordTypeId=prospectRecTypeId));
        }
        insert accounts;
        
        // find the account just inserted. Add billing group and billing product for each
        for (Account account : [select id from account]) {
            Integer ratingClass = Date.today().addMonths(7).month();
  			Date renewalDate = Date.today();
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                Renewal_Date__c=renewalDate.addDays(10), account__c=account.id, Agent_Code__c='C700'));
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                Renewal_Date__c=renewalDate, account__c=account.id, Agent_Code__c='C800'));
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                Renewal_Date__c=renewalDate.addDays(5), account__c=account.id, Agent_Code__c='C900'));
        }
        insert groups;

        for (Billing_Group__c grp : [select id, account__c from Billing_Group__c]) {
            products.add(new Billing_Product__c(name='Test', 
                                                Billing_Group__c =  grp.Id,
                                                Product__c=product.Id,
                                                Drug_Coverage_Code__c='009',
                                                Med_Coverage_Code__c='008',
                                                Vision_Coverage_Code__c='007'));
        }
        insert products;
    }

    public static void setupOppsExistRatingClass() {
        
        setupOppsRatingClass();

        opps = new  List<Opportunity>();
        Integer counter = 0;
        for (Account account : [Select Id, Name, OwnerId From Account]) {
            opps.add(new Opportunity(Name='Renewal for '+ account.Name, 
                                    CloseDate=Date.today().addMonths(-7),
                                    RecordTypeId=oppRenewalTypeId,
                                    Expected_Member_Percent__c=100,
                                    AccountId=account.Id,
                                    Initiating_Billing_Group__c=groups[counter].Id,
                                    OwnerId=account.OwnerId,
                                    StageName='Planning'));
            counter++;
        }
        insert opps;

     }

    public static void setupProposalAcceptanceOpps() {

        setupCommon();

        accounts = new List<Account>();
        opps = new  List<Opportunity>();
        oppProducts = new List<OpportunityLineItem>();

        for (Integer i=0;i<5;i++) {
            accounts.add(new Account(Name='Account '+i, 
                                    BillingCity='New York', 
                                    BillingCountry='USA',
                                    RecordTypeId=prospectRecTypeId,
                                    Funding_Type__c='Fully Insured',
                                    Funding_Mechanism__c='Community Rated Group (CRG)'));
        }
        insert accounts;


        for (Account account : [select Id, Name from account]) {
            opps.add(new Opportunity(Name='Assumptive Renewal for '+ account.Name, 
                                    CloseDate=Date.today().addDays(30),
                                    RecordTypeId=oppRecTypeId,
                                    AccountId=account.Id,
                                    Effective_Date__c=Date.today(),
                                    Effective_End_Date__c = Date.today(),
                                    Reason_for_Shopping__c='Price',
                                    Contract_Sending_Method__c='Hard Copy - Mailed by SAS',
                                    Rate_Benefit_info_with_confirmation__c='Yes',
                                    Contract_Type__c='Annual',
                                    Won_Reason__c='Network', 
                                    Employee_Count__c=3, 
                                    StageName='New'));

        }
        insert opps;

        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry];
        for(Opportunity opp : [Select Id, Name from Opportunity]) {
           oppProducts.add(new OpportunityLineItem(UnitPrice=0.0, 
                                                PricebookEntryId=pbe.Id,
                                                OpportunityId=opp.Id,
                                                Product2Id=product.Id,
                                                Quantity=1));
        }
        insert oppProducts;
    }
    
    public static void setupAcceptanceOppsWithBillingGroup() {

        setupCommon();

        accounts = new List<Account>();
        groups = new List<Billing_Group__c>();
        opps = new  List<Opportunity>();
        oppProducts = new List<OpportunityLineItem>();

        for (Integer i=0;i<5;i++) {
            accounts.add(new Account(Name='Account '+i, 
                                    BillingCity='New York', 
                                    BillingCountry='USA',
                                    RecordTypeId=prospectRecTypeId,
                                    Funding_Type__c='Fully Insured',
                                    Funding_Mechanism__c='Community Rated Group (CRG)'));
        }
        insert accounts;
        
        for (Account account : [select id from account]) {
            Integer ratingClass = Date.today().month();
            Date renewalDate = Date.today();
            
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                							Renewal_Date__c=renewalDate, 
                                            Group_Status__c='Pending',
                                            account__c=account.id, 
                                            Agent_Code__c='C900'));
        }
        insert groups;
        
        for (Account account : [select Id, Name from account]) {
            opps.add(new Opportunity(Name='Assumptive Renewal for '+ account.Name, 
                                    CloseDate=Date.today().addDays(30),
                                    RecordTypeId=oppRecTypeId,
                                    AccountId=account.Id,
                                    Effective_Date__c=Date.today(),
                                    Effective_End_Date__c = Date.today(),
                                    Reason_for_Shopping__c='Price',
                                    Contract_Sending_Method__c='Hard Copy - Mailed by SAS',
                                    Rate_Benefit_info_with_confirmation__c='Yes',
                                    Contract_Type__c='Annual',
                                    Won_Reason__c='Network', 
                                    Employee_Count__c=3, 
                                    StageName='New'));

        }
        insert opps;
        
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry];
        for(Opportunity opp : [Select Id, Name from Opportunity]) {
           oppProducts.add(new OpportunityLineItem(UnitPrice=0.0, 
                                                PricebookEntryId=pbe.Id,
                                                OpportunityId=opp.Id,
                                                Product2Id=product.Id,
                                                Quantity=1));
        }
        insert oppProducts;
    }

    public static void setupOppsWithBillingGroupOppProducts() {

        setupCommon();

        accounts = new List<Account>();
        groups = new List<Billing_Group__c>();
        opps = new  List<Opportunity>();
        oppProducts = new List<OpportunityLineItem>();
        grpOppProducts = new List<Billing_Group_Opp_Product__c>(); 

        for (Integer i=0;i<5;i++) {
            accounts.add(new Account(Name='Account '+i, 
                                    BillingCity='New York', 
                                    BillingCountry='USA',
                                    RecordTypeId=prospectRecTypeId,
                                    Funding_Type__c='Fully Insured',
                                    Funding_Mechanism__c='Community Rated Group (CRG)'));
        }
        insert accounts;
        
        for (Account account : [select id from account]) {
            Integer ratingClass = Date.today().month();
            Date renewalDate = Date.today();
            
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                                            Renewal_Date__c=renewalDate, 
                                            Group_Status__c='Pending',
                                            account__c=account.id, 
                                            Agent_Code__c='C900'));
        }
        insert groups;
        
        for (Account account : [select Id, Name from account]) {
            opps.add(new Opportunity(Name='Assumptive Renewal for '+ account.Name, 
                                    CloseDate=Date.today().addDays(30),
                                    RecordTypeId=oppRecTypeId,
                                    AccountId=account.Id,
                                    Effective_Date__c=Date.today(),
                                    Effective_End_Date__c = Date.today(),
                                    Reason_for_Shopping__c='Price',
                                    Contract_Sending_Method__c='Hard Copy - Mailed by SAS',
                                    Rate_Benefit_info_with_confirmation__c='Yes',
                                    Contract_Type__c='Annual',
                                    Won_Reason__c='Network', 
                                    Employee_Count__c=3, 
                                    StageName='New'));

        }
        insert opps;
        
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry];
        for(Opportunity opp : [Select Id, Name from Opportunity]) {
           oppProducts.add(new OpportunityLineItem(UnitPrice=0.0, 
                                                PricebookEntryId=pbe.Id,
                                                OpportunityId=opp.Id,
                                                Product2Id=product.Id,
                                                Billing_Group__c=groups[0].Id,
                                                Quantity=1));
        }
        insert oppProducts;

        for(OpportunityLineItem oppItem : [Select Id, Name, OpportunityId, Billing_Group__c from OpportunityLineItem]) {
           grpOppProducts.add(new Billing_Group_Opp_Product__c(Opportunity_Product_ID__c=oppItem.Id,
                                                Opportunity__c=oppItem.OpportunityId,
                                                Billing_Group__c=oppItem.Billing_Group__c));
        }
        insert grpOppProducts;
    }
    
     public static void setupOpportunityWithMissingData(String stageName) {

        setupCommon();

        accounts = new List<Account>();
        contacts = new List<Contact>();
        groups = new List<Billing_Group__c>();
        opps = new  List<Opportunity>();
        oppProducts = new List<OpportunityLineItem>();
        grpOppProducts = new List<Billing_Group_Opp_Product__c>(); 

        for (Integer i=0;i<1;i++) {
            accounts.add(new Account(Name='Account '+i, 
                                    BillingCity='New York', 
                                    BillingCountry='USA',
                                    RecordTypeId=prospectRecTypeId,
                                    Funding_Type__c='Fully Insured',
                                    Funding_Mechanism__c='Community Rated Group (CRG)'));

            contacts.add(new Contact(FirstName='First'+i, LastName='Last'+i));
        }
        insert accounts;
        insert contacts;

        
        for (Account account : [select id from account]) {
            Integer ratingClass = Date.today().month();
            Date renewalDate = Date.today();
            
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                							Renewal_Date__c=renewalDate, 
                                            Group_Status__c='Pending',
                                            Account__c=account.id, 
                                            Requested_Agent_Code__c=null, 
                         					Requested_Rating_Class__c=null,
                         					Retro_Cancellation_Allowance__c=null,
                         					Domestic_Partnership_Allowed__c=null));
        }
        insert groups;
        
        for (Account account : [select Id, Name from account]) {
            opps.add(new Opportunity(Name='Assumptive Renewal for '+ account.Name, 
                                    CloseDate=Date.today().addDays(30),
                                    RecordTypeId=oppRecTypeId,
                                    AccountId=account.Id,
                                    Employee_Count__c=3, 
                                    Effective_Date__c=Date.today(),
                                    Contract_Sending_Method__c='Hard Copy - Mailed by SAS',
                                    Rate_Benefit_info_with_confirmation__c='Yes',
                                    Won_Reason__c='Network',  
                                    Contract_Type__c='Annual', 
                                    Reason_for_Shopping__c='Price', 
                                    Effective_End_Date__c=Date.today(),
                                    GPA_Notice_Contact__c=contacts[0].Id,
                                    StageName=stageName));

        }
        insert opps;
        
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry];
        for(Opportunity opp : [Select Id, Name from Opportunity]) {
           oppProducts.add(new OpportunityLineItem(UnitPrice=0.0, 
                                                PricebookEntryId=pbe.Id,
                                                OpportunityId=opp.Id,
                                                Product2Id=product.Id,
                                                Billing_Group__c=groups[0].Id,   
                                                Quantity=1));
        }
        insert oppProducts;
        
        for(OpportunityLineItem oppItem : [Select Id, Name, OpportunityId, Billing_Group__c from OpportunityLineItem]) {
           grpOppProducts.add(new Billing_Group_Opp_Product__c(Opportunity_Product_ID__c=oppItem.Id,
                                                Opportunity__c=oppItem.OpportunityId,
                                                Billing_Group__c=oppItem.Billing_Group__c));
        }
        insert grpOppProducts;
         
    }
    
    public static void setupOpportunityWithCompleteData(String stageName) {

        setupCommon();

        accounts = new List<Account>();
        contacts = new List<Contact>();
        groups = new List<Billing_Group__c>();
        opps = new  List<Opportunity>();
        oppProducts = new List<OpportunityLineItem>();
        grpOppProducts = new List<Billing_Group_Opp_Product__c>(); 

        for (Integer i=0;i<1;i++) {
            accounts.add(new Account(Name='Account '+i, 
                                    BillingCity='New York', 
                                    BillingCountry='USA',
                                    RecordTypeId=customerRecTypeId,
                                    Funding_Type__c='Fully Insured',
                                    Funding_Mechanism__c='Community Rated Group (CRG)'));

            contacts.add(new Contact(FirstName='First'+i, LastName='Last'+i));
        }
        insert accounts;
        insert contacts;
        
        for (Account account : [select id from account]) {
            Integer ratingClass = Date.today().month();
            Date renewalDate = Date.today();
            
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                							Renewal_Date__c=renewalDate, 
                                            Group_Status__c='Active',
                                            Account__c=account.id, 
                                            Requested_Agent_Code__c='C009', 
                         					Requested_Rating_Class__c='April',
                         					Retro_Cancellation_Allowance__c='60',
                         					Domestic_Partnership_Allowed__c='No'));
        }
        insert groups;
        //List<Billing_Group__c> groupList = [Select Id, Account__r.RecordType.DeveloperName From Billing_Group__c];
        //System.debug('###groups: '+groupList[0].Account__r.RecordType.DeveloperName);
        for (Account account : [select Id, Name from account]) {
            opps.add(new Opportunity(Name='Assumptive Renewal for '+ account.Name, 
                                    CloseDate=Date.today().addDays(30),
                                    RecordTypeId=oppRecTypeId,
                                    AccountId=account.Id,
                                    Reason_for_Shopping__c='Price',
                                    Contract_Sending_Method__c='Hard Copy - Mailed by SAS',
                                    Rate_Benefit_info_with_confirmation__c='Yes',
                                    Contract_Type__c='Annual',
                                    Won_Reason__c='Network', 
                                    Employee_Count__c=3, 
                                    Effective_Date__c=Date.today(),
                                    Effective_End_Date__c=Date.today(),
                                    GPA_Notice_Contact__c=contacts[0].Id,
                                    Send_Contract_To__c=contacts[0].Id,
                                    StageName=stageName));

        }
        insert opps;
        
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry];
        for(Opportunity opp : [Select Id, Name from Opportunity]) {
           oppProducts.add(new OpportunityLineItem(UnitPrice=100.0, 
                                                PricebookEntryId=pbe.Id,
                                                OpportunityId=opp.Id,
                                                Product2Id=product.Id,
                                                Billing_Group__c=groups[0].Id,   
                                                Quantity=1));
        }
        insert oppProducts;
        
        for(OpportunityLineItem oppItem : [Select Id, Name, OpportunityId,Billing_Group__c from OpportunityLineItem]) {
           grpOppProducts.add(new Billing_Group_Opp_Product__c(Opportunity_Product_ID__c=oppItem.Id,
                                                Opportunity__c=oppItem.OpportunityId,
                                                Billing_Group__c=oppItem.Billing_Group__c));
        }
        insert grpOppProducts;
         
    }
    
    public static User getTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='AMS Account Manager'];
        User user = new User(Alias ='testUser', 
                            Email='testuser@testorg.com',
         					EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US',
         					LocaleSidKey='en_US', 
                            ProfileId=p.Id,
         					TimeZoneSidKey='America/Los_Angeles', 
                            UserName='testonic@testorg.com');
        return user;
    }
}