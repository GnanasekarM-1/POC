({
	doinit : function(component, event, helper) {
		var action = component.get("c.getSLADetails");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var slaResponse = response.getReturnValue();
                component.set("v.slaDetils",slaResponse);
                component.set("v.woRecord",slaResponse.WOObj);
                if(component.get("v.woRecord.SVMXC__SLA_Clock_Paused__c")){
                    component.set("v.clockPaused",true);
                }
                helper.parseResponse(component, event, helper,slaResponse);
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    onRender : function(component, event, helper) {
        //This executes after the Component/DOM is rendered
        //If Clocks are already paused on load
        if(component.get("v.woRecord.SVMXC__SLA_Clock_Paused__c")){
            var toggleButtonPlay = component.find("playId");
            $A.util.removeClass(toggleButtonPlay, "slds-hide"); 
            var toggleButtonPause = component.find("pauseId");
            $A.util.addClass(toggleButtonPause, "slds-hide");
            component.set("v.clockPaused",true);
        }
    },
    
    pause : function(component, event, helper) {
        var modalbox = document.getElementsByClassName("modalbox");
        for (var i=0; i<modalbox.length; i++) {
            $A.util.removeClass(modalbox[i], "slds-hide");
        }        
    },
    pauseClock : function(component, event, helper) {
        if(component.find("reason").get("v.value")){
            helper.showSpinner(component);
            //Set the pause reason on work order record before calling apex class
            component.set("v.woRecord.SVMXC__SLA_Clock_Pause_Reason__c",component.find("reason").get("v.value"))
            //call apex pause
            var action = component.get("c.SVMX_PauseNow");
            action.setParams({
                "WOObj": component.get("v.woRecord"),
                "ForHowLong":"a"
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.clockPaused",true);//pause the clocks
                    var updatedWO = response.getReturnValue();
                    component.set("v.woRecord",updatedWO);
                    //Toggle the pause/play buttons
                    var toggleButtonPlay = component.find("playId");
                    $A.util.removeClass(toggleButtonPlay, "slds-hide"); 
                    var toggleButtonPause = component.find("pauseId");
                    $A.util.addClass(toggleButtonPause, "slds-hide");
                    helper.hideSpinner(component);
                }
                else if (state === "ERROR") {
                    helper.hideSpinner(component);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        //close the modal after pause
        var a = component.get('c.closePopup');
        $A.enqueueAction(a);
        }else{
            alert($A.get("$Label.c.SLAT003_TAG038"));
        }
			
    },
    resume : function(component, event, helper) {
        var action = component.get("c.getElapsedMinutes");
        action.setParams({
            "WOObj": component.get("v.woRecord")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ElapsedMinutes = response.getReturnValue();
                component.set("v.elapsedMinutes",ElapsedMinutes);
                var modalbox = document.getElementsByClassName("modalboxResume");
                for (var i=0; i<modalbox.length; i++) {
                    $A.util.removeClass(modalbox[i], "slds-hide");
                }   
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
             
    },
    closePopup : function(component, event, helper) {
        var modalbox = document.getElementsByClassName("modalbox");
        for (var i=0; i<modalbox.length; i++) {
            $A.util.addClass(modalbox[i], "slds-hide");
        }
    },
    closePopupResume : function(component, event, helper) {
        var modalbox = document.getElementsByClassName("modalboxResume");
        for (var i=0; i<modalbox.length; i++) {
            $A.util.addClass(modalbox[i], "slds-hide");
        }
    },
    resumeClock : function(component, event, helper) {
        helper.showSpinner(component);
        var elapsedMins ='0';
        if(component.find("checkExtend").get("v.checked")){
            //Yes function SVMX_Yes
            elapsedMins = component.get("v.elapsedMinutes");
        }
        console.log('elapsedMins==',typeof elapsedMins);
        var action = component.get("c.SVMX_Yes");
            action.setParams({
                "WOObj": component.get("v.woRecord"),
                "SLADetails":component.get("v.slaDetils").SLADetails,
                "BHMap":component.get("v.slaDetils").BHMap,
                "ElapsedMins": elapsedMins.toString()
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var updatedWO = response.getReturnValue();
                    console.log('updatedWO==',updatedWO);
                    component.set("v.woRecord",updatedWO);
                    component.set("v.clockPaused",false);//Resume Clocks
                    //Toggle the pause/play buttons
                    var toggleButtonPlay = component.find("playId");
                    $A.util.addClass(toggleButtonPlay, "slds-hide"); 
                    var toggleButtonPause = component.find("pauseId");
                    $A.util.removeClass(toggleButtonPause, "slds-hide"); 
                    helper.hideSpinner(component);
                    $A.enqueueAction(component.get('c.doinit')); // refresh the clock.
                }
                else if (state === "ERROR") {
                    helper.hideSpinner(component);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        
        //close the modal after resume and uncheck the checkbox
        //component.find("checkExtend").set("v.checked","false");
        var a = component.get('c.closePopupResume');
        $A.enqueueAction(a);
    }
    
})