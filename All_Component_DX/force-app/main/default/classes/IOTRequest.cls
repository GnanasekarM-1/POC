global class IOTRequest{

    global class ServiceRequestAlert{
        global Asset Asset;
        global Event Event;
        global Map<String, String> Others;
        global Map<String, String> CustomEvent;
    }
    
    global class Asset{
        global String ThingName;
        global String ProductName;
        global String InstalledPrductNumber;
        global String SerialNumber;
    }
    
    global class Event{
        global String Subject;
        global String Priority;
        global String Description;
        global String EventTime;
        global String AlertType;  
        global String Property;
        global String ServiceSessionId;
        global TechnicalAttributeConfiguration.IbInstancePayload instancePayload;
    }
   }