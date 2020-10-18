/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * The SFA_Platform_Event_publish class provide a feature to publish platform event upon creation and updatation of records . 
   The Fields in scope are included in the Field Set associated with each object.
 *
 * @author Jaysukh Patel
 * @version 19.2
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Jaysukh Patel        20 March 2019       Created. 
 *****************************************************************************************************/

public with sharing class SFA_PlatformEventPublish
{
        public void publishEventAfterInsert(List<Sobject> lstOfNewRecord,String objectName){
          // Added check to not support bulk insert
          if(lstOfNewRecord != null && lstOfNewRecord.size() == 1)
          {
            List<SVMXC__SFA_Platform_Event__e> platformEventsToPublish = new List<SVMXC__SFA_Platform_Event__e>();
              Set<String> fields = new Set<String>();
              try{  
                if(!String.isBlank(objectName) && 'SVMXC__Service_Order__c'.equalsIgnoreCase(objectName))
                {
                  List<String> lstOfFields  = getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_WORD');
                  if(lstOfFields!=null && lstOfFields.size()>0)
                  {
                   fields.addAll(lstOfFields);
                  }
                  fields.add('Id');
                }
                if(!String.isBlank(objectName) && 'SVMXC__SVMX_Event__c'.equalsIgnoreCase(objectName))
                {
                  List<String> lstOfFields  = getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_SVMXEVENT');
                  if(lstOfFields != null && lstOfFields.size()>0)
                   {
                    fields.addAll(lstOfFields);
                   }
                   fields.add('Id');    
                }
                if(!String.isBlank(objectName) && 'Event'.equalsIgnoreCase(objectName))
                {
                  List<String> lstOfFields  = getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_EVENT');
                  if(lstOfFields != null && lstOfFields.size()>0)
                   {
                    fields.addAll(lstOfFields);
                   }
                   fields.add('Id');    
                }
                if(fields.size()>0)
                {
                  System.debug('fields: '+fields);
                  for(Sobject sobj : lstOfNewRecord)
                  {
                    SFA_WrapperDef.SFA_RecordWrapper new_Record = new SFA_WrapperDef.SFA_RecordWrapper(); 
                    for(String fieldName:fields)
                      {
                          new_Record.mapfieldNameValues.put(fieldName,String.valueOf(sobj.get(fieldName)));
                      }
                      String strNewObjJson = JSON.serialize(new_Record);
                      SVMXC__SFA_Platform_Event__e plEvent = new SVMXC__SFA_Platform_Event__e();
                      plEvent.SVMXC__New_Record_JSON__c = strNewObjJson; 
                      plEvent.SVMXC__Record_Id__c = String.valueOf(sobj.get('Id'));
                      plEvent.SVMXC__Event_Type__c = 'Inserted';
                      plEvent.SVMXC__Object_Name__c = objectName;
                      platformEventsToPublish.add(plEvent);
                  }
                   
                }
                if(platformEventsToPublish != null && platformEventsToPublish.size()>0)
                {   //Removed security check as part of defect BAC-5115
                    EventBus.publish(platformEventsToPublish);//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
             }catch(Exception ex)
             {
                 System.debug('exception'+ex.getStackTraceString()+ 'Mesaage: '+ex.getMessage());
             }
          }  
        }
        public void publishEventAfterUpdate(List<Sobject> lstOfNewRecord,List<Sobject> lstOfOldRecord,String objectName)
        {
          // Added check to not support bulk update
          if(lstOfNewRecord != null && lstOfNewRecord.size() == 1)
           {
              List<SVMXC__SFA_Platform_Event__e> platformEventsToPublish = new List<SVMXC__SFA_Platform_Event__e>();
              Set<String> fields = new Set<String>();
              try{  
                 if(!String.isBlank(objectName) && 'SVMXC__Service_Order__c'.equalsIgnoreCase(objectName))
                 {
                   List<String> lstOfFields  = getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_WORD');
                   if(lstOfFields!=null && lstOfFields.size()>0)
                   {
                    fields.addAll(lstOfFields);
                   }
                   fields.add('Id');
                 }
                 if(!String.isBlank(objectName) && 'SVMXC__SVMX_Event__c'.equalsIgnoreCase(objectName))
                 {
                   List<String> lstOfFields  = getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_SVMXEVENT');
                   if(lstOfFields != null && lstOfFields.size()>0)
                    {
                     fields.addAll(lstOfFields);
                    }
                    fields.add('Id');   
                 }
                 if(!String.isBlank(objectName) && 'Event'.equalsIgnoreCase(objectName))
                 {
                   List<String> lstOfFields  = getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_EVENT');
                   if(lstOfFields != null && lstOfFields.size()>0)
                    {
                     fields.addAll(lstOfFields);
                    }
                    fields.add('Id');   
                  }
                  if(fields.size()>0)
                  {
                      System.debug('fields: '+fields);
                      for(integer i =0; i<lstOfNewRecord.size();i++)
                      {
                          SFA_WrapperDef.SFA_RecordWrapper old_Record = new SFA_WrapperDef.SFA_RecordWrapper();
                          SFA_WrapperDef.SFA_RecordWrapper new_Record = new SFA_WrapperDef.SFA_RecordWrapper();
                          for(String fieldName:fields)
                          {
                              old_Record.mapfieldNameValues.put(fieldName,String.valueOf(lstOfOldRecord[i].get(fieldName)));
                              new_Record.mapfieldNameValues.put(fieldName,String.valueOf(lstOfNewRecord[i].get(fieldName)));
                              
                          }
                          String strOldObjJson = JSON.serialize(old_Record); 
                          String strNewObjJson = JSON.serialize(new_Record);
                          SVMXC__SFA_Platform_Event__e plEvent = new SVMXC__SFA_Platform_Event__e();
                          plEvent.SVMXC__New_Record_JSON__c = strNewObjJson; 
                          plEvent.SVMXC__Old_Record_JSON__c = strOldObjJson;
                          plEvent.SVMXC__Record_Id__c = String.valueOf(lstOfnewRecord[i].get('Id'));
                          plEvent.SVMXC__Event_Type__c = 'Updated';
                          plEvent.SVMXC__Object_Name__c = objectName;
                          platformEventsToPublish.add(plEvent);
                          
                      }
                      
                  }
                  if(platformEventsToPublish != null && platformEventsToPublish.size()>0)
                  {    //Removed security check as part of defect BAC-5115
                       EventBus.publish(platformEventsToPublish);//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                  }
                }catch(Exception ex)
                {
                    System.debug('Exception'+ex.getStackTraceString() + 'Mesaage: '+ex.getMessage());  
                }
           }    
        }
        public List<String> getFieldSetFields(String objectname,String fieldSetName)
        {   
            //This method implimented to support only one object at a time
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{objectName});
            List<String> lstOfField = new List<String>();            
            for(DescribeSObjectResult results : descResult)
            {
                Schema.FieldSet fieldSetObj = results.FieldSets.getMap().get(fieldSetName);
                if(fieldSetObj != null)
                {
                   List<Schema.FieldSetMember> fields = fieldSetObj.getFields();
                   if(fields != null && fields.size() >0)
                   {
                     for(Schema.FieldSetMember member:fields )
                     {
                       lstOfField.add(member.getFieldPath());
                     }
                   }
                }
                System.debug('lstOfField: '+lstOfField);    
            }
           return lstOfField;
        }

}