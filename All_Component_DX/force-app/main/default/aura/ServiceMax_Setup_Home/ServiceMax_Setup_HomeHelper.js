({
    fetchSections: function(component, event, helper) {
        const sections = component.get("c.getSetupHomeDetails");
        sections.setCallback(this, function(response) {
            const state = response.getState();
            if(state === 'SUCCESS') {
                let setupSections = response.getReturnValue();
                component.set("v.setupComponentTitle", setupSections.setupComponentTitle);
                component.set("v.helpButtonLabel", setupSections.helpBtnLabel);
                component.set("v.helpButtonUrl", setupSections.helpBtnUrl);
                component.set("v.licenseDescription", setupSections.licenseDesc);
                component.set("v.licenseTypeTxt", setupSections.licenseType);
                component.set("v.versionLabelTxt", setupSections.versionLabel);
                component.set("v.versionNumberTxt", setupSections.versionNumber);
                let sectionsList = setupSections.setupSections;
                //sort section by it's titles
                sectionsList.sort(compareSections);
                let recentBtnIds = setupSections.recentlyVisited.recentlyVisitedBtnIds;
                let recentButtons = [];
                let allButtons = [];
                if(sectionsList && sectionsList.length > 0) {
                    for(let i = 0; i < sectionsList.length; i++) {
                        if(sectionsList[i].buttonList){
                            // sort buttons by it's labels
                            sectionsList[i].buttonList.sort(compareLabels);
                            allButtons.push(...sectionsList[i].buttonList);
                        }
                    }
                }
                component.set("v.sectionObj", sectionsList);
                component.set("v.recentlyVisited", setupSections.recentlyVisited.recentlyVisitedTitle);
                component.set("v.allButtons", allButtons);
                var setupBodyId = component.find('setupBodyId');
                var recentBodyId = component.find('recentBodyId');
                // Recent container hidden by default while data is null 
                if(recentBtnIds.length === 0) {
                    $A.util.addClass(setupBodyId, 'slds-size_3-of-3');
                    $A.util.addClass(recentBodyId,'hide-recent');
                    $A.util.removeClass(setupBodyId, 'slds-size_2-of-3');
                }
                else {
                    $A.util.addClass(setupBodyId, 'slds-size_2-of-3');
                    $A.util.removeClass(recentBodyId,'hide-recent');
                    $A.util.removeClass(setupBodyId, 'slds-size_3-of-3');
                    // Read recent button data
                    for(let j = 0; j<recentBtnIds.length; j++) {
                        for(let i = 0; i <allButtons.length; i++) {
                            if(allButtons[i].buttonId === recentBtnIds[j]) {
                                recentButtons.push(allButtons[i]);
                                break;
                            }                            
                        }
                    }
                    component.set("v.recentlyVisitedBtns", recentButtons);
                }
                helper.callPollingMethod(component,event,helper);//Added by Nidhi BAC-5957  
            }
            else {
                console.error("Error in fetching setup page data");
            }
        });
        $A.enqueueAction(sections);
        
        function compareSections(a,b) {
          if (a.sectionTitle < b.sectionTitle)
            return -1;
          if (a.sectionTitle > b.sectionTitle)
            return 1;
          return 0;
        }
        
        function compareLabels(a,b) {
            if (a.buttonLabel < b.buttonLabel)
                return -1;
            if (a.buttonLabel > b.buttonLabel)
                return 1;
            return 0;            
        }
    },
    toggleHelpText: function(component, event, helper) {
        let anchorId = event.target.id;
        let tooltipId = "TP-"+anchorId;
        let selectedItemNew = document.getElementById(tooltipId);
        setTimeout(function() {
            $A.util.toggleClass(selectedItemNew, "toggle-tooltip");
        }, 500);
    },
    addReturnUrl: function(url){
        const attrName = 'RetURL';
        const urlParam = window.location.pathname;
        const saperator = url.includes('?') ? '&' : '?';
        return saperator + attrName +'='+ urlParam;
    },
    callPollingMethod : function (component,helper){  //Added by Nidhi BAC-5957  
        var action = component.get("c.checkToolSeedStatus");        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let isEnabled = response.getReturnValue();
                var sectionsList = component.get("v.sectionObj");
                if(isEnabled && sectionsList!=null){
                    for(let i = 0; i < sectionsList.length; i++) {
                        if(sectionsList[i].sectionId === "SECTION1"){
                          var buttonList = sectionsList[i].buttonList;
                          for(let j = 0; j <buttonList.length; j++) {
                             if(buttonList[j].buttonId === "SECTION1_BTN9") {
                                buttonList[j].isButtonEnabled = 'true';
                                break;
                             }                            
                          } 
                          break;
                        }
                    }
                    component.set("v.sectionObj",sectionsList);
                    //Update Recent View Buttons
                    var recentlyVisitedBtns = component.get("v.recentlyVisitedBtns");
                    if(recentlyVisitedBtns!==null){
                        for(let j = 0; j <recentlyVisitedBtns.length; j++) {
                            if(recentlyVisitedBtns[j].buttonId === "SECTION1_BTN9") {
                                recentlyVisitedBtns[j].isButtonEnabled = 'true';
                                break;
                            }                            
                        }
                        component.set("v.recentlyVisitedBtns",recentlyVisitedBtns);
                    }
                    
                    component.set("v.configuratorDeployed",true);
                }else if(!isEnabled && sectionsList!=null){
                    for(let i = 0; i < sectionsList.length; i++) {
                        if(sectionsList[i].sectionId === "SECTION1"){
                          var buttonList = sectionsList[i].buttonList;
                          for(let j = 0; j <buttonList.length; j++) {
                             if(buttonList[j].buttonId === "SECTION1_BTN9") {
                                buttonList[j].isButtonEnabled = 'false';
                                break;
                             }                            
                          } 
                          break;
                        }
                    }
                    component.set("v.sectionObj",sectionsList);
                    //Update Recent View Buttons
                    var recentlyVisitedBtns = component.get("v.recentlyVisitedBtns");
                    if(recentlyVisitedBtns!==null){
                        for(let j = 0; j <recentlyVisitedBtns.length; j++) {
                            if(recentlyVisitedBtns[j].buttonId === "SECTION1_BTN9") {
                                recentlyVisitedBtns[j].isButtonEnabled = 'false';
                                break;
                            }                            
                        }
                    	component.set("v.recentlyVisitedBtns",recentlyVisitedBtns);
                    }
                    component.set("v.configuratorDeployed",false);
                }
            }
        });
        $A.enqueueAction(action); 
    }, 
})