/**
 * The TOOL_SeedWrapper used as model class to get json data 
 * while deserializing the json.
 *
 * @author D B Sathish Kumar
 * @version Sum 17
 * @created 20/03/2017
 * @updated 19/12/2018
 */

public class TOOL_SeedWrapper {

    public class ProfileData {
        public String SVMXC_PROFILE_NAME_C;
        public String SVMXC_DESCRIPTION_C;
        public String SVMXC_CONFIGURATION_TYPE_C;
        public String SVMXC_ACTIVE_C;
        public String SVMXC_ISDEFAULT_C;
        public String SVMXC_Enable_Calendar_c;
    }
    
    public class Profile {
        public List<ProfileData> profiles;
    }
    
    public class ModuleData {
        public String SVMXC_MODULEID_C;
        public String SVMXC_NAME_C;
        public String SVMXC_DESCRIPTION_C;
        public String SVMXC_ISSTANDARD_C;
    }
    
    public class Module {
        public List<ModuleData> modules;
    }
    
    public class SubmoduleData {
        public String SVMXC_MODULEID_C;
        public String SVMXC_SUBMODULEID_C;
        public String SVMXC_NAME_C;
        public String SVMXC_DESCRIPTION_C;
        public String SVMXC_ISSTANDARD_C;
    }
    
    public class Submodule {
        public List<SubmoduleData> submodules;
    }
    
    public class SettingData {
        public String SVMXC_SUBMODULEID_C;
        public String SVMXC_SETTINGID_C;
        public String SVMXC_SETTINGS_NAME_C;
        public String SVMXC_DATA_TYPE_C;
        public String SVMXC_VALUES_C;
        public String SVMXC_DEFAULT_VALUE_C;
        public String SVMXC_SETTING_TYPE_C;
        public String SVMXC_SEARCH_ORDER_C;
        public String SVMXC_ISPRIVATE_C;
        public String SVMXC_ISSTANDARD_C;
        public String SVMXC_ACTIVE_C;
        public String SVMXC_SUBMODULE_C;
        public String SVMXC_DESCRIPTION_C;
        public String IsFreshInstall;
        public String FreshInstallValue;
    }
    
    public class Setting {
        public List<SettingData> settings;
    }
    
    public class SettingValueData {
        public String SVMXC_SETTING_CONFIGURATION_PROFILE_C;
        public String SVMXC_SETTING_ID_C;
        public String SVMXC_INTERNAL_VALUE_C;
        public String SVMXC_DISPLAY_VALUE_C;
        public String SVMXC_ACTIVE_C;
        public String SVMXC_ISDEFAULT_C;
        public String PROFILETYPE;
        public String SETTINGTYPE;
    }
    
    public class SettingValue {
        public List<SettingValueData> settingValues;
    }
    
    public class MacroDefinitionData {
        public String SVMXC_Type_c;
        public String SVMXC_Macro_Id_c;
        public String SVMXC_Macro_Name_c;
        public String SVMXC_Description_c;
        public String SVMXC_Syntax_c;
        public String SVMXC_Example_c;
        public String SVMXC_IsStandard_c;
        public String SVMXC_IsActive_c;
        public String SVMXC_SM_Entity_Type_c;
    }
    
    public class MacroDefinition {
        public List<MacroDefinitionData> macroDefinition;
    }
    
    public class ApplicationFilterData {
        public String SVMXC_ProcessID_c;
        public String SVMXC_Name_c;
        public String SVMXC_Description_c;
        public String SVMXC_Values_c;
        public String SVMXC_IsStandard_c;
    }
    
    public class ApplicationFilter {
        public List<ApplicationFilterData> applicationFilter;
    }
    
    public class ManifestData {
        public String SVMXC_Code_Snippet_c;
        public String SVMXC_Referenced_Code_Snippet_c;
    }
    
    public class SnippetManifest {
        public List<ManifestData> codeSnippetManifest;
    }
    
    public class ElementData {
        public String SVMXC_NAME_C;
        public String SVMXC_Property_Key_c;
        public String SVMXC_Element_Type_c;
        public String SVMXC_Element_Value_c;
    }
    
    public class PropertyElement {
        public List<ElementData> propertyElements;
    }
    
    public class MapHoverData {
        public String SVMXC_NAME_C;
        public String SVMXC_Rule_Type_c;
        public String SVMXC_Source_Object_Name_c;
        public String SVMXC_ProcessID_c;
        public String SVMXC_ISSTANDARD_C;
    }
    
    public class MapHover {
        public List<MapHoverData> mapHover;
    }
    
