public class SVMXC_CreateWarrantyClass{

//to avaoid infinite loops
private static boolean warrantyCreationExecuted = false;

public static boolean isWarrantyCreationExecuted(){
    return warrantyCreationExecuted;
}

public static void SVMX_CreateWarranty(List<SVMXC__Installed_Product__c> lstInstalledProduct,Map<String, String> AllSubModuleSettings){
        warrantyCreationExecuted = true;
        list<SVMXC__Installed_Product__c> IBforParentWrnty = new list<SVMXC__Installed_Product__c>();
        Set<string> prodfamilySet = new Set<string>();
        Set<string> prodlineSet = new Set<string>();
        list<SVMXC__Installed_Product__c> IBforWrnty = new list<SVMXC__Installed_Product__c>();
        set<Id> WrntyProdIds = new set<Id>();      
        Map<Id,integer> ChildWrntyMap = new Map<Id,integer>();
        Map<Id,list<SVMXC__Installed_Product__c>> ProdwithIbMap = new Map<Id,list<SVMXC__Installed_Product__c>>();  
        List<Product2> prodLst = new List<Product2>(); 
        Map<Id, Product2> mapProduct = new Map<Id, Product2>();
        String prodfamily;
        String prodline;
        String InheritChild;    
        
        String IsCreateWarAfterInsert = AllSubModuleSettings.get('SET010'); //Create Warranty From Templates Even After Warranty Inheritance
        String isCreateMissingWarranty = AllSubModuleSettings.get('SET011'); //Create Missing Warranty setting
        String isCreateWarrantyForProdFamily = 'TRUE'; //AllSubModuleSettings.get('SET013'); 
        String isCreateWarrantyForProdLine = 'TRUE'; //AllSubModuleSettings.get('SET014'); 
        
        if(AllSubModuleSettings.containsKey('SET013') && AllSubModuleSettings.get('SET013') != NULL)
            isCreateWarrantyForProdFamily = AllSubModuleSettings.get('SET013');
        if(AllSubModuleSettings.containsKey('SET014') && AllSubModuleSettings.get('SET014') != NULL)
            isCreateWarrantyForProdLine = AllSubModuleSettings.get('SET014');
        
        set<Id> lstIBForWarranty = new set<Id>();
        List<Id> lstProductIds = new List<String>();
        Map<String, Set<Id>> mapIBWarranty = new Map<String, Set<Id>>();
        
        System.debug('isCreateMissingWarranty :'+isCreateMissingWarranty);
        lstIBForWarranty = getInstalledProductForWarranty(lstInstalledProduct, isCreateMissingWarranty.toUpperCase());
        for(SVMXC__Installed_Product__c objIB: lstInstalledProduct){
            if(lstIBForWarranty.contains(objIB.Id) && objIB.SVMXC__Product__c != null){
                lstProductIds.add(objIB.SVMXC__Product__c);
            }
        }       
        
        System.debug('lstIBForWarranty :'+lstIBForWarranty);
        System.debug('lstProductIds :'+lstProductIds);
        
        prodLst = [SELECT SVMXC__Inherit_Parent_Warranty__c, SVMXC__Product_Line__c, Family FROM Product2 WHERE Id IN : lstProductIds];

        if(prodLst.size()>0){
            for(Product2 product: prodLst){
                mapProduct.put(product.Id, product);
                ProdwithIbMap.put(product.Id, new List<SVMXC__Installed_Product__c> ());
            }
            for(SVMXC__Installed_Product__c ib : lstInstalledProduct){
                if(lstIBForWarranty.contains(ib.Id))
                    if(ProdwithIbMap.containsKey(ib.SVMXC__Product__c))
                        ProdwithIbMap.get(ib.SVMXC__Product__c).add(ib);
            }
            
            InheritChild = AllSubModuleSettings.get('SET002');
            mapIBWarranty = getExistingWarranty(lstIBForWarranty);
            
            //Inheriting parent product warranty
            for(Product2 product: prodLst){
                if(product.SVMXC__Inherit_Parent_Warranty__c == true && InheritChild.toUpperCase()=='TRUE' && ProdwithIbMap.get(product.Id) != null){
                    list<SVMXC__Installed_Product__c> lst = ProdwithIbMap.get(product.Id);
                    for(SVMXC__Installed_Product__c ib : lst){
                        if(ib.SVMXC__Parent__c != NULL){
                            IBforParentWrnty.add(ib);
                        }                   
                    }
                }           
                
                if(isCreateWarrantyForProdFamily.toUpperCase() == 'TRUE' && product.Family != null && product.Family.length() > 0)
                    prodfamilySet.add(product.Family);
                    
                if(isCreateWarrantyForProdLine.toUpperCase() == 'TRUE' && product.SVMXC__Product_Line__c != null && product.SVMXC__Product_Line__c.length() > 0)
                    prodlineSet.add(product.SVMXC__Product_Line__c);
            }
            
            ChildWrntyMap = SVMX_CopyParentWarranty(IBforParentWrnty);      
            for(SVMXC__Installed_Product__c ib : lstInstalledProduct){
                if(lstIBForWarranty.contains(ib.Id))
                {
                    if(ChildWrntyMap.containsKey(ib.Id)){               
                        if(ChildWrntyMap.get(ib.Id) == 0){                    
                            IBforWrnty.add(ib);
                        }
                        else if(ChildWrntyMap.get(ib.Id) > 0){ 
                            if(IsCreateWarAfterInsert.toUpperCase() == 'TRUE'){                       
                                IBforWrnty.add(ib);
                            }
                        }
                    }
                    else{
                        //if(IsCreateWarAfterInsert.toUpperCase()=='FALSE'){                
                            IBforWrnty.add(ib);
                        //}
                    }
                }
            }
            
            for(SVMXC__Installed_Product__c ib : IBforWrnty){
                WrntyProdIds.add(ib.SVMXC__Product__c);
            }
            
             if(WrntyProdIds != null && WrntyProdIds.size() > 0 && WrntyProdIds.contains(null))
                WrntyProdIds.remove(null);
            
            if(prodfamilySet != null && prodfamilySet.size() > 0 && prodfamilySet.contains(null))
                prodfamilySet.remove(null);
                
            if(prodlineSet != null && prodlineSet.size() > 0 && prodlineSet.contains(null))
                prodlineSet.remove(null);
            
            //Generating Lists and Map to create warranty
            List<SVMXC__Installed_Product__c> IBCreateList = new List<SVMXC__Installed_Product__c>();
            Map<Id,list<SVMXC__Service_Template__c>> IBtoWarranty = new Map<Id,list<SVMXC__Service_Template__c>>();
            set<String> SelectedIdSet = new set<String>();   
            
            Map<Id, SVMXC__Service_Template_Products__c> StempMap = new  Map<Id, SVMXC__Service_Template_Products__c>();
            if(WrntyProdIds.size() > 0)
                StempMap.putAll([SELECT SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c, SVMXC__Service_Template__c FROM SVMXC__Service_Template_Products__c WHERE SVMXC__Product__c IN :WrntyProdIds ]);
            
            if(isCreateWarrantyForProdFamily.toUpperCase() == 'TRUE' && prodfamilySet.size() > 0)
                StempMap.putAll([SELECT SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c, SVMXC__Service_Template__c FROM SVMXC__Service_Template_Products__c WHERE SVMXC__Product_Family__c IN :prodfamilySet ]);
                
            if(isCreateWarrantyForProdLine.toUpperCase() == 'TRUE' && prodlineSet.size() > 0)
                StempMap.putAll([SELECT SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c, SVMXC__Service_Template__c FROM SVMXC__Service_Template_Products__c WHERE  SVMXC__Product_Line__c IN :prodlineSet]);
            
            System.debug('Log 1 : '+StempMap);
            // creating key V lst of Service Template Product
            Map<String, Set<String>> mapPrudctVsServiceTmpltlst = new Map<String, Set<String>>();
            Map<String, Set<String>> mapPrudctLineVsServiceTmpltlst = new Map<String, Set<String>>();
            Map<String, Set<String>> mapPrudctFimlyVsServiceTmpltlst = new Map<String, Set<String>>();
            
            for(String strKey : StempMap.keySet())
            {
                SelectedIdSet.add(StempMap.get(strKey).SVMXC__Service_Template__c);
                if(StempMap.get(strKey).SVMXC__Product__c != null)
                {
                    if(!mapPrudctVsServiceTmpltlst.containsKey(StempMap.get(strKey).SVMXC__Product__c))
                        mapPrudctVsServiceTmpltlst.put(StempMap.get(strKey).SVMXC__Product__c, new Set<String>());
                    mapPrudctVsServiceTmpltlst.get(StempMap.get(strKey).SVMXC__Product__c).add(strKey);
                }
                if(StempMap.get(strKey).SVMXC__Product_Family__c != null)
                {
                    if(!mapPrudctFimlyVsServiceTmpltlst.containsKey(StempMap.get(strKey).SVMXC__Product_Family__c))
                        mapPrudctFimlyVsServiceTmpltlst.put(StempMap.get(strKey).SVMXC__Product_Family__c, new Set<String>());
                    mapPrudctFimlyVsServiceTmpltlst.get(StempMap.get(strKey).SVMXC__Product_Family__c).add(strKey);
                }
                if(StempMap.get(strKey).SVMXC__Product_Line__c != null)
                {
                    if(!mapPrudctLineVsServiceTmpltlst.containsKey(StempMap.get(strKey).SVMXC__Product_Line__c))
                        mapPrudctLineVsServiceTmpltlst.put(StempMap.get(strKey).SVMXC__Product_Line__c, new Set<String>());
                    mapPrudctLineVsServiceTmpltlst.get(StempMap.get(strKey).SVMXC__Product_Line__c).add(strKey);
                }
            }
            if(StempMap.size()>0){
                map<Id,SVMXC__Service_Template__c> WrntyMap2 = new map<Id,SVMXC__Service_Template__c>();    
                WrntyMap2.putAll([SELECT Id,Name,SVMXC__Coverage_Effective_From2__c,SVMXC__Duration_of_Time_Coverage__c,SVMXC__Unit_of_Time__c,SVMXC__Duration_of_Material_Coverage__c,SVMXC__Unit_of_Time_Material__c,SVMXC__Duration_of_Expenses__c,SVMXC__Unit_of_Time_Expenses__c FROM SVMXC__Service_Template__c  WHERE Id IN :SelectedIdSet]);
                for(SVMXC__Installed_Product__c objIB : IBforWrnty){
                    system.debug(LoggingLevel.Warn, ' : for IB : '+objIB.Name);
                    Set<SVMXC__Service_Template__c> lstServiceTemplate = new Set<SVMXC__Service_Template__c>();
                    boolean isAnyMatch = false;
                    
                    Set<String> setStrngIDs = new Set<String>();
                    
                    if(objIB.SVMXC__Product__c != null){
                        if(mapPrudctVsServiceTmpltlst.containsKey(objIB.SVMXC__Product__c))
                            setStrngIDs.addAll(mapPrudctVsServiceTmpltlst.get(objIB.SVMXC__Product__c));
                    }
                    if(mapProduct.get(objIB.SVMXC__Product__c).SVMXC__Product_Line__c != null){
                        if(mapPrudctLineVsServiceTmpltlst.containsKey(mapProduct.get(objIB.SVMXC__Product__c).SVMXC__Product_Line__c))
                            setStrngIDs.addAll(mapPrudctLineVsServiceTmpltlst.get(mapProduct.get(objIB.SVMXC__Product__c).SVMXC__Product_Line__c));
                    }
                    if(mapProduct.get(objIB.SVMXC__Product__c).Family != null){
                        if(mapPrudctFimlyVsServiceTmpltlst.containsKey(mapProduct.get(objIB.SVMXC__Product__c).Family))
                            setStrngIDs.addAll(mapPrudctFimlyVsServiceTmpltlst.get(mapProduct.get(objIB.SVMXC__Product__c).Family));        
                    }
                                    
                    for(string strTempId : setStrngIDs)
                    {
                        if(WrntyMap2.containsKey(StempMap.get(strTempId).SVMXC__Service_Template__c) && mapIBWarranty.containsKey(objIB.Id) && mapIBWarranty.get(objIB.Id) != null && !mapIBWarranty.get(objIB.Id).contains(StempMap.get(strTempId).SVMXC__Service_Template__c))
                            lstServiceTemplate.add(WrntyMap2.get(StempMap.get(strTempId).SVMXC__Service_Template__c));
                    }
                    
                    
                    system.debug(LoggingLevel.Warn, 'IB Key: '+objIB.SVMXC__Product__c+':'+mapProduct.get(objIB.SVMXC__Product__c).Family+':'+mapProduct.get(objIB.SVMXC__Product__c).SVMXC__Product_Line__c+' : templates : '+setStrngIDs);
                    
                    system.debug(LoggingLevel.Warn, 'template list size : '+lstServiceTemplate.size());
                    if(lstServiceTemplate != null && lstServiceTemplate.size() > 0)
                        isAnyMatch = true;
                    List<SVMXC__Service_Template__c> lstWrntTemplt = new List<SVMXC__Service_Template__c> ();
                    lstWrntTemplt.addAll(lstServiceTemplate);
                    if(isAnyMatch)
                    {
                        IBtoWarranty.put(objIB.Id, lstWrntTemplt); 
                    }
                    IBCreateList.add(objIB);               
                }
                System.debug(LoggingLevel.Warn, 'Log 12 : '+IBCreateList);
                System.debug(LoggingLevel.Warn, 'Log 13 : '+IBtoWarranty);
                
                if(IBCreateList != null && IBCreateList.size() > 0 && IBtoWarranty != null && IBtoWarranty.size() > 0)
                {
                    SVMXC.IPRD_Utils IPRD_Utils = new SVMXC.IPRD_Utils(); 
                    IPRD_Utils.SVMXC_Set_CreateWarranty_IPW(IBCreateList, IBtoWarranty);
                }                   
            }
        }
    }
    
