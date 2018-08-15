({
	
	getInitialSelectedLabels: function(component, selectedItems, productId){
        var labels = [];
        selectedItems.forEach(function(item) {
            if(item.product === productId) {
                labels.push(item.label);
            }
        });
        return labels;
    },
    getInitialSelectedValues: function(component, selectedItems, productId){
        var values = [];
        selectedItems.forEach(function(item) {
            if(item.product === productId) {
                values.push(item.value);
            }
        });
        return values;
    }
     
	
})