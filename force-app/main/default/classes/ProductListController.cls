/*****************************************************************
Name:  ProductListController
 
=================================================================
Purpose: 
Apex Controller for Group Product Mgmt custom component                                                                                                                       
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS: 
*****************************************************************/

public with sharing class ProductListController {
    
    public static Map<Schema.DisplayType, String> typesMap = new Map<Schema.DisplayType, String>();
    
    static {
        typesMap.put(Schema.DisplayType.TextArea, 'TextArea');
        typesMap.put(Schema.DisplayType.STRING, 'String');
        typesMap.put(Schema.DisplayType.BOOLEAN, 'Boolean');
        typesMap.put(Schema.DisplayType.COMBOBOX, 'Combobox');
        typesMap.put(Schema.DisplayType.CURRENCY, 'Currency');
        typesMap.put(Schema.DisplayType.DATE, 'Date');
        typesMap.put(Schema.DisplayType.DATETIME, 'Datetime');
        typesMap.put(Schema.DisplayType.DOUBLE, 'Double');
        typesMap.put(Schema.DisplayType.ADDRESS, 'Adress');
        typesMap.put(Schema.DisplayType.EMAIL, 'Email');
        typesMap.put(Schema.DisplayType.INTEGER, 'Integer');
        typesMap.put(Schema.DisplayType.PERCENT, 'Percent');
        typesMap.put(Schema.DisplayType.MULTIPICKLIST, 'Multi PickList');
        typesMap.put(Schema.DisplayType.PICKLIST, 'PickList');
        typesMap.put(Schema.DisplayType.PHONE, 'Phone');
        typesMap.put(Schema.DisplayType.REFERENCE, 'Reference');
        typesMap.put(Schema.DisplayType.URL, 'Url');       
    }
    
    /**
    * Clean the related list metadata
	* -If the field is AutoNumber or Calculated set the type to Formula. Otherwise set the type from the map
	* -If the column is not an inner field set the type to Reference
	* -If the field is not accessible remove the field from columns list  
	* */
    private static void cleanRelatedListMetadata(Map<String, Object> mRelatedListMetadata)
    {
        Object[] columns = (Object[] )mRelatedListMetadata.get('columns');                
        String relatedObjectName = (String)mRelatedListMetadata.get('sobject');
        
        Schema.SObjectType relatedObjType = Schema.getGlobalDescribe().get(relatedObjectName);
        Schema.DescribeSObjectResult relatedObjDesc = relatedObjType.getDescribe();        

        for(Integer i=0; i<columns.size(); i++){
            Map<String, Object> mColumn = (Map<String, Object>) columns.get(i);
            String columnKey = (String)mColumn.get('name');

            //If it's a Picklist field
            if(columnKey.startsWith('toLabel(')){
                columnKey = columnKey.substringBetween('toLabel(', ')');
                mColumn.put('name', columnKey);
            }
            //If it's a Reference field
            if(columnKey.endsWith('.Name')){                
                mColumn.put('refObjName', ((String)mColumn.get('field')).replace('.Name', ''));
                if(mColumn.get('lookupId')!=null){
                    columnKey = ((String)mColumn.get('lookupId')).replace('.', '');
                    mColumn.put('name', columnKey); 
                }
            }
            
            Schema.SObjectField sfield = relatedObjDesc.fields.getMap().get(columnKey);           
            if(sfield != null){
                DescribeFieldResult fieldDescResult = sfield.getDescribe(); 
                
                if(fieldDescResult.isAccessible()){
                    //Set requied flag
                    mColumn.put('required', JSON.serialize(!fieldDescResult.isNillable()));
                    
                    //Set precision
                    mColumn.put('precision', JSON.serialize(fieldDescResult.getPrecision()));
                    
                    //Set picklistValues
                    mColumn.put('options', JSON.serialize(fieldDescResult.getPicklistValues()));
                    
                    //Set digits
                    mColumn.put('digits', JSON.serialize(fieldDescResult.getDigits()));
                    
                    //Set length
                    mColumn.put('length', JSON.serialize(fieldDescResult.getLength()));
                    
                    //Set type
                    mColumn.put('type', typesMap.get(fieldDescResult.getType()));        
                    
                    //Set type for Formula Fields
                    if(fieldDescResult.isCalculated()){
                        mColumn.put('calculatedType', mColumn.get('type')); 
                        mColumn.put('type', 'Formula');                           
                    }   
                    
 					//Set type for AutoNumber Fields
                    if(fieldDescResult.isAutoNumber()){
                        mColumn.put('calculatedType', mColumn.get('type')); 
                        mColumn.put('type', 'ItemLink');                           
                    }                       
                }else{
                    columns.remove(i);
                }                            
            }else{
                mColumn.put('type', 'Reference');                    
            }
        }
    }
    
   /**
    * Clean the opportunity product metadata
	* -If the field is AutoNumber or Calculated set the type to Formula. Otherwise set the type from the map
	* -If the column is not an inner field set the type to Reference
	* -If the field is not accessible remove the field from columns list  
	* */
    private static void cleanOpportunityProductMetadata(Map<String, Object> mRelatedListMetadata)
    {
        Object[] columns = (Object[] )mRelatedListMetadata.get('columns');
        
        /* 
        String groupJson = '{"field":"OpportunityLineItem.Billing_Group__c","fieldApiName":"Billing_Group__c","format":"null","label":"Billing Group","lookupId":"Id","name":"Billing_Group__c","refObjName":"Billing_Group__c"}';       
        columns.add( (Object)JSON.deserializeUntyped(groupJson));
        */
        
        String relatedObjectName = (String)mRelatedListMetadata.get('sobject');        
        Schema.SObjectType relatedObjType = Schema.getGlobalDescribe().get(relatedObjectName);
        Schema.DescribeSObjectResult relatedObjDesc = relatedObjType.getDescribe();       
        
        //System.debug('***column size: '+columns.size());
        for(Integer i=0; i<columns.size(); i++) {
            Map<String, Object> mColumn = (Map<String, Object>) columns.get(i);
            //System.debug('***mColumn__'+i+': ' +mColumn);  
            String columnKey = (String)mColumn.get('name');             
                       
            //If it's a Picklist field
            if(columnKey.startsWith('toLabel(')){
                columnKey = columnKey.substringBetween('toLabel(', ')');
                mColumn.put('name', columnKey);
            }
            //If it's a Reference field
            if(columnKey.endsWith('.Name')){                
                mColumn.put('refObjName', ((String)mColumn.get('field')).replace('.Name', ''));
                if(mColumn.get('lookupId')!=null){
                    columnKey = ((String)mColumn.get('lookupId')).replace('.', '');
                    //mColumn.put('name', 'columnKey');  
                    //mColumn.put('name', 'Name'); 
                    if(columnKey == 'Id') {
                        mColumn.put('name', 'ProductCode');
                    } else {
                        mColumn.put('name', columnKey);
                    }
                }
            }
            
            Schema.SObjectField sfield = relatedObjDesc.fields.getMap().get(columnKey);
            if(sfield != null){
                DescribeFieldResult fieldDescResult = sfield.getDescribe();      
                //System.debug('***fieldDescResult: '+columnKey+' : '+fieldDescResult); 
                if(fieldDescResult.isAccessible()) {
                       
                    //Set requied flag
                    mColumn.put('required', JSON.serialize(!fieldDescResult.isNillable()));
                    
                    //Set precision
                    mColumn.put('precision', JSON.serialize(fieldDescResult.getPrecision()));
                    
                    //Set picklistValues
                    mColumn.put('options', JSON.serialize(fieldDescResult.getPicklistValues()));
                    
                    //Set digits
                    mColumn.put('digits', JSON.serialize(fieldDescResult.getDigits()));
                    
                    //Set length
                    mColumn.put('length', JSON.serialize(fieldDescResult.getLength()));
                    
                    //Set type
                    mColumn.put('type', typesMap.get(fieldDescResult.getType()));        
                    
                    //Set type for Formula Fields
                    if(fieldDescResult.isCalculated()){
                        mColumn.put('calculatedType', mColumn.get('type')); 
                        mColumn.put('type', 'Formula');                           
                    }   
                    
 					//Set type for AutoNumber Fields
                    if(fieldDescResult.isAutoNumber()){
                        mColumn.put('calculatedType', mColumn.get('type')); 
                        mColumn.put('type', 'ItemLink');                           
                    }
                }
                else {
                    columns.remove(i);
                } 
            }
            else {
                mColumn.put('type', 'Reference');                    
            }
        }
        // Remove the columns not being displayed
        Integer j = 0;
		while (j < columns.size())
		{
            Map<String, Object> column = (Map<String, Object>) columns.get(j);
            String columnKey = (String)column.get('name'); 
  			if(columnKey == 'Quantity'
               || columnKey == 'ServiceDate'
               || columnKey == 'ListPrice'
               || columnKey == 'Annualized_Revenue__c') {
                  columns.remove(j); 
            } else {
    			j++;
  			}
		}
        System.debug('***columns - required: '+columns); 
    }
    
    /**
    * Return the list of related metadata information
    * */
    @AuraEnabled
    public static Object[] getReleatedListsMetadata(Id objectId)
    {
        String recordTypeName = RestAPIUtils.getObjectRecordTypeName(objectId);
        if(recordTypeName=='Master' || recordTypeName=='Principal'){
            recordTypeName = null;
        }
        Object[] relatedListsMetatdata = RestAPIUtils.getRelatedListsMetadata(objectId, 
                                                                              recordTypeName);
        
        for(Object relatedListMetadata : relatedListsMetatdata){
            cleanRelatedListMetadata((Map<String, Object>)relatedListMetadata); 
        }
        return relatedListsMetatdata;
    }
    
    /**
    * Return the metadata of the related list
    * */
    @AuraEnabled
    public static Object getReleatedListMetadata(Id objectId, 
                                                 String relatedListLabel)
    {
        String recordTypeName = RestAPIUtils.getObjectRecordTypeName(objectId);
        if(recordTypeName=='Master' || recordTypeName=='Principal'){
            recordTypeName = null;
        }
        Object[] relatedListsMetatdata = RestAPIUtils.getRelatedListsMetadata(objectId, 
                                                                              recordTypeName);
        for(Object relatedListMetadata : relatedListsMetatdata){
            Map<String, Object> mRelatedListMetadata = (Map<String, Object>)relatedListMetadata;
            if(mRelatedListMetadata.get('label') == relatedListLabel){
                cleanRelatedListMetadata(mRelatedListMetadata); 
                return mRelatedListMetadata;
            }
        }                
        return null;
    } 
    
   /**
    * Return the metadata of the opportunity product
    * */
    @AuraEnabled
    public static Object getOpportunityProductMetadata(Id objectId, 
                                                 String relatedListLabel)
    {
        String recordTypeName = RestAPIUtils.getObjectRecordTypeName(objectId);
        if(recordTypeName=='Master' || recordTypeName=='Principal'){
            recordTypeName = null;
        }
        Object[] relatedListsMetatdata = RestAPIUtils.getRelatedListsMetadata(objectId, 
                                                                              recordTypeName);
        for(Object relatedListMetadata : relatedListsMetatdata){
            Map<String, Object> mRelatedListMetadata = (Map<String, Object>)relatedListMetadata;
             if(mRelatedListMetadata.get('label') == relatedListLabel){
            	cleanOpportunityProductMetadata(mRelatedListMetadata); 
            	return mRelatedListMetadata;
            }
        }                
        return null;
    }  
    
    /**
    * Return the the related list items
    * */
    @AuraEnabled
    public static Object[] getReleatedListItems(Id objectId, 
                                                String relatedlistName)
    {            
        Object[] items = RestAPIUtils.getRelatedListItems(objectId, 
                                                          relatedlistName);
        
        if(items.size()>0){        
            Id firstChildId = (Id)((Map<String, Object>) items.get(0)).get('Id');            
        	DescribeSObjectResult objectDescResult = firstChildId.getSobjectType().getDescribe();
            
        	Map<String, DescribeFieldResult> lookupFields = new Map<String,DescribeFieldResult>();  
            Map<String, DescribeFieldResult> pickListFields = new Map<String,DescribeFieldResult>();    
            Map<String, DescribeFieldResult> percentFields = new Map<String,DescribeFieldResult>();    
            
            for(Schema.SObjectField sfield : objectDescResult.fields.getMap().Values()){ 
                DescribeFieldResult fieldDescResult = sfield.getDescribe();
                if(fieldDescResult.getType()==Schema.DisplayType.REFERENCE){                        
                    lookupFields.put(fieldDescResult.getName(), fieldDescResult);
                } 
                
                if(fieldDescResult.getType()==Schema.DisplayType.PICKLIST){                        
                    pickListFields.put(fieldDescResult.getName(), fieldDescResult);
                } 
                
                if(fieldDescResult.getType()==Schema.DisplayType.PERCENT){                        
                    percentFields.put(fieldDescResult.getName(), fieldDescResult);
                } 
            }   
		
            //Set the lookup labels based on the field type
            for(String fieldKey : lookupFields.keySet()){
                Set<Id> lookupIds = new Set<Id>();
                Map<Id, List<Object>> lookupMap = new Map<Id, List<Object>>();                
                
                //Build the list of IDs
                for(Object item : items){
                    Map<String, Object> mItem = (Map<String, Object>) item;
                    if(mItem.containsKey(fieldKey)){
                        Id lookupId = (Id)mItem.get(fieldKey);
                        if(lookupId != null){
                            lookupIds.add(lookupId); 
                            if(!lookupMap.containsKey(lookupId)){
                                lookupMap.put(lookupId, new List<Object>());
                            }
                            lookupMap.get(lookupId).add(mItem);
                        }                        
                    }
                }
                               
                //Do SOQL query based on the ID list
                if(!lookupIds.isEmpty()){
                    SObject[] lookupObjs = getLookupObjects(lookupIds);                 
                    for(SObject lookupObj : lookupObjs){
                        for(Object item : lookupMap.get(lookupObj.Id)){
                            Map<String, Object> mItem = (Map<String, Object>) item;
                            try{                            	
                                mItem.put(fieldKey + '__Name', lookupObj.get('Name'));                                                                                        
                            }
                            catch(Exception e){
                                System.debug(e.getMessage());
                                mItem.put(fieldKey + '__Name', 'Undefined'); 
                            }
                        }
                    }
                }
            }
            
            //Update the pickList field 
            for(String fieldKey : pickListFields.keySet()){                
                DescribeFieldResult fieldDescResult =  pickListFields.get(fieldKey);                        
                List<PicklistEntry> valuesList = fieldDescResult.getPicklistValues();                    
                Map<String, String> valuesMap = new Map<String, String>();
                for(PicklistEntry entry : valuesList){
                    valuesMap.put(entry.getValue(), entry.getLabel());
                }
                
                for(Object item : items){                    
                    Map<String, Object> mItem = (Map<String, Object>) item;
                    mItem.put(fieldKey, (String)valuesMap.get((String)mItem.get(fieldKey)));
                }
            }             
                         
            //Update the percent field 
            for(String fieldKey : percentFields.keySet()){                
                for(Object item : items){                    
                    Map<String, Object> mItem = (Map<String, Object>) item;
                    if(mItem.get(fieldKey) != null){
	                    mItem.put(fieldKey, (decimal)mItem.get(fieldKey)/100);
                    }
                }
            }         
            return items;                    
        }
                
        return null;
    } 
    
    /**
     * Return the list of objects based on the lookup ids
     * */
    private static SObject[] getLookupObjects(Set<Id> lookupIds)
    {
        Schema.SObjectType sobjectType = (new list<Id>(lookupIds))[0].getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        if(isSafeObject(sobjectName) && isSafeField('Name', sobjectName)){
        	return Database.query('Select Id, Name From ' + 
	                              sobjectName + 
	                              ' Where Id in :lookupIds');
        }      
        return null;                   
    }
    
    /**
    * Save the related list items
    * */
    @AuraEnabled
    public static Boolean saveRelatedListItems(String jsonData, String initialData, String selectedData)
    {
        List<SObject> sObjectsItems = new List<SObject>();         
        Object[] items = (Object[])JSON.deserializeUntyped(jsonData);
       
        for(Object obj : items) {
            Map<String, Object> mObj = (Map<String, Object>)obj;
            
            //Init the SObject instance
            Id objId = (Id)mObj.get('Id');
            Schema.SObjectType objType = objId.getSobjectType();
            SObject sObj = objType.newSObject(objId);
            
            /* Create new Billing Group
            if(mObj.containsKey('Billing_Group__c__New') && mObj.get('Billing_Group__c__New') != null ) {
               	OpportunityLineItem item = [SELECT OpportunityId, Opportunity.AccountId 
                                            FROM OpportunityLineItem 
                                            WHERE Id =: objId LIMIT 1];
                   
             	if(item.Opportunity.AccountId != null) {
                	Billing_Group__c billingGroup = new Billing_Group__c(Name = (String)mObj.get('Billing_Group__c__New'),
                                                                       Account__c = item.Opportunity.AccountId);
                        
             		Database.SaveResult sr = Database.insert(billingGroup);
					if (sr.isSuccess()) {
 						mObj.put('Billing_Group__c', billingGroup.Id);
					}
              	}
          	} */

            //Set Billing_Group__c to null
            if(mObj.containsKey('Billing_Group__c') && mObj.get('Billing_Group__c') != null ) {
                mObj.put('Billing_Group__c', null);
            }

            for(String field : mObj.keySet()){
                
                //Update the fields
                Schema.SObjectField sfield = objType.getDescribe().fields.getMap().get(field);
                if(sfield != null && sfield.getDescribe().isUpdateable()){
                    if(sfield.getDescribe().getType() == Schema.DisplayType.DATE){
                        if(mObj.get(field) != null){
                            String dateStr = ((String)mObj.get(field)) + ' 00:00:00';
                            sObj.put(field, Date.valueOf(dateStr));                                                
                        }
                    }
                    else if(sfield.getDescribe().getType() == Schema.DisplayType.DATETIME){
                        if(mObj.get(field) != null){
                            String datetimeStr = ((String)mObj.get(field)).replace('T', ' ').replace('000Z', '');
                            sObj.put(field, Datetime.valueOf(datetimeStr));                    
                        }
                    }
                    else if(sfield.getDescribe().getType() == Schema.DisplayType.PERCENT){
                        if(mObj.get(field) != null){                            
                            sObj.put(field, (decimal)mObj.get(field)*100);                    
                        }
                    }
                    else{                        
                        sObj.put(field, mObj.get(field));                    
                    }                    
                }                    
            }      
            sObjectsItems.add(sObj);
        }
        try {
            update sObjectsItems;

            //Update Selected Billing Groups
            updateSelectedBillingGroups(initialData, selectedData);

        } 
        catch (Exception e) {
            /* AMS_ErrorLogger.logMessage('OpportunityListController.saveRelatedListItems','','', e.getMessage(), e.getStackTraceString()); */
            System.debug(LoggingLevel.Error, 'ERROR! Class: ProductListController.saveRelatedListItems '+
                                             'Message: '+e.getMessage() + ' '+
                                             'StackTrace: '+e.getStackTraceString());
            
            throw new AuraHandledException(e.getMessage());                               
            
        }
        /* finally {AMS_ErrorLogger.saveError();} */
        return true;
    } 
    
    /**
     * Search Candiate for Lookup Field
     * */
    @AuraEnabled
	public static Object[] getLookupCandidates(String refObjName, String searchTerm) {
		String qname = '%' + searchTerm + '%';
		if(isSafeObject(refObjName) && isSafeField('Name', refObjName)){
	        return Database.query('Select Id,Name From ' + 
	        					  refObjName + 
	            				  ' Where Name Like :qname order by createdDate DESC Limit 5');
		}
		
		return null;
	}
	
	private static boolean isSafeObject(String objName){
	    Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    SObjectType myObj = schemaMap.get(objName);
	    
	    return (myObj != null && myObj.getDescribe().isAccessible()); 
	}
	
	private static boolean isSafeField(String fieldName, String objName){
	    	Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    	SObjectType myObj = schemaMap.get(objName);
	    	
	        SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);
	        return (myField != null && myField.getDescribe().isAccessible());	    
	}	
    
    /*
    @AuraEnabled
    public static Boolean deleteRelatedRecord(Id objectId){
        Schema.SObjectType sobjectType = objectId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        if(isSafeObject(sobjectName)) {
            Database.DeleteResult result = Database.delete(objectId);          
            return result.isSuccess();
        }
        return false;
    } */
    
    /**
    * Return the object details
    * */
    @AuraEnabled
    public static Object getObject(Id objectId)
    {            
        Object item = RestAPIUtils.getObject(objectId);
        if(item != null){        
            DescribeSObjectResult objectDescResult = objectId.getSobjectType().getDescribe();
            
        	Map<String, DescribeFieldResult> lookupFields = new Map<String,DescribeFieldResult>();            
            for(Schema.SObjectField sfield : objectDescResult.fields.getMap().Values()){ 
                DescribeFieldResult fieldDescResult = sfield.getDescribe();                
                if(fieldDescResult.getType()==Schema.DisplayType.REFERENCE){                        
                    lookupFields.put(fieldDescResult.getName(), fieldDescResult);
                }                                
            }   
			
            //Set the lookup labels based on the field type
            for(String fieldKey : lookupFields.keySet()){
                Set<Id> lookupIds = new Set<Id>();
                
                //Build the list of IDs
                Map<String, Object> mItem = (Map<String, Object>) item;
                if(mItem.containsKey(fieldKey)){
                    Id lookupId = (Id)mItem.get(fieldKey);
                    if(lookupId != null){
                        lookupIds.add(lookupId); 
                    }                        
                }
                
                               
                //Do SOQL query based on the ID list
                if(!lookupIds.isEmpty()){
                    SObject[] lookupObjs = getLookupObjects(lookupIds);                 
                    for(SObject lookupObj : lookupObjs){
                        try{                            	
                            mItem.put(fieldKey + '__Name', lookupObj.get('Name'));                                                                                        
                        }
                        catch(Exception e){
                            System.debug(e.getMessage());
                            mItem.put(fieldKey + '__Name', 'Undefined'); 
                        }                        
                    }
                }                                    
            }
            
            return item;                    
        }   
                
        return null;
    } 
    
    /**
    * Create the object based on a json
    * */
    @AuraEnabled
    public static Id createRelatedObject(Id objectId,
                                         String objectName,
                                         String jsonData)
    {
        if(isSafeObject(objectName)){
            Map<String, Object> defaultValues = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        	SObjectType relatedObjectType =  Schema.getGlobalDescribe().get(objectName);    
            Schema.DescribeSobjectResult relatedDescribe = relatedObjectType.getDescribe();
            
        	SObject relatedObject = relatedObjectType.newSObject();
            
            //Update the fields from default values
            for(String field : relatedDescribe.fields.getMap().keySet()){                 
                if(defaultValues.containsKey(field)){    
                    Schema.SObjectField sfield = relatedDescribe.fields.getMap().get(field);
                    if(sfield.getDescribe().getType() == Schema.DisplayType.DATE){
                        String dateStr = ((String)defaultValues.get(field)) + ' 00:00:00';
                        relatedObject.put(field, Date.valueOf(dateStr));                                                
                    }                    
                    else if(sfield.getDescribe().getType() == Schema.DisplayType.DATETIME){
                        String datetimeStr = ((String)defaultValues.get(field)).replace('T', ' ').replace('000Z', '');
                        relatedObject.put(field, Datetime.valueOf(datetimeStr));                                            
                    }                                                            
                    else{
                        relatedObject.put(field, defaultValues.get(field));                    
                    }
                }                    
            }           
            
            insert relatedObject;            
            return relatedObject.Id;
        }
        return null;
    } 


    /**
     * Get Billing Groups Dropdown Options
     * */
    @AuraEnabled
    public static Object[] getBillingGroups(String objectId) {
        
        List<List<SelectItem>> optionsList = new List<List<SelectItem>>();
        List<Opportunity> opps = [Select Id, AccountId From Opportunity Where Id = :objectId];
        List<OpportunityLineItem> oppLineItems = [Select Id, OpportunityId From OpportunityLineItem Where OpportunityId = :opps[0].Id];
        List<SelectItem> items = new List<SelectItem>();
        if(opps != null) {
            String accountId = opps[0].AccountId;
            for(Billing_Group__c bg : Database.query('Select Id, Name, Full_Group_Number__c From Billing_Group__c ' +
                                                     'Where (Group_Status__c = \'Active\' OR Group_Status__c = \'Pending\') ' +
                                                     'And Account__c = :accountId ')) {
                
                SelectItem item = new SelectItem(bg.Id, bg.Name + ' ('+bg.Full_Group_Number__c+ ')');
                items.add(item);
            }    
        }
        //return items;  
        if(oppLineItems != null) {
            for(Integer i=0; i<oppLineItems.size(); i++) {
                optionsList.add(items);
            }
        }
        return optionsList;   
    }

    /**
     * Get Selected Billing Groups
     * */
    @AuraEnabled
    public static Object[] getSelectedBillingGroups(String objectId) {

        List<SelectItem> items = new List<SelectItem>();
        
        for(Billing_Group_Opp_Product__c bgop : Database.query('Select Id, Billing_Group__c, Billing_Group__r.Name, ' +
                                                                'Opportunity_Product_ID__c, Opportunity__c ' +
                                                                'From Billing_Group_Opp_Product__c ' +
                                                                'Where Opportunity__c = :objectId ' )) {
            
            SelectItem item = new SelectItem(bgop.Billing_Group__c, bgop.Billing_Group__r.Name, 
                                                true, bgop.Opportunity_Product_ID__c, 
                                                bgop.Opportunity__c, bgop.Id);
            items.add(item);
        }
        return items;  
    }

    public class SelectItem {

        @AuraEnabled public String  value  {get; set;}
        @AuraEnabled public String  label  {get; set;}
        @AuraEnabled public Boolean selected  {get; set;}
        @AuraEnabled public String  product  {get; set;}
        @AuraEnabled public String  opportunity  {get; set;}
        @AuraEnabled public String  id  {get; set;}

        public SelectItem( String value, String label) {
            this.label = label;
            this.value = value;
            this.selected = false;
        }

        public SelectItem( String value, String label, Boolean selected, 
                            String  product, String  opportunity, String  id) {
            this(value, label);
            this.selected = selected;
            this.product = product;
            this.opportunity = opportunity;
            this.id = id;
        }
    }

   /**
    * Update the selected items
    * */
    private static void updateSelectedBillingGroups(String initialData, String selectedData)
    {       
        List<String> errors = new List<String>(); 
        List<Billing_Group_Opp_Product__c> groupProductsForInsert = new List<Billing_Group_Opp_Product__c>();
        List<Billing_Group_Opp_Product__c> groupProductsForDelete = new List<Billing_Group_Opp_Product__c>();
        
        if(selectedData != null) {
            Object[] selectedItems = (Object[])JSON.deserializeUntyped(selectedData);
        
            for(Object obj : selectedItems) {
                Map<String, Object> mObj = (Map<String, Object>)obj;
                Billing_Group_Opp_Product__c groupProduct = new Billing_Group_Opp_Product__c();
                groupProduct.Opportunity_Product_ID__c = (String)mObj.get('productid');
                groupProduct.Billing_Group__c = (Id)mObj.get('groupid');
                groupProduct.Opportunity__c = (Id)mObj.get('oppid');
                groupProductsForInsert.add(groupProduct); 
            }
        }
        if(initialData != null) {
            Object[] initialItems = (Object[])JSON.deserializeUntyped(initialData);
            for(Object obj : initialItems) {
                Map<String, Object> mObj = (Map<String, Object>)obj;
                Billing_Group_Opp_Product__c groupProduct2 = new Billing_Group_Opp_Product__c();
                groupProduct2.Id = (Id)mObj.get('id');
                groupProductsForDelete.add(groupProduct2);
            }
        }
        
        //Savepoint sp = Database.setSavepoint();
        try {
            if(!groupProductsForDelete.isEmpty()) {
                Database.DeleteResult[] drList = Database.delete(groupProductsForDelete);
                for(Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        for(Database.Error err : dr.getErrors()) {
                            /*AMS_ErrorLogger.logMessage('ProductListController.updateSelectedBillingGroups', 
                                  				!err.getFields().isEmpty()?String.join(err.getFields(), ','):'', 
                                  				err.getStatusCode()+'', 
                                  				err.getMessage(),''); 
                            Database.rollback(sp);*/
                            throw new AMS_ErrorLogger.AMSException(err.getMessage());
                        }
					  
                    }
                }
            }
            if(!groupProductsForInsert.isEmpty()) {
                List<Database.SaveResult> srList = Database.insert(groupProductsForInsert);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so throw all errors               
                        for(Database.Error err : sr.getErrors()) {
                            throw new AMS_ErrorLogger.AMSException(err.getMessage());
                        }
                    }
                }
            }
        }
        catch (Exception e) {
           	/*AMS_ErrorLogger.logMessage('OpportunityRenewalHelper.updateSelectedBillingGroups','','', e.getMessage(), e.getStackTraceString());  
            Database.rollback(sp);*/ 
            System.debug(LoggingLevel.Error, 'ERROR! Method: OpportunityRenewalHelper.updateSelectedBillingGroups '+
                                             'Message: '+e.getMessage() + ' '+
                                             'StackTrace: '+e.getStackTraceString());
            
            throw new AMS_ErrorLogger.AMSException(e.getMessage());
        }
    }
    
    //Create new billing group records
    @AuraEnabled
    public static void createBillingGroup(Billing_Group__c billingGroup, String itemId) {
        
        if(billingGroup != null) {
            try {
                OpportunityLineItem item = [Select Id, OpportunityId, Opportunity.AccountId From OpportunityLineItem Where Id = :itemId Limit 1]; 
                billingGroup.Account__c = item.Opportunity.AccountId;
                Database.SaveResult sr = Database.insert(billingGroup, false);
           
                if (sr.isSuccess()) {
              	    Billing_Group_Opp_Product__c groupProduct = new Billing_Group_Opp_Product__c();
              	    groupProduct.Opportunity_Product_ID__c = itemId;
            	    groupProduct.Billing_Group__c = sr.getId();
            	    groupProduct.Opportunity__c = item.OpportunityId;
                    Database.insert(groupProduct, false);    
                } 
                else {
                    throw new AMS_ErrorLogger.AMSException(sr.getErrors()[0].getMessage());
                }
            }
            catch (Exception e) {
                System.debug(LoggingLevel.Error, 'ERROR! Class: ProductListController.createBillingGroup '+
                                             'Message: '+e.getMessage() + ' '+
                                             'StackTrace: '+e.getStackTraceString());
                
                throw new AuraHandledException(e.getMessage()); 
            }

        } 
    }
    
    @AuraEnabled
    public static List<String> getDomesticPartnershipAllowed(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Billing_Group__c.Domestic_Partnership_Allowed__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getRequestedRatingClass(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Billing_Group__c.Requested_Rating_Class__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getRequestedCobraAdmin(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Billing_Group__c.Requested_COBRA_Admin__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getRetroCancellationAllowance(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Billing_Group__c.Retro_Cancellation_Allowance__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<SelectItem> getRequestedCobraAdminOptions(){
        List<SelectItem> options = new List<SelectItem>();
        Schema.DescribeFieldResult fieldResult = Billing_Group__c.Requested_COBRA_Admin__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(new SelectItem(p.getValue(), p.getLabel()));
        }
        return options;
    }

}