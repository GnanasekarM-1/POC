public with sharing class ProductIQUtils {
    
    public ProductIQUtils() {
        
    }
    
    public List<ProductIQConfiguration.TemplateHeader> getProductIQTemplates(List<SVMXC__ProductIQTemplate__c> ibTemplatesSF) {
        List<ProductIQConfiguration.TemplateHeader> ibTemplates = getTemplateInfo(ibTemplatesSF);
        getProductsInfo(ibTemplates);
        return ibTemplates;
    }
    
    public List<ProductIQConfiguration.TemplateHeader> getProductIQTemplatesWithMappings(List<SVMXC__ProductIQTemplate__c> ibTemplatesSF) {
        List<ProductIQConfiguration.TemplateHeader> ibTemplates = getTemplateInfo(ibTemplatesSF);
        getProductsInfoWithMappings(ibTemplates);
        return ibTemplates;
    }
    
    public List<ProductIQConfiguration.TemplateHeader> getTemplateInfo(List<SVMXC__ProductIQTemplate__c> ibTemplatesSF) {
        List<ProductIQConfiguration.TemplateHeader> ibTemplates = new List<ProductIQConfiguration.TemplateHeader>();
        for(SVMXC__ProductIQTemplate__c currTemplate : ibTemplatesSF) {
            ProductIQConfiguration.TemplateHeader ibTemplate = new ProductIQConfiguration.TemplateHeader();
            ibTemplate.sfdcId = currTemplate.Id;
            ibTemplate.templateName = currTemplate.name;
            ibTemplate.templateId = currTemplate.SVMXC__ProductIQTemplateId__c;
            String templateDetails = '{"templateDetails": ' + currTemplate.SVMXC__Contents__c + '}';
            ProductIQConfiguration.Template template = 
                                        (ProductIQConfiguration.Template)JSON.deserialize(templateDetails, ProductIQConfiguration.Template.class);
            template.type = 'root';
            template.text = template != null && template.templateDetails != null ? template.templateDetails.templateName : '';                              
            String children = '{"children":' + currTemplate.SVMXC__TemplateContentDetails__c + '}';
            template.children = 
                    ((ProductIQConfiguration.Template)JSON.deserialize(children, ProductIQConfiguration.Template.class)).children;
            ibTemplate.template = new ProductIQConfiguration.Template();
            ibTemplate.template.children = new List<ProductIQConfiguration.Template>();
            ibTemplate.template.children.add(template);     
            ibTemplates.add(ibTemplate);        
        }
        return ibTemplates;
    }
    
    //this util is used from setup page and service impl
    public List<ProductIQConfiguration.TemplateHeader> getProductIQTemplates() {
        List<SVMXC__ProductIQTemplate__c> ibTemplatesSF = 
                                            [Select Id, Name, SVMXC__ProductIQTemplateId__c, SVMXC__Contents__c, SVMXC__TemplateContentDetails__c from SVMXC__ProductIQTemplate__c];
        return getProductIQTemplates(ibTemplatesSF);
    }
    
    private void getProductsInfo(List<ProductIQConfiguration.TemplateHeader> ibTemplates) {
        
        Map<String, ProductIQConfiguration.Product> product = new Map<String, ProductIQConfiguration.Product>();
        for(ProductIQConfiguration.TemplateHeader ibTemplate : ibTemplates) {
            if(ibTemplate.template.children[0] != null) {
                getProductConfiguration(ibTemplate.template.children[0] ,product);
            }
        }
        
        Map<String, SVMXC__ProductConfiguration__c> productInfo = getProductConfigurationSF(product.keySet());
        Set<String> allMapIds = new Set<String>();
        for(ProductIQConfiguration.TemplateHeader ibTemplate : ibTemplates) {
            
            updateProductConfiguration(ibTemplate.template.children[0], productInfo,  allMapIds);
        }
                
    }
    
    private void getProductsInfoWithMappings(List<ProductIQConfiguration.TemplateHeader> ibTemplates) {
        
        Map<String, ProductIQConfiguration.Product> product = new Map<String, ProductIQConfiguration.Product>();
        for(ProductIQConfiguration.TemplateHeader ibTemplate : ibTemplates) {
            if(ibTemplate.template.children[0] != null) {
                getProductConfiguration(ibTemplate.template.children[0] ,product);
            }
        }
        
        Map<String, SVMXC__ProductConfiguration__c> productInfo = getProductConfigurationSF(product.keySet());
        Map<String, Set<String>> templateMappings = new Map<String, Set<String>>();
        Set<String> allMapIds = new Set<String>();
        for(ProductIQConfiguration.TemplateHeader ibTemplate : ibTemplates) {
            Set<String> mapIds = new Set<String>();
            templateMappings.put(ibTemplate.templateId, mapIds);
            updateProductConfiguration(ibTemplate.template.children[0], productInfo, mapIds);
            allMapIds.addAll(mapIds);
        }
        Map<String, ProductIQConfiguration.Mapping> mappingsData = getMappings(allMapIds);
        
        for(ProductIQConfiguration.TemplateHeader ibTemplate : ibTemplates) {
            ibTemplate.mappings = new List<ProductIQConfiguration.Mapping>();
            Set<String> mapIds = templateMappings.get(ibTemplate.templateId);
            for(String currMap : mapIds) {
                if(mappingsData.containsKey(currMap)) {
                    ibTemplate.mappings.add(mappingsData.get(currMap));
                }               
            }
        }
        
    } 
    
    private void updateProductConfiguration(ProductIQConfiguration.Template template, 
                                    Map<String, SVMXC__ProductConfiguration__c> productConfiguration,
                                    Set<String> mapIds) {
        ProductIQConfiguration.Product pro = template.product;
        if(pro != null && productConfiguration.containsKey(pro.productId)) {
            
            ProductIQConfiguration.Product savedConfig = 
            (ProductIQConfiguration.Product)JSON.deserialize(productConfiguration.get(pro.productId).SVMXC__Contents__c, ProductIQConfiguration.Product.class);
            System.debug( 'Product Configuration: ' + savedConfig);
            pro.product = savedConfig.product;
            pro.productIcon = savedConfig.productIcon;
            pro.productDefaultValues = savedConfig.productDefaultValues;
            pro.oldProductValueMap = savedConfig.oldProductValueMap;            
            pro.newProductValueMap = savedConfig.newProductValueMap;
                
            template.type = 'product';
            template.text = savedConfig.product;
            if(savedConfig.productDefaultValues != null && savedConfig.productDefaultValues.length() > 0) {
                mapIds.add(savedConfig.productDefaultValues);
            }
            
            if(savedConfig.oldProductValueMap != null && savedConfig.oldProductValueMap.length() > 0) {
                mapIds.add(savedConfig.oldProductValueMap);
            }
            
            if(savedConfig.newProductValueMap != null && savedConfig.newProductValueMap.length() > 0) {
                mapIds.add(savedConfig.newProductValueMap);
            }            
                        
            
        }
        
        if(template.children != null && template.children.size() > 0) {
            for(ProductIQConfiguration.Template currTemp : template.children) {           
                updateProductConfiguration(currTemp, productConfiguration, mapIds);
            }
        }       
    }    
    
    public void getProductConfiguration(ProductIQConfiguration.Template template, 
                                        Map<String, ProductIQConfiguration.Product> productConfiguration) {
        
        ProductIQConfiguration.Product pro = template.product;
        if(pro != null)
        productConfiguration.put(pro.productId, pro);
                
        if(template.children != null && template.children.size() > 0) {
            for(ProductIQConfiguration.Template currTemp : template.children) {           
                getProductConfiguration(currTemp, productConfiguration);
            }
        }
    }
    
    
    public Map<String, SVMXC__ProductConfiguration__c> getProductConfigurationSF(Set<String> lstProducts) {
        
        List<SVMXC__ProductConfiguration__c> proConfig = [Select Id, SVMXC__Product__c, SVMXC__Contents__c
                                                                from SVMXC__ProductConfiguration__c where SVMXC__Product__c In: lstProducts];
        Map<String, SVMXC__ProductConfiguration__c> productData = new Map<String, SVMXC__ProductConfiguration__c>();
        for(SVMXC__ProductConfiguration__c currProConf : proConfig) {
            productData.put(currProConf.SVMXC__Product__c, currProConf);
        }                                                   
        return productData;
    }
   
   //utility used to get the mappings data
    public List<ProductIQConfiguration.CustomActionURL> getCustomURLs(Set<String> customURLIds) {
        List<ProductIQConfiguration.CustomActionURL> lstCustomURLs = new List<ProductIQConfiguration.CustomActionURL>();
        
        List<String> queryFields = new List<String>{'Id', 'SVMXC__Source_Object_Name__c', 'SVMXC__ProcessID__c', 'SVMXC__Target_URL__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

        Map<String, SVMXC__ServiceMax_Processes__c> rawUrls = new Map<String, SVMXC__ServiceMax_Processes__c>([Select Id, SVMXC__Source_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Target_URL__c from SVMXC__ServiceMax_Processes__c
                                            where SVMXC__ProcessID__c In: customURLIds and RecordType.Name = 'SF Action']); 
        
        List<String> queryFields1 = new List<String>{'SVMXC__Parameter_Name__c', 'SVMXC__Parameter_Type__c', 'SVMXC__Parameter_Value__c', 'SVMXC__Dispatch_Process__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields1, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        List<SVMXC__ServiceMax_Config_Data__c> urlParameters = [select SVMXC__Parameter_Name__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c, SVMXC__Dispatch_Process__c 
                                                                    from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN: rawUrls.keyset()];
        
        System.debug('Raw URLs: ' + rawUrls);
        System.debug('Raw Parameters: ' + urlParameters);
        
        Map<String, List<ProductIQConfiguration.URLParameters>> objectIdURLPramaters = new Map<String, List<ProductIQConfiguration.URLParameters>>();
        
        for(SVMXC__ServiceMax_Config_Data__c parameter: urlParameters){
            ProductIQConfiguration.URLParameters urlParameter = new ProductIQConfiguration.URLParameters(parameter.SVMXC__Parameter_Name__c, parameter.SVMXC__Parameter_Type__c, parameter.SVMXC__Parameter_Value__c);
            if(!objectIdURLPramaters.containsKey(parameter.SVMXC__Dispatch_Process__c)){
                objectIdURLPramaters.put(parameter.SVMXC__Dispatch_Process__c, new List<ProductIQConfiguration.URLParameters>());
            }
            objectIdURLPramaters.get(parameter.SVMXC__Dispatch_Process__c).add(urlParameter);
        }
        
        for(SVMXC__ServiceMax_Processes__c urlProcess : rawUrls.values()){
            List<ProductIQConfiguration.URLParameters> urlProcessDtls = objectIdURLPramaters.get(urlProcess.Id);
            ProductIQConfiguration.CustomActionURL actionUrl = new ProductIQConfiguration.CustomActionURL(urlProcess.SVMXC__ProcessID__c, urlProcess.SVMXC__Target_URL__c, urlProcess.SVMXC__Source_Object_Name__c, urlProcessDtls);
            lstCustomURLs.add(actionUrl);
        }
        
        return lstCustomURLs;
    }
    
    //utility used to get the mappings data
    public List<ProductIQConfiguration.Mapping> getMappingsData(Set<String> mappingNames) {
        return getMappings(mappingNames).values();
    }
    
    public Map<String, ProductIQConfiguration.Mapping> getMappings(Set<String> mappingNames) {
            List<String> queryFields = new List<String>{'Id', 'SVMXC__Source_Object_Name__c', 'SVMXC__Target_Object_Name__c', 'SVMXC__MapID__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            Map<String, SVMXC__ServiceMax_Processes__c> rawMappings = new Map<String, SVMXC__ServiceMax_Processes__c>([Select Id, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__MapID__c from SVMXC__ServiceMax_Processes__c
                                            where SVMXC__MapID__c In: mappingNames and RecordType.Name = 'Object Mapping']);
            
            List<String> queryFields1 = new List<String>{'Id', 'SVMXC__Source_Field_Name__c', 'SVMXC__Target_Field_Name__c', 'SVMXC__Display_Value__c', 'SVMXC__MapID__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields1, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            List<SVMXC__ServiceMax_Config_Data__c> fieldMappingsData = [Select Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Value__c, SVMXC__MapID__c from SVMXC__ServiceMax_Config_Data__c
                                            where SVMXC__MapID__c In: rawMappings.keySet()];
            
            System.debug('Raw Mappings: ' + rawMappings);
            System.debug('Raw field mappings: ' + fieldMappingsData);
            //loop through all the field maps and point to object map id
            Map<String, List<ProductIQConfiguration.FieldMapping>> objectIdFieldMappings = new Map<String, List<ProductIQConfiguration.FieldMapping>>(); 
            for(SVMXC__ServiceMax_Config_Data__c currFieldMapping : fieldMappingsData) {
                ProductIQConfiguration.FieldMapping fieldMapping = new ProductIQConfiguration.FieldMapping();
                fieldMapping.targetField = currFieldMapping.SVMXC__Target_Field_Name__c;
                fieldMapping.value = currFieldMapping.SVMXC__Display_Value__c;
                if(!objectIdFieldMappings.containsKey(currFieldMapping.SVMXC__MapID__c)) {
                    objectIdFieldMappings.put(currFieldMapping.SVMXC__MapID__c, new List<ProductIQConfiguration.FieldMapping>());
                }
                objectIdFieldMappings.get(currFieldMapping.SVMXC__MapID__c).add(fieldMapping);            
            }
            
            //loop through all the mappings and update with the field maps
            Map<String, ProductIQConfiguration.Mapping> mappings = new Map<String, ProductIQConfiguration.Mapping>();
            for(String currMappingId : rawMappings.keySet()) {
                ProductIQConfiguration.Mapping mapping = new ProductIQConfiguration.Mapping();
                mapping.name = rawMappings.get(currMappingId).SVMXC__MapID__c;
                mapping.targetObjectName = rawMappings.get(currMappingId).SVMXC__Target_Object_Name__c;
                mapping.mappingFields = objectIdFieldMappings.get(currMappingId);
                mappings.put(rawMappings.get(currMappingId).SVMXC__MapID__c, mapping);
            }           
            return mappings;                        
    }
    
    public List<ProductIQConfiguration.DataValidationRule> getDataValidationRules(set<String> configuredRules){
        List<ProductIQConfiguration.DataValidationRule> dataValidationRules = new List<ProductIQConfiguration.DataValidationRule>();
      
        if(configuredRules == null || configuredRules.size() == 0)
        	return dataValidationRules;
        
        map<id, SVMXC__ServiceMax_Processes__c> mpRules = new map<id, SVMXC__ServiceMax_Processes__c>();
        mpRules.putAll([select id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Parent_Error_Msg__c, SVMXC__ProcessID__c, SVMXC__Source_Object_Name__c, SVMXC__Advance_Expression__c, SVMXC__Message_Type__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c IN: configuredRules AND RecordType.Name = 'Business Rule']);
        
        if(mpRules == null || mpRules.size() == 0)
            return dataValidationRules;
        List<String> queryFields = new List<String>{'id', 'SVMXC__Expression_Rule__c', 'SVMXC__Expression_Type__c', 'SVMXC__Display_Type__c', 'SVMXC__Parameter_Type__c', 'SVMXC__Field_Name__c', 'SVMXC__Sequence__c', 'SVMXC__Operator__c', 'SVMXC__Operand__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = [select id, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c, SVMXC__Display_Type__c, SVMXC__Parameter_Type__c, SVMXC__Field_Name__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN: mpRules.keyset()];
        
        map<id, List<ProductIQConfiguration.Expression>> mpRuleToExprs = new map<id, List<ProductIQConfiguration.Expression>>();
        
        for(SVMXC__ServiceMax_Config_Data__c exp: lstConfigData){
            if(!mpRuleToExprs.containsKey(exp.SVMXC__Expression_Rule__c) || mpRuleToExprs.get(exp.SVMXC__Expression_Rule__c) == null)
            	mpRuleToExprs.put(exp.SVMXC__Expression_Rule__c, new List<ProductIQConfiguration.Expression>());
          	ProductIQConfiguration.Expression exprCls = new ProductIQConfiguration.Expression(exp.SVMXC__Field_Name__c, exp.SVMXC__Operator__c, exp.SVMXC__Operand__c, exp.SVMXC__Expression_Type__c, exp.SVMXC__Display_Type__c, string.valueOf(exp.SVMXC__Sequence__c), string.valueOf(exp.SVMXC__Expression_Rule__c));
            exprCls.parameterType = exp.SVMXC__Parameter_Type__c;
            mpRuleToExprs.get(exp.SVMXC__Expression_Rule__c).add(exprCls);
        }
        
        for(id ruleId : mpRules.keyset()){
            SVMXC__ServiceMax_Processes__c rule = mpRules.get(ruleId);
            ProductIQConfiguration.DataValidationRuleInfo ruleInfo = new ProductIQConfiguration.DataValidationRuleInfo(rule.SVMXC__ProcessID__c, rule.SVMXC__Name__c, rule.SVMXC__Description__c, rule.SVMXC__Message_Type__c, rule.SVMXC__Source_Object_Name__c, rule.SVMXC__Advance_Expression__c, rule.SVMXC__Parent_Error_Msg__c);
            ProductIQConfiguration.DataValidationRule dVRule = new ProductIQConfiguration.DataValidationRule(ruleInfo, mpRuleToExprs.get(ruleId));
            dataValidationRules.add(dVRule);
        }
        
        return dataValidationRules;
    }
    
    public ProductIQConfiguration.Template getTemplateFromIB(String topLevelId) {
        SVMXC__Installed_Product__c topLevelRec = getIBSF(topLevelId);
        List<SVMXC__Installed_Product__c> allChilds = getAllChildsSF(topLevelId);
        Map<String, List<SVMXC__Installed_Product__c>> ibParentMap = getIBParentMap(allChilds);
        ProductIQConfiguration.Template template = new ProductIQConfiguration.Template();
        template.product = new ProductIQConfiguration.Product();
        template.text = topLevelRec.SVMXC__Product_Name__c;
        template.type = 'product';
        template.product.productId = topLevelRec.SVMXC__Product__c;
        template.product.product = topLevelRec.SVMXC__Product_Name__c;
        createTemplate(topLevelId, ibParentMap, template);
        return template;    
    }
    
    private void createTemplate(String parentId, Map<String, List<SVMXC__Installed_Product__c>> ibParentMap, ProductIQConfiguration.Template parentTemplate) {
        
        List<SVMXC__Installed_Product__c> childIBs = ibParentMap.get(parentId);
        parentTemplate.children = new List<ProductIQConfiguration.Template>();
        if(childIBs != null && childIBs.size() > 0) {
            for(SVMXC__Installed_Product__c ib : childIBs) {
                ProductIQConfiguration.Template template = new ProductIQConfiguration.Template();
                template.text = ib.SVMXC__Product_Name__c;
                template.type = 'product';      
                template.product = new ProductIQConfiguration.Product();
                template.product.productId = ib.SVMXC__Product__c;
                template.product.product = ib.SVMXC__Product_Name__c;
                createTemplate(ib.Id, ibParentMap, template);
                parentTemplate.children.add(template);
            }           
        }               
    }
    
    private List<SVMXC__Installed_Product__c> getAllChildsSF(String topLevelId) {
        List<SVMXC__Installed_Product__c> allChildIbs = [Select Id, SVMXC__Parent__c, SVMXC__Top_Level__c, SVMXC__Product__c ,SVMXC__Product_Name__c from SVMXC__Installed_Product__c
                                                            where SVMXC__Top_Level__c =: topLevelId];
        return allChildIbs;                                         
    }
    
    private SVMXC__Installed_Product__c getIBSF(String topLevelId) {
        SVMXC__Installed_Product__c Ib = [Select Id, SVMXC__Parent__c, SVMXC__Top_Level__c, SVMXC__Product__c ,SVMXC__Product_Name__c from SVMXC__Installed_Product__c
                                                            where Id =: topLevelId];
        return Ib;                                          
    }
    
    private Map<String, List<SVMXC__Installed_Product__c>> getIBParentMap(List<SVMXC__Installed_Product__c> allChildIbs) {
        
        Map<String, List<SVMXC__Installed_Product__c>> parentIbs = new Map<String, List<SVMXC__Installed_Product__c>>();
        String parentId;
        for(SVMXC__Installed_Product__c currIB : allChildIbs) {
            parentId = currIB.SVMXC__Parent__c;
            if(currIB.SVMXC__Parent__c != null) {
                if(!parentIbs.containsKey(parentId)) {
                    parentIbs.put(parentId, new List<SVMXC__Installed_Product__c>());
                }
                parentIbs.get(parentId).add(currIB);                
            }       
        }
        return parentIbs;
    }   
        
    public Map<String, String> getProductIQSettings(){
        
        Map<String, String> priqSettings = new Map<String, String>();
        INTF_WebServicesDef.INTF_Response settings = (INTF_WebServicesDef.INTF_Response)new SVMXC.SFMDeliveryServiceImpl().retrieveSettingsInternal(
            new SVMXC.SFMDeliveryServiceImpl.RetrieveSettingsRequest('PRODIQ001')
        );
        
        for(INTF_WebServicesDef.INTF_StringMap currSett : settings.stringMap){
            priqSettings.put(currSett.key, currSett.value);
        }
        return priqSettings;
    }
    
    public List<ProductIQConfiguration.Field> getFields(String objectName, String fieldSetName){
        List<ProductIQConfiguration.Field> fields = new List<ProductIQConfiguration.Field>();
        if(fieldSetName == null) return fields;
        Integer priority = 1;
        Schema.FieldSet fs1 = Schema.getGlobalDescribe().get(objectName).getDescribe()
                                            .fieldSets.getMap().get(fieldSetName);
        if(fs1 == null) return fields;
        for(Schema.FieldSetMember currField : fs1.getFields()){
            ProductIQConfiguration.Field fld = new ProductIQConfiguration.Field();
            fld.name = currField.getFieldPath();
        fld.required = currField.getRequired();
            fld.priority = priority;
            fields.add(fld);
            priority++;
        }           
        return fields;
    }
    
    private List<SVMXC__ServiceMax_Config_Data__c> getSearchConfigurationSF(List<SVMXC__ServiceMax_Processes__c> searchObjects){
        
        List<SVMXC__ServiceMax_Config_Data__c> searchFields = null;
        if(searchObjects.size() > 0 && searchObjects != null){
            List<String> queryFields = new List<String>{'Id', 'SVMXC__Field_Name__c', 'SVMXC__Display_Type__c', 'SVMXC__Sequence__c', 'SVMXC__Search_Object_Field_Type__c', 'SVMXC__Object_Name__c', 'SVMXC__FKey_Name_Field__c', 'SVMXC__Object_Name2__c', 'SVMXC__Operator__c', 'SVMXC__Display_Value__c', 'SVMXC__Operand__c', 'SVMXC__Lookup_Field_API_Name__c', 'SVMXC__Is_Name_Field__c', 'SVMXC__Field_Relationship_Name__c', 'SVMXC__Sort_Order__c', 'SVMXC__Expression_Type__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            searchFields = [SELECT Id, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Object_Name2__c, SVMXC__Operator__c, SVMXC__Display_Value__c, SVMXC__Operand__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Sort_Order__c, SVMXC__Expression_Type__c  FROM SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: searchObjects[0].Id];
        }
        return searchFields;
    }

    private List<SVMXC__ServiceMax_Processes__c> getSearchProcessSF(String searchId, String objectName){
        List<String> queryFields = new List<String>{'Id', 'SVMXC__Advance_Expression__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        List<SVMXC__ServiceMax_Processes__c> searchObjects = [Select Id, SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Processes__c where SVMXC__Target_Object_Name__c =: objectName and SVMXC__Module__r.SVMXC__ProcessID__c =: searchId and SVMXC__Module__r.RecordType.DeveloperName = 'Named_Search'limit 1];
        return searchObjects;

    }

    public ProductIQConfiguration.Search getSearchConfiguration(String searchId, String objectName){
        List<SVMXC__ServiceMax_Processes__c> sProc = getSearchProcessSF(searchId, objectName);
        List<SVMXC__ServiceMax_Config_Data__c> sConf = getSearchConfigurationSF(sProc);
        ProductIQConfiguration.Search searchObject = new ProductIQConfiguration.Search();
        List<ProductIQConfiguration.SearchField> searchFields = new List<ProductIQConfiguration.SearchField>();
        ProductIQConfiguration.SearchField searchField = null;

        if(sConf != null)
        {
	        for(SVMXC__ServiceMax_Config_Data__c curr : sConf){
	            searchField = new ProductIQConfiguration.SearchField();
	            searchField.displayType = curr.SVMXC__Display_Type__c;
	            searchField.fieldName = curr.SVMXC__Field_Name__c;
	            searchField.objectName = curr.SVMXC__Object_Name2__c;
	            searchField.fieldType = curr.SVMXC__Search_Object_Field_Type__c;
	            searchField.lookupFieldAPIName = curr.SVMXC__Lookup_Field_API_Name__c;
	            searchField.fieldRelationshipName = curr.SVMXC__Field_Relationship_Name__c;
	            searchField.relatedObjectName = curr.SVMXC__Object_Name__c;
	            searchField.sortOrder = curr.SVMXC__Sort_Order__c;
	            searchField.sequence = curr.SVMXC__Sequence__c + '';
	            searchField.objectName2 = curr.SVMXC__Object_Name2__c;
	            searchField.operand = curr.SVMXC__Operand__c;
	            searchField.operatorValue = curr.SVMXC__Operator__c;
	            searchField.isNameField = curr.SVMXC__Is_Name_Field__c + '';
	            searchField.expressionType = curr.SVMXC__Expression_Type__c;
	            searchField.fKeyNameField = curr.SVMXC__FKey_Name_Field__c;
	            searchFields.add(searchField);
	        }
        }
        searchObject.advancedExpression = sProc.size() > 0 ? sProc[0].SVMXC__Advance_Expression__c : '';
        searchObject.searchfields = searchFields;
        return searchObject;
    }
}