    // To get Installed Product for which we need to create warranty
    public static set<Id> getInstalledProductForWarranty(List<SVMXC__Installed_Product__c> lstInstalledProduct, String isCreateMissingWarranty){
        Map<Id, integer> WrntyMapCount = new Map<Id, integer>();
        set<Id> lstIBForWarranty = new set<Id>();
        
        WrntyMapCount = SVMX_IBWarrantyCount(lstInstalledProduct); // get the count of warranty against each IB
        //IsCreateWarAfterInsert = 'true';
        //isCreateMissingWarranty = 'true';
        System.debug('WrntyMapCount :'+WrntyMapCount);
        System.debug('isCreateMissingWarranty :'+isCreateMissingWarranty);
        for(integer i = 0;i < lstInstalledProduct.size(); i++){
            if(isCreateMissingWarranty == 'TRUE' || WrntyMapCount.get(lstInstalledProduct[i].Id) == 0){
                lstIBForWarranty.add(lstInstalledProduct[i].Id);
            }
        }
        return lstIBForWarranty;
    }

    // To get existing warranty for IB
    public static Map<String, Set<Id>> getExistingWarranty(set<Id> lstIBForWarranty){
        Map<String, Set<Id>> mapIBWarranty = new Map<String, Set<Id>>();
        if(lstIBForWarranty == null)
            return mapIBWarranty;
        List<SVMXC__Warranty__c> WarntyList =new List<SVMXC__Warranty__c>();
        WarntyList = [select id ,SVMXC__Service_Template__c, SVMXC__Installed_Product__c FROM SVMXC__Warranty__c WHERE SVMXC__Installed_Product__c IN: lstIBForWarranty];
        
        for(Id idsIb : lstIBForWarranty)
        {
            mapIBWarranty.put(idsIb, new Set<Id>());
        }
        
        if(WarntyList.size() > 0){
            for(SVMXC__Warranty__c objWarranty : WarntyList){
                if(mapIBWarranty.containsKey(objWarranty.SVMXC__Installed_Product__c))
                    mapIBWarranty.get(objWarranty.SVMXC__Installed_Product__c).add(objWarranty.SVMXC__Service_Template__c);
            }
        }
        return mapIBWarranty;
    }

