@isTest
public class ProductListControllerTest {
    static testMethod void testGetReleatedListsMetadata()
    {
		Test.startTest();                
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseUtil());  
        Object[] relatedListsMatadata = ProductListController.getReleatedListsMetadata('0010Y000003iFovQAE');
		System.assertEquals(true, relatedListsMatadata.size() > 0);        
        
        Test.stopTest();        
    }
    
    
    static testMethod void testGetReleatedListMetadata()
    {
        Test.startTest();       
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseUtil());        		
             
        Object relatedListsMatadata = ProductListController.getReleatedListMetadata('0010Y000003iFovQAE',
                                                                                            'Contacts');
		System.assertEquals(true, relatedListsMatadata != null);        
        
        Test.stopTest();         
    }

    static testMethod void testGetOpportunityProductMetadata()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseUtil());                              
        Object relatedListsMatadata = ProductListController.getOpportunityProductMetadata('0010Y000003iFovQAE', 
                                                                               'Contacts');        
        System.assertEquals(true, relatedListsMatadata != null);        
        
        Test.stopTest();
    } 
    
    static testMethod void testGetReleatedListItems()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseUtil());                              
        Object[] contacts = ProductListController.getReleatedListItems('0010Y000003iFovQAE', 
                                                                               'Contacts');        
		System.assertEquals(true, contacts.size()>0);         
        
        Test.stopTest();
    } 
    
   
    static testMethod void testSaveRelatedListItems()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseUtil());        
        
        Object[] contacts = ProductListController.getReleatedListItems('0010Y000003iFovQAE', 
                                                                               'Contacts');                
		Sobject acc = getNewSobject('Account');
        acc.put('Name', 'Test Account');
        insert acc;

        Sobject contact = getNewSobject('Contact');
        contact.put('AccountId', acc.get('Id'));
        contact.put('FirstName', 'Test');
        contact.put('LastName', 'Test');        
        insert contact;

        Map<String, Object> mContact = (Map<String, Object>)contacts.get(0);        
        mContact.put('AccountId', contact.get('AccountId'));
        mContact.put('Id', contact.get('Id'));        
        mContact.remove('OwnerId');

        Object[] candidates = ProductListController.getLookupCandidates('Account', 'Test');
        System.assertEquals(true, candidates.size() > 0);
        
		Boolean result = ProductListController.saveRelatedListItems(System.JSON.serialize(contacts),null,null);
        System.assertEquals(true, result);
          
        Test.stopTest();        
    }
    
    public static SObject getNewSobject(String typeName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        
        Schema.SObjectType st = gd.get(typeName);
        System.assert(st != null,'Type provided: "' + typeName + '" doesnt map to an sobject token in this org.');
        
        Sobject s = st.newSobject();        
        return s;
    }    
   
    static testMethod void testGetObject()
    {
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseUtil());                                
        Object jsonObj = ProductListController.getObject('0019E000006nVr3QAE');        
        System.assertEquals(true, jsonObj != null);        
        
        Test.stopTest();            
    }
    
    static testMethod void testDeleteObject()
    {
        Test.startTest();
        
        Sobject contact = getNewSobject('Contact');        
        contact.put('FirstName', 'Test');
        contact.put('LastName', 'Test');        
        insert contact;           
        
        //boolean result = ProductListController.deleteRelatedRecord(contact.Id);
        //System.assertEquals(true, result);
        
        Test.stopTest();
    }     
    
    static testMethod void testCreateRelatedObject()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseUtil()); 
        
        Sobject acc = getNewSobject('Account');
        acc.put('Name', 'Test Account');
        insert acc;

        Map<String, String> data = new Map<String, String>();
        data.put('AccountId', acc.id);
        data.put('lastname', 'Test');
        data.put('firstname', 'Test');        
                
        Id IdContact = ProductListController.createRelatedObject(acc.Id, 
                                                                         'Contact', 
                                                                         JSON.serialize(data));
        Test.stopTest();
        System.assertEquals(true, IdContact != null);
    }

    static testMethod void testGetBillingGroups()
    {
        Test.startTest();

        TestDataFactory.setupAcceptanceOppsWithBillingGroup();

        List<Opportunity> opps = [Select Id From Opportunity];        
        
        Object[] result = ProductListController.getBillingGroups(opps[0].Id);
        
        Test.stopTest();

        System.assert(result.size() > 0);
    }

    static testMethod void testGetSelectedBillingGroups()
    {
        Test.startTest();

        TestDataFactory.setupOppsWithBillingGroupOppProducts();

        List<Opportunity> opps = [Select Id From Opportunity];        
        
        Object[] result = ProductListController.getSelectedBillingGroups(opps[0].Id);
        
        Test.stopTest();
        System.assert(result.size() > 0);
    }

    static testMethod void testCreateBillingGroup()
    {
        Test.startTest();

        TestDataFactory.setupProposalAcceptanceOpps();

        List<OpportunityLineItem> items = [Select Id From OpportunityLineItem];   
        Billing_Group__c billGroup = new Billing_Group__c();     
        
        ProductListController.createBillingGroup(billGroup, items[0].Id);
        
        Test.stopTest();

        System.assert(billGroup.Id != null); 
        
        
    }

    static testMethod void testGetDomesticPartnershipAllowed()
    {
        Test.startTest();
         List<String> options = ProductListController.getDomesticPartnershipAllowed();
        Test.stopTest();
        system.assert(!options.isEmpty());
    }

    static testMethod void testGetRequestedRatingClass()
    {
        Test.startTest();
         List<String> options = ProductListController.getRequestedRatingClass();
        Test.stopTest();
        system.assert(options != null);
    }

    static testMethod void testGetRequestedCobraAdmin()
    {
        Test.startTest();
         List<String> options = ProductListController.getRequestedCobraAdmin();
        Test.stopTest();
        system.assert(options != null);
    }

    static testMethod void testGetRetroCancellationAllowance()
    {
        Test.startTest();
         List<String> options = ProductListController.getRetroCancellationAllowance();
        Test.stopTest();
        system.assert(options != null);
    }

    static testMethod void testGetRequestedCobraAdminOptions()
    {
        Test.startTest();
         List<ProductListController.SelectItem> options = ProductListController.getRequestedCobraAdminOptions();
        Test.stopTest();
        system.assert(options != null);
    }


}