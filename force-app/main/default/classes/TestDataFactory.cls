@isTest
public class TestDataFactory implements HttpCalloutMock {

    static List<Account> accounts; 
    static List<Billing_Group__c> groups; 
    static List<Billing_Product__c> products;
    static List<Opportunity> opps;  
    static Product2 product;

    static String oppRecTypeId = Schema.getGlobalDescribe()
            .get('Opportunity').getDescribe()
            .getRecordTypeInfosByName()
            .get('Assumptive Renewal')
            .getRecordTypeId();
        
    static String prospectRecTypeId = Schema.getGlobalDescribe()
            .get('Account').getDescribe()
            .getRecordTypeInfosByName()
            .get('Prospect')
            .getRecordTypeId();

    public HTTPResponse respond(HTTPRequest req) {
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

        insert new Coverage_Code__c(Coverage_Code_Type__c='Med Cov Code', 
                                    Current_Cov_Code__c='008', 
                                    New_Cov_Code__c='005',
                                    Start_Date__c=Date.today(), 
                                    Active_Through__c=Date.today().addMonths(12));
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
                                                //Account_ID__c=grp.account__c,
                                                Billing_Group__c =  grp.Id,
                                                Product__c=product.Id,
                                                Drug_Coverage_Code__c='009',
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
            //System.debug('###Rating_Class_Test: '+OpportunityRenewalHelper.integerToStringMonthsMap.get(Date.today().month()-7));
            
            //Integer startMonth = Date.today().month()-7;
            Integer ratingClass = Date.today().addMonths(-7).month();
            System.debug('###Rating_Class_Test: '+OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass));
            //Date renewalDate = startMonth<1 ? Date.newInstance(Date.today().year()-1, 12, 1) : Date.today().addDays(30);
            Date renewalDate = Date.today().addMonths(-7);
            groups.add(new Billing_Group__c(Rating_Class__c=OpportunityRenewalHelper.integerToStringMonthsMap.get(ratingClass),  
                Renewal_Date__c=renewalDate, 
                account__c=account.id, Agent_Code__c='C900'));
        }
        insert groups;

        for (Billing_Group__c grp : [select id, account__c from Billing_Group__c]) {
            products.add(new Billing_Product__c(name='Test', 
                                                //Account_ID__c=grp.account__c,
                                                Billing_Group__c =  grp.Id,
                                                Product__c=product.Id,
                                                Drug_Coverage_Code__c='009',
                                                Med_Coverage_Code__c='008',
                                                Vision_Coverage_Code__c='007'));
        }
        insert products;
        
        

    }
}