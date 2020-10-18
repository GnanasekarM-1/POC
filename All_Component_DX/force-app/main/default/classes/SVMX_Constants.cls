public with sharing class SVMX_Constants {
  public Integer maxBubbleCount{get;set;}
  public Integer maxResultsetCount{get;set;}
  public static string constRecordId = 'RECORDID';
  public static string constSVMXConstant = 'SVMXCONSTANT';
  
  public static map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
  public static map<string, Map<String, String>> AllDCSettingList = new map<string, Map<String, String>>();
  public static Map<String, String> AllsvmxSettingListCase = new Map<String, String>();
  
  public SVMX_Constants(){
    maxBubbleCount = 5;
    maxResultsetCount = 10;
  }
  //Added for BAC-4676
    public Map<String, String> geolocationOptions()
    {
        Map<String, String> response = new Map<String, String>();
        response.put('SVMX.Geolocation.Latitude', 'SVMX.GEOLOCATION.COORDS.LATITUDE'+'~'+system.label.SFM001_TAG735);//'Geolocation.Latitude'
        response.put('SVMX.Geolocation.Longitude', 'SVMX.GEOLOCATION.COORDS.LONGITUDE'+'~'+system.label.SFM001_TAG736);//'Geolocation.Longitude'
        response.put('SVMX.Geolocation.Accuracy', 'SVMX.GEOLOCATION.COORDS.ACCURACY'+'~'+system.label.SFM001_TAG737);//'Geolocation.Accuracy'
        return response;
    }
  public Map<String, String> getDateOptions(){
    Map<String, String> response = new Map<String, String>();
    response.put('SVMX.TODAY','Today~'+system.label.COMM001_TAG018);//'Today'
    response.put('SVMX.TOMORROW','Tomorrow~'+system.label.COMM001_TAG019);//'Tomorrow'
    response.put('SVMX.YESTERDAY','Yesterday~'+system.label.COMM001_TAG020);//'Yesterday'
    return response;
  }
  
  public Map<String, String> getDateTimeOptions(){
    Map<String, String> response = new Map<String, String>();
    response.put('SVMX.NOW','Now~'+system.label.COMM001_TAG021);//'Now'
    response.put('SVMX.TODAY','Today~'+system.label.COMM001_TAG018);//'Today'
    response.put('SVMX.TOMORROW','Tomorrow~'+system.label.COMM001_TAG019);//'Tomorrow'
    response.put('SVMX.YESTERDAY','Yesterday~'+system.label.COMM001_TAG020);//'Yesterday'
    return response;
  }
  
    public Map<String, String> getUserOptions()
    {
        Map<String, String> response = new Map<String, String>();
        response.put('SVMX.CURRENTUSER','Current User~'+system.label.COMM001_TAG022);//'Current User'
        response.put('SVMX.RECORDOWNER','Record Owner~'+system.label.COMM001_TAG023);//'Record Owner'
        return response;
    }
  
    //Neeraj: Added below code at the time of mobile config code migration.
    public Map<String, String> getObjectMappingHeaderDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'object_mapping_id');
        mapObjectMappingHeader.put('SVMXC__MapID__c', 'object_mapping_name');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'source_object_name');
        mapObjectMappingHeader.put('SVMXC__Target_Object_Name__c', 'target_object_name');
        return mapObjectMappingHeader;
    }
  
    public Map<String, String> getObjectMappingDetailDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('SVMXC__MapID__c', 'object_mapping_id');
        mapObjectMappingHeader.put('SVMXC__Source_Field_Name__c', 'source_field_name');
        mapObjectMappingHeader.put('SVMXC__Target_Field_Name__c', 'target_field_name');
        mapObjectMappingHeader.put('SVMXC__Preference_2__c', 'preference_2');
        mapObjectMappingHeader.put('SVMXC__Preference_3__c', 'preference_3');
        mapObjectMappingHeader.put('SVMXC__Display_Value__c', 'mapping_value');
        return mapObjectMappingHeader;
    }
  
    public Map<String, String> getObjectExpressionHeaderDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'expression_id');
        mapObjectMappingHeader.put('SVMXC__ProcessID__c', 'expression_name');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'source_object_name');
        mapObjectMappingHeader.put('SVMXC__Values__c', 'failure_reason');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__Advance_Expression__c', 'advance_expression');
        mapObjectMappingHeader.put('SVMXC__Parent_Error_Msg__c', 'error_message');
        return mapObjectMappingHeader;
    }
  
    public Map<String, String> getObjectExpressionDetailDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('SVMXC__Expression_Rule__c', 'expression_id');
        mapObjectMappingHeader.put('SVMXC__Field_Name__c', 'source_field_name');
        mapObjectMappingHeader.put('SVMXC__Operator__c', 'operator');
        mapObjectMappingHeader.put('SVMXC__Operand__c', 'value');
        mapObjectMappingHeader.put('SVMXC__Display_Type__c', 'field_type');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__Parameter_Type__c', 'parameter_type');
        mapObjectMappingHeader.put('SVMXC__Expression_Type__c', 'expression_type');
        mapObjectMappingHeader.put('SVMXC__Formula__c', 'formula');
        mapObjectMappingHeader.put('SVMXC__Action_Type__c', 'action_type');
        mapObjectMappingHeader.put('SVMXC__Description__c', 'description');
        return mapObjectMappingHeader;
    }
  
    public Map<String, String> getNamedSearchHeaderDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'search_sfid');
        mapObjectMappingHeader.put('SVMXC__ProcessID__c', 'search_id');
        mapObjectMappingHeader.put('SVMXC__Name__c', 'search_name');
        mapObjectMappingHeader.put('SVMXC__IsStandard__c', 'is_standard');
        mapObjectMappingHeader.put('SVMXC__Rule_Type__c', 'search_type');
        mapObjectMappingHeader.put('SVMXC__IsDefault__c', 'is_default');
        mapObjectMappingHeader.put('SVMXC__Number_of_Lookup_Records__c', 'no_of_lookup_records');
        mapObjectMappingHeader.put('SVMXC__Default_Lookup_Column__c', 'default_lookup_column');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'search_object_name');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'object_name');
        mapObjectMappingHeader.put('SVMXC__Rule_Type__c', 'search_type');
        mapObjectMappingHeader.put('SVMXC__ProcessID__c', 'named_search_id');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__Process__c', 'filter_criteria');
        return mapObjectMappingHeader;
    }
  
    public Map<String, String> getNamedSearchDetailDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('SVMXC__Internal_Value__c', 'named_search');
        mapObjectMappingHeader.put('SVMXC__Field_Name__c', 'field_name');
        mapObjectMappingHeader.put('SVMXC__Search_Object_Field_Type__c', 'search_object_field_type');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        //mapObjectMappingHeader.put('SVMXC__Related_To__c', 'related_to');
        //mapObjectMappingHeader.put('SVMXC__Related_Field_Name__c', 'related_field_name');
        mapObjectMappingHeader.put('SVMXC__Field_Relationship_Name__c', 'field_relationship_name');
        mapObjectMappingHeader.put('SVMXC__Display_Type__c', 'field_type');
        mapObjectMappingHeader.put('SVMXC__Expression_Type__c', 'expression_type');
        
        //Fields added for the Advanced Lookup Config...
        mapObjectMappingHeader.put('SVMXC__Parameter_Type__c', 'parameter_type');
        mapObjectMappingHeader.put('SVMXC__Operator__c', 'operator');
        mapObjectMappingHeader.put('SVMXC__Operand__c', 'operand');
        mapObjectMappingHeader.put('SVMXC__Object_Name__c', 'object_name');
        mapObjectMappingHeader.put('SVMXC__FKey_Name_Field__c', 'fkey_name_field');
        mapObjectMappingHeader.put('SVMXC__Expression_Rule__c', 'exp_rule');
        
        return mapObjectMappingHeader;
    }
    
    public Map<String, String> getNamedSearchObjCriDef()
    {
        Map<String, String> mapNamedSearchObjCri = new Map<String, String>();
        mapNamedSearchObjCri.put('Id', 'id');
        mapNamedSearchObjCri.put('SVMXC__Name__c', 'name');
        mapNamedSearchObjCri.put('SVMXC__Default_On__c', 'default_on');
        mapNamedSearchObjCri.put('SVMXC__Field_Name__c', 'field_name');
        mapNamedSearchObjCri.put('SVMXC__Allow_Override__c', 'allow_override');
        mapNamedSearchObjCri.put('SVMXC__Advance_Expression__c', 'advanced_exp');
        mapNamedSearchObjCri.put('SVMXC__Rule_Type__c', 'rule_type');
        mapNamedSearchObjCri.put('SVMXC__Parent_Object_Criteria__c', 'parent_object_criteria');
        mapNamedSearchObjCri.put('SVMXC__Source_Object_Name__c', 'source_object_name');
        mapNamedSearchObjCri.put('SVMXC__Sequence__c', 'sequence');
        mapNamedSearchObjCri.put('SVMXC__Module__c', 'module');
        return mapNamedSearchObjCri;
    }
    
    public Map<String, String> getAdvLookupHdrDef()
    {
        Map<String, String> mapAdvLookupHdr = new Map<String, String>();
        mapAdvLookupHdr.put('Id', 'Id');
        mapAdvLookupHdr.put('SVMXC__Name__c', 'lkp_name');
        mapAdvLookupHdr.put('SVMXC__Description__c', 'lkp_desc');
        mapAdvLookupHdr.put('SVMXC__Default_On__c', 'default_on');
        mapAdvLookupHdr.put('SVMXC__Field_Name__c', 'field_name');
        mapAdvLookupHdr.put('SVMXC__Allow_Override__c', 'allow_override');
        mapAdvLookupHdr.put('SVMXC__Advance_Expression__c', 'adv_exp');
        mapAdvLookupHdr.put('SVMXC__Rule_Type__c', 'rule_type');
        mapAdvLookupHdr.put('SVMXC__Parent_Object_Criteria__c', 'parent_obj_criteria');
        mapAdvLookupHdr.put('SVMXC__Source_Object_Name__c', 'src_obj_name');
        mapAdvLookupHdr.put('SVMXC__Sequence__c', 'sequence');
        mapAdvLookupHdr.put('SVMXC__Module__c', 'header_pro');
        return mapAdvLookupHdr;
    }
    
    public Map<String, String> getProcessHeaderDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'process_id');
        mapObjectMappingHeader.put('SVMXC__Purpose__c', 'process_type');
        mapObjectMappingHeader.put('SVMXC__Name__c', 'process_name');
        mapObjectMappingHeader.put('SVMXC__Page_Layout__c', 'page_layout_id');
        mapObjectMappingHeader.put('SVMXC__Description__c', 'process_description');
        mapObjectMappingHeader.put('SVMXC__ProcessID__c', 'process_unique_id');
        //Added by Naveen V for SFM Process - Document Template
        mapObjectMappingHeader.put('SVMXC__Doc_Template__c', 'doc_template_id');
        return mapObjectMappingHeader;
    }
    public Map<String, String> getProcessDetailDefinition()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'local_id');
        mapObjectMappingHeader.put('SVMXC__Process__c', 'process_id');
        mapObjectMappingHeader.put('SVMXC__Type__c', 'component_type');
        mapObjectMappingHeader.put('SVMXC__Page_Layout__c', 'layout_id');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'object_name');
        mapObjectMappingHeader.put('SVMXC__Target_Object_label__c', 'target_object_label');
        mapObjectMappingHeader.put('SVMXC__Submodule__c', 'expression_id');
        mapObjectMappingHeader.put('SVMXC__Module__c', 'object_mapping_id');
        mapObjectMappingHeader.put('SVMXC__Final_Exception_Process__c', 'value_mapping_id');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__Node_Parent_API__c', 'node_parent_api');
        mapObjectMappingHeader.put('SVMXC__Node_Source_Object_API__c', 'node_source_object_api');
        mapObjectMappingHeader.put('SVMXC__Node_Parent__c', 'node_parent');
        mapObjectMappingHeader.put('SVMXC__Parent_Object__c', 'parent_object');
        mapObjectMappingHeader.put('SVMXC__Parent_Column_Name__c', 'parent_column');
        mapObjectMappingHeader.put('SVMXC__Values__c', 'SVMXC__Values__c');
        mapObjectMappingHeader.put('SVMXC__Doc_Template_Details__c', 'doc_template_Detail_id');
        mapObjectMappingHeader.put('SVMXC__Enable_Attachment__c', 'enable_attachment');
        return mapObjectMappingHeader;
    }
    public Map<String, String> getSFWWizard()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'wizard_id');
        mapObjectMappingHeader.put('SVMXC__Name__c', 'wizard_name');
        mapObjectMappingHeader.put('SVMXC__Description__c', 'wizard_description');
        mapObjectMappingHeader.put('SVMXC__Active__c', 'is_active');
        mapObjectMappingHeader.put('SVMXC__Submodule__c', 'expression_id');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'object_name');
        return mapObjectMappingHeader;
    }
    public Map<String, String> getSFWWizardActions()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'wizard_step_id');
        mapObjectMappingHeader.put('SVMXC__Module__c', 'wizard_id');
        mapObjectMappingHeader.put('SVMXC__Submodule__c', 'expression_id');
        mapObjectMappingHeader.put('SVMXC__Name__c', 'wizard_step_name');
        mapObjectMappingHeader.put('SVMXC__Description__c', 'wizard_step_description');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__Process__c', 'process_id');
        mapObjectMappingHeader.put('SVMXC__Expertise_Match_Enabled__c', 'perform_sync');
        mapObjectMappingHeader.put('SVMXC__Action_Type__c', 'type');
        return mapObjectMappingHeader;
    }
    
    public Map<String, String> getSFWWizardCustomActions()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'Id');
        mapObjectMappingHeader.put('SVMXC__Name__c', 'wizard_step_name');
        mapObjectMappingHeader.put('SVMXC__Description__c', 'wizard_step_description');
        mapObjectMappingHeader.put('SVMXC__Service_Class_Name__c', 'class_name');
        mapObjectMappingHeader.put('SVMXC__Service_Method_Name__c', 'method_name');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__Target_URL__c', 'target_url');
        mapObjectMappingHeader.put('SVMXC__Custom_Action_Type__c', 'custom_action_type');
        return mapObjectMappingHeader;
    }
    
    public Map<String, String> getSFWWizardSyncOverride()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'Id');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__ServiceMax_Process__c', 'wizard_step_id');
        mapObjectMappingHeader.put('SVMXC__Target_Call__c', 'service_name');
        mapObjectMappingHeader.put('SVMXC__Event_Call_Type__c', 'type');
        return mapObjectMappingHeader;
    }
    
    public Map<String, String> getLinkedProHdrDef()
    {
        Map<String, String> mapLinkedProHdr = new Map<String, String>();
        mapLinkedProHdr.put('Id', 'Id');
        mapLinkedProHdr.put('SVMXC__Process1__c', 'source_header');
        mapLinkedProHdr.put('SVMXC__Process2__c', 'source_detail');
        mapLinkedProHdr.put('SVMXC__Process3__c', 'target_header');
        return mapLinkedProHdr;
    }
    
    public Map<String, String> getSFMDocTemplateDef()
    {
        Map<String, String> mapDocTemplateHdr = new Map<String, String>();
        mapDocTemplateHdr.put('Id', 'Id');
        mapDocTemplateHdr.put('SVMXC__Name__c', 'doc_template_name');
        mapDocTemplateHdr.put('SVMXC__Template_Id__c', 'doc_template_id');
        mapDocTemplateHdr.put('SVMXC__Media_Resources__c', 'media_resources');
        mapDocTemplateHdr.put('SVMXC__IsStandard__c', 'is_standard');
        mapDocTemplateHdr.put('SVMXC__Detail_Object_Count__c', 'detail_object_count');
        return mapDocTemplateHdr;
    }
    public Map<String, String> getSFMDocTemplateDtlDef()
    {
        Map<String, String> mapDocTemplateDtl = new Map<String, String>();
        mapDocTemplateDtl.put('Id', 'Id');
        mapDocTemplateDtl.put('SVMXC__Doc_Template__c', 'doc_template');
        mapDocTemplateDtl.put('SVMXC__Doc_Template_Detail_Unique_Id__c', 'doc_template_detail_unique_id');
        mapDocTemplateDtl.put('SVMXC__Alias__c', 'alias');
        mapDocTemplateDtl.put('SVMXC__Doc_Template_Detail_Id__c', 'doc_template_detail_id');
        mapDocTemplateDtl.put('SVMXC__Fields__c', 'fields');
        mapDocTemplateDtl.put('SVMXC__Header_Reference_Field__c', 'header_ref_fld');
        mapDocTemplateDtl.put('SVMXC__Object_Name__c', 'object_name');
        mapDocTemplateDtl.put('SVMXC__SOQL__c', 'soql');
        mapDocTemplateDtl.put('SVMXC__Type__c', 'type');
        return mapDocTemplateDtl;
    }
    public Map<String, String> getAttachmentDef()
    {
        Map<String, String> mapAttachment = new Map<String, String>();
        mapAttachment.put('Id', 'Id');
        mapAttachment.put('Name', 'attachment_name');
        mapAttachment.put('ParentId', 'parent_id');
        return mapAttachment;
    }
    
    public void outputDoc_Lib(set<string> set_OpDocSRNames)
    {
        set_OpDocSRNames.add('com_servicemax_client_lib');
        set_OpDocSRNames.add('com_servicemax_client_mvc');
        set_OpDocSRNames.add('com_servicemax_client_runtime');
        set_OpDocSRNames.add('com_servicemax_client_sfmconsole');
        set_OpDocSRNames.add('com_servicemax_client_sfmopdocdelivery');
        set_OpDocSRNames.add('com_servicemax_client_sfmopdocdelivery_model');
        set_OpDocSRNames.add('com_servicemax_client_tablet_sal_sfmopdoc_model');
        set_OpDocSRNames.add('com_servicemax_client_sal_sfmconsole_model');
    }
    
    public void bizRule_Lib(set<string> set_BizRuleSRNames)
    {
        set_BizRuleSRNames.add('com_servicemax_client_lib');
        set_BizRuleSRNames.add('com_servicemax_client_app');
        set_BizRuleSRNames.add('com_servicemax_client_runtime');
        set_BizRuleSRNames.add('com_servicemax_client_sfmbizrules');
        //set_BizRuleSRNames.add('');
    }
    
    public Map<String, String> getStaticResourcesDef()
    {
        Map<String, String> mapOpDocResources = new Map<String, String>();
        mapOpDocResources.put('Id', 'Id');
        mapOpDocResources.put('Name', 'Name');
        return mapOpDocResources;
    }
    
    public Map<String, String> getProcessBusinessRules()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'Id');
        mapObjectMappingHeader.put('Name', 'name');
        mapObjectMappingHeader.put('SVMXC__Process1__c', 'target_manager');
        mapObjectMappingHeader.put('SVMXC__Process2__c', 'process_node_object');
        mapObjectMappingHeader.put('SVMXC__Process3__c', 'business_rule');
        mapObjectMappingHeader.put('SVMXC__Description__c', 'description');
        mapObjectMappingHeader.put('SVMXC__Parent_Error_Msg__c', 'error_msg');
        mapObjectMappingHeader.put('SVMXC__Sequence__c', 'sequence');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'source_object_name');
        return mapObjectMappingHeader;
    }
    
    public Map<String, String> getBusinessRules()
    {
        Map<String, String> mapObjectMappingHeader = new Map<String, String>();
        mapObjectMappingHeader.put('Id', 'Id');
        mapObjectMappingHeader.put('Name', 'name');
        mapObjectMappingHeader.put('SVMXC__ProcessID__c', 'process_ID');
        mapObjectMappingHeader.put('SVMXC__Description__c', 'description');
        mapObjectMappingHeader.put('SVMXC__Source_Object_Name__c', 'source_object_name');
        mapObjectMappingHeader.put('SVMXC__Parent_Error_Msg__c', 'error_msg');
        mapObjectMappingHeader.put('SVMXC__Advance_Expression__c', 'advanced_expression');
        mapObjectMappingHeader.put('SVMXC__Message_Type__c', 'message_type');
        mapObjectMappingHeader.put('SVMXC__Rule_Type__c', 'rule_type');
        return mapObjectMappingHeader;
    }
    
    public Map<String, String> getDocumentDef()
    {
        Map<String, String> mapDoc = new Map<String, String>();
        mapDoc.put('Id', 'Id');
        mapDoc.put('Name', 'Name');
        mapDoc.put('DeveloperName', 'DeveloperName');
        return mapDoc;
    }
    
    public Map<String, String> getSourceUpdate()
    {
        Map<String, String> mapSU = new Map<String, String>();
        mapSU.put('Id', 'Id');
        mapSU.put('SVMXC__Setting_ID__c', 'setting_Id');
        mapSU.put('SVMXC__Action__c', 'action');
        mapSU.put('SVMXC__Display_Value__c', 'display_value');
        mapSU.put('SVMXC__Configuration_Type__c', 'configuration_type');
        mapSU.put('SVMXC__Target_Field_Name__c', 'target_field_name');
        mapSU.put('SVMXC__Source_Field_Name__c', 'source_field_name');
        mapSU.put('SVMXC__Dispatch_Process__c', 'process');
        return mapSU;
    }
    
    public Map<String, String> getSFMWizardLayout()
    {
        Map<String, String> mapSFWLayout = new Map<String, String>();
        mapSFWLayout.put('Id', 'wizard_layout_id');
        mapSFWLayout.put('SVMXC__Object_Name__c', 'object_name');
        mapSFWLayout.put('SVMXC__Button_Size__c', 'button_size');
        mapSFWLayout.put('SVMXC__Dispatch_Process__c', 'wizard_id');
        mapSFWLayout.put('SVMXC__Wizard_Layout_Column__c', 'wizard_layout_column');
        mapSFWLayout.put('SVMXC__Wizard_Layout_Row__c', 'wizard_layout_row');
        return mapSFWLayout;
    }
    
    public Map<String, String> getSFWWizardCustomActionParams()
    {
        Map<String, String> mapCustomActionParam = new Map<String, String>();
        mapCustomActionParam.put('Id', 'Id');
        mapCustomActionParam.put('Name', 'Name');
        mapCustomActionParam.put('SVMXC__Action_Type__c', 'action_type');
        mapCustomActionParam.put('SVMXC__Dispatch_Process__c', 'dispatch_Process');
        mapCustomActionParam.put('SVMXC__Parameter_Name__c', 'parameter_name');
        mapCustomActionParam.put('SVMXC__Parameter_Type__c', 'parameter_type');
        mapCustomActionParam.put('SVMXC__Parameter_Value__c', 'parameter_value');
        return mapCustomActionParam;
    }
}