    public static Map<Id,integer> SVMX_CopyParentWarranty(List<SVMXC__Installed_Product__c> lstInstalledProduct){     
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();   
        Schema.DescribeSObjectResult SObj = SVMXC__Warranty__c.sObjectType.getDescribe();
        Map<String, SObjectField> SObjfieldMap = Schema.SObjectType.SVMXC__Warranty__c.fields.getMap();
        String SObjFieldNames;
        List<String> SObjFieldList = utils.SVMX_getFieldList(SObjfieldMap,true); 
        
         /**********duplicate Check********************/
        SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2();
        SObjFieldList = commutils.checkDuplicateFields(SObjFieldList,'SVMXC__Warranty__c');
        /*********************************************/
        
        SObjFieldNames = utils.SVMX_getFieldNamesFromList(SObjFieldList);
        List<SVMXC__Warranty__c> ChldWarrLst = new List<SVMXC__Warranty__c>(); 
        List<SVMXC__Warranty__c> ParentWarLst = new List<SVMXC__Warranty__c>();     
        List<Id> ParentIb = new List<Id>(); 
        Map<Id,integer> ChildWrntyMap = new Map<Id,integer>();  
        Map<Id,list<string>> ParentIbMap = new Map<Id,list<string>>();
        Integer i;          
        for(integer j=0;j<lstInstalledProduct.size();j++){
            if(lstInstalledProduct[j].SVMXC__Parent__c!=null){
                ParentIb.add(lstInstalledProduct[j].SVMXC__Parent__c);
                list<string> s = new list<string>();
                ParentIbMap.put(lstInstalledProduct[j].SVMXC__Parent__c,s);
            }
        }
        
        for(SVMXC__Installed_Product__c IB : lstInstalledProduct){
            ParentIbMap.get(IB.SVMXC__Parent__c).add(IB.Id);
        }
        ParentWarLst = Database.query('SELECT ' + SObjFieldNames +' FROM SVMXC__Warranty__c WHERE SVMXC__Installed_Product__c IN: ParentIb');   
        
        for(SVMXC__Installed_Product__c IB : lstInstalledProduct){
            i = 0;
            //ChildWrntyMap.put(IB.Id,i);
            for(SVMXC__Warranty__c w : ParentWarLst){
                SVMXC__Warranty__c childwarr = w.clone(false,true);
                childwarr.SVMXC__Installed_Product__c=IB.Id;
                childwarr.SVMXC__Start_Date__c=System.today();
                ChldWarrLst.add(childwarr);
                i++;
                ChildWrntyMap.put(IB.Id,i);
            }
        }
        //insert ChldWarrLst;
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ChldWarrLst, COMM_SecurityUtils.Access.Createable)){
            insert ChldWarrLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        }
        else{
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
        return ChildWrntyMap;
    }
    
    public static map<Id,integer> SVMX_IBWarrantyCount(List<SVMXC__Installed_Product__c> lstInstalledProduct){  
        Integer warrantyCount=0;        
        list<SVMXC__Warranty__c> WrntyLst = new list<SVMXC__Warranty__c>();
        Map<Id,list<string>> WrntyMap = new Map<Id,list<string>>();
        Map<Id,integer> WrntyMapCount = new Map<Id,integer>();
        list<Id> Idlst = new list<Id>();
        try{
            for(SVMXC__Installed_Product__c Ib : lstInstalledProduct){
                Idlst.add(Ib.Id);
                list<string> s = new list<string>();
                WrntyMap.put(Ib.Id,s);
            }       
            WrntyLst=[SELECT Id, SVMXC__Installed_Product__r.Id FROM SVMXC__Warranty__c WHERE SVMXC__Installed_Product__c IN:Idlst];   
            for(SVMXC__Warranty__c w: WrntyLst){
                WrntyMap.get(w.SVMXC__Installed_Product__r.Id).add(w.Id);
            }
            for(Id Ib : WrntyMap.keyset()){ 
                WrntyMapCount.put(Ib, WrntyMap.get(Ib).size() );
            }
        }
        catch(Exception e){}
        return WrntyMapCount;
    }
 }