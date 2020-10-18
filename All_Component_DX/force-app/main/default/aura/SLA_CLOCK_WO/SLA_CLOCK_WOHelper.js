({
	parseResponse : function(component, event, helper,slaResponse) {
        var me = this;
        me.shouldEnablePlayAndPauseButtons(component,slaResponse);
        
        var initialMap = me.getinitialClockMap(slaResponse);
        var onsiteMap = me.getOnsiteResponseClockMap(slaResponse);
        var resolutionMap  = me.getResolutionClockMap(slaResponse);
        var  restorationMap = me.getRestorationClockMap(slaResponse);
        
        component.set("v.initialClock",initialMap);
         component.set("v.onsiteClock",onsiteMap);
         component.set("v.restorationClock",restorationMap);
         component.set("v.resolutionClock",resolutionMap);
       	component.set("v.isLoadingDone",true);
	},
    getinitialClockMap: function(slaResponse){
        var me = this;
        var initialTimeleft = '',isDaysAvailableIR = false;
        if(slaResponse.iIRdays == '0'){
            initialTimeleft = slaResponse.iIRhrs + ' : '+ slaResponse.iIRmins;
        }else{
            initialTimeleft = slaResponse.iIRdays + ' '+ $A.get("$Label.c.SLAT003_TAG009");
            isDaysAvailableIR = true;
        }
        var initialTimeDegree = me.calculateCirleDegree('initialTime',slaResponse);
        var isClockSetIR = true,isClockCompletedIR = false, isOverTimeIR = false;        
        if($A.util.isEmpty(slaResponse.InitialResponseBy)){
            isClockSetIR = false;
        }
        if(!$A.util.isEmpty(slaResponse.WOObj.SVMXC__Actual_Initial_Response__c)){
            isClockCompletedIR = true;
        }
        
        if(slaResponse.isOverTimeIR){
            isOverTimeIR = true;
        }
        var actualValue = Number(slaResponse.iIRdays*24*60)+Number(slaResponse.iIRhrs*60)+Number(slaResponse.iIRmins);
        var totalValue = '';
        if(actualValue>slaResponse.SLAIRMin && slaResponse.CommitmentTimeIR){
            totalValue = Number(slaResponse.CommitmentTimeIR.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeIR.split(':')[1]*60)+Number(slaResponse.CommitmentTimeIR.split(':')[2]);
        }else{
            totalValue = slaResponse.SLAIRMin;
        }  
        
        var initialMap = {
            'title':$A.get("$Label.c.SLAT003_TAG030"),
            'dateTimeValue':slaResponse.InitialResponseBy,
            'timeLeft':initialTimeleft,
            'circleDegree':initialTimeDegree,
            'totalMin':totalValue,
            'isClockSet':isClockSetIR,
            'isClockCompleted':isClockCompletedIR,
            'isOverTime':isOverTimeIR,
            'isDaysAvailable':isDaysAvailableIR,
            'overDueTime':slaResponse.overdueTimeIR
        }
        
        return initialMap;
    },
    getOnsiteResponseClockMap: function(slaResponse){
		var me = this;
        var onsiteTimeleft = '',isDaysAvailableOR = false;
        if(slaResponse.iORdays  == '0'){
            onsiteTimeleft = slaResponse.iORhrs + ' : '+ slaResponse.iORmins;
        }else{
            onsiteTimeleft = slaResponse.iORdays  + ' '+$A.get("$Label.c.SLAT003_TAG009");
            isDaysAvailableOR = true;
        }
        var onsiteTimeDegree = me.calculateCirleDegree('onsiteTime',slaResponse);
        var isClockSetOR = true,isClockCompletedOR = false, isOverTimeOR = false;        
        if($A.util.isEmpty(slaResponse.OnsiteResponseBy)){
            isClockSetOR = false;
        }
        if(!$A.util.isEmpty(slaResponse.WOObj.SVMXC__Actual_Onsite_Response__c)){
            isClockCompletedOR = true;
        }
        if(slaResponse.isOverTimeOR){
            isOverTimeOR = true;
        }
        var actualValue = Number(slaResponse.iORdays*24*60)+Number(slaResponse.iORhrs*60)+Number(slaResponse.iORmins);
        var totalValue='';
        if(actualValue>slaResponse.SLAORMin && slaResponse.CommitmentTimeOR){
            totalValue = Number(slaResponse.CommitmentTimeOR.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeOR.split(':')[1]*60)+Number(slaResponse.CommitmentTimeOR.split(':')[2]);
        }else{
            totalValue = slaResponse.SLAORMin;
        }
        var onsiteMap = {
            'title':$A.get("$Label.c.SLAT003_TAG031"),
            'dateTimeValue':slaResponse.OnsiteResponseBy,
            'timeLeft':onsiteTimeleft,
            'circleDegree':onsiteTimeDegree,
            'totalMin':totalValue,
            'isClockSet':isClockSetOR,
            'isClockCompleted':isClockCompletedOR,
            'isOverTime':isOverTimeOR,
            'isDaysAvailable':isDaysAvailableOR,
            'overDueTime':slaResponse.overdueTimeOR
        }
		return onsiteMap;
    },
    getResolutionClockMap: function(slaResponse){
        var me = this;
        var resolutionleft = '',isDaysAvailableRES = false;
        if(slaResponse.iAROdays  == '0'){
            resolutionleft = slaResponse.iAROhrs  + ' : '+ slaResponse.iAROmins;
        }else{
            resolutionleft = slaResponse.iAROdays  + ' '+$A.get("$Label.c.SLAT003_TAG009");
            isDaysAvailableRES = true;
        }
        var resolutionTimeDegree = me.calculateCirleDegree('resolutionTime',slaResponse);
        var isClockSetRES = true,isClockCompletedRES = false, isOverTimeRES = false;
        if($A.util.isEmpty(slaResponse.ResolutionBy)){
            isClockSetRES = false;
        }
        if(!$A.util.isEmpty(slaResponse.WOObj.SVMXC__Actual_Resolution__c)){
            isClockCompletedRES = true;
        }
        if(slaResponse.isOverTimeRES){
            isOverTimeRES = true;
        }
        var actualValue = Number(slaResponse.iAROdays*24*60)+Number(slaResponse.iAROhrs*60)+Number(slaResponse.iAROmins);
        var totalValue='';
        if(actualValue>slaResponse.SLAResolutionMin && slaResponse.CommitmentTimeResol){
            totalValue = Number(slaResponse.CommitmentTimeResol.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeResol.split(':')[1]*60)+Number(slaResponse.CommitmentTimeResol.split(':')[2]);
        }else{
            totalValue = slaResponse.SLAResolutionMin;
        }
        var resolutionMap = {
            'title':$A.get("$Label.c.SLAT003_TAG033"),
            'dateTimeValue':slaResponse.ResolutionBy,
            'timeLeft':resolutionleft,
            'circleDegree':resolutionTimeDegree,
            'totalMin':totalValue,
            'isClockSet':isClockSetRES,
            'isClockCompleted':isClockCompletedRES,
            'isOverTime': isOverTimeRES,
            'isDaysAvailable':isDaysAvailableRES,
            'overDueTime':slaResponse.overdueTimeRES
        }
        
        return resolutionMap;
    },
    getRestorationClockMap: function(slaResponse){
        var me = this; 
        var restorationeft = '',isDaysAvailableREST = false;
        if(slaResponse.iAREdays  == '0'){
            restorationeft = slaResponse.iAREhrs   + ' : '+ slaResponse.iAREmins ;
        }else{
            restorationeft = slaResponse.iAREdays  + ' '+$A.get("$Label.c.SLAT003_TAG009");
            isDaysAvailableREST = true;
        }
        var restorationTimeDegree = me.calculateCirleDegree('restorationTime',slaResponse);
        var isClockSetREST = true,isClockCompletedREST = false, isOverTimeREST = false;
        if($A.util.isEmpty(slaResponse.RestorationBy)){
            isClockSetREST = false;
        }
        if(!$A.util.isEmpty(slaResponse.WOObj.SVMXC__Actual_Restoration__c)){
            isClockCompletedREST = true;
        }
        
        if(slaResponse.isOverTimeREST){
            isOverTimeREST = true;
        }
        var actualValue = Number(slaResponse.iAREdays*24*60)+Number(slaResponse.iAREhrs*60)+Number(slaResponse.iAREmins);
        var totalValue='';
        if(actualValue>slaResponse.SLARestorationMin && slaResponse.CommitmentTimeResto){
            totalValue = Number(slaResponse.CommitmentTimeResto.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeResto.split(':')[1]*60)+Number(slaResponse.CommitmentTimeResto.split(':')[2]);
        }else{
            totalValue = slaResponse.SLARestorationMin;
        }
        var restorationMap = {
            'title':$A.get("$Label.c.SLAT003_TAG032"),
            'dateTimeValue':slaResponse.RestorationBy ,
            'timeLeft':restorationeft,
            'circleDegree':restorationTimeDegree,
            'totalMin':totalValue,
            'isClockSet':isClockSetREST,
            'isClockCompleted':isClockCompletedREST,
            'isOverTime':isOverTimeREST,
            'isDaysAvailable':isDaysAvailableREST,
            'overDueTime':slaResponse.overdueTimeREST
        }
        
        return restorationMap;
    },
    calculateCirleDegree: function(clockType, slaResponse){
        var totalValue = 0, actualValue = 0;
        if(clockType == 'initialTime'){
            actualValue = Number(slaResponse.iIRdays*24*60)+Number(slaResponse.iIRhrs*60)+Number(slaResponse.iIRmins);
            if(actualValue>slaResponse.SLAIRMin && slaResponse.CommitmentTimeIR){
                totalValue = Number(slaResponse.CommitmentTimeIR.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeIR.split(':')[1]*60)+Number(slaResponse.CommitmentTimeIR.split(':')[2]);
            }else{
                totalValue = slaResponse.SLAIRMin;
            }           
        }else if(clockType == 'onsiteTime'){
            actualValue = Number(slaResponse.iORdays*24*60)+Number(slaResponse.iORhrs*60)+Number(slaResponse.iORmins);
        	if(actualValue>slaResponse.SLAORMin && slaResponse.CommitmentTimeOR){
                totalValue = Number(slaResponse.CommitmentTimeOR.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeOR.split(':')[1]*60)+Number(slaResponse.CommitmentTimeOR.split(':')[2]);
            }else{
                totalValue = slaResponse.SLAORMin;
            }
        }else if(clockType == 'resolutionTime'){
            actualValue = Number(slaResponse.iAROdays*24*60)+Number(slaResponse.iAROhrs*60)+Number(slaResponse.iAROmins);
        	if(actualValue>slaResponse.SLAResolutionMin && slaResponse.CommitmentTimeResol){
                totalValue = Number(slaResponse.CommitmentTimeResol.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeResol.split(':')[1]*60)+Number(slaResponse.CommitmentTimeResol.split(':')[2]);
            }else{
                totalValue = slaResponse.SLAResolutionMin;
            }
        }else if(clockType == 'restorationTime'){
            actualValue = Number(slaResponse.iAREdays*24*60)+Number(slaResponse.iAREhrs*60)+Number(slaResponse.iAREmins);
        	if(actualValue>slaResponse.SLARestorationMin && slaResponse.CommitmentTimeResto){
                totalValue = Number(slaResponse.CommitmentTimeResto.split(':')[0]*24*60)+Number(slaResponse.CommitmentTimeResto.split(':')[1]*60)+Number(slaResponse.CommitmentTimeResto.split(':')[2]);
            }else{
                totalValue = slaResponse.SLARestorationMin;
            }
        }
        
        var percent = actualValue/totalValue;
        var valueInDegree = percent*360;
        
        if(valueInDegree == 0)valueInDegree=360;
        return valueInDegree;
    },
    showSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    shouldEnablePlayAndPauseButtons: function(component,slaResponse){
        var isEnabled = true;
        if(!(slaResponse.iIRdays || slaResponse.iIRhrs || slaResponse.iIRmins || slaResponse.iIRsecs || slaResponse.iORdays || slaResponse.iORhrs || slaResponse.iORmins || slaResponse.iORsecs || slaResponse.iAREdays || slaResponse.iAREhrs
            || slaResponse.iAREmins || slaResponse.iAREsecs || slaResponse.iAROdays || slaResponse.iAROhrs || slaResponse.iAROmins || slaResponse.iAROsecs)) {
        	isEnabled = false;
        }
        if(slaResponse.SLAClockPausedSetting){
            component.set("v.shouldEnablePlayPause",isEnabled);
        }   
    }

})