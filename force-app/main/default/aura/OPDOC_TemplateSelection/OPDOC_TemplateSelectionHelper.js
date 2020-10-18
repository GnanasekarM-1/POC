({
   	navigateToPath: function(component, event, helper) {
        event.preventDefault();
        // We are getting action URL to be passed to COMM_Footer component
        var target = event.target; 
        var recordIndex = target.getAttribute("data-selected-Index");
        
        var tableData = component.get("v.tableData");
       	var targetUrl = tableData[recordIndex].targetUrl;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": targetUrl,
        });
        urlEvent.fire(); 
    }
})