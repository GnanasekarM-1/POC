public with sharing class COMM_Inventory_Classes 
{
    public class InventoryProcess
    {
        public boolean Allow_Partial_Closure = false;
            public boolean getAllow_Partial_Closure(){return this.Allow_Partial_Closure;}
            public void setAllow_Partial_Closure(boolean b){this.Allow_Partial_Closure = b;}
          
        public boolean Allow_Excess_Quantity = false;
            public boolean getAllow_Excess_Quantity(){return this.Allow_Excess_Quantity;}
            public void setAllow_Excess_Quantity(boolean str){this.Allow_Excess_Quantity = str;}
          
        public string Child_Object_RecordType = '';
            public string getChild_Object_RecordType(){return this.Child_Object_RecordType;}
            public void setChild_Object_RecordType(string str){this.Child_Object_RecordType = str;}
          
        public boolean Enable_Bar_Code_Entry = false;
            public boolean getEnable_Bar_Code_Entry(){return this.Enable_Bar_Code_Entry;}
            public void setEnable_Bar_Code_Entry(boolean str){this.Enable_Bar_Code_Entry = str;}
          
        public string Number_of_locations = '';
            public string getNumber_of_locations(){return this.Number_of_locations;}
            public void setNumber_of_locations(string str){this.Number_of_locations = str;}
          
        public boolean Is_Email_Sent_To_Location_Owner = false;
            public boolean getIs_Email_Sent_To_Location_Owner(){return this.Is_Email_Sent_To_Location_Owner;}
            public void setIs_Email_Sent_To_Location_Owner(boolean str){this.Is_Email_Sent_To_Location_Owner = str;}
          
        public string Email_For_Negative_Stock_Alert = '';
            public string getEmail_For_Negative_Stock_Alert(){return this.Email_For_Negative_Stock_Alert;}
            public void setEmail_For_Negative_Stock_Alert(string str){this.Email_For_Negative_Stock_Alert = str;}
          
        public boolean Enable_Serial_Selection = false;
            public boolean getEnable_Serial_Selection(){return this.Enable_Serial_Selection;}
            public void setEnable_Serial_Selection(boolean str){this.Enable_Serial_Selection = str;}
          
        public boolean Maintain_Serial_History = false;
            public boolean getMaintain_Serial_History(){return this.Maintain_Serial_History;}
            public void setMaintain_Serial_History(boolean str){this.Maintain_Serial_History = str;}
           
        public boolean Maintain_Stock_History = false;
            public boolean getMaintain_Stock_History(){return this.Maintain_Stock_History;}
            public void setMaintain_Stock_History(boolean str){this.Maintain_Stock_History = str;}
           
        public string Enforce_Uniqueness_In_Serial_Selection = '';
            public string getEnforce_Uniqueness_In_Serial_Selection(){return this.Enforce_Uniqueness_In_Serial_Selection;}
            public void setEnforce_Uniqueness_In_Serial_Selection(string str){if(str == 'SVMX.NONE') str = ''; this.Enforce_Uniqueness_In_Serial_Selection = str;}
           
        public string RelationShip_to_Source_Location = '';
            public string getRelationShip_to_Source_Location(){return this.RelationShip_to_Source_Location;}
            public void setRelationShip_to_Source_Location(string str){this.RelationShip_to_Source_Location = str;}
           
        public string RelationShip_to_Target_Location = '';
            public string getRelationShip_to_Target_Location(){return this.RelationShip_to_Target_Location;}
            public void setRelationShip_to_Target_Location(string str){this.RelationShip_to_Target_Location = str;}
           
        public boolean Is_Source_Location_From_Header = false;
            public boolean getIs_Source_Location_From_Header(){return this.Is_Source_Location_From_Header;}
            public void setIs_Source_Location_From_Header(boolean str){this.Is_Source_Location_From_Header = str;}
        
        public boolean Is_Source_Location_Stockable = false;
            public boolean getIs_Source_Location_Stockable(){return this.Is_Source_Location_Stockable;}
            public void setIs_Source_Location_Stockable(boolean str){this.Is_Source_Location_Stockable = str;}
        
        public boolean Is_Target_Location_Stockable = false;
            public boolean getIs_Target_Location_Stockable(){return this.Is_Target_Location_Stockable;}
            public void setIs_Target_Location_Stockable(boolean str){this.Is_Target_Location_Stockable = str;}
            
        public boolean Is_Target_Location_From_Header = false;
            public boolean getIs_Target_Location_From_Header(){return this.Is_Target_Location_From_Header;}
            public void setIs_Target_Location_From_Header(boolean str){this.Is_Target_Location_From_Header = str;}
           
        public string Parent_Object_Criteria = '';
            public string getParent_Object_Criteria(){return this.Parent_Object_Criteria;}
            public void setParent_Object_Criteria(string str){this.Parent_Object_Criteria = str;}
           
        public string Child_Object_Criteria = '';
            public string getChild_Object_Criteria(){return this.Child_Object_Criteria;}
            public void setChild_Object_Criteria(string str){this.Child_Object_Criteria = str;}
           
        public string Stock_History_Header_API_Name = '';
            public string getStock_History_Header_API_Name(){return this.Stock_History_Header_API_Name;}
            public void setStock_History_Header_API_Name(string str){this.Stock_History_Header_API_Name = str;}
           
        public string Stock_History_Line_API_Name = '';
            public string getStock_History_Line_API_Name(){return this.Stock_History_Line_API_Name;}
            public void setStock_History_Line_API_Name(string str){this.Stock_History_Line_API_Name = str;}
           
        public string Target_Status = '';
            public string getTarget_Status(){return this.Target_Status;}
            public void setTarget_Status(string str){this.Target_Status = str;}
           
        public string Target_Location_From = '';
            public string getTarget_Location_From(){return this.Target_Location_From;}
            public void setTarget_Location_From(string str){this.Target_Location_From = str;}
           
        public string Target_Location_API_Name = '';
            public string getTarget_Location_API_Name(){return this.Target_Location_API_Name;}
            public void setTarget_Location_API_Name(string str){this.Target_Location_API_Name = str;}
           
        public string Target_Action = '';
            public string getTarget_Action(){return this.Target_Action;}
            public void setTarget_Action(string str){this.Target_Action = str;}
           
        public string Source_Status = '';
            public string getSource_Status(){return this.Source_Status;}
            public void setSource_Status(string str){this.Source_Status = str;}
           
        public string Source_Location_From = '';
            public string getSource_Location_From(){return this.Source_Location_From;}
            public void setSource_Location_From(string str){this.Source_Location_From = str;}
           
        public string Source_Location_API_Name = '';
            public string getSource_Location_API_Name(){return this.Source_Location_API_Name;}
            public void setSource_Location_API_Name(string str){this.Source_Location_API_Name = str;}
           
        public string Source_Action = '';
            public string getSource_Action(){return this.Source_Action;}
            public void setSource_Action(string str){this.Source_Action = str;}
           
        public string RelationShip_Name_to_Product = '';
            public string getRelationShip_Name_to_Product(){return this.RelationShip_Name_to_Product;}
            public void setRelationShip_Name_to_Product(string str){this.RelationShip_Name_to_Product = str;}
           
        public string RelationShip_Name_to_Parent = '';
            public string getRelationShip_Name_to_Parent(){return this.RelationShip_Name_to_Parent;}
            public void setRelationShip_Name_to_Parent(string str){this.RelationShip_Name_to_Parent = str;}
           
        public string Related_Product_Field = '';
            public string getRelated_Product_Field(){return this.Related_Product_Field;}
            public void setRelated_Product_Field(string str){this.Related_Product_Field = str;}
           
        public string Original_Qty_API_Name = '';
            public string getOriginal_Qty_API_Name(){return this.Original_Qty_API_Name;}
            public void setOriginal_Qty_API_Name(string str){this.Original_Qty_API_Name = str;}
           
        public string Actual_Qty_API_Name = '';
            public string getActual_Qty_API_Name(){return this.Actual_Qty_API_Name;}
            public void setActual_Qty_API_Name(string str){this.Actual_Qty_API_Name = str;}
           
        public string Product_Field_API_Name = '';
            public string getProduct_Field_API_Name(){return this.Product_Field_API_Name;}
            public void setProduct_Field_API_Name(string str){this.Product_Field_API_Name = str;}
           
        public string Parent_Object_Name = '';
            public string getParent_Object_Name(){return this.Parent_Object_Name;}
            public void setParent_Object_Name(string str){this.Parent_Object_Name = str;}
           
        public string Lookup_Field_to_Parent = '';
            public string getLookup_Field_to_Parent(){return this.Lookup_Field_to_Parent;}
            public void setLookup_Field_to_Parent(string str){this.Lookup_Field_to_Parent = str;}
           
        public boolean Is_User_Enter_Qty = false;
            public boolean getIs_User_Enter_Qty(){return this.Is_User_Enter_Qty;}
            public void setIs_User_Enter_Qty(boolean b){this.Is_User_Enter_Qty = b;}
           
        public boolean Is_Multiline_Transaction = false;
            public boolean getIs_Multiline_Transaction(){return this.Is_Multiline_Transaction;}
            public void setIs_Multiline_Transaction(boolean b){this.Is_Multiline_Transaction = b;}
           
        public string Child_Object_Name = '';
            public string getChild_Object_Name(){return this.Child_Object_Name;}
            public void setChild_Object_Name(string str){this.Child_Object_Name = str;}
           
        public boolean Allow_Partial_Quantity = false;
            public boolean getAllow_Partial_Quantity(){return this.Allow_Partial_Quantity;}
            public void setAllow_Partial_Quantity(boolean b){this.Allow_Partial_Quantity = b;}
        
        public boolean IsStandard = false;
            public boolean getIsStandard(){return this.IsStandard;}
            
        public string Parent_Advanced_Option = '';
            public string getParent_Advanced_Option(){return this.Parent_Advanced_Option;}
            public void setParent_Advanced_Option(string str){this.Parent_Advanced_Option = str;}
        
        public string Child_Advanced_Option = '';
            public string getChild_Advanced_Option(){return this.Child_Advanced_Option;}
            public void setChild_Advanced_Option(string str){this.Child_Advanced_Option = str;}
        
        public string Module = '';
            public string getModule(){return this.Module;}
            public void setModule(string str){this.Module = str;}
            
        public string Submodule = '';
            public string getSubmodule(){return this.Submodule;}
            public void setSubmodule(string str){this.Submodule = str;}
        
        public string ModuleId = '';
            public string getModuleId(){return this.ModuleId;}
            public void setModuleId(String str){this.ModuleId = str;}
            
        public String SubmoduleId = '';
            public String getSubmoduleId(){return this.SubmoduleId;}
            public void setSubmoduleId(String str){this.SubmoduleId = str;}
        
        public string ProcessID = '';
            public string getProcessID(){return this.ProcessID;}
            public void setProcessID(string str){this.ProcessID = str;}
        
        public string Name = '';
            public string getName(){return this.Name;}
            public void setName(string str){this.Name = str;}
        
        public string Description = '';
            public string getDescription(){return this.Description;}
            public void setDescription(string str){this.Description = str;}
            
       public string Child_Error_Msg = '';
            public string getChild_Error_Msg(){return this.Child_Error_Msg;}
            public void setChild_Error_Msg(string str){this.Child_Error_Msg = str;}
       
       public string Parent_Error_Msg = '';
            public string getParent_Error_Msg(){return this.Parent_Error_Msg;}
            public void setParent_Error_Msg(string str){this.Parent_Error_Msg = str;}          
        
         public string SerialNumberFieldAPIName = '';
            public string getSerialNumberFieldAPIName(){return this.SerialNumberFieldAPIName;}
            public void setSerialNumberFieldAPIName(string str){this.SerialNumberFieldAPIName = str;} 
            
         public string StockResultUpdateFieldAPIName = '';
            public string getStockResultUpdateFieldAPIName(){return this.StockResultUpdateFieldAPIName;}
            public void setStockResultUpdateFieldAPIName(string str){this.StockResultUpdateFieldAPIName = str;} 
        
        //Start - Jaysukh Added two new setting value retrieval For New Invetory Engine : GBL002 setting 
        public Boolean allow_inventory_withoutSufficientStock = false;
        public Boolean getAllow_Inventory_withoutSufficientStock(){return this.allow_inventory_withoutSufficientStock;}
        public void setAllow_inventory_withoutSufficientStock(boolean b){this.allow_inventory_withoutSufficientStock = b;}
        
        /*public String statusConsiderationForUniqueness = '';
        public string getStatusConsiderationForUniqueness(){return this.statusConsiderationForUniqueness;}
        public void setStatusConsiderationForUniqueness(string str){this.statusConsiderationForUniqueness = str;} */
        //End - Jaysukh 
        
        //Added for BAC-5625
        /* Commented as part of BAC-6042
        public Boolean Is_ManuallyEntryFor_Batch = false;
        public Boolean getIs_ManuallyEntryFor_Batch(){return this.Is_ManuallyEntryFor_Batch;}
        public void setIs_ManuallyEntryFor_Batch(Boolean str){this.Is_ManuallyEntryFor_Batch = str;} */

        public Boolean Is_InactiveBatch_Supported = false;
        public Boolean getIs_InactiveBatch_Supported(){return this.Is_InactiveBatch_Supported;}
        public void setIs_InactiveBatch_Supported(Boolean str){this.Is_InactiveBatch_Supported = str;} 
        //End for BAC-5625
        //Constructor   
        public InventoryProcess()
        {
            
        }
        public SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c(); //Added public for BAC-5665
        map<String, SVMXC__ServiceMax_Config_Data__c> mapSetting = new map<String, SVMXC__ServiceMax_Config_Data__c>();
        
        public InventoryProcess(SVMXC__ServiceMax_Processes__c oSVMXProcess, map<String, SVMXC__ServiceMax_Config_Data__c> mSetting, boolean isNewProcess)
        {
            if(isNewProcess) 
            {
                SVMXProcess = oSVMXProcess;
                SVMXProcess.SVMXC__Parent_Object_Criteria__c = '';
                SVMXProcess.SVMXC__Child_Object_Criteria__c = '';
                SVMXProcess.SVMXC__Module__c = null;
                SVMXProcess.SVMXC__Submodule__c  = null;
                SVMXProcess.SVMXC__ProcessID__c = '';
                SVMXProcess.SVMXC__Name__c = '';
                SVMXProcess.SVMXC__Description__c = '';
                SVMXProcess.SVMXC__IsStandard__c =  false;
                SVMXProcess.SVMXC__Parent_Error_Msg__c = '';
                SVMXProcess.SVMXC__Child_Error_Msg__c = '';
             }
            if(!isNewProcess && oSVMXProcess != null) 
            {
                SVMXProcess = oSVMXProcess;
                this.Parent_Object_Criteria = SVMXProcess.SVMXC__Parent_Object_Criteria__c;
                this.Child_Object_Criteria = SVMXProcess.SVMXC__Child_Object_Criteria__c;
                this.Module = SVMXProcess.SVMXC__Module__c;
                this.Submodule = SVMXProcess.SVMXC__Submodule__c;
                this.ModuleId = SVMXProcess.SVMXC__Module__r.SVMXC__ModuleId__c;
                this.SubmoduleId = SVMXProcess.SVMXC__Submodule__r.SVMXC__SubmoduleId__c;
                this.ProcessID = SVMXProcess.SVMXC__ProcessID__c;
                this.Name = SVMXProcess.SVMXC__Name__c;
                this.Description = SVMXProcess.SVMXC__Description__c;
                this.IsStandard = SVMXProcess.SVMXC__IsStandard__c;
                this.Parent_Error_Msg = SVMXProcess.SVMXC__Parent_Error_Msg__c;
                this.Child_Error_Msg  = SVMXProcess.SVMXC__Child_Error_Msg__c;
            }
            if(mSetting != null && mSetting.size() > 0)
                mapSetting.putAll(mSetting);
            if(!isNewProcess && mSetting != null && mSetting.size() > 0)
            {
                if(IsValidValue(mSetting, 'SET001'))     
                     this.Actual_Qty_API_Name = mapSetting.get('SET001').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET002'))     
                     this.Allow_Excess_Quantity = getBooleanfromString(mapSetting.get('SET002').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET003'))     
                     this.Allow_Partial_Closure = getBooleanfromString(mapSetting.get('SET003').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET004'))     
                     this.Allow_Partial_Quantity = getBooleanfromString(mapSetting.get('SET004').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET005'))     
                     this.Child_Advanced_Option = mapSetting.get('SET005').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET006'))     
                     this.Child_Object_Name = mapSetting.get('SET006').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET007'))     
                     this.Child_Object_RecordType = mapSetting.get('SET007').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET008'))     
                     this.Email_For_Negative_Stock_Alert = mapSetting.get('SET008').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET009'))     
                     this.Enable_Bar_Code_Entry = getBooleanfromString(mapSetting.get('SET009').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET010'))     
                     this.Enable_Serial_Selection = getBooleanfromString(mapSetting.get('SET010').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET011'))     
                     this.Enforce_Uniqueness_In_Serial_Selection = mapSetting.get('SET011').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET012'))     
                     this.Is_Email_Sent_To_Location_Owner = getBooleanfromString(mapSetting.get('SET012').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET013'))     
                     this.Is_Multiline_Transaction = getBooleanfromString(mapSetting.get('SET013').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET014'))     
                     this.Is_Source_Location_From_Header = getBooleanfromString(mapSetting.get('SET014').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET015'))     
                     this.Is_Source_Location_Stockable = getBooleanfromString(mapSetting.get('SET015').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET016'))     
                     this.Is_Target_Location_From_Header = getBooleanfromString(mapSetting.get('SET016').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET017'))     
                     this.Is_Target_Location_Stockable = getBooleanfromString(mapSetting.get('SET017').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET018'))     
                     this.Is_User_Enter_Qty = getBooleanfromString(mapSetting.get('SET018').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET019'))     
                     this.Lookup_Field_to_Parent = mapSetting.get('SET019').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET020'))     
                     this.Maintain_Serial_History = getBooleanfromString(mapSetting.get('SET020').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET021'))     
                     this.Maintain_Stock_History = getBooleanfromString(mapSetting.get('SET021').SVMXC__Internal_Value__c);
                if(IsValidValue(mSetting, 'SET022'))     
                     this.Number_of_locations = mapSetting.get('SET022').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET023'))     
                     this.Original_Qty_API_Name = mapSetting.get('SET023').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET024'))     
                     this.Parent_Advanced_Option = mapSetting.get('SET024').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET025'))     
                     this.Parent_Object_Name = mapSetting.get('SET025').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET026'))     
                     this.Product_Field_API_Name = mapSetting.get('SET026').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET027'))     
                     this.Related_Product_Field = mapSetting.get('SET027').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET028'))     
                     this.RelationShip_Name_to_Parent = mapSetting.get('SET028').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET029'))     
                     this.RelationShip_Name_to_Product = mapSetting.get('SET029').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET030'))     
                     this.RelationShip_to_Source_Location = mapSetting.get('SET030').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET031'))     
                     this.RelationShip_to_Target_Location = mapSetting.get('SET031').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET032'))     
                     this.Source_Action = mapSetting.get('SET032').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET033'))     
                     this.Source_Location_API_Name = mapSetting.get('SET033').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET034'))     
                     this.Source_Status = mapSetting.get('SET034').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET035'))     
                     this.Stock_History_Header_API_Name = mapSetting.get('SET035').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET036'))     
                     this.Stock_History_Line_API_Name = mapSetting.get('SET036').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET037'))     
                     this.Target_Action = mapSetting.get('SET037').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET038'))     
                     this.Target_Location_API_Name = mapSetting.get('SET038').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET039'))     
                     this.Target_Status = mapSetting.get('SET039').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET040'))     
                    this.SerialNumberFieldAPIName = mapSetting.get('SET040').SVMXC__Internal_Value__c;
                if(IsValidValue(mSetting, 'SET041'))     
                    this.StockResultUpdateFieldAPIName = mapSetting.get('SET041').SVMXC__Internal_Value__c; 
                //Added for BAC-5625
                /*if(IsValidValue(mSetting, 'SET042')) Commented as part of BAC-6042    
                    this.Is_ManuallyEntryFor_Batch = getBooleanfromString(mapSetting.get('SET042').SVMXC__Internal_Value__c); */
                if(IsValidValue(mSetting, 'SET043'))     
                    this.Is_InactiveBatch_Supported = getBooleanfromString(mapSetting.get('SET043').SVMXC__Internal_Value__c); 
                //End for BAC-5625  
                //Jaysukh Start Added for new invetory engine
                 if(IsValidValue(mSetting, 'GBL002'))
                  this.allow_inventory_withoutSufficientStock = getBooleanfromString(mapSetting.get('GBL002').SVMXC__Internal_Value__c);
                /* if(IsValidValue(mSetting, 'GBL004'))
                    this.statusConsiderationForUniqueness = mapSetting.get('GBL004').SVMXC__Internal_Value__c; */
                //Jaysukh End
            }
        }
        public InventoryProcessResult SVMX_getInventoryProcess()
        {
            if(SVMXProcess != null)
            {
                SVMXProcess.SVMXC__Parent_Object_Criteria__c = this.Parent_Object_Criteria ;
                SVMXProcess.SVMXC__Child_Object_Criteria__c = this.Child_Object_Criteria;
                SVMXProcess.SVMXC__Module__c = this.Module;
                SVMXProcess.SVMXC__Submodule__c = this.Submodule;
                SVMXProcess.SVMXC__ProcessID__c = this.ProcessID;
                SVMXProcess.SVMXC__Name__c = this.Name;
                SVMXProcess.SVMXC__Description__c = this.Description;
                SVMXProcess.SVMXC__IsStandard__c = this.IsStandard;
                SVMXProcess.SVMXC__Parent_Error_Msg__c = this.Parent_Error_Msg;
                SVMXProcess.SVMXC__Child_Error_Msg__c = this.Child_Error_Msg;
            }
            if(mapSetting != null && mapSetting.size() > 0)
            {
                putValueInMap(mapSetting, 'SET001', this.Actual_Qty_API_Name);
                putValueInMap(mapSetting, 'SET002', getStringfromBoolean(this.Allow_Excess_Quantity));
                putValueInMap(mapSetting, 'SET003', getStringfromBoolean(this.Allow_Partial_Closure));
                putValueInMap(mapSetting, 'SET004', getStringfromBoolean(this.Allow_Partial_Quantity));
                putValueInMap(mapSetting, 'SET005', this.Child_Advanced_Option);
                putValueInMap(mapSetting, 'SET006', this.Child_Object_Name);
                putValueInMap(mapSetting, 'SET007', this.Child_Object_RecordType);
                putValueInMap(mapSetting, 'SET008', this.Email_For_Negative_Stock_Alert);
                putValueInMap(mapSetting, 'SET009', getStringfromBoolean(this.Enable_Bar_Code_Entry));
                putValueInMap(mapSetting, 'SET010', getStringfromBoolean(this.Enable_Serial_Selection));
                putValueInMap(mapSetting, 'SET011', this.Enforce_Uniqueness_In_Serial_Selection);
                putValueInMap(mapSetting, 'SET012', getStringfromBoolean(this.Is_Email_Sent_To_Location_Owner));
                putValueInMap(mapSetting, 'SET013', getStringfromBoolean(this.Is_Multiline_Transaction));
                putValueInMap(mapSetting, 'SET014', getStringfromBoolean(this.Is_Source_Location_From_Header));
                putValueInMap(mapSetting, 'SET015', getStringfromBoolean(this.Is_Source_Location_Stockable));
                putValueInMap(mapSetting, 'SET016', getStringfromBoolean(this.Is_Target_Location_From_Header));
                putValueInMap(mapSetting, 'SET017', getStringfromBoolean(this.Is_Target_Location_Stockable));
                putValueInMap(mapSetting, 'SET018', getStringfromBoolean(this.Is_User_Enter_Qty));
                putValueInMap(mapSetting, 'SET019', this.Lookup_Field_to_Parent);
                putValueInMap(mapSetting, 'SET020', getStringfromBoolean(this.Maintain_Serial_History));
                putValueInMap(mapSetting, 'SET021', getStringfromBoolean(this.Maintain_Stock_History));
                putValueInMap(mapSetting, 'SET022', this.Number_of_locations);
                putValueInMap(mapSetting, 'SET023', this.Original_Qty_API_Name);
                putValueInMap(mapSetting, 'SET024', this.Parent_Advanced_Option);
                putValueInMap(mapSetting, 'SET025', this.Parent_Object_Name);
                putValueInMap(mapSetting, 'SET026', this.Product_Field_API_Name);
                putValueInMap(mapSetting, 'SET027', this.Related_Product_Field);
                putValueInMap(mapSetting, 'SET028', this.RelationShip_Name_to_Parent);
                putValueInMap(mapSetting, 'SET029', this.RelationShip_Name_to_Product);
                putValueInMap(mapSetting, 'SET030', this.RelationShip_to_Source_Location);
                putValueInMap(mapSetting, 'SET031', this.RelationShip_to_Target_Location);
                putValueInMap(mapSetting, 'SET032', this.Source_Action);
                putValueInMap(mapSetting, 'SET033', this.Source_Location_API_Name);
                putValueInMap(mapSetting, 'SET034', this.Source_Status);
                putValueInMap(mapSetting, 'SET035', this.Stock_History_Header_API_Name);
                putValueInMap(mapSetting, 'SET036', this.Stock_History_Line_API_Name);
                putValueInMap(mapSetting, 'SET037', this.Target_Action);
                putValueInMap(mapSetting, 'SET038', this.Target_Location_API_Name);
                putValueInMap(mapSetting, 'SET039', this.Target_Status);
                putValueInMap(mapSetting, 'SET040', this.SerialNumberFieldAPIName);
                putValueInMap(mapSetting, 'SET041', this.StockResultUpdateFieldAPIName);
                //putValueInMap(mapSetting, 'SET042', getStringfromBoolean(this.Is_ManuallyEntryFor_Batch)); //Added for BAC-5625 Commented as part of BAC-6042
                putValueInMap(mapSetting, 'SET043', getStringfromBoolean(this.Is_InactiveBatch_Supported)); //Added for BAC-5625
            }
                return new InventoryProcessResult( SVMXProcess, mapSetting);
        }
        public void putValueInMap(map<String, SVMXC__ServiceMax_Config_Data__c> m, string strKey, string strValue)
        {
            if(m.containsKey(strKey) && mapSetting.get(strKey) != null)
            {
                if(strValue != 'SVMX.NONE')
                    mapSetting.get(strKey).put('SVMXC__Internal_Value__c', strValue);
                else 
                    mapSetting.get(strKey).put('SVMXC__Internal_Value__c', null);
            }
        }
        public boolean IsValidValue(map<String, SVMXC__ServiceMax_Config_Data__c> m, string strKey)
        {
            if(m != null && m.containsKey(strKey) && m.get(strKey) != null)
                return true;
            return false;
        }
        public boolean getBooleanfromString(String str)
        {
            if(str != null && str.ToUpperCase() == 'TRUE')
                return true;
            else 
                return false;
        }
        public string getStringfromBoolean(Boolean b)
        {
            if(b != null && b)
                return 'TRUE';
            else if (b != null && !b)
                return 'FALSE';
            return null;
        }
    }
    public class InventoryProcessResult
    {
        public SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c(); 
        public map<String, SVMXC__ServiceMax_Config_Data__c> mapSetting = new map<String, SVMXC__ServiceMax_Config_Data__c>();
        public InventoryProcessResult(SVMXC__ServiceMax_Processes__c oSVMXProcess, map<String, SVMXC__ServiceMax_Config_Data__c> mSetting)
        {
            SVMXProcess = oSVMXProcess;
            mapSetting = mSetting;
        }
        //Constructor
        public InventoryProcessResult() {} 
    }
}