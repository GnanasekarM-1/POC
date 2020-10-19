({
	getWizardsController : function(component, event, helper) {
        var main = component.find('main');
       	$A.util.removeClass(main, 'medium');
        $A.util.addClass(main, component.get("v.maxheight"));
        
    },
    
    recordUpdated : function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "LOADED" || changeType === "CHANGED" || recordId.startsWith('00U')) { //#defectFix: 048326, added recordId.startsWith('00U') since force:recordData does not support Event/Task Object
            helper.getWizardsHelper(component, event, helper);
        }
    },
    
    showMoreClick: function(component, event, helper){
        // BAC-3020 - Show All and Show Less Functionality
        event.preventDefault();
        var main = component.find('main');
        $A.util.removeClass(main, component.get("v.maxheight"));
        helper.showLessMore(component, event, helper);
        
    },
    showLessClick: function(component, event, helper){
        // BAC-3020 - Show All and Show Less Functionality
        event.preventDefault();
        var main = component.find('main');
        $A.util.addClass(main, component.get("v.maxheight"));
        helper.showLessMore(component, event, helper);
    },
    
    onRender: function(component, event, helper){
        // BAC-3912 - Show All/ Show Less should be displayed only 
        // when the content height is more than the Height defined
        var maxHeightValue =  component.get("v.maxheight"); 
        maxHeightValue = maxHeightValue == 'large'? 580 : (maxHeightValue == 'medium'? 385: 195); 
        var wizardComponentLoadHeight = component.find('wizardStepWrapper').getElement().offsetHeight;
        if(wizardComponentLoadHeight > maxHeightValue)
            component.set('v.isLoadingDone', true);
    }
})