@isTest
private Class SmartObject_UT{
    static testMethod void Test1(){
        SmartObject obj = new SmartObject();
        
        SVMXC__Object_Cache__c objSmartObject = new SVMXC__Object_Cache__c();
        objSmartObject.SVMXC__Object_API_Name__c = 'ApptOfferRequest__sm';
        objSmartObject.SVMXC__Object_Label__c = 'ApptOfferRequest';
        objSmartObject.SVMXC__Description__c = 'This is Test description';
        objSmartObject.SVMXC__Schema__c = '{"name": "ApptOfferRequest__sm", "label": "ApptOfferRequest",  "createable": "true",    "fields": [{ "name": "Login__sm",  "label": "Login",  "type": "STRING",  "createable": "false", "custom": "false",   "length": "50",  "updateable": "false",  "precision": "null", "nameField": "false", "referenceTo": "null", "relationshipName": "null",  "picklistValues": "null" },  {  "name": "NumReq__sm", "label": "NumReq",  "type": "DOUBLE",  "createable": "false", "custom": "false",   "length": "4",  "updateable": "false", "precision": "2", "nameField": "false", "referenceTo": "null", "relationshipName": "null", "picklistValues": "null" },  {  "name": "Job_Is_Fixed__sm", "label": "Job Is Fixed",  "type": "BOOLEAN",  "createable": "false", "custom": "false",   "length": "null",  "updateable": "false", "precision": "null", "nameField": "false", "referenceTo": "null", "relationshipName": "null", "picklistValues": "null" }]}';
        insert objSmartObject;
        System.assert(objSmartObject.SVMXC__Object_API_Name__c == 'ApptOfferRequest__sm');
        
        Map<String, SmartObject.DescribeSmartObjectResult> mapAllSmartObject = SmartObject.getGlobalDescribe();
        System.assert(mapAllSmartObject.size()>0);
        
        SmartObject.SmartObjectType objSmartObjectType = new SmartObject.SmartObjectType();
        SmartObject.DescribeSmartObjectResult objDescribe = objSmartObjectType.getDescribe('ApptOfferRequest__sm');
        System.assert(objDescribe != null);
        
        SmartObject.DescribeSmartObjectResult objDescResult = mapAllSmartObject.get('ApptOfferRequest__sm');
        objDescResult.getFields();
        objDescResult.getName();
        objDescResult.getLabel();
        objDescResult.createable = '';
        Map<String, SmartObject.SmartObjectField> mapObjectField = objDescResult.getFieldMap();
        System.assert(mapObjectField.size()>0);
        
        SmartObject.SmartObjectField obj22 = new SmartObject.SmartObjectField();
        obj22.getobjDescribeSmartFieldResult();
        obj22.getDescribe();
        
        SmartObject.SmartObjectField obj221 = new SmartObject.SmartObjectField(new SmartObject.DescribeSmartFieldResult());
        obj221.setobjDescribeSmartFieldResult(new SmartObject.DescribeSmartFieldResult());
        
        SmartObject.SmartObjectField objfield = mapObjectField.get('Login__sm');
        SmartObject.DescribeSmartFieldResult objSmartResult = objfield.getDescribe();
        System.assert(objSmartResult != null);
        objSmartResult.getLabel();
        objSmartResult.getName();
        objSmartResult.getType();
        objSmartResult.getlength();
        
        SmartObject.DescribeSmartFieldResult objSmartResult11 = new SmartObject.DescribeSmartFieldResult();
        objSmartResult11.createable = '';
        objSmartResult11.custom = '';
        objSmartResult11.updateable = '';
        objSmartResult11.precision = '';
        objSmartResult11.nameField = '';
        objSmartResult11.referenceTo = '';
        objSmartResult11.relationshipName = '';
        objSmartResult11.picklistValues = '';
        SmartObject.SmartObjectRecord objSmartObjectRecord = new SmartObject.SmartObjectRecord();
    }
}