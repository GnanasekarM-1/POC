({
    doinit: function(component, event, helper){
        console.log('init called');
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariables = sPageURL.split('&');
        var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === 'SVMXC__SVMX_recordId') {
                component.set("v.SVMXC__SVMX_recordId", sParameterName[1]);
            }
            if (sParameterName[0] === 'SVMXC__SVMX_action') {
                component.set("v.SVMXC__SVMX_action", sParameterName[1]);
            }
            if (sParameterName[0] === 'SVMXC__SVMX_processId') {
                component.set("v.SVMXC__SVMX_processId", sParameterName[1]);
            }
            if (sParameterName[0] === 'SVMXC__SVMX_retURL') {
                component.set("v.SVMXC__SVMX_retURL", sParameterName[1]);
            }
            if (sParameterName[0] === 'SVMXC__SVMX_JWTEnabled') {
                component.set("v.SVMXC__SVMX_JWTEnabled", sParameterName[1]);
            }
        }
        console.log('init done');
    },
    
    handleMessage: function(component, message, helper) {
        debugger;
        var actionName = message && message.getParams() && message.getParams().payload && message.getParams().payload.name;
        if(actionName == "navigateTo"){
            console.log('HandleMessage call for navigateTo');
            var urlToNavigate = message.getParams().payload.value && message.getParams().payload.value.url;
            helper.navigateTo(urlToNavigate);
        }
        if(actionName == "callApex"){
            var methodName = message.getParams().payload.value && message.getParams().payload.value.method;
            var request = message.getParams().payload.value && message.getParams().payload.value.request;
            var callbackId = message.getParams().payload.value && message.getParams().payload.value.callbackId;
            if(methodName == "getSessionToken"){
                console.log('HandleMessage call for GetSessionToken');
                helper.getTokenByVfPage(component, message, helper, request, callbackId);
            }
            if(methodName == "getConfigInfo"){
                console.log('HandleMessage call for GetConfigInfo');
                helper.getConfigInfo(component, message, helper, request, callbackId);
            }
        }
    }
})