    public class HoverDetailData {
        public String SVMXC_Expression_Rule_c;
        public String SVMXC_Expression_Type_c;
        public String SVMXC_Sequence_c;
        public String SVMXC_Field_Name_c;
        public String SVMXC_Display_Type_c;
        public String SVMXC_Field_Relationship_Name_c;
        public String SVMXC_FKey_Name_Field_c;
    }
    
    public class HoverDetail {
        public List<HoverDetailData> mapHoverDetails;
    }

    public class SeedData {
        public String Name;
        public String FileName;
    }
    
    public class SeedFile {
        public List<SeedData> files;
    }
    
    public class SFActionData {
        public String RecordTypeName;
        public String SVMXC_ProcessID_c;
        public String SVMXC_Name_c;
        public String SVMXC_Description_c;
        public String SVMXC_Target_Type_c;
        public String SVMXC_Target_URL_c;
        public String SVMXC_IsStandard_c;
        public String SVMXC_Window_Height_c;
        public String SVMXC_Window_Width_c;
        public String SVMXC_Active_c;
        public String SVMXC_Open_As_Full_Window_c;
        public String SVMXC_Source_Object_Name_c;
        public String SVMXC_Custom_Action_Type_c;
        public String SVMXC_Service_Namespace_c;
        public String SVMXC_Service_Class_Name_c;
        public String SVMXC_Service_Method_Name_c;
    }
    
    public class ServiceFlowAction {
        public List<SFActionData> sfactions;
    }
    
    public class SFActionParameterData {
        public String RecordTypeName;
        public String SVMXC_Dispatch_Process_c;
        public String SVMXC_Parameter_Name_c;
        public String SVMXC_Parameter_Type_c;
        public String SVMXC_Parameter_Value_c;
    }

    public class ServiceFlowActionParameter {
        public List<SFActionParameterData> sfactionparameters;
    }
    
    public class PriceFieldData {
        public String Name;
        public String SVMXC_Code_Snippet_ID_c;
        public String SVMXC_Object_API_Name_c;
        public String SVMXC_Field_API_Name_List_c;
    }
    
    public class GetPriceField {
        public List<PriceFieldData> getpricefields;
    }
    
    public class IOTData{
    	public String SVMXC_Name_c;
    	public String SVMXC_Contents_c;
    	public String SVMXC_Type_c;
    	public String SVMXC_IsStandard_c;
    }
    
    public class IOTConfiguration {
        public List<IOTData> iotconfiguration;
    }
    
    public class InventoryProcessData {
    	public String SVMXC_PROCESSID_C;
    	public String SVMXC_MODULE_C;
    	public String SVMXC_SUBMODULE_C;
    	public String SVMXC_NAME_C;
    	public String SVMXC_DESCRIPTION_C;
    	public String SVMXC_ISSTANDARD_C;
    	public String SVMXC_PARENT_OBJECT_CRITERIA_C;
    	public String SVMXC_CHILD_OBJECT_CRITERIA_C;
    	public String SVMXC_Tag_Keys_c;
    	public String SVMXC_Parent_Error_Msg_c;
    	public String SVMXC_Child_Error_Msg_c;
    }
    
    public class InventoryProcess {
        public List<InventoryProcessData> inventoryprocess;
    }
    
    public class InventoryExpressionData {
        public String SVMXC_INVENTORY_PROCESS_C;
    	public String SVMXC_EXPRESSION_TYPE_C;
    	public String SVMXC_SEQUENCE_C;
    	public String SVMXC_OBJECT_NAME_C;
    	public String SVMXC_FKey_Name_Field_c;
        public String SVMXC_FIELD_NAME_C;
        public String SVMXC_Display_Type_c;
        public String SVMXC_OPERATOR_C;
        public String SVMXC_OPERAND_C;
        public String SVMXC_Lookup_Field_API_Name_c;
    }
    
    public class InventoryExpression {
        public List<InventoryExpressionData> inventoryexpression;
    }
    
    public class OptimaxSettingData {
    	public String Name;
    	public String SVMXC_Source_Key_c;
    	public String SVMXC_Source_Type_c;
    	public String SVMXC_Target_Key_c;
    	public String SVMXC_Target_Value_c;
    }
    
    public class OptimaxCustomSetting {
        public List<OptimaxSettingData> customsetting;
    }
    
    public class ExpressionData {
    	public String SVMXC_Rule_Type_c;
    	public String SVMXC_Source_Object_Name_c;
    	public String SVMXC_ProcessID_c;
    	public String SVMXC_NAME_C;
    	public String SVMXC_DESCRIPTION_C;
    	public String SVMXC_ISSTANDARD_C;
    	public String SVMXC_Advance_Expression_c;
    	public String SVMXC_Parent_Object_Criteria_c;
    }
    
    public class NamedExpression {
        public List<ExpressionData> expression;
    }
    
