({
	doInit : function(component, event, helper) {
        var item = component.get("v.item");        
        var itemRank = component.get("v.itemRank");
        
        var columns = component.get("v.columns");
        var displayMode = component.get("v.displayMode");
        //alert(JSON.stringify(columns));
        function getCellComponent(column, index){	
            var columnType = column.type; 
            if(displayMode == 'read' && 
               	column.name.toLowerCase() == 'name'){
                return "c:DataGridCellLink";
            }
            else{
                switch(columnType) {
                    case 'Boolean':
                        return "c:DataGridCellBoolean";
                    case 'String':
                        return "c:DataGridCellString"; 
                    case 'TextArea':
                        return "c:DataGridCellTextArea";
                    case 'Phone':
                        return "c:DataGridCellPhone";
                    case 'Email':
                        return "c:DataGridCellEmail";
                    case 'Url':
                        return "c:DataGridCellUrl";
                    case 'Currency':
                        return "c:DataGridCellCurrency";
                    case 'Double':
                        return "c:DataGridCellDouble";
                    case 'Integer':
                        return "c:DataGridCellInteger";
                    case 'Percent':
                        return "c:DataGridCellPercent";
                    case 'Date':
                        return "c:DataGridCellDate";
                    case 'Datetime':
                        return "c:DataGridCellDatetime";
                    case 'PickList':
                        return "c:DataGridCellPickList";
                    case 'Reference':
                        return "c:DataGridCellReference";
                    case 'ItemLink':
                        return "c:DataGridCellLink";
                    case 'Formula':
                        return "c:DataGridCellFormula";
                    default:
                        return "c:DataGridCellFormula";
                }  
            }
        }
        
        var cellComponents = columns.map(function(column, index){
            return [getCellComponent(column, index),{                
                "aura:id" : "cellWrapper",
                "item" : item,
                "itemRank" : itemRank,                
                "displayMode" : displayMode,                
                "columnRank" : index,
                "column" : column				
            }];    
        });        
        
        $A.createComponents(
            cellComponents, 
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    components.forEach(function(subCmp){
                        body.push(subCmp);
                    });
                    component.set("v.body", body);
                }                
                else {
                    if(status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }                    
                }
            }
        );                            
    },    
    handleMenuSelect: function(component, event, helper) {
        var selectedValue = event.getParam("value");        
        if(selectedValue === "delete"){
            var deleteEvt = component.getEvent("onDelete");                
            deleteEvt.setParams({
                item: component.get('v.item')
            });
            
            deleteEvt.fire();          
        }
        if(selectedValue === "edit"){            
            var updateEvt = component.getEvent("onEdit");                
            updateEvt.setParams({
                item: component.get('v.item')
            });
            
            updateEvt.fire();
        }            
    }
})