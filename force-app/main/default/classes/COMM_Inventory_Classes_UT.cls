@isTest(SeeAllData=true)
private class COMM_Inventory_Classes_UT{
    static testMethod void COMM_Inventory_Classes_UT(){
        try{
            SVMXC__ServiceMax_Processes__c oSVMXProcess = new SVMXC__ServiceMax_Processes__c();
            map<String, SVMXC__ServiceMax_Config_Data__c> mSetting = new map<String, SVMXC__ServiceMax_Config_Data__c>();
            boolean isNewProcess = true;
            test.startTest();
            string ProcessFields = 'id, Name, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ModuleId__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__Child_Object_Criteria__c, SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__Child_Error_Msg__c';
            list<SVMXC__ServiceMax_Processes__c> lstSVMXPro = database.query('select ' + ProcessFields + ' from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = \'PORD007\'');
            SVMXC__ServiceMax_Processes__c Inventory_Process = lstSVMXPro[0];
            SVMXC.COMM_Inventory_Classes plClasses = new SVMXC.COMM_Inventory_Classes();
            //Create Instance of InventoryProcess Class
            SVMXC.COMM_Inventory_Classes.InventoryProcess plClassesInvPro = new SVMXC.COMM_Inventory_Classes.InventoryProcess();
            SVMXC.COMM_Inventory_Classes.InventoryProcess plClassesInvPro1 = new SVMXC.COMM_Inventory_Classes.InventoryProcess(oSVMXProcess,mSetting,isNewProcess);
            SVMXC.COMM_Inventory_Classes.InventoryProcess plClassesInvPro2 = new SVMXC.COMM_Inventory_Classes.InventoryProcess(Inventory_Process,mSetting,false);
            
            //Members of Class
            plClassesInvPro.Allow_Partial_Closure = false;
            system.assert(plClassesInvPro.getAllow_Partial_Closure()==false,'getAllow_Partial_Closure assertion failed');
            plClassesInvPro.setAllow_Partial_Closure(plClassesInvPro.Allow_Partial_Closure);
            
            plClassesInvPro.Allow_Excess_Quantity = false;
            system.assert(plClassesInvPro.getAllow_Excess_Quantity()==false,'getAllow_Excess_Quantity assertion failed');
            plClassesInvPro.setAllow_Excess_Quantity(plClassesInvPro.Allow_Excess_Quantity);
            
            plClassesInvPro.Child_Object_RecordType = '';
            system.assert(plClassesInvPro.getChild_Object_RecordType()!=null,'getChild_Object_RecordType assertion failed');
            plClassesInvPro.setChild_Object_RecordType(plClassesInvPro.Child_Object_RecordType );
            
            plClassesInvPro.Enable_Bar_Code_Entry = false;
            system.assert(plClassesInvPro.getEnable_Bar_Code_Entry()==false,'getEnable_Bar_Code_Entry assertion failed');
            plClassesInvPro.setEnable_Bar_Code_Entry(plClassesInvPro.Enable_Bar_Code_Entry);
            
            plClassesInvPro.Number_of_locations = '';
            system.assert(plClassesInvPro.getNumber_of_locations()!=null,'getNumber_of_locations assertion failed');
            plClassesInvPro.setNumber_of_locations(plClassesInvPro.Number_of_locations);
            
            plClassesInvPro.Is_Email_Sent_To_Location_Owner = false;            
            system.assert(plClassesInvPro.getIs_Email_Sent_To_Location_Owner()==false,'getIs_Email_Sent_To_Location_Owner assertion failed');
            plClassesInvPro.setIs_Email_Sent_To_Location_Owner(plClassesInvPro.Is_Email_Sent_To_Location_Owner);
            
            plClassesInvPro.Email_For_Negative_Stock_Alert = '';
            system.assert(plClassesInvPro.getEmail_For_Negative_Stock_Alert()!=null,'getEmail_For_Negative_Stock_Alert assertion failed');
            plClassesInvPro.setEmail_For_Negative_Stock_Alert(plClassesInvPro.Email_For_Negative_Stock_Alert );
            
            plClassesInvPro.Enable_Serial_Selection = false;            
            system.assert(plClassesInvPro.getEnable_Serial_Selection()==false,'getEnable_Serial_Selection assertion failed');
            plClassesInvPro.setEnable_Serial_Selection(plClassesInvPro.Enable_Serial_Selection );
            
            plClassesInvPro.Maintain_Serial_History = false;            
            system.assert(plClassesInvPro.getMaintain_Serial_History()==false,'getMaintain_Serial_History assertion failed');
            plClassesInvPro.setMaintain_Serial_History(plClassesInvPro.Maintain_Serial_History );
            
            plClassesInvPro.Maintain_Stock_History = false;         
            system.assert(plClassesInvPro.getMaintain_Stock_History()==false,'getMaintain_Stock_History assertion failed');
            plClassesInvPro.setMaintain_Stock_History(plClassesInvPro.Maintain_Stock_History );
            
            plClassesInvPro.Enforce_Uniqueness_In_Serial_Selection = '';
            plClassesInvPro.getEnforce_Uniqueness_In_Serial_Selection();
            plClassesInvPro.setEnforce_Uniqueness_In_Serial_Selection(plClassesInvPro.Enforce_Uniqueness_In_Serial_Selection );
            
            plClassesInvPro.RelationShip_to_Source_Location = '';
            plClassesInvPro.getRelationShip_to_Source_Location();
            plClassesInvPro.setRelationShip_to_Source_Location(plClassesInvPro.RelationShip_to_Source_Location );
            
            plClassesInvPro.RelationShip_to_Target_Location = '';
            plClassesInvPro.getRelationShip_to_Target_Location();
            plClassesInvPro.setRelationShip_to_Target_Location(plClassesInvPro.RelationShip_to_Target_Location );
            
            plClassesInvPro.Is_Source_Location_From_Header = false;         
            system.assert(plClassesInvPro.getIs_Source_Location_From_Header()==false,'getIs_Source_Location_From_Header assertion failed');
            plClassesInvPro.setIs_Source_Location_From_Header(plClassesInvPro.Is_Source_Location_From_Header );
            
            plClassesInvPro.Is_Source_Location_Stockable = false;
            system.assert(plClassesInvPro.getIs_Source_Location_Stockable()==false,'getIs_Source_Location_Stockable assertion failed');
            plClassesInvPro.setIs_Source_Location_Stockable(plClassesInvPro.Is_Source_Location_Stockable );
            
            plClassesInvPro.Is_Target_Location_Stockable = false;
            system.assert(plClassesInvPro.getIs_Target_Location_Stockable()==false,'getIs_Target_Location_Stockable assertion failed');
            plClassesInvPro.setIs_Target_Location_Stockable(plClassesInvPro.Is_Target_Location_Stockable );
            
            plClassesInvPro.Is_Target_Location_From_Header = false;
            system.assert(plClassesInvPro.getIs_Target_Location_From_Header()==false,'getIs_Target_Location_From_Header assertion failed');
            plClassesInvPro.setIs_Target_Location_From_Header(plClassesInvPro.Is_Target_Location_From_Header );
            
            plClassesInvPro.Parent_Object_Criteria = '';
            plClassesInvPro.getParent_Object_Criteria();
            plClassesInvPro.setParent_Object_Criteria(plClassesInvPro.Parent_Object_Criteria );
            
            plClassesInvPro.Child_Object_Criteria = '';
            plClassesInvPro.getChild_Object_Criteria();
            plClassesInvPro.setChild_Object_Criteria(plClassesInvPro.Child_Object_Criteria );
            
            plClassesInvPro.Stock_History_Header_API_Name = '';
            plClassesInvPro.getStock_History_Header_API_Name();
            plClassesInvPro.setStock_History_Header_API_Name(plClassesInvPro.Stock_History_Header_API_Name );
            
            plClassesInvPro.Stock_History_Line_API_Name = '';
            plClassesInvPro.getStock_History_Line_API_Name();
            plClassesInvPro.setStock_History_Line_API_Name(plClassesInvPro.Stock_History_Line_API_Name );
            
            plClassesInvPro.Target_Status = '';
            plClassesInvPro.getTarget_Status();
            plClassesInvPro.setTarget_Status(plClassesInvPro.Target_Status );
            
            plClassesInvPro.Target_Location_From = '';
            plClassesInvPro.getTarget_Location_From();
            plClassesInvPro.setTarget_Location_From(plClassesInvPro.Target_Location_From );
            
            plClassesInvPro.Target_Location_API_Name = '';
            plClassesInvPro.getTarget_Location_API_Name();
            plClassesInvPro.setTarget_Location_API_Name(plClassesInvPro.Target_Location_API_Name );
            
            plClassesInvPro.Target_Action = '';
            plClassesInvPro.getTarget_Action();
            plClassesInvPro.setTarget_Action(plClassesInvPro.Target_Action );
            
            plClassesInvPro.Source_Status = '';
            plClassesInvPro.getSource_Status();
            plClassesInvPro.setSource_Status(plClassesInvPro.Source_Status );
            
            plClassesInvPro.Source_Location_From = '';
            plClassesInvPro.getSource_Location_From();
            plClassesInvPro.setSource_Location_From(plClassesInvPro.Source_Location_From );
            
            plClassesInvPro.Source_Location_API_Name = '';
            plClassesInvPro.getSource_Location_API_Name();
            plClassesInvPro.setSource_Location_API_Name(plClassesInvPro.Source_Location_API_Name );
            
            plClassesInvPro.Source_Action = '';
            plClassesInvPro.getSource_Action();
            plClassesInvPro.setSource_Action(plClassesInvPro.Source_Action );
            
            plClassesInvPro.RelationShip_Name_to_Product = '';
            plClassesInvPro.getRelationShip_Name_to_Product();
            plClassesInvPro.setRelationShip_Name_to_Product(plClassesInvPro.RelationShip_Name_to_Product );
            
            plClassesInvPro.RelationShip_Name_to_Parent = '';
            plClassesInvPro.getRelationShip_Name_to_Parent();
            plClassesInvPro.setRelationShip_Name_to_Parent(plClassesInvPro.RelationShip_Name_to_Parent );
            
            plClassesInvPro.Related_Product_Field = '';
            plClassesInvPro.getRelated_Product_Field();
            plClassesInvPro.setRelated_Product_Field(plClassesInvPro.Related_Product_Field );
            
            plClassesInvPro.Original_Qty_API_Name = '';
            plClassesInvPro.getOriginal_Qty_API_Name();
            plClassesInvPro.setOriginal_Qty_API_Name(plClassesInvPro.Original_Qty_API_Name );
            
            plClassesInvPro.Actual_Qty_API_Name = '';
            plClassesInvPro.getActual_Qty_API_Name();
            plClassesInvPro.setActual_Qty_API_Name(plClassesInvPro.Actual_Qty_API_Name );
            
            plClassesInvPro.Product_Field_API_Name = '';
            plClassesInvPro.getProduct_Field_API_Name();
            plClassesInvPro.setProduct_Field_API_Name(plClassesInvPro.Product_Field_API_Name );
            
            plClassesInvPro.Parent_Object_Name = '';
            plClassesInvPro.getParent_Object_Name();
            plClassesInvPro.setParent_Object_Name(plClassesInvPro.Parent_Object_Name );
            
            plClassesInvPro.Lookup_Field_to_Parent = '';
            plClassesInvPro.getLookup_Field_to_Parent();
            plClassesInvPro.setLookup_Field_to_Parent(plClassesInvPro.Lookup_Field_to_Parent );
            
            plClassesInvPro.Is_User_Enter_Qty = false;
            plClassesInvPro.getIs_User_Enter_Qty();
            plClassesInvPro.setIs_User_Enter_Qty(plClassesInvPro.Is_User_Enter_Qty );
            
            plClassesInvPro.Is_Multiline_Transaction = false;
            plClassesInvPro.getIs_Multiline_Transaction();
            plClassesInvPro.setIs_Multiline_Transaction(plClassesInvPro.Is_Multiline_Transaction );
            
            plClassesInvPro.Child_Object_Name = '';
            plClassesInvPro.getChild_Object_Name();
            plClassesInvPro.setChild_Object_Name(plClassesInvPro.Child_Object_Name );
            
            plClassesInvPro.Allow_Partial_Quantity = false;
            plClassesInvPro.getAllow_Partial_Quantity();
            plClassesInvPro.setAllow_Partial_Quantity(plClassesInvPro.Allow_Partial_Quantity );
                            
            plClassesInvPro.IsStandard = false;
            plClassesInvPro.getIsStandard();
            
            plClassesInvPro.Parent_Advanced_Option = '';
            plClassesInvPro.getParent_Advanced_Option();
            plClassesInvPro.setParent_Advanced_Option(plClassesInvPro.Parent_Advanced_Option );
            
            plClassesInvPro.Child_Advanced_Option = '';
            plClassesInvPro.getChild_Advanced_Option();
            plClassesInvPro.setChild_Advanced_Option(plClassesInvPro.Child_Advanced_Option );
                            
            plClassesInvPro.Module = '';
            plClassesInvPro.getModule();
            system.assert(plClassesInvPro.getModule()!=null,'getModule assertion failed');
            plClassesInvPro.setModule(plClassesInvPro.Module );
                                
            plClassesInvPro.Submodule = '';         
            system.assert(plClassesInvPro.getSubmodule()!=null,'getSubmodule() assertion failed');          
            plClassesInvPro.setSubmodule(plClassesInvPro.Submodule );
                            
            plClassesInvPro.ModuleId = '';      
            system.assert(plClassesInvPro.getModuleId()!=null,'getModuleId assertion failed');          
            plClassesInvPro.setModuleId(plClassesInvPro.ModuleId );
                                
            plClassesInvPro.SubmoduleId = '';           
            system.assert(plClassesInvPro.getSubmoduleId()!=null,'getSubmoduleId assertion failed');            
            plClassesInvPro.setSubmoduleId(plClassesInvPro.SubmoduleId );
                            
            plClassesInvPro.ProcessID = '';         
            system.assert(plClassesInvPro.getProcessID()!=null,'getProcessID assertion failed');            
            plClassesInvPro.setProcessID(plClassesInvPro.ProcessID );
            
            plClassesInvPro.Name = '';          
            system.assert(plClassesInvPro.getName()!=null,'getName assertion failed');          
            plClassesInvPro.setName(plClassesInvPro.Name );
            
            plClassesInvPro.Description = '';
            plClassesInvPro.getDescription();
            plClassesInvPro.setDescription(plClassesInvPro.Description );
            
            plClassesInvPro.putValueInMap(mSetting, 'STR', 'STR');
            plClassesInvPro.IsValidValue(mSetting, 'STR');
            plClassesInvPro.getBooleanfromString('STR');
            plClassesInvPro.getStringfromBoolean(true);
            
            //Create Instance of InventoryProcessResult Class
            SVMXC.COMM_Inventory_Classes.InventoryProcessResult plClassesInvResults = new SVMXC.COMM_Inventory_Classes.InventoryProcessResult();
            test.stopTest();
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }       
    }
}