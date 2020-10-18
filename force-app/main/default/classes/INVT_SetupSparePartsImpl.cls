/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The PM_Plan_Wrapper is a wrapper class for wrapping the data retrieved from the Service class which 
 * is used during the PM plan create or edit
 * 
 *
 * @author Anchal
 * @version 39
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anchal               7 June 2017       Created.
 *              Soumyaranjan        13th July 2018    Security Scanned 
 *****************************************************************************************************/
 /* Security Scanned */
 public with sharing class INVT_SetupSparePartsImpl{
     public INVT_SpareParts_Wrapper.SpareParts_Response getProfileDetails(INVT_SpareParts_Wrapper.SpareParts_Request  request) {
            INVT_SpareParts_Wrapper.SpareParts_Response sparePartsRes = new INVT_SpareParts_Wrapper.SpareParts_Response();
            
            List<INVT_SpareParts_Wrapper.ObjectInfo> listProfileData = new List<INVT_SpareParts_Wrapper.ObjectInfo>();
            try{
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__ServiceMax_Config_Data__c profileData :[Select Id, SVMXC__PROFILE_NAME__c from SVMXC__ServiceMax_Config_Data__c 
                                    where RecordType.Name = 'Configuration Profile' and  SVMXC__Active__c = true and SVMXC__CONFIGURATION_TYPE__c = 'Group' Order By SVMXC__PROFILE_NAME__c]){
                    INVT_SpareParts_Wrapper.ObjectInfo groupProfile = new INVT_SpareParts_Wrapper.ObjectInfo();
                    groupProfile.id = profileData.id;
                    groupProfile.name = profileData.SVMXC__PROFILE_NAME__c;
                    listProfileData.add(groupProfile);
                }
                
                sparePartsRes.success = true;
                sparePartsRes.profilelist = listProfileData;
                
            }
            catch(Exception e){
                sparePartsRes.success = false;
                sparePartsRes.messageList = new List<String>();
                sparePartsRes.messageList.add(e.getMessage());
            }
            
            return sparePartsRes;
     }
     
     
     
     public INVT_SpareParts_Wrapper.SpareParts_Response getSparePartConfig(INVT_SpareParts_Wrapper.SpareParts_Request  request) {
         INVT_SpareParts_Wrapper.SpareParts_Response sparePartsConfigRes = new INVT_SpareParts_Wrapper.SpareParts_Response();
         sparePartsConfigRes.success = false;
         try{
             // Get location Type
             Schema.DescribeFieldResult fieldResult = SVMXC__Site__c.SVMXC__Location_Type__c.getDescribe();
             List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
               
             List <INVT_SpareParts_Wrapper.ObjectInfo> locationTypePicklist = new List <INVT_SpareParts_Wrapper.ObjectInfo>();
                
             for( Schema.PicklistEntry f : ple){
                 INVT_SpareParts_Wrapper.ObjectInfo opVal = new INVT_SpareParts_Wrapper.ObjectInfo();
                 opVal.id = f.getValue();
                 opVal.name = f.getLabel();
                 locationTypePicklist.add(opVal);
             }       
             
             system.debug(locationTypePicklist);
             //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             List<SVMXC__SM_Inventory_Config__c> listPartsConfig = [Select SVMXC__SM_Content__c 
                                                                     FROM SVMXC__SM_Inventory_Config__c 
                                                                         WHERE SVMXC__SM_ServiceMax_Profile__c =: request.profileId]; 
             
             if(listPartsConfig != null && listPartsConfig.size() > 0){
                 Content contentJSON = (Content) JSON.deserialize(listPartsConfig[0].SVMXC__SM_Content__c,Content.class);
                 sparePartsConfigRes.layout= contentJSON.layout;
                 sparePartsConfigRes.locatepartsetup = contentJSON.locatepartsetup;
                 
             }
             sparePartsConfigRes.success = true;
             sparePartsConfigRes.profileId = request.profileId;
             system.debug(locationTypePicklist);
             
             if(sparePartsConfigRes.locatepartsetup == null){
                 INVT_SpareParts_Wrapper.LocatePart locatePart= new INVT_SpareParts_Wrapper.LocatePart (); 
                 sparePartsConfigRes.locatepartsetup = locatePart ;
             }
             
             sparePartsConfigRes.locatepartsetup.listlocationtype = locationTypePicklist;
             //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             List<SVMXC__ServiceMax_Processes__c> svmxProcess = [Select SVMXC__ProcessID__c, SVMXC__Name__c
                                                                     FROM SVMXC__ServiceMax_Processes__c
                                                                         WHERE SVMXC__Module__r.SVMXC__ModuleID__c = 'SXFR' AND RecordType.Name = 'Inventory Process'];
                                                                         
             List <INVT_SpareParts_Wrapper.ObjectInfo> locationStockTransferProcess = new List <INVT_SpareParts_Wrapper.ObjectInfo>();
             
             for( SVMXC__ServiceMax_Processes__c process : svmxProcess){
                 INVT_SpareParts_Wrapper.ObjectInfo opProcess = new INVT_SpareParts_Wrapper.ObjectInfo();
                 opProcess.id = process.SVMXC__ProcessID__c;
                 opProcess.name = process.SVMXC__Name__c;
                 locationStockTransferProcess.add(opProcess);
             } 
             sparePartsConfigRes.liststockinventoryprocess = locationStockTransferProcess;
             
            // Get Product Fields to display in UI.
            SObjectType productObject = Schema.getGlobalDescribe().get('Product2');
            DescribeSObjectResult productDes = productObject.getDescribe();
            Map<String, SObjectField> productFields = productDes.fields.getMap(); 
            
            // Set of fields to avoid
            Set<String> removeFields = new Set<String>();
            removeFields.add('CreatedDate');
            removeFields.add('CreatedById');
            removeFields.add('LastModifiedById');
            removeFields.add('LastModifiedDate');
            removeFields.add('LastViewedDate');
            removeFields.add('LastReferencedDate');
            removeFields.add('LastViewedDate');
            removeFields.add('IsDeleted'); 
            // BAC-2731 - Removing ExternalId from the picklist options as this field is not accessible by FSA.
            removeFields.add('ExternalId'); 
             
            Set<String> setProductFields = productFields.keySet();
            List<INVT_SpareParts_Wrapper.ObjectInfo> listproductfields = new List<INVT_SpareParts_Wrapper.ObjectInfo>(); 
            for(String s: setProductFields)
            {    
                SObjectField fieldToken = productFields.get(s);
                DescribeFieldResult selectedField = fieldToken.getDescribe();
                INVT_SpareParts_Wrapper.ObjectInfo fieldData = new INVT_SpareParts_Wrapper.ObjectInfo();
                fieldData.fieldtype = String.valueOf(selectedField.getType()); 
                if(fieldData.fieldtype.equalsIgnoreCase('REFERENCE') &&  selectedField.getReferenceTo() != null && selectedField.getReferenceTo().size() > 0){
                    String referenceObject = String.valueOf(selectedField.getReferenceTo()[0]);
                    referenceObject = referenceObject.replace('__c', '__r');
                    fieldData.id = referenceObject +'.' +selectedField.getName();    
                }
                else{
                    fieldData.id = selectedField.getName();    
                }
                fieldData.name = selectedField.getLabel(); 
                
                if(!removeFields.contains(selectedField.getName()))
                    listproductfields.add(fieldData);
            }
            sparePartsConfigRes.listproductfields = listproductfields; 
             
             
            // Story - BAC-2204 : Select Product Stock Status to be downloaded
            // Load Quantity field from Product Stock Obj
            SObjectType productStockObject = Schema.getGlobalDescribe().get('SVMXC__Product_Stock__c');
            DescribeSObjectResult productStockDes = productStockObject.getDescribe();
            Map<String, SObjectField> productStockFields = productStockDes.fields.getMap(); 
            Set<String> setProductStockFields = productStockFields.keySet();
            List<INVT_SpareParts_Wrapper.ObjectInfo> listQuantityFields = new List<INVT_SpareParts_Wrapper.ObjectInfo>(); 
            List<INVT_SpareParts_Wrapper.ObjectInfo> listProductStockStatus = new List<INVT_SpareParts_Wrapper.ObjectInfo>(); 
            
            for(String s: setProductStockFields){
                DescribeFieldResult selectedPSField = productStockFields.get(s).getDescribe();
                if(String.valueOf(selectedPSField.getType()).equalsIgnoreCase('DOUBLE')){
                    INVT_SpareParts_Wrapper.ObjectInfo quantityField = new INVT_SpareParts_Wrapper.ObjectInfo();
                    quantityField.id = selectedPSField.getName(); 
                    quantityField.name = selectedPSField.getLabel(); 
                    listQuantityFields.add(quantityField);
                }
                
                if(String.valueOf(selectedPSField.getType()).equalsIgnoreCase('PICKLIST') && String.valueOf(selectedPSField.getName()).equalsIgnoreCase('SVMXC__Status__c')){
                    List<Schema.PicklistEntry> psStatusPicklistOptions = selectedPSField.getPicklistValues();
                    for( Schema.PicklistEntry f : psStatusPicklistOptions ){
                        if(f.isActive()){
                            INVT_SpareParts_Wrapper.ObjectInfo statusData = new INVT_SpareParts_Wrapper.ObjectInfo();
                            statusData.id = f.getValue(); 
                            statusData.name = f.getLabel(); 
                            listProductStockStatus.add(statusData);    
                        }
                    }
                }
            } 
            sparePartsConfigRes.listproductstockstatus = listProductStockStatus;
            sparePartsConfigRes.listquantityfields = listQuantityFields;
          }
         catch(Exception e){
             sparePartsConfigRes.success = false;
             sparePartsConfigRes.messageList = new List<String>();
             sparePartsConfigRes.messageList.add(e.getMessage());
         }
         return sparePartsConfigRes;
     }
     
     public INVT_SpareParts_Wrapper.SpareParts_Response saveSparePartConfig(INVT_SpareParts_Wrapper.SpareParts_Request  request) {
         INVT_SpareParts_Wrapper.SpareParts_Response sparePartsSaveRes = new INVT_SpareParts_Wrapper.SpareParts_Response();
         try{
             Content wrapperSpareConfig = new Content(request.layout, request.locatepartsetup);
             
             List<SVMXC__SM_Inventory_Config__c > listPartsConfig = new List<SVMXC__SM_Inventory_Config__c >();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             listPartsConfig = [Select Id, SVMXC__SM_Content__c 
                                     FROM SVMXC__SM_Inventory_Config__c 
                                         WHERE SVMXC__SM_ServiceMax_Profile__c =: request.profileId]; 
            
             if(listPartsConfig != null && listPartsConfig.size() > 0){
                 listPartsConfig[0].SVMXC__SM_Content__c = JSON.serializePretty(wrapperSpareConfig); 
             }
             else{
                 SVMXC__SM_Inventory_Config__c newRec = new SVMXC__SM_Inventory_Config__c();
                 newRec.SVMXC__SM_Content__c = JSON.serializePretty(wrapperSpareConfig);
                 newRec.SVMXC__SM_ServiceMax_Profile__c = request.profileId; 
                 listPartsConfig = new List<SVMXC__SM_Inventory_Config__c>();
                 listPartsConfig.add(newRec);
             }
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             upsert listPartsConfig;
             
             sparePartsSaveRes.success = true; 
         }
         catch(Exception e){
             sparePartsSaveRes.success = false;
             sparePartsSaveRes.messageList = new List<String>();
             sparePartsSaveRes.messageList.add(e.getMessage());
         }
        
         return sparePartsSaveRes;
     }
     
     public class Content{
        public INVT_SpareParts_Wrapper.Layout layout;
        public INVT_SpareParts_Wrapper.LocatePart locatepartsetup;
        public Content(){
    
        }
        
        public Content(INVT_SpareParts_Wrapper.Layout layoutCons,  INVT_SpareParts_Wrapper.LocatePart locatepartConst){
            this.layout = layoutCons; 
            this.locatepartsetup = locatepartConst; 
        }
     }
     
 }