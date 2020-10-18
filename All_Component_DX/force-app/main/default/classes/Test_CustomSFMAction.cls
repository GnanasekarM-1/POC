global class Test_CustomSFMAction 
{
     webservice static SVMXC.INTF_WebServicesDef.INTF_Response takeWOOwnership(SVMXC.INTF_WebServicesDef.INTF_Request request)
     {     
          system.debug(LoggingLevel.WARN, 'req is = ' + request); 
          SVMXC.INTF_WebServicesDef.INTF_Response obj = new SVMXC.INTF_WebServicesDef.INTF_Response(); 
          try 
          {
              String recordId; 
              for(SVMXC.INTF_WebServicesDef.SVMXMap objSVXMMap : request.valueMap) 
              { 
                  if(objSVXMMap.key == 'SVMX_RECORDID') 
                  { 
                       recordId = objSVXMMap.value; 
                  } 
              } 
              SVMXC__Service_Order__c objWO = [Select Id, Name, OwnerId from SVMXC__Service_Order__c where Id=:recordId]; 
              objWO.OwnerId = UserInfo.getUserId(); 
              Update objWO; 
             
              SVMXC.INTF_WebServicesDef.SVMXMap sObj = new SVMXC.INTF_WebServicesDef.SVMXMap(); 
              sObj.record = objWO; 

              obj.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>(); 
              obj.valueMap.add(sObj); 

              obj.message = 'Work Order updated';
              obj.success = true;
              obj.messageType = 'INFO'; 
              system.debug(LoggingLevel.WARN, 'obj is = ' + obj); 
              return obj; // Return should be of INTF_Response type and 
          } 
          catch(Exception ex) 
          { 
              // Construct Failure response, Update response object members 
              obj.message = ex.getMessage(); 
              obj.success = false; 
             obj.messageType = 'ERROR'; 
              return obj; 
          }
     }
}