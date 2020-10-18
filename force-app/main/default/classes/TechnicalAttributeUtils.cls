/* Security Scanned */
public with sharing class TechnicalAttributeUtils {

  public TechnicalAttributeUtils(){
  calledfrom = TechnicalAttributeImpl.source.API;
  }

  public TechnicalAttributeUtils(TechnicalAttributeImpl.source source){
  calledfrom = source;
  }

  public TechnicalAttributeImpl.source calledfrom;

 @future
 public static void updateIbTechnicalAttributeObject(List < Id > instanceIdList, Boolean isUpdate) {
  system.debug('updateIbTechnicalAttributeObject    ' + instanceIdList + '   ' + isUpdate);
  List < String > queryFields = new List < String > {
   'Id',
   'SVMXC__SM_Attr_Payload__c',
   'SVMXC__SM_Attr_Type__c',
   'SVMXC__SM_Captured_On__c',
   'SVMXC__SM_Installed_Product_Id__c',
   'SVMXC__SM_Instance_Template_Id__c'
  };
  if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_IB_Attributes_Template_Instance__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
   throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
  }
  //SDL-SVMX-READ-FLS-ENFORCED
  List < SVMXC__SM_IB_Attributes_Template_Instance__c > instanceRecordList = [Select Id, SVMXC__SM_Attr_Payload__c, SVMXC__SM_Attr_Type__c, SVMXC__SM_Captured_On__c, SVMXC__SM_Installed_Product_Id__c, SVMXC__SM_Instance_Template_Id__c from SVMXC__SM_IB_Attributes_Template_Instance__c where Id in: instanceIdList];
  List < SVMXC__SM_IB_Technical_Attributes__c > technicalAttributeList = new List < SVMXC__SM_IB_Technical_Attributes__c > ();
  String ibId;
  system.debug('instanceRecordList  ' + instanceRecordList);
  for (SVMXC__SM_IB_Attributes_Template_Instance__c instanceRecord: instanceRecordList) {
   ibId = instanceRecord.SVMXC__SM_Installed_Product_Id__c;
   system.debug('ibInstancePayload  before ');
   TechnicalAttributeConfiguration.IbInstancePayload ibInstancePayload =
    (TechnicalAttributeConfiguration.IbInstancePayload) JSON.deserialize(instanceRecord.SVMXC__SM_Attr_Payload__c, TechnicalAttributeConfiguration.IbInstancePayload.class);
   system.debug('ibInstancePayload  after ' + ibInstancePayload);
   List < TechnicalAttributeConfiguration.AttributesCategory > catetoryList = new List < TechnicalAttributeConfiguration.AttributesCategory > ();
   if (ibInstancePayload.fields != null) catetoryList = ibInstancePayload.fields;
   for (TechnicalAttributeConfiguration.AttributesCategory catetory: catetoryList) {
    List < TechnicalAttributeConfiguration.Attribute > attributeList = new List < TechnicalAttributeConfiguration.Attribute > ();
    if (catetory.technicalAttributes != null) attributeList = catetory.technicalAttributes;
    for (TechnicalAttributeConfiguration.Attribute attribute: attributeList) {
     system.debug('attributeList  before ' + attributeList);
     SVMXC__SM_IB_Technical_Attributes__c technicalAttribute = new SVMXC__SM_IB_Technical_Attributes__c();
     if (!String.isBlank(attribute.label)) technicalAttribute.SVMXC__SM_Attr_Name__c = attribute.label;
     if (attribute.defaultValue != null) technicalAttribute.SVMXC__SM_Attr_Value__c = attribute.defaultValue;
     if(attribute.format == 'Text' || attribute.format == 'Picklist'){
          technicalAttribute.SVMXC__SM_Type__c = 'Text';
      }else if(attribute.format == 'Number'){
          technicalAttribute.SVMXC__SM_Type__c = 'Number';
          try{
              if(attribute.defaultValue != null)technicalAttribute.SVMXC__SM_Number_Value__c = Decimal.valueOf(attribute.defaultValue);
          }catch(exception ex){
              //Just ignore if value is invalid
          }
      }else if(attribute.format == 'Boolean'){
          technicalAttribute.SVMXC__SM_Type__c = 'Boolean';
          technicalAttribute.SVMXC__SM_Boolean_Value__c = false;
          if(attribute.defaultValue != null){
              if(attribute.defaultValue == 'true')technicalAttribute.SVMXC__SM_Boolean_Value__c = true;
          }
      }
      
     system.debug('attributeList  after ' + attributeList);
     technicalAttribute.SVMXC__SM_Created_Date__c = System.now();
     system.debug('attribute.label != null  before ' + attribute);
     if (!String.isBlank(attribute.label)) {
      String attrName = attribute.label;
      attrName = attrName.trim();
      attrName = attrName.replace(' ', '~');
      technicalAttribute.SVMXC__SM_IBAttr_ExtId__c = instanceRecord.SVMXC__SM_Installed_Product_Id__c + attrName;
      // system.debug('attrName ' + attrName + ' attribute.defaultValue ' + attrName.defaultValue);
     }
     system.debug('attribute.label != null  after ' + attributeList);
     if (instanceRecord.SVMXC__SM_Installed_Product_Id__c != null) technicalAttribute.SVMXC__SM_Installed_Product_id__c = instanceRecord.SVMXC__SM_Installed_Product_Id__c;
     technicalAttribute.SVMXC__SM_IsActive__c = true;
     technicalAttributeList.add(technicalAttribute);
    }
   }
  }

  /* If the records are updated then varify the new and old set of 
    attributes and mark SVMXC__SM_IsActive__c as true/false respectively. */

  if (isUpdate) {
   Map < String, SVMXC__SM_IB_Technical_Attributes__c > newAttributeMap = new Map < String, SVMXC__SM_IB_Technical_Attributes__c > ();
   for (SVMXC__SM_IB_Technical_Attributes__c taAttribute: technicalAttributeList)
    newAttributeMap.put(taAttribute.SVMXC__SM_IBAttr_ExtId__c, taAttribute);
   for (SVMXC__SM_IB_Technical_Attributes__c oldAttribute: [Select Id, SVMXC__SM_IsActive__c, SVMXC__SM_Installed_Product_Id__c, SVMXC__SM_Created_Date__c, SVMXC__SM_Attr_Name__c, SVMXC__SM_Attr_Value__c, SVMXC__SM_IBAttr_ExtId__c from SVMXC__SM_IB_Technical_Attributes__c where SVMXC__SM_Installed_Product_id__c =: ibId]) {
    if (!newAttributeMap.containsKey(oldAttribute.SVMXC__SM_IBAttr_ExtId__c)) {
     oldAttribute.SVMXC__SM_IsActive__c = false;
     technicalAttributeList.add(oldAttribute);
    }
   }
  }



  // filter the attribute list for uniq set of attributes.
  Set < String > setExtId = new Set < String > ();
  Map < String, SVMXC__SM_IB_Technical_Attributes__c > finalAttrMap = new Map < String, SVMXC__SM_IB_Technical_Attributes__c > ();
  for (Integer i = 0; i < technicalAttributeList.size(); i++) {
   if (technicalAttributeList[i].SVMXC__SM_IBAttr_ExtId__c != null) {
    system.debug('technicalAttributeList[i] ' + technicalAttributeList[i]);
    setExtId.add(technicalAttributeList[i].SVMXC__SM_IBAttr_ExtId__c.toLowerCase());
    finalAttrMap.put(technicalAttributeList[i].SVMXC__SM_IBAttr_ExtId__c.toLowerCase(), technicalAttributeList[i]);

   }
  }

  List < SVMXC__SM_IB_Technical_Attributes__c > finalAttributeList = new List < SVMXC__SM_IB_Technical_Attributes__c > ();
  for (String attriExtId: setExtId) {
   finalAttributeList.add(finalAttrMap.get(attriExtId));
  }
  schema.sobjectField extIdField = SVMXC__SM_IB_Technical_Attributes__c.fields.SVMXC__SM_IBAttr_ExtId__c;
  system.debug('finalAttributeList ' + finalAttributeList);
  if (COMM_SecurityUtils.getInstance().verifyFieldAccess(finalAttributeList, COMM_SecurityUtils.Access.Upsertable)) {
   //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
   Database.upsert(finalAttributeList, extIdField, true);
  } else {
   throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
  }


 }

 public TechnicalAttributeConfiguration.AttributesTemplateInstance getAttributesTemplateInstanceForIB(String ibId) {
  List < String > queryFields = new List < String > {
   'Id',
   'SVMXC__SM_Attr_Payload__c',
   'SVMXC__SM_Captured_On__c',
   'SVMXC__SM_Attr_Type__c',
   'SVMXC__SM_Instance_Template_Id__c',
   'LastModifiedDate'
  };
  if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_IB_Attributes_Template_Instance__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
   throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
  }
  //SDL-SVMX-READ-FLS-ENFORCED
  List < SVMXC__SM_IB_Attributes_Template_Instance__c > instanceRecords = [Select Id, SVMXC__SM_Attr_Payload__c, SVMXC__SM_Captured_On__c, SVMXC__SM_Attr_Type__c, SVMXC__SM_Instance_Template_Id__c, LastModifiedDate from SVMXC__SM_IB_Attributes_Template_Instance__c
   where SVMXC__SM_Installed_Product_Id__c =: ibId
  ];
  system.debug('instanceRecords  ' + instanceRecords);
  TechnicalAttributeConfiguration.AttributesTemplateInstance attributesTemplateInstance = new TechnicalAttributeConfiguration.AttributesTemplateInstance();
  attributesTemplateInstance.isTemplateFound = true;
  TechnicalAttributeConfiguration.AttributesTemplateInstanceObject attributesTemplateInstanceObject = new TechnicalAttributeConfiguration.AttributesTemplateInstanceObject();
  TechnicalAttributeConfiguration.TAtemplate taTemplate = getTemplateForIB(ibId);
  if (!instanceRecords.isEmpty()) {
   SVMXC__SM_IB_Attributes_Template_Instance__c instanceRec = instanceRecords[0];
   String attributesPayloadJSON;
   system.debug('taTemplate  ' + taTemplate);
   if (taTemplate.sfdcId != null) {
    attributesPayloadJSON = compareAndMergeTechnicalAttributes(taTemplate.templateJSON, instanceRec.SVMXC__SM_Attr_Payload__c);
   } else {
    attributesPayloadJSON = instanceRec.SVMXC__SM_Attr_Payload__c;
   }

   attributesTemplateInstanceObject.sfdcId = instanceRec.Id;
   attributesTemplateInstanceObject.attributesPayload = attributesPayloadJSON;
   attributesTemplateInstanceObject.installedProductId = ibId;
   attributesTemplateInstanceObject.templateId = taTemplate.sfdcId;
   attributesTemplateInstanceObject.capturedOn = instanceRec.SVMXC__SM_Captured_On__c;
   attributesTemplateInstanceObject.isNew = false;
   attributesTemplateInstanceObject.lmd = instanceRec.LastModifiedDate;
   attributesTemplateInstance.attributesTemplateInstance = attributesTemplateInstanceObject;

   // get attribute history details.
   attributesTemplateInstance.totalHistoryRecords = getHistoryCount(ibId);
   SVMXC__SM_IB_Attributes_History__c historyRecord = [SELECT Id, SVMXC__SM_Captured_On__c FROM SVMXC__SM_IB_Attributes_History__c WHERE SVMXC__SM_Installed_Product_Id__c =: ibId ORDER BY SVMXC__SM_Captured_On__c DESC NULLS LAST LIMIT 1];
   attributesTemplateInstance.lastHistoryId = historyRecord.Id;
   attributesTemplateInstance.lastHistoryCapturedOn = historyRecord.SVMXC__SM_Captured_On__c;

  } else {

   if (taTemplate.isTemplateFound) {
    attributesTemplateInstanceObject.attributesPayload = taTemplate.templateJSON;
    attributesTemplateInstanceObject.installedProductId = ibId;
    attributesTemplateInstanceObject.templateId = taTemplate.sfdcId;
    attributesTemplateInstanceObject.isNew = true;
    attributesTemplateInstance.attributesTemplateInstance = attributesTemplateInstanceObject;
   } else {
    attributesTemplateInstance.isTemplateFound = false;
   }
  }
  system.debug('attributesTemplateInstance  ' + attributesTemplateInstance);
  return attributesTemplateInstance;
 }
 private Integer getHistoryCount(String ibId) {
  List < String > queryFields = new List < String > {
   'SVMXC__SM_Captured_On__c'
  };
  if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_IB_Attributes_History__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
   throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
  }
  //SDL-SVMX-READ-FLS-ENFORCED
  List < SVMXC__SM_IB_Attributes_History__c > allHistoryRecords = [select SVMXC__SM_Captured_On__c from SVMXC__SM_IB_Attributes_History__c where SVMXC__SM_Installed_Product_Id__c =: ibId];
  Set < String > uniqueList = new Set < String > ();
  for (SVMXC__SM_IB_Attributes_History__c historyRecord: allHistoryRecords) {
   DATETIME captureOn = historyRecord.SVMXC__SM_Captured_On__c;
   if (captureOn != null) {
    String value = String.valueOf(captureOn.format('YYYY-MM-dd', UserInfo.getTimeZone().getID()));
    if (!uniqueList.contains(value)) {
     uniqueList.add(value);
    }
   }
  }
  Integer historyCount = uniqueList.size();
  return historyCount;
 }
 public String compareAndMergeTechnicalAttributes(String templateJsonPaylod, String instanceJsonPaylod) {
  String returnJsonPayload;

  if (String.isBlank(templateJsonPaylod)) {
   returnJsonPayload = instanceJsonPaylod;
  } else {


   TechnicalAttributeConfiguration.IbInstancePayload oldPayload =
    (TechnicalAttributeConfiguration.IbInstancePayload) JSON.deserialize(instanceJsonPaylod, TechnicalAttributeConfiguration.IbInstancePayload.class);
   List < TechnicalAttributeConfiguration.AttributesCategory > oldCategoryList = oldPayload.fields;
   List < TechnicalAttributeConfiguration.Attribute > oldAttributeList = new List < TechnicalAttributeConfiguration.Attribute > ();
   for (TechnicalAttributeConfiguration.AttributesCategory oldCategory: oldCategoryList) {
    if (oldCategory.technicalAttributes != null) oldAttributeList.addAll(oldCategory.technicalAttributes);
   }

   TechnicalAttributeConfiguration.IbInstancePayload newPayload =
    (TechnicalAttributeConfiguration.IbInstancePayload) JSON.deserialize(templateJsonPaylod, TechnicalAttributeConfiguration.IbInstancePayload.class);
   List < TechnicalAttributeConfiguration.AttributesCategory > newCategoryList = newPayload.fields;
   List < TechnicalAttributeConfiguration.AttributesCategory > updatedNewCategoryList = new List < TechnicalAttributeConfiguration.AttributesCategory > ();
   for (TechnicalAttributeConfiguration.AttributesCategory newCategory: newCategoryList) {


    List < TechnicalAttributeConfiguration.Attribute > newAttributeList = newCategory.technicalAttributes;
    List < TechnicalAttributeConfiguration.Attribute > updatedAttributeList = new List < TechnicalAttributeConfiguration.Attribute > ();


    for (TechnicalAttributeConfiguration.Attribute newAttribute: newAttributeList) {
     TechnicalAttributeConfiguration.Attribute attribute = newAttribute;
      if(attribute.req == null){
        attribute.req = '0';
      }
     for (TechnicalAttributeConfiguration.Attribute oldAttribute: oldAttributeList) {
      if (newAttribute.label.toLowerCase().equals(oldAttribute.label.toLowerCase())) {
       attribute.defaultValue = oldAttribute.defaultValue;
       break;
      }
     }
     updatedAttributeList.add(attribute);

    }

    TechnicalAttributeConfiguration.AttributesCategory attributesCategory = new TechnicalAttributeConfiguration.AttributesCategory();
    attributesCategory.title = newCategory.title;
    attributesCategory.description = newCategory.description;
    attributesCategory.technicalAttributes = updatedAttributeList;
    updatedNewCategoryList.add(attributesCategory);
   }

   TechnicalAttributeConfiguration.IbInstancePayload updatedPayload = new TechnicalAttributeConfiguration.IbInstancePayload();
   updatedPayload.fields = updatedNewCategoryList;
   updatedPayload.picklist = newPayload.picklist;

   returnJsonPayload = JSON.serialize(updatedPayload);
  }


  return returnJsonPayload;
 }
 public TechnicalAttributeConfiguration.TAtemplate getTemplateForIB(String ibId) {

  TechnicalAttributeConfiguration.TAtemplate taTemplate = new TechnicalAttributeConfiguration.TAtemplate();
  TechnicalAttributeConfiguration.ProductDetails pDetails = getProductDetailsForIB(ibId);
  String templateId;
  String templateIdForProduct = getTemplateIDForIBsProduct(pDetails.pId);
  String templateIdForPline = getTemplateIDForIBsProductLine(pDetails.pLine);
  String templateIdForPFamily = getTemplateIDForIBsProductFamily(pDetails.pFamily);

  if (!String.isBlank(templateIdForProduct)) {
   templateId = templateIdForProduct;
  } else if (!String.isBlank(templateIdForPline)) {
   templateId = templateIdForPline;
  } else if (!String.isBlank(templateIdForPFamily)) {
   templateId = templateIdForPFamily;
  } else {
   taTemplate.isTemplateFound = false;
  }


  if (!String.isBlank(templateId)) {
   taTemplate = getAttributeTemplateForTemplateId(templateId);
   taTemplate.isTemplateFound = true;
  }
  return taTemplate;
 }

 public TechnicalAttributeConfiguration.ProductDetails getProductDetailsForIB(String ibId) {
  List < String > queryFields = new List < String > {
   'SVMXC__Product__r.Id',
   'SVMXC__Product__r.Family',
   'SVMXC__Product__r.SVMXC__Product_Line__c'
  };
  if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
   throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
  }
  //SDL-SVMX-READ-FLS-ENFORCED
  List < SVMXC__Installed_Product__c > ibRecords = [Select SVMXC__Product__r.Id, SVMXC__Product__r.Family, SVMXC__Product__r.SVMXC__Product_Line__c from SVMXC__Installed_Product__c where Id =: ibId];
  TechnicalAttributeConfiguration.ProductDetails pDetails = new TechnicalAttributeConfiguration.ProductDetails();
  if (!ibRecords.isEmpty()) {
   SVMXC__Installed_Product__c ibRec = ibRecords[0];
   pDetails.pId = ibRec.SVMXC__Product__r.Id;
   pDetails.pLine = ibRec.SVMXC__Product__r.SVMXC__Product_Line__c;
   pDetails.pFamily = ibRec.SVMXC__Product__r.Family;

  }
  return pDetails;
 }

 public String getTemplateIDForIBsProduct(String productId) {
  String templateId;
  if (!String.isBlank(productId)) {
   List < String > queryFields = new List < String > {
    'SVMXC__SM_Attribute_Template_Id__c'
   };
   if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Product_Attributes__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
   }
   //SDL-SVMX-READ-FLS-ENFORCED
   List < SVMXC__SM_Product_Attributes__c > productAttributes = [Select SVMXC__SM_Attribute_Template_Id__c from SVMXC__SM_Product_Attributes__c where SVMXC__SM_Product__c =: productId];
   if (!productAttributes.isEmpty()) templateId = productAttributes[0].SVMXC__SM_Attribute_Template_Id__c;
  }

  return templateId;

 }

 public String getTemplateIDForIBsProductLine(String pLine) {
  String templateId;
  if (!String.isBlank(pLine)) {
   List < String > queryFields = new List < String > {
    'SVMXC__SM_Attribute_Template_Id__c'
   };
   if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Product_Attributes__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
   }
   //SDL-SVMX-READ-FLS-ENFORCED
   List < SVMXC__SM_Product_Attributes__c > productAttributes = [Select SVMXC__SM_Attribute_Template_Id__c from SVMXC__SM_Product_Attributes__c where SVMXC__SM_Product_Line__c =: pLine];
   if (!productAttributes.isEmpty()) templateId = productAttributes[0].SVMXC__SM_Attribute_Template_Id__c;
  }

  return templateId;
 }

 public String getTemplateIDForIBsProductFamily(String pFamily) {
  String templateId;
  if (!String.isBlank(pFamily)) {
   List < String > queryFields = new List < String > {
    'SVMXC__SM_Attribute_Template_Id__c'
   };
   if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Product_Attributes__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
   }
   //SDL-SVMX-READ-FLS-ENFORCED
   List < SVMXC__SM_Product_Attributes__c > productAttributes = [Select SVMXC__SM_Attribute_Template_Id__c from SVMXC__SM_Product_Attributes__c where SVMXC__SM_Product_Family__c =: pFamily];
   if (!productAttributes.isEmpty()) templateId = productAttributes[0].SVMXC__SM_Attribute_Template_Id__c;
  }

  return templateId;
 }

 public TechnicalAttributeConfiguration.TAtemplate getAttributeTemplateForTemplateId(String templateId) {

  List < String > queryFields = new List < String > {
   'SVMXC__SM_Template_Json__c',
   'SVMXC__SM_Title__c'
  };
  if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Attributes_Template__c', queryFields, COMM_SecurityUtils.Access.Accessible)) {
   throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
  }
  //SDL-SVMX-READ-FLS-ENFORCED
  SVMXC__SM_Attributes_Template__c attributeTemplate = [Select SVMXC__SM_Template_Json__c, SVMXC__SM_Title__c from SVMXC__SM_Attributes_Template__c where Id =: templateId];
  TechnicalAttributeConfiguration.TAtemplate taTemplate = new TechnicalAttributeConfiguration.TAtemplate();
  // #picklistChange starts
  // List<String> picklistSfIdList = new List<String> ();
  Map < String, String > picklistSfIdNameMap = new Map < String, String > ();
  TechnicalAttributeConfiguration.IbInstancePayload templateJsonPayload =
   (TechnicalAttributeConfiguration.IbInstancePayload) JSON.deserialize(attributeTemplate.SVMXC__SM_Template_Json__c, TechnicalAttributeConfiguration.IbInstancePayload.class);
  System.debug('templateJsonPayload1##' + templateJsonPayload);
  List < TechnicalAttributeConfiguration.AttributesCategory > newCategoryList = new List < TechnicalAttributeConfiguration.AttributesCategory > ();
  if (templateJsonPayload.fields != NULL) {
   newCategoryList = templateJsonPayload.fields;
  }
  for (TechnicalAttributeConfiguration.AttributesCategory newCategory: newCategoryList) {
   List < TechnicalAttributeConfiguration.Attribute > newAttributeList = newCategory.technicalAttributes;
   List < TechnicalAttributeConfiguration.Attribute > updatedAttributeList = new List < TechnicalAttributeConfiguration.Attribute > ();
   for (TechnicalAttributeConfiguration.Attribute newAttribute: newAttributeList) {
    TechnicalAttributeConfiguration.Attribute attribute = newAttribute;
    if (String.isNotBlank(attribute.picklistSfId)) {
     // picklistSfIdList.add(attribute.picklistSfId); // collect picklist salesforce id so that latest values can be queried
     picklistSfIdNameMap.put(attribute.picklistSfId, attribute.picklistId);
    }
   }
  }


  if (!picklistSfIdNameMap.isEmpty()) {
   List < String > picklistRecordIdList = new List < String > (picklistSfIdNameMap.keySet());

   // query picklist definition records and update the payload
   List < SM_TA_Picklist_Definition__c > pklistDefRecords = [SELECT Id, SM_Name__c, SM_Values__c FROM SM_TA_Picklist_Definition__c
    WHERE Id IN: picklistRecordIdList
   ];
   for (SM_TA_Picklist_Definition__c pikcklistDefRecord: pklistDefRecords) {
    TechnicalAttributeConfiguration.AttributesPicklist attributePicklist =
     (TechnicalAttributeConfiguration.AttributesPicklist) JSON.deserialize(pikcklistDefRecord.SM_Values__c, TechnicalAttributeConfiguration.AttributesPicklist.class);
    templateJsonPayload.picklist.put(picklistSfIdNameMap.get(pikcklistDefRecord.Id), attributePicklist);
   }
  }
  String updatedTemplateJSON = JSON.serialize(templateJsonPayload);
  taTemplate.templateJSON = updatedTemplateJSON;
  // #picklistChange ends

  taTemplate.sfdcId = templateId;
  taTemplate.title = attributeTemplate.SVMXC__SM_Title__c;
  //taTemplate.templateJSON = attributeTemplate.SVMXC__SM_Template_Json__c; // #pickListChange commented code
  System.debug('taTemplate##' + taTemplate);
  return taTemplate;
 }

 public TechnicalAttributeConfiguration.AttributesTemplateInstance saveTechnicalAttributeDetails(String request) {
  System.debug('request Data: ' + request);
  TechnicalAttributeConfiguration.AttributesTemplateInstance instance =
   (TechnicalAttributeConfiguration.AttributesTemplateInstance) JSON.deserialize(request, TechnicalAttributeConfiguration.AttributesTemplateInstance.class);
  TechnicalAttributeConfiguration.AttributesTemplateInstanceObject instanceObject = instance.attributesTemplateInstance;
  System.debug('instanceObject 0 0 0 0 0 : ' + instanceObject);
  String lastHistoryId = instance.lastHistoryId;
  Datetime currentDateTime = System.now();
  Date currentDate = currentDateTime.date();
  Datetime capturedOnDateTime = instanceObject.capturedOn;
  Date capturedOnDate;
  if (capturedOnDateTime != null) capturedOnDate = capturedOnDateTime.date();
  Datetime lmdTime = instanceObject.lmd;
  Date lmd;
  if (lmdTime != null) lmd = lmdTime.date();

  SVMXC__SM_IB_Attributes_Template_Instance__c attributesTemplateInstance = new SVMXC__SM_IB_Attributes_Template_Instance__c();
  if (instanceObject != null) {
   if (instanceObject.sfdcId != null) {
    attributesTemplateInstance.Id = instanceObject.sfdcId;
   }
   attributesTemplateInstance.SVMXC__SM_Attr_Payload__c = instanceObject.attributesPayload;
   attributesTemplateInstance.SVMXC__SM_Instance_Template_Id__c = instanceObject.templateId;
   attributesTemplateInstance.SVMXC__SM_Installed_Product_Id__c = instanceObject.installedProductId;
   attributesTemplateInstance.SVMXC__SM_Captured_On__c = currentDateTime;
   if (COMM_SecurityUtils.getInstance().verifyFieldAccess(attributesTemplateInstance, COMM_SecurityUtils.Access.Upsertable)) {
    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
    upsert attributesTemplateInstance;
   } else {
    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
   }
  }

  SVMXC__SM_IB_Attributes_History__c ibAttributeHistrory = new SVMXC__SM_IB_Attributes_History__c();
  ibAttributeHistrory.SVMXC__SM_Attr_Payload__c = attributesTemplateInstance.SVMXC__SM_Attr_Payload__c;
  ibAttributeHistrory.SVMXC__SM_Attr_Type__c = 'TECHNICAL';
  ibAttributeHistrory.SVMXC__SM_Installed_Product_Id__c = attributesTemplateInstance.SVMXC__SM_Installed_Product_Id__c;
  ibAttributeHistrory.SVMXC__SM_Instance_Template_Id__c = attributesTemplateInstance.Id;
  ibAttributeHistrory.SVMXC__SM_Captured_On__c = currentDateTime;

  ibAttributeHistrory.SVMXC__SM_Source__c = 'Web';
  system.debug(LoggingLevel.WARN, 'calledfrom: ' + calledfrom);

  //Removing the lastHistoryId so that we can save multiple records per day in web UI
  if(calledfrom == null || calledfrom == TechnicalAttributeImpl.source.WEB){
      //Create new tech attribute history, don't update existing record.
  }else{
      if(capturedOnDate != null){
          if(currentDate > capturedOnDate){
              lastHistoryId = null;    
          }
      }else if(currentDate > lmd){
          lastHistoryId = null;
      }
      if(lastHistoryId != null){
          ibAttributeHistrory.Id = lastHistoryId;
      }
  }

  if (COMM_SecurityUtils.getInstance().verifyFieldAccess(ibAttributeHistrory, COMM_SecurityUtils.Access.Upsertable)) {
   //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
   upsert ibAttributeHistrory;
  } else {
   throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
  }

  instance.lastHistoryId = ibAttributeHistrory.Id;

  return instance;

 }

 public TechnicalAttributeConfiguration.MetaData getMetaData() {
  TechnicalAttributeConfiguration.MetaData mData = new TechnicalAttributeConfiguration.MetaData();
  String svmxGrpProfileId = (new INTF_ConfigSync()).getSVMXGrpProfileId(null);
  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
  List < SVMXC__ProductIQProfile__c > profile = [Select SVMXC__Contents__c from SVMXC__ProductIQProfile__c where SVMXC__ServiceMax_Profile__c =: svmxGrpProfileId];
  mData.isTechnicalAttributesEnabled = 'false';
  mData.isProductIQEnabled = 'false';
  if (!profile.isEmpty()) {
   Map < String, Object > content = (Map < String, Object > ) JSON.deserializeUntyped(profile[0].SVMXC__Contents__c);
   mData.isTechnicalAttributesEnabled = (String) content.get('isTechnicalAttributesEnabled');
  }
  List < SVMXC__ServiceMax_Config_Data__c > lstSettings = (new INTF_ConfigSync()).getSettings(new Set < String > (), new Set < String > (), new set < String > {
   'PRODIQ002_SET001'
  }, svmxGrpProfileId);
  if (!lstSettings.isEmpty()) {
   SVMXC__ServiceMax_Config_Data__c configData = lstSettings[0];
   mData.isProductIQEnabled = configData.SVMXC__Internal_Value__c;
  }
  mData.translations = getTranslations();
  mData.timeZone = UserInfo.getTimeZone().getID();
  //Changes done as part of BAC-5346 by Nidhi
  Organization org = [SELECT InstanceName FROM Organization];
  mData.instanceName = org.InstanceName;
  //Changes done by Nidhi ends here
  return mData;
 }

 public Map < String, String > getTranslations() {
  Map < String, String > translations = new Map < String, String > ();
  translations.put('NONE', system.Label.COMM002_TAG005); //'--None--'
  translations.put('TA', system.Label.PRODIQ001_TAG150); //'Technical Attributes'
  translations.put('NO_TA', system.Label.FSA017_TAG009); //'No technical attributes associated with this installed product.'      
  translations.put('PREVIOUS', system.Label.PRODIQ001_TAG146); //'Previous'
  translations.put('NEXT', system.Label.FSA008_TAG030); //'Next'
  translations.put('CURRENT', system.Label.FSA017_TAG024); //'Current'
  translations.put('ATTRIBUTES', system.Label.FSA017_TAG007); //'Attributes'
  translations.put('SETTING', system.Label.PRODIQ001_TAG149); //'Setting'
  translations.put('SAVE', system.Label.PRODIQ001_TAG192); //'Save'
  translations.put('CANCEL', system.Label.PRODIQ001_TAG098); //'Cancel'
  translations.put('ATTRIBUTES_ERROR', system.Label.FSA017_TAG026); //'Failed to retrieve attributes for selected IB. Please contact your administrator.'
  translations.put('PARAMS_ERROR', system.Label.PRODIQ001_TAG208); //'Insufficient number of parameters provided to Technical Attributes. Please contact your ServiceMax administrator to resolve this.'
  translations.put('PIQ_DISABLED', system.Label.PRODIQ001_TAG210); //'Installed Base is disabled for this user. Please contact your ServiceMax administrator'
  translations.put('TA_DISABLED', system.Label.PRODIQ001_TAG211); //'Technical Attributes are disabled for this user. Please contact your ServiceMax administrator.'
  translations.put('ENTER_VALID_NUMBER', system.Label.PRODIQ001_TAG216); //'Enter a valid number'

  return translations;
 }

}