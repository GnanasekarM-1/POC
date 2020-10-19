({
    getSections: function(component, event, helper) {
        helper.fetchSections(component, event, helper);
        //helper.callPollingMethod(component,event,helper);//Added by Nidhi BAC-5957  
    },
    helpTextOut: function(component, event, helper) {
        helper.toggleHelpText(component, event, helper);
    },
    helpTextIn: function(component, event, helper) {
        helper.toggleHelpText(component, event, helper);        
    },
    doneWaiting: function(component, event, helper) {
        setTimeout(function() {
            component.set("v.spinner", false);
        }, 2000);
    },
    handleValueChange : function (component,event,helper){//Added by Nidhi BAC-5957  
        if( !event.getParam("value")){
            var timer = setInterval($A.getCallback(function() {
                helper.callPollingMethod(component,helper);
            }), 60000
        );    
            component.set("v.setIntervalId", timer) ;                        
        }else{
            clearInterval(component.get("v.setIntervalId"));
        }  
    },
    clickHandler: function(component, event, helper) {
        let allButtons = component.get("v.allButtons");
        let btnUrl = null;
        let btnId = event.getSource().get("v.name");
        let isUpdatedId = btnId.startsWith("Rec-");
        if(isUpdatedId) {
            btnId = btnId.replace(/^(Rec-){1}/, '');
        }
        for(let i = 0; i<allButtons.length; i++) {
            if(btnId === allButtons[i].buttonId) {
                btnUrl = allButtons[i].buttonUrl;
                break;
            }
        }
        const action = component.get("c.updateRecentItem");
        // Set clicked button id to recent items list
        action.setParams({
            "strButtonId": btnId
        });
        // Navigate to clicked url
        if(btnUrl){
            btnUrl += helper.addReturnUrl(btnUrl);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": btnUrl,
            });
            urlEvent.fire(); 
        }
        $A.enqueueAction(action);
        
        //Added by Nidhi BAC-5957  
        if(btnId==="SECTION1_BTN9"){  
            component.set("v.spinner", true);
            const postInstallScript = component.get("c.callPostPackageInstall");
            postInstallScript.setCallback(this, function(response) {
                let state = response.getState();
                if(state === 'SUCCESS') {
                    component.set("v.configuratorDeployed",false);
                    var sectionsList = component.get("v.sectionObj");
                    if(sectionsList!=null){
                        for(let i = 0; i < sectionsList.length; i++) {
                            if(sectionsList[i].sectionId === "SECTION1"){
                              var buttonList = sectionsList[i].buttonList;
                              for(let j = 0; j <buttonList.length; j++) {
                                 if(buttonList[j].buttonId === btnId) {
                                    buttonList[j].isButtonEnabled = 'false';
                                    component.set("v.spinner", false);
                                    break;
                                 }                            
                              } 
                              break;
                            }
                        }
                        component.set("v.sectionObj",sectionsList);
                    }
                    
                    //Update Recent View Buttons
                    var recentlyVisitedBtns = component.get("v.recentlyVisitedBtns");
                    if(recentlyVisitedBtns!==null){
                        for(let j = 0; j <recentlyVisitedBtns.length; j++) {
                            if(recentlyVisitedBtns[j].buttonId === btnId) {
                                recentlyVisitedBtns[j].isButtonEnabled = 'false';
                                break;
                            }                            
                        }
                        component.set("v.recentlyVisitedBtns",recentlyVisitedBtns);
                    }
                }else {
                    component.set("v.spinner", false);
                    console.error("Error in Post Install Script.");
                    //debugger;
                }
            });
            $A.enqueueAction(postInstallScript);
        }
    }
})