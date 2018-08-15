({
 	doInit: function(component, event, helper) {
        helper.getRequestedCobraAdminOptions(component);
        helper.getRequestedRatingClass(component);
        helper.getDomesticPartnershipAllowed(component);
        helper.getRetroCancellationAllowance(component);
    },
    
    closedModal: function(component,event,helper){
       helper.closedModal();         
    },
    
    hideModal: function(component,event,helper){
       helper.hideModal();         
    },
    
    saveBillingGroup : function(component,event,helper){
       
        var btnClicked = event.getSource();
        btnClicked.set("v.disabled",true);
        
        var name = component.find("groupName");
        var isValid = name.checkValidity();
        if(isValid) {
            
       		//getting the candidate information
        	var groupRecord = component.get("v.groupObj");
        	var itemId = component.get("v.itemId");
        
        	//Calling the Apex function
        	var action = component.get("c.createBillingGroup");
        
        	//Setting the Apex Parameter
        	action.setParams({
            	billingGroup : groupRecord,
            	itemId : itemId
        	});
        
        	//Setting the Callback
        	action.setCallback(this,function(res){
            
            	//get the response state
            	var state = res.getState();
              
            	//check if result is successful
            	if(state == "SUCCESS"){
                
                	//Reset Form
                	var newGroup = {'sobjectType': 'Billing_Group__c',
                                    'Name': '',
                                    'Requested_Agent_Code__c': '',
                                    'Requested_COBRA_Admin__c': '',
                                	'Requested_Rating_Class__c': '',
                                	'Requested_Domestic_Partnership_Allowed__c' : '',
                                    'Employee_Count__c': '',
                                    'Retro_Cancellation_Allowance__c': ''};
                
                	//resetting the Values in the form
                	component.set("v.groupObj",newGroup);
                
                	//calls helper controller method to close the popup and refresh the page.
        			helper.closedModal(component);  
            	} 
           		else if(state == "ERROR"){
                    var errMsg = null;
                    var errors = res.getError();
                	if(errors[0] && errors[0].message){
                    	errMsg = errors[0].message;
                	} 
                    
                    var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"title": "Error!",
                    	"type" : "error",
                    	"mode" : "sticky",
                    	"message": "Server Error: " + errMsg
                	});
                	toastEvent.fire(); 
                    btnClicked.set("v.disabled",false);
                    console.log('Error in calling server side action: ' + errMsg);
            	}
        	});
 			//adds the server-side action to the queue        
        	$A.enqueueAction(action);
        }
        else {
            name.showHelpMessageIfInvalid();
		}    
    },
    
    setOpportunityProduct: function(component, event, helper){
        var itemId = event.getParam("itemId");
        var itemRank = event.getParam("itemRank");
        component.set("v.itemId", itemId);
        component.set("v.itemRank", itemRank);
    } 
})