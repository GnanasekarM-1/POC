({
    startClock : function(component) {
        if(component.get("v.setIntervalId")){
            window.clearInterval(component.get("v.setIntervalId"));
        }
        
        var myInterval = window.setInterval (
            $A.getCallback(function() {
                var totalMin = component.get("v.totalMin");
                var reduceDegree = 1/totalMin*360;
                var currentValue = component.get("v.circleDegree");
                if(currentValue != 0){
                    currentValue = currentValue-reduceDegree;
                    component.set("v.circleDegree", currentValue);
                    var timeLeftValue = component.get("v.timeLeft");
                    var minutes = 0,hours = 0,totalMinutes = 0;
                    var isDaysAvailable = component.get("v.isDaysAvailable")
                    if(!isDaysAvailable && timeLeftValue){
                        minutes = Number(timeLeftValue.split(' : ').pop());
                        hours = Number(timeLeftValue.split(' : ')[0]);
                        totalMinutes = hours*60+minutes;
                        totalMinutes = totalMinutes-1;
                        timeLeftValue = Math.floor(totalMinutes / 60) +' : '+totalMinutes % 60;
                        component.set("v.timeLeft", timeLeftValue);
                    }
                    if(timeLeftValue && timeLeftValue == '0 : 0'){
                        window.clearInterval(myInterval);                           
                    }
                }
            }), 60000);
        component.set("v.setIntervalId", myInterval) ; 
    },
    stopClock : function(component) {
        window.clearInterval(component.get("v.setIntervalId"));
    }
})