    public class ExpressionDetailData {
    	public String SVMXC_Expression_Rule_c;
    	public String SVMXC_Expression_Type_c;
    	public String SVMXC_Sequence_c;
    	public String SVMXC_Field_Name_c;
    	public String SVMXC_Operator_c;
    	public String SVMXC_Object_Name_c;
    	public String SVMXC_Operand_c;
    	public String SVMXC_Display_Type_c;
    	public String SVMXC_Object_Name2_c;
    	public String SVMXC_FKey_Name_Field_c;
    	public String SVMXC_Field_Relationship_Name_c;
    	public String SVMXC_Parameter_Type_c;
    	public String SVMXC_Internal_Value_c;
    	public String SVMXC_Source_Field_Name_c;
    }
    
    public class ExpressionDetail {
        public List<ExpressionDetailData> expressiondetail;
    }
    
    public class WOBillingData {
    	public String SVMXC_ProcessID_c;
    	public String SVMXC_Name_c;
    	public String SVMXC_Description_c;
    	public String SVMXC_Invoice_Scope_c;
    	public String SVMXC_Module_c;
    	public String SVMXC_Submodule_c;
    	public String SVMXC_Primary_Consolidation_Rule_c;
    	public String SVMXC_Secondary_Consolidation_Rule_c;
    	public String SVMXC_Tertiary_Consolidation_Rule_c;
    	public String SVMXC_Include_Product_c;
    	public String SVMXC_Node_Parent_c;
    	public String SVMXC_Process_c;
    	public String SVMXC_Capture_Log_c;
    	public String SVMXC_Email_On_Success_c;
    	public String SVMXC_Email_On_Error_c;
    	public String SVMXC_IsStandard_c;
    	public String SVMXC_Active_c;
    }
    
    public class WOBilling {
        public List<WOBillingData> wobilling;
    }
    
    public class ObjectMapData {
    	public String SVMXC_MAPID_C;
    	public String SVMXC_NAME_C;
    	public String SVMXC_DESCRIPTION_C;
    	public String SVMXC_SOURCE_OBJECT_NAME_C;
    	public String SVMXC_TARGET_OBJECT_NAME_C;
    	public String SVMXC_TARGET_RECORD_TYPE_C;
    	public String SVMXC_ISSTANDARD_C;
    	public String SVMXC_ACTIVE_C;
    }
    
    public class ObjectMapping {
        public List<ObjectMapData> objmapping;
    }
    
    public class FieldMapData {
    	public String SVMXC_MAPID_C;
    	public String SVMXC_SOURCE_FIELD_NAME_C;
    	public String SVMXC_TARGET_FIELD_NAME_C;
    	public String SVMXC_ACTIVE_C;
    	public String SVMXC_Parameter_Type_c;
    	public String SVMXC_Display_Value_c;
    	public String SVMXC_Preference_3_c;
    	public String SVMXC_Configuration_Type_c;
    	public String SVMXC_Preference_2_c;
    	public String SVMXC_ISDEFAULT_C;
    }
    
    public class FieldMapping {
        public List<FieldMapData> fieldmapping;
    }
    
    public class PmProcessData {
    	public String SVMXC_Name_c;
    	public String SVMXC_ProcessID_c;
    	public String SVMXC_Description_c;
    	public String SVMXC_Active_c;
    	public String SVMXC_Frequency_c;
    	public String SVMXC_Module_c;
    	public String SVMXC_Create_Work_Order_c;
    	public String SVMXC_Node_Parent_c;
    	public String SVMXC_Assign_Work_Order_To_c;
    	public String SVMXC_Assign_To_Service_Team_c;
    	public String SVMXC_Target_Object_Name_c;
    	public String SVMXC_Process1_c;
    	public String SVMXC_Process2_c;
    	public String SVMXC_Process3_c;
    	public String SVMXC_Include_Parent_c;
    	public String SVMXC_Process_c;
    	public String SVMXC_Assign_Case_To_c;
    	public String SVMXC_Case_Assign_To_User_c;
    	public String SVMXC_IsStandard_c;
    }
    
    public class PmProcess {
        public List<PmProcessData> pmprocess;
    }
    
    public class DcViewData {
    	public String SVMXC_Name_c;
    	public String SVMXC_ProcessID_c;
    	public String SVMXC_Description_c;
    	public String SVMXC_Source_Object_Name_c;
    	public String SVMXC_View_For_c;
    	public String SVMXC_Ownership_Type_c;
    	public String SVMXC_Parent_Object_Criteria_c;
    	public String SVMXC_Record_Type_Name_c;
    	public String SVMXC_Values_c;
    	public String SVMXC_Advance_Expression_c;
    	public String SVMXC_Rule_Type_c;
    	public String SVMXC_IsStandard_c;
    }
    
