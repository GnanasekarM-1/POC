@isTest(SeeAlldata=true)
private class COMM_Webservices_UT
{
    static testMethod void COMM_Utils_OEM()
    {
        String name='abc';
        String value='abc';
       
        COMM_Webservices.KeyValue keyVal1 = new COMM_Webservices.KeyValue(name,value);
        COMM_Webservices.KeyValue keyVal2 = new COMM_Webservices.KeyValue();
        List<COMM_Webservices.KeyValue> request= new List<COMM_Webservices.KeyValue>();
        request.add(keyVal1);
        request.add(keyVal2);
        COMM_Webservices.SVMX_GetSvmxVersion(request);
        COMM_Webservices.SVMX_isEnterpriseLicense_WS();
        COMM_Webservices.SVMX_isObjectLicensed_WS('CASE');
        COMM_Webservices.SVMX_isObjectLicensed_WS('SVMXC__Service_Order__c');
        COMM_Webservices.SVMX_getPermittedStandardObjectList_WS();
        COMM_Webservices.SVMX_updateLicenseType_WS('licenceKey', 'ENTERPRISE', 'devKey');
        COMM_Webservices.SVMX_getPropertyElements_WS();
        COMM_Webservices.SVMX_updatePropertyElements_WS(new List<SVMXC__ServiceMax_Property_Elements__c>(), 'licenceKey', 'licenseType', 'devKey');
        COMM_Webservices.SVMX_UpdateGetPriceFields_WS(new List<SVMXC__GetPrice_Fields__c>(), 'licenceKey', 'licenseType', 'devKey'); //Added for the story BAC-4512
        try{
            COMM_Webservices.SVMX_createSchedulersForAPLUDAT_WS('SCON',false);      
        }
        catch(Exception ex){}
        
        try{
            COMM_Webservices.SVMX_createSchedulersForAPLUDAT_WS('TEST',true);
        }
        catch(Exception ex){}
        
        try{
            COMM_Webservices.SVMX_createSchedulersForAPLUDAT_WS(null,false);
        }
        catch(Exception ex){}
        
        try{
            COMM_Webservices.SVMX_createSchedulersForAPLUDAT_WS('Notifications',false);
        }
        catch(Exception ex){}
        
        try{
            COMM_Webservices.saveDescribeObjectCache_WS('Type','Account');
        }
        catch(Exception ex){}
        
        try{
            COMM_Webservices.KeyValue kV = new COMM_Webservices.KeyValue('SVMX_NAMED_EXPRESSIONS_UPD_REF_FLDS', 'test');
            COMM_Webservices.SVMX_doPerform_WS(new List<COMM_Webservices.KeyValue>{kV});
        }
        catch(Exception ex){}
        COMM_Webservices.checkPermission(new List<String>{'Test'}, 'test');
        COMM_Webservices.SVMX_CURD_OnServiceMaxProperties_WS(request);
        
        List<Case> ca = new List<Case>();
        String serial = JSON.serialize(ca);
        COMM_Webservices.saveDescribeLayoutCache_WS(serial,'Case'); 

        //COMM_Webservices.saveDescribeObjectCache_WS(ser,'Contact');       
        list<RecordType> lstRecordType = new list<RecordType>();
        lstRecordType = [select Id, Name From RecordType where SobjectType= 'SVMXC__ServiceMax_Processes__c' OR Name=: 'Estimate' OR Name =: 'RequestReceipt'];
        System.debug(lstRecordType);
        
        
        COMM_Webservices.getObjectDefination_WS();
        
        String objectName = 'SVMXC__Service_Order_Line__c';
        list<String> recordTypeId = new list<String>();
        if(lstRecordType != null && lstRecordType.size() >= 1)
        {
            recordTypeId.add(lstRecordType[0].Id);
            recordTypeId.add(lstRecordType[1].Id);
        }
        list<String> picklistFields = new list<String>();
        picklistFields.add('SVMXC__Activity_Type__c');
        picklistFields.add('SVMXC__Applied_Rate_Type__c');
        COMM_Webservices.ObjectDefination commWeb1 = new COMM_Webservices.ObjectDefination(objectName, recordTypeId, picklistFields);
        COMM_Webservices.ObjectDefination commWeb2 = new COMM_Webservices.ObjectDefination();
    }
}