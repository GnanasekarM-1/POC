({
	getWizardsHelper : function(component) {
		var action = component.get("c.getWizards");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
			if (state === "SUCCESS") {
                var StoreResponse = response.getReturnValue();
                component.set('v.wizardToWizardStepMap', StoreResponse.mapWizIdWizSteps);
                component.set('v.wizardMap', StoreResponse.mapWizIdWizSteps);
                component.set('v.sitePrefix', StoreResponse.strSitePrefix);
                component.set('v.isCommunityRunning', StoreResponse.isCommunityRunning); //Added for the defect 046614 fix
 				var arrayOfMapKeys = [];
                for (var singlekey in StoreResponse.mapWizIdRecord) {
                    var processRec = StoreResponse.mapWizIdRecord[singlekey]
                    arrayOfMapKeys.push(processRec);
                }
                component.set('v.wizardHeaderRec', arrayOfMapKeys);
                
            }
        });
        $A.enqueueAction(action);
        
	},
    showLessMore: function(component, event, helper){
        // BAC-3020 - Show All and Show Less Functionality
				
        event.preventDefault();
        var showMoreLessElement = component.find("showMoreLess");
        // by using $A.util.toggleClass add-remove slds-hide class
      	$A.util.toggleClass(showMoreLessElement, "show-more");
        $A.util.toggleClass(showMoreLessElement, "show-less");
    }, 
    
})