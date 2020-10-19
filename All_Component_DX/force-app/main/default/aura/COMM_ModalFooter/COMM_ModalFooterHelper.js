({
	redirectPath: function(component, event, helper){
        
        var wizStepRec = component.get("v.wizardStepRec");
        if(wizStepRec != null  && wizStepRec != ''){
            //var actionUrl = wizStepRec.actionURL;
            var actionUrl = component.get("v.actionUrl");
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
                            windowObjRef[urlStr] = window.open(actionUrl,'_blank');
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
})