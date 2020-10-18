({
	doinit : function(component, event, helper) {
		component.set("v.title", component.get("v.clockDetails")["title"]);
        component.set("v.dateTimeValue", component.get("v.clockDetails")["dateTimeValue"]);
        component.set("v.timeLeft", component.get("v.clockDetails")["timeLeft"]);
        component.set("v.circleDegree", component.get("v.clockDetails")["circleDegree"]);
        component.set("v.totalMin", component.get("v.clockDetails")["totalMin"]);
        component.set("v.isClockSet", component.get("v.clockDetails")["isClockSet"]);
        component.set("v.isClockCompleted", component.get("v.clockDetails")["isClockCompleted"]);
        component.set("v.isOverTime", component.get("v.clockDetails")["isOverTime"]);
        component.set("v.isDaysAvailable", component.get("v.clockDetails")["isDaysAvailable"]);
        component.set("v.overDueTime", component.get("v.clockDetails")["overDueTime"]);
        if(!component.get("v.clockPaused")){
        	helper.startClock(component);
        }else{
            helper.stopClock(component);
        }
	}
})