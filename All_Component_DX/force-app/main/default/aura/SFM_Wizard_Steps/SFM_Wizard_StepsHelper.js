({
    redirectPath: function(component, event, helper){
        var target = event.target; 
        var actionUrl = target.getAttribute('data-value');
        // To be removed once unit testing is done.
        // In lightning community, extra parameters has been added for actions url which leads to invalid page.
        // Hence removing the extra parameters . /s. 
        
        //-----Start----Added for the defect 046614 fix----
       	console.log("isCommunityRunning: "+component.get("v.isCommunityRunning"));
       	var isCommunity = component.get("v.isCommunityRunning");
       	if(isCommunity){
        	actionUrl = this.getCommunityUrl(actionUrl,component.get("v.sitePrefix"));
       	} 
        this.redirectActionURL(component, event, helper,actionUrl); 
       	//-----End------Added for the defect 046614 fix----
        
        /*Commented for defect 046614 fix
        var action = component.get("c.isCommunity");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              	var isCommunity = response.getReturnValue(); 
            	if(isCommunity)actionUrl = this.getCommunityUrl(actionUrl,component.get("v.sitePrefix"));
            	this.redirectActionURL(component, event, helper,actionUrl);  
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
		});
		$A.enqueueAction(action);
        */
    },
    
    getCommunityUrl: function(actionUrl,sitePrefix){
        debugger;
        var oldSitePrefix = sitePrefix;
        var newSitePrefix = '';
        if (oldSitePrefix.endsWith('/s'))newSitePrefix = oldSitePrefix.slice(0,-2);
        //actionUrl = actionUrl.replace(oldSitePrefix,newSitePrefix);
        actionUrl = actionUrl.split(oldSitePrefix).join(newSitePrefix);
        return actionUrl;
    },
    redirectActionURL: function(component, event, helper,actionUrl ){
        var target = event.target; 
        var wizardStepListHelper = component.get("v.wizardSteps");
        var wizStepIndex = target.getAttribute("data-selected-Index");
        var wizStepRec = wizardStepListHelper[wizStepIndex];
        
        var parentRecord = component.get("v.record");
        var processid = wizStepRec.processid +'*'+parentRecord.Id; 
        
        var strSitePrefix = '{!$Site.Prefix}';
        var windowObjRef = {};
        var newTab = this.getParameterByName('newTab', actionUrl);
        
        // Only for IB tree custom action on Installed Product object, we open modal window(nothing but new tab)
        if((wizStepRec.winType == 'New Window'|| wizStepRec.winType == 'Modal Window') && wizStepRec.fullscreen == 'yes'){
            
            // Checking for the browser type; based on which will open the window. 
            var isOpera = !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;
            var isChrome = !!window.chrome && !isOpera;
            var isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0;
            if(isChrome || isSafari){
                if (windowObjRef == null || windowObjRef[actionUrl] == null || (windowObjRef[actionUrl] != null && windowObjRef[actionUrl].closed)) {
                    if(newTab && newTab.toLowerCase() == 'true') {//for IB Tree, It should open as new tab, not as new window.
                        windowObjRef[actionUrl] = window.open(actionUrl,'_blank');
                    }
                    else{
                        windowObjRef[actionUrl] = window.open(actionUrl,processid,'width='+screen.width+','+'height='+screen.height+','+'resizable=yes'+',scrollbars='+wizStepRec.winScroll);
                    }
                }
                windowObjRef[actionUrl].focus();
                
            }
            else{
                if (windowObjRef == null || windowObjRef[actionUrl] == null || (windowObjRef[actionUrl] != null && windowObjRef[actionUrl].closed)) {
                    if(newTab && newTab.toLowerCase() == 'true') {
                        windowObjRef[actionUrl] = window.open(actionUrl,'_blank');
                    }
                    else{
                        windowObjRef[actionUrl] = window.open(actionUrl,processid,'fullscreen=yes, resizable=yes'+',scrollbars='+wizStepRec.winScroll);
                    }
                }
                windowObjRef[actionUrl].focus();
                
            }
            
        }
        else if((wizStepRec.winType == 'New Window' || wizStepRec.winType == 'Modal Window') && wizStepRec.fullscreen == 'no'){
            if (windowObjRef == null || windowObjRef[actionUrl] == null || (windowObjRef[actionUrl] != null && windowObjRef[actionUrl].closed)) {
                if(newTab && newTab.toLowerCase() == 'true') {
                    windowObjRef[actionUrl] = window.open(actionUrl,'_blank');
                }
                else{    
                    windowObjRef[actionUrl] = window.open(actionUrl,processid,'width='+wizStepRec.winWidth+','+'height='+wizStepRec.winHeight+','+'scrollbars='+wizStepRec.winScroll+','+'resizable=yes'); 
                }     
            }
            windowObjRef[actionUrl].focus();
        }
        else{
        	if(actionUrl){

           		var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                	"url": actionUrl,
                });
                urlEvent.fire(); 
				            
            }
        }
    },
    
    getParameterByName : function(name, url){
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    showConfirm: function(component, event, wizardStepRec){
       var target = event.target; 
        var actionUrl = target.getAttribute('data-value');
        // In lightning community, extra parameters has been added for actions url which leads to invalid page.
        // Hence removing the extra parameters . /s. 
        
        //-----Start----Added for the defect 046614 fix----
       	var isCommunity = component.get("v.isCommunityRunning");
       	if(isCommunity){
        	actionUrl = this.getCommunityUrl(actionUrl,component.get("v.sitePrefix"));
       	} 
        this.showConfirmForActionURL(component, event, wizardStepRec,actionUrl); 
        //-----End----Added for the defect 046614 fix----
        
        /*Commented for defect 046614 fix
        var action = component.get("c.isCommunity");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              	var isCommunity = response.getReturnValue(); 
            	if(isCommunity)actionUrl = this.getCommunityUrl(actionUrl,component.get("v.sitePrefix"));
            	this.showConfirmForActionURL(component, event,wizardStepRec,actionUrl);  
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
		});
		$A.enqueueAction(action);
        */
    },
    showConfirmForActionURL:function(component, event, wizardStepRec, actionUrl){
    	var modalBody;
        var modalFooter;
        var modalContent = wizardStepRec.confirmationMessage;  
        var modalHeader = $A.get("$Label.c.SFW001_TAG003");
        var showOk = true;
        $A.createComponents([
                ["c:COMM_ModalContent",{"modalContent" : modalContent }],
            ["c:COMM_ModalFooter",{"actionUrl": actionUrl, "showOk": showOk, "wizardStepRec": wizardStepRec, "record": component.get("v.record")}], 
            ],
            function(components, status){
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find('overlayLib').showCustomModal({
                        header: modalHeader,
                        body: modalBody, 
                        footer: modalFooter,
                        showCloseButton: true,
                        cssClass: "lcmp-confirmation-box"
                    }).then(function (overlay) {
                        component.set('v.overlayPanel', overlay);
                    });
                }
            }
        );
    },
    getData : function(component, event, helper) {
        component.set('v.waiting', true);
        var action = component.get('c.getOutputDocTemplate');
        var parentRecord = component.get("v.record");
        action.setParams({
            "recordId": parentRecord.Id
        });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                this.createDynamicComponent(component, event, helper, response.getReturnValue());
                component.set('v.waiting', false);
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set('v.waiting', false);
            }
            
        }));
        
        $A.enqueueAction(action);
    },
    createDynamicComponent: function(component, event, helper, tabelData){
        // Show the popup-up to select template from Modal  
        var modalBody;
        var modalFooter;
        
        var showOk = false; 
        var parentRecord = component.get("v.record");
        component.set('v.waiting', false);
        
        // Create a helper to create dynamic component, as we need to call the controller as well. 
        
        var modalHeader = $A.get("$Label.c.SFW001_TAG009") + ' '+ parentRecord.Name;
        $A.createComponents([
            ["c:OPDOC_TemplateSelection",{"recordId": parentRecord.Id, "tableData": tabelData }],
            ["c:COMM_ModalFooter",{"showOk": showOk}], 
        ],
        function(components, status){
            if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find('overlayLib').showCustomModal({
                        header: modalHeader,
                        body: modalBody, 
                        footer: modalFooter,
                        showCloseButton: true,
                        cssClass: "lcmp-modal-window"
                    }).then(function (overlay) {
                        component.set('v.overlayPanel', overlay);
                    });
                }
            }); 
       }
})