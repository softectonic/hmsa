({
 	closedModal : function(component) {
     	var appEvent = $A.get("e.c:ClosedModalEvent"); 
     	appEvent.setParams({ "closedModal" : false });
     	appEvent.fire();
 	},
 	getRequestedCobraAdmin: function(component) {
        var action = component.get("c.getRequestedCobraAdmin");
        var requestedCobraAdmin = component.find("requestedCobraAdmin");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            requestedCobraAdmin.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
    },
    getRequestedCobraAdminOptions: function(component) {
        var action = component.get("c.getRequestedCobraAdminOptions");
        var requestedCobraAdmin = component.find("requestedCobraAdmin");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            var selectItems = JSON.parse(JSON.stringify(a.getReturnValue()));
            selectItems.forEach(function(item) {
                opts.push({"class": "optionClass", label: item.label, value: item.value});
      		});
            requestedCobraAdmin.set("v.options", opts);
            
        });
        $A.enqueueAction(action); 
    },
    getRequestedRatingClass: function(component) {
        var action = component.get("c.getRequestedRatingClass");
        var requestedRatingClass = component.find("requestedRatingClass");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            requestedRatingClass.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
    }, 
    getDomesticPartnershipAllowed: function(component) {
        var action = component.get("c.getDomesticPartnershipAllowed");
        var domesticPartnershipAllowed = component.find("domesticPartnershipAllowed");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            domesticPartnershipAllowed.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
    },
    getRetroCancellationAllowance: function(component) {
        var action = component.get("c.getRetroCancellationAllowance");
        var retroCancellationAllowance = component.find("retroCancellationAllowance");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            retroCancellationAllowance.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
    },
    hideModal : function(component) {
        var appEvent = $A.get("e.c:HideModalEvent"); 
     	appEvent.setParams({ "hideModal" : false });
     	appEvent.fire();
    }
})