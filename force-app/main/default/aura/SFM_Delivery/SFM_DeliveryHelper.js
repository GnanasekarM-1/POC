({
    navigateTo: function(urlStr) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": urlStr,
        });
        urlEvent.fire();
    },
    
    getConfigInfo: function(component, message, helper, request, callbackId){
        console.log('Getting action getConfigInfo');
        var action = component.get("c.getConfigInfo");
        action.setParams({
            "recordId": request.recordId,
            "processId": request.processId
        });
        console.log('Calling action getConfigInfo');
        
        action.setCallback(this, function(response, event) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var configInfoResponse = response.getReturnValue();
                console.log('Got Response getConfigInfo: ',configInfoResponse);
                
                var message = {
                    name: "AURA",
                    result: configInfoResponse,
                    callbackId: callbackId,
                    event: event,
                    methodName: "getConfigInfo"
                };
                component.find("SFMDeliveryApp").message(message);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getTokenByVfPage: function(component, message, helper, request, callbackId){
        console.log('Getting action getTokenByVfPage');
        var action = component.get("c.getTokenByVfPage");
        console.log('Calling action getTokenByVfPage');
        action.setCallback(this, function(response, event) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tokenResponse = response.getReturnValue();
                console.log('Got Response getTokenByVfPage: ',tokenResponse);
                
                var message = {
                    name: "AURA",
                    result: tokenResponse,
                    callbackId: callbackId,
                    event: event,
                    methodName: "getSessionToken"
                };
                component.find("SFMDeliveryApp").message(message);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})