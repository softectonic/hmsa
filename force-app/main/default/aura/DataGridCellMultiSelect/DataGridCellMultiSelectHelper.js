({
  init: function(component) {
    //debugger;
    var item = component.get("v.item");
    var itemRank = component.get("v.itemRank");
    var itemId = item['Id'];
    var selectedItems = component.get("v.selectedItems");
    var options = component.get("v.options");  
    var initialSelectedLabels = component.get("v.initialSelectedLabels");
    var initialSelectedValues = component.get("v.initialSelectedValues");  	
   
    //note, we get options and set options_
    //options_ is the private version and we use this from now on.
    //this is to allow us to sort the options array before rendering
    if (component.get("v.initialized")){
      return;
    }
    component.set("v.initialized",true);  
    component.set("v.lastSelectedItems", initialSelectedValues); 
    component.set("v.itemId", itemId);   
    
    if(options) {
    	options.sort(function compare(a, b) {
      	if (a.selected) {
        	return -1;
      	} else if (a.label < b.label) {
        	return -1;
      	}
      	if (a.label > b.label) {
        	return 1;
      	}
      	return 0;
    	});
    }      
      
    component.set("v.options_", options);
    var opts = component.get("v.options_");
    //var initialSelectedOptions = this.setInitialSelectedOptions(component, opts, initialSelectedLabels);
    var initialSelectedPickList = this.setInitialSelectedPickList(component, opts, initialSelectedValues);   
    
    var values = this.getSelectedValues(component);
    var labels = this.getSelectedLabels(component);
    var selectedLabels = initialSelectedLabels.concat(labels);  

    this.setInfoText(component, initialSelectedPickList, opts, values);  
  },  

  setInfoText: function(component, values, NumOptions, NumSelected) {
    
    if (values.length == 0) {
      component.set("v.infoText", "Select an Option");
    }
    if (values.length == 1) {
      component.set("v.infoText", values[0]);
      component.set("v.value", values[0]);
    }
    else if (NumOptions && values.length <= NumOptions.length && values.length > 1) {
      component.set("v.infoText", values.length + " Options Selected");
      component.set("v.value", values.length + " Options Selected");
    } 
    else if(NumSelected.length == 1) {
      component.set("v.infoText", values[0]);
      component.set("v.value", values[0]);
    } 
    else if(NumSelected.length > 1) {
      component.set("v.infoText", NumSelected.length + " Options Selected");
      component.set("v.value", NumSelected.length + " Options Selected");
    }
  },

  setSelectedOptions: function(component, options, selectedItems, itemId){
    options.forEach(function(element) {
      for (var key in selectedItems) {
        //alert('itemId: '+itemId+' selectedItems[key].product: '+selectedItems[key].product+' element.label: '+element.label+' element.value: '+element.value+' selectedItems[key].label: '+selectedItems[key].label+' selectedItems[key].value: '+selectedItems[key].value);
        if(selectedItems[key].product === itemId && element.value === selectedItems[key].value) {
            element.selected = true;
        }
      }
    });
  },

  setInitialSelectedOptions: function(component, options, initialSelectedItems){
    var labels = [];    
    if(options) {
    	options.forEach(function(option) {
      		initialSelectedItems.forEach(function(item) {
        	if(option.label === item) {
            	option.selected = true;
            	labels.push(option.label);
        	}
      		});
    	});
     }    
     return labels;      
  },
    
  setInitialSelectedPickList: function(component, options, initialSelectedValues){
    var labels = []; 
    if(options) {
    	options.forEach(function(option) {
      		initialSelectedValues.forEach(function(item) {
        	if(option.value === item) {
            	option.selected = true;
            	labels.push(option.label);
        	}
      		});
    	});
     }    
     return labels;      
  },  

  getSelectedValues: function(component){
    var options = component.get("v.options_");
    var values = [];
    if(options) {  
    	options.forEach(function(element) {
      		if (element.selected) {
        		values.push(element.value);
      		}
    	});
    }
    return values;
  },

  getSelectedLabels: function(component){
    var options = component.get("v.options_");
    var labels = [];
    if(options) {    
    	options.forEach(function(element) {
      		if (element.selected) {
        		labels.push(element.label);
      		}
    	});
    }
    return labels;
  },

  dispatchSelectChangeEvent: function(component,values, itemIndex){
    component.set("v.lastSelectedItems", values); 
    component.set("v.lastSelectedItemsIndex", itemIndex);   
    var compEvent = component.getEvent("selectChange");
      compEvent.setParams({ "values": values, 
                           	"itemIndex": itemIndex});
    compEvent.fire();
  },
  showModal : function(component) {
     var appEvent = $A.get("e.c:ShowModalEvent"); 
     appEvent.setParams({ "showModal" : true });
     appEvent.fire();
   },
   dispatchSelectedOpptyProduct : function(component) {
     var itemId = component.get("v.itemId");
     var itemRank = component.get("v.itemRank");  
     var appEvent = $A.get("e.c:NewBillingGroupEvent"); 
     appEvent.setParams({"itemId" : itemId, 
                         "itemRank" : itemRank 
     });
     appEvent.fire();
   }   
  
})