({
	setWizardList : function(component, event, helper) {
		var key = component.get("v.wizardID");
        //var wizardMap = component.get("v.wizardMap");
        var wizardToWizardStepMap = component.get("v.wizardToWizardStepMap");
        
        // set the values of map to the value attribute	
        // to get map values in lightning component use "map[key]" syntax. 
        component.set("v.wizardSteps" , wizardToWizardStepMap[key]);
        
    },
    
    loadAction: function(component, event, helper){
        event.preventDefault();
        
        // We are getting action URL to be passed to COMM_Footer component
        var target = event.target; 
        var actionUrl = target.getAttribute('data-value');
        var recordIndex = target.getAttribute("data-selected-Index");
        
        if(recordIndex != null){
            var wizardStepList = component.get("v.wizardSteps");
            var wizardStepRec = wizardStepList[recordIndex];
            
            // Here we are checking only for confirmation message
            // Redirection logic is implemented in helper class. Open new window, existing window, console etc
            if(wizardStepRec.isConfirmationMessageEnabled){
                helper.showConfirm(component, event,wizardStepRec);
            }
            else if(wizardStepRec.selectTemplateAtRuntime){
                helper.getData(component, event, helper) ;
            }
            else{
               helper.redirectPath(component, event, helper);
        	}
        }
        
    },
    

})