    public class DcView {
        public List<DcViewData> dcviews;
    }
    
    public class DcViewConfigData {
    	public String RecordTypeName;
    	public String SVMXC_Expression_Type_c;
    	public String SVMXC_Expression_Rule_c;
    	public String SVMXC_Field_Name_c;
    	public String SVMXC_Operator_c;
    	public String SVMXC_Operand_c;
    	public String SVMXC_Display_Type_c;
    	public String SVMXC_Sequence_c;
    	public String SVMXC_Object_Name_c;
    	public String SVMXC_FKey_Name_Field_c;
    	public String SVMXC_Object_Name2_c;
    	public String SVMXC_Lookup_Field_API_Name_c;
    	public String SVMXC_Field_Relationship_Name_c;
    	public String SVMXC_Ownership_Type_c;
    }
    
    public class DcViewConfig {
        public List<DcViewConfigData> dcviewconfigdata;
    }
    
    public class QuickBookConfigData {
    	public String SVMXC_Name_c;
    	public String SVMXC_ProcessID_c;
    	public String SVMXC_Export_Configuration_c;
    	public String SVMXC_IsDefault_c;
    	public String SVMXC_IsStandard_c;
    }
    
    public class QuickBookConfig {
        public List<QuickBookConfigData> quickbookconfiguration;
    }
    
    public class SmartObjectData {
    	public String SVMXC_Object_API_Name_c;
    	public String SVMXC_Object_Label_c;
    	public String SVMXC_Schema_c;
    	public String SVMXC_Description_c;
    }
    
    public class SmartObject {
        public List<SmartObjectData> smartobject;
    }
    public class CustomSettingValueData{
        public string SettingId;
        public String SettingValue;
        public string NewInternalValue;
    }
    public class CustomSettingValue{
        public List<CustomSettingValueData> customSettingValues;
    }
    public class APLReceiveReturnShipmentData{
        public String SVMXC_Name_c;
        public string SVMXC_ProcessID_c;
        public String SVMXC_Description_c;
        public String SVMXC_APL_Action_On_Unexpected_SN_c;
        public String SVMXC_APL_Action_On_Unexpected_Product_c;
        public String SVMXC_APL_Action_On_Excess_Qty_c;
        public String SVMXC_APL_Action_On_Less_Qty_c;
        public String SVMXC_APL_Create_Work_Order_On_c;
        public String SVMXC_APL_Group_Work_Order_By_c;
        public String SVMXC_APL_Serial_Number_Source_c;
        public String SVMXC_Parent_Error_Msg_c;
        public String SVMXC_Child_Error_Msg_c;
        public String SVMXC_Parent_Error_Msg2_c;
        public String SVMXC_Child_Error_Msg2_c;
        public String SVMXC_APL_Perform_Entitlement_c;
        public String SVMXC_Node_Parent_c;
        public String SVMXC_Submodule_c;
        public String SVMXC_Module_c;
        public String SVMXC_Final_Exception_Process_c;
        public String SVMXC_APL_Split_Lines_c;
        public String SVMXC_Parent_Object_c;
        public String SVMXC_Process_c;
        public String SVMXC_APL_Create_WO_Preference_c;
        public String SVMXC_IsStandard_c;
        public String SVMXC_APL_Perform_Route_Calculations_c;
        public String SVMXC_Consider_Location_From_Object_c;
        public String SVMXC_Consider_Location_From_c;
        public String SVMXC_Process1_c;
        public String SVMXC_Process2_c;
        public String SVMXC_APL_Print_RMA_Template_c;
    }
    public class APLReceiveValue{
        public List<APLReceiveReturnShipmentData> aplreceive;
    }
    public class APLReturnValue{
        public List<APLReceiveReturnShipmentData> aplreturn;
    }
    public class APLShipmentValue{
        public List<APLReceiveReturnShipmentData> aplshipment;
    }
    public class SourceUpdatesData{
        public String SVMXC_Dispatch_Process_c;
        public String SVMXC_Configuration_Type_c;
        public String SVMXC_Sequence_c;
        public String SVMXC_Field_Name_c;
        public String SVMXC_Action_c;
        public String SVMXC_Display_Value_c;
        public String SVMXC_Target_Field_Name_c;
        public String SVMXC_Field_Relationship_Name_c;
        public String SVMXC_Object_Name_c;
        public String SVMXC_FKey_Name_Field_c;
    }
    public class SourceUpdatesValue{
        public List<SourceUpdatesData> aplsourceupdates;
    }
    public class CustomSettingData {
        public String Name;
        public String SVMXC_Key_c;
        public String SVMXC_Value_c;
    }
    
    public class CustomSetting {
        public List<CustomSettingData> googleapicustomsettings;
    }
}