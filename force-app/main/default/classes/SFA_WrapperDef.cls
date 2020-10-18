/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * The SFA_WrapperDef provides common wrapper classes which can be used for Service Flow Automation
 *
 * @author Manish Kushwah
 * @version 19.2
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Manish Kushwah         20 March 2019     Created.
 *   Soumyaranjan Pati      6th Sept 2019     Code changes for BAC-5214
 *****************************************************************************************************/

public with sharing class SFA_WrapperDef{

    //Using to generate JSON for record to publish the platform event
    public class SFA_RecordWrapper{
        public Map<String,String> mapfieldNameValues= new Map<String,String>();
    }

    //Class is for Event JSON - Salesforce event
    public class SFA_SFDCEventJsonWrapper{
        public String Object_API_Name;
        public String SFDC_Data_Event_Type;
        public Set<String> Event_Trigger_Fields;
        public Set<String> Preview_Field_List;
    }

    //Class is for Event JSON - Geofence
    public class SFA_GeofenceEventJsonWrapper{
        public String Object_API_Name;
        public String Trigger_Type;
        public String Location_Field;
        public String Fence_Radius;
        public String Sort_Records_By;
    }

    //Class is for Action JSON - Salesforce event
    public class SFA_SFDCActionJsonWrapper{
        public Set<String> Recipient_Field_API_Names;
        public String Message_Title;
        public String Message_Body;
        public String Service_Provider;
        public String Client_App_Name;
        public String Display_Object_Record;
        public String Screen_To_Load;
        public Boolean IsInteractiveAction;
        public List<InteractiveAction> InteractiveActions;
        public List<RelatedRecipient> Recipient_Related_Field_API_Names;
        public List<RelatedListRecipient> RelatedList_Recipients;
    }

    //Class is for Action JSON - Geofence
    public class SFA_GeofenceActionJsonWrapper{
        public String Message_Title;
        public String Message_Body;
        public String Client_App_Name;
        public String Display_Object_Record;
        public String Screen_To_Load;
        public Boolean IsInteractiveAction;
        public List<InteractiveAction> InteractiveActions;
    }

    //Class is for Action JSON - SMS added for BAC-5214
    public class SFA_SMSActionJsonWrapper{
        public List<Recipients> Recipients;
        public String Message_Body;
        public String Service_Provider;
        public String Display_Object_Record;
    }

    //added for BAC-5214
    public class Recipients {
        public String field;
        public String country;
        public String contactnumber;
        public String relatedObject;
        public String relatedRefNameField;
        public String relatedCountryField;
        public List<String> relatedField;

    }

    public class InteractiveAction {
        public String Button_Id;
        public String Button_Title;
        public String Target_Process_Id;
        public String Process_Type;
        public Boolean Is_Background;
    }

    public class RelatedRecipient {
      public String Related_Object;
      public String Relationship_Name;
      public String Lookup_Field_Name;
      public List<String> Related_Recipient_Fields;
    }

    public class RelatedListRecipient {
      public String RelatedList_Object_API_Name;
      public String RelatedList_Field_API_Name;
      public String Relationship_Name;
      public List<String> RelatedList_Recipient_Field;
    }

    //-----------Below classes are for SFA Configuration Page--------------//
    public class SFA_ProcessDetail{
        public String strSFAId;
        public String strSFAProcessId;
        public String strSFAProcessName;
        public String strEventType;
        public String strActionType;
        public Boolean isEnabled;
        public String strLastActivity;
        public String strGroupProfileName;
    }

    public class SFA_ProcessInformation{
        public String strSFAId;
        public String strSFAProcessId;
        public String strSFAProcessName;
        public String strDescription;
        public Boolean isEnabled;
        public String strEventType;
        public String strActionType;
        public String strObjectApiName;
        public String strExpressionId;
        public String strSFMProcessId;
        public String strSVMXGroupProfileId;
        public SFA_SFDCEventJsonWrapper objSFDCEventJson;
        public SFA_GeofenceEventJsonWrapper objGeofenceEventJson;
        public SFA_SFDCActionJsonWrapper objSFDCActionJson;
        public SFA_GeofenceActionJsonWrapper objGeofenceActionJson;
        public SFA_SMSActionJsonWrapper objSMSActionJson; // Added for BAC-5214
    }

    public class SFA_ExpressionDetail{
        public String strSequence;
        public String strFieldName;
        public String strOperator;
        public String strOperand;
        public String strFieldDataType;
    }
    public class SFA_Expression{
        public String strExpressionSFId;
        public String strExpressionProcessId;
        public String strExpressionProcessName;
        public String strAdvancedExpr;
        public Boolean isStandard;
        public List<SFA_WrapperDef.SFA_ExpressionDetail> lstExprDetails;
    }

    public class SFA_ConfigurationRequest{
        public String strSFAId;
        public SFA_ProcessInformation objSFAProcessInfo;
        public String strFilterId;
        public List<String> lstObjectName;
        public String strObjectName;
        public List<String> lstLookupToObject;
        public List<String> lstDataType;
        public Boolean relatedObjectDetails = false; //Added for BAC-5214
    }

    public class SFA_ConfigurationResponse{
        public Boolean success;
        public String message;
        public List<SFA_WrapperDef.SFA_ProcessDetail> lstSFAProcesses;
        public SFA_ProcessInformation objSFAProcessInfo;
        public SFA_ItemListInformation objItemListInformation;
        public List<SFA_WrapperDef.SFA_ItemListInformation> lstItemListInformation;
        public SFA_Expression objExpression;
        public List<SFA_CustomLabel> lstCustomLabel;
        public UserInfoWrapper objUserInfo;
    }

    public class SFA_ItemListInformation{
        public String strObjectLabel;
        public String strObjectValue;
        public List<SFA_WrapperDef.SFA_ItemList> lstFieldList;
        public List<SFA_WrapperDef.SFA_ItemList> lstFilterList;
        public List<SFA_WrapperDef.SFA_ItemList> lstSFM;
        public List<SFA_WrapperDef.SFA_ItemList> lstGroupProfile;
        public List<SFA_WrapperDef.SFA_ItemList> lstObject;
    }

    public class SFA_ItemList{
        public String strValue;
        public String strLabel;
        public String strValueId;
        public String strRelatedObjectName; //Added for BAC-5214
        public String strRelatedRefFieldName; //Added for BAC-5214
    }

    public class SFA_CustomLabel{
        public String tagName;
        public String tagValue;
        public SFA_CustomLabel(String tagName, String tagValue){
            this.tagName = tagName;
            this.tagValue = tagValue;
        }
    }

    public class SFA_RestResponse{
        public Object data;
        public Boolean success;
        public String message;
    }

    public class UserInfoWrapper{
        public String userId;
        public String firstName;
        public String lastName;
        public String dateFormat;
        public String timeZoneOffSet;
        public String timeFormat;
        public String thousandSepartor;
        public String decimalSeparator;
        public String userCurrency;
        public String svmxNameSpace;
    }
    //-----------Below classes are used for SyncGateway JSON--------------//
    public class SyncGatewayMessageWrapper {
        public String loginUrl;
        public List<SFA_WrapperDef.SyncGatewayMessages> messages;
        public syncGatewayMessageWrapper(String loginUrl, List<SFA_WrapperDef.SyncGatewayMessages> messages){
            this.loginUrl = loginUrl;
            this.messages = messages;
        }
    }
    public class SyncGatewayMessages {
        public List<String> applications;
        public List<String> users;
        public SFA_WrapperDef.SyncGatewayMetaData data;
        public SyncGatewayMessages(List<String> applications, List<String> users, SFA_WrapperDef.SyncGatewayMetaData data){
            this.applications = applications;
            this.users = users;
            this.data = data;
        }
    }
    public class SyncGatewayMetaData {
        public String operation;
        public String title;
        public String body;
        public Boolean richContent;
        public Map<String,Object> meta = new Map<String,Object>();
        public SyncGatewayMetaData(String operation, String title, String body, Map<String,Object> meta, Boolean richContent){
            this.operation = operation;
            this.title = title;
            this.body = body;
            this.meta = meta;
            this.richContent = richContent;
        }
    }
    public class SMSRequest {
        public List<SMSMessageRequest> messages;
    }
    public class SMSMessageRequest {
        public String message;
        public List<SMSRecipient> to;
    }
    public class SMSRecipient {
        public String contactnumber;
        public String country;
    }
    public class SMSResponse {
        public List<SMSMessageResponse> messages;
    }
    public class SMSMessageResponse {
      public List<SMSRecipientResponse> to;
    }
    public class SMSRecipientResponse {
       public String sid;
       public String contactnumber;
       public String status;
       public String country;
       public String error_code;
       public String error_message;
    }

    //-----------End for SyncGateway JSON--------------//
}