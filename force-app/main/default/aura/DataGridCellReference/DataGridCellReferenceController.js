({
	 doInit : function(component, event, helper) {              
        helper.doInit(component, event); 
        helper.doCustomInit(component, event);
    },
    onFocus : function(component,event,helper){
        var forOpen = component.find("searchContainer");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC
        component.set('v.searchTerm','');
         helper.searchByName(component, event);
    },
    // Automatically call when the component is done waiting for a response to a server request
    hideSpinner : function (component, event, helper) {
		var spinner = component.find("spinner");
		$A.util.addClass(spinner, 'slds-hide');
    },
 	// Automatically call when the component is waiting for a response to a server request
    showSpinner : function (component, event, helper) {
		var spinner = component.find("spinner");
		$A.util.removeClass(spinner, 'slds-hide');
    },
    onMouseOver : function (component, event, helper) {
        var isSelecting = component.get('v.isSelecting');
        component.set('v.isSelecting',!isSelecting);
        component.set('v.mouseOverList', true);
	},
	onMouseOut : function (component, event, helper) {
        var isSelecting = component.get('v.isSelecting');
        component.set('v.isSelecting',!isSelecting);
		component.set('v.mouseOverList', false);
		window.setTimeout(
			$A.getCallback(function() {
				var mouseBoolean = component.get('v.mouseOverList');
				if(mouseBoolean == false) {
					var forOpen = component.find("searchContainer");
					$A.util.removeClass(forOpen, 'slds-is-open');
					$A.util.addClass(forOpen, 'slds-is-close');
				}
			}), 100
		);
	},
    handleSearchChange : function(component, event, helper) {
        if (component.get('v.searchTerm') && component.get('v.searchTerm').length>0){
          	var forOpen = component.find("searchContainer");
        	$A.util.addClass(forOpen, 'slds-is-open');
         	$A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchByName(component, event);
        } 
        else {
         	component.set("v.searchResults", null );
         	var forclose = component.find("searchContainer");
           	$A.util.addClass(forclose, 'slds-is-close');
         	$A.util.removeClass(forclose, 'slds-is-open');
       }
    },
    handleResultSelect: function(component, event, helper) {
        helper.setResultsInfo(component,event);         
    },
    handleSearchBlur : function(component, event, helper){
        helper.resetAfterBlur(component, event);                
    },
    toggleSelecting : function(component, event, helper){
        var isSelecting = component.get('v.isSelecting');
        component.set('v.isSelecting',!isSelecting);
    },
    toggleSearching : function(component, event, helper){
        helper.resetBeforeSearch(component, event);
    },
    createNewRecord : function (component, event, helper){
        
		var createRecordEvent = $A.get("e.force:createRecord");
		var objName = component.get('v.refObjName');
        var windowHash = window.location.hash;
		createRecordEvent.setParams({
			"entityApiName": objName,
            "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;
        	}
		});
		createRecordEvent.fire();
	}
})