public with sharing class ProductIQSetupImpl {
    
    public Object getSetupMetadata(){
       ProductIQUtils objUtils = new ProductIQUtils();
       Map<String, String> priqSettings = objUtils.getProductIQSettings();            
       List<String> objectsfrdesc = new List<String>();
       objectsfrdesc.add('SVMXC__Installed_Product__c');
       objectsfrdesc.add('Product2'); 
       objectsfrdesc.add('SVMXC__SM_Product_Attributes__c');   
       objectsfrdesc.add('SVMXC__SM_TA_Picklist_Definition__c');    
       GetSetupMetadataResponse metadataResponse = new GetSetupMetadataResponse();
       metadataResponse.setSVMXProfiles(getSVMXProfiles());
       metadataResponse.setIBValueMaps(getIBValueMappings());
       metadataResponse.setIBActionURL(getIBActionURL());
       metadataResponse.setDataValidationRules(getDataValidationRules());
       metadataResponse.setSForceObjectDescribes(getObjectDescribes(objectsfrdesc));
       metadataResponse.setInstalligenceLogos(getInstalligenceLogos());
       metadataResponse.setIBTemplates(objUtils.getProductIQTemplates());
       metadataResponse.setTranslations(getTranslations());
       metadataResponse.productDisplayFields = objUtils.getFields('Product2', priqSettings.get('SET009')); 
       metadataResponse.productSearchFields = objUtils.getFields('Product2', priqSettings.get('SET010')); 
       metadataResponse.availableSearchProc = getSearchConf();
       metadataResponse.setAvailableLocationEditProcess(getLocationEditProcessConfig());
       metadataResponse.setAvailableIBEditProcess(getIBEditProcessConfig());
       metadataResponse.setTotalTAtemplates(getTotalTAtemplateCount());
       
       return metadataResponse;    
    }
    public Integer getTotalTAtemplateCount(){
      Integer totalCount = [Select Count() from SVMXC__SM_Attributes_Template__c];
      return totalCount;
    }
    
    public Object saveSetupData(String request) {
        
        System.debug('request Data: ' + request); 
        ProductIQConfiguration.Configuration configuration = 
                            (ProductIQConfiguration.Configuration)JSON.deserialize(request, ProductIQConfiguration.Configuration.class);
        
        String taProductId;
        String taProductFamily;
        String taProductLine;
        String taTemplateId;
        if(configuration != null && configuration.technicalAttributesTemplate != null && configuration.technicalAttributesTemplate.templateId != null){
            taTemplateId = configuration.technicalAttributesTemplate.templateId;
        }
        if(configuration != null && configuration.technicalAttributesTemplate != null && configuration.technicalAttributesTemplate.templateApplicationCriteria != null) {
            for(ProductIQConfiguration.TAapplicationCriteria applicationCriteria : configuration.technicalAttributesTemplate.templateApplicationCriteria){
                
                
                if(applicationCriteria.productId != null){
                    
                    taProductId = applicationCriteria.productId;
                    List<SVMXC__SM_Product_Attributes__c> productDetailsList = [Select Id,Name,SVMXC__SM_Attribute_Template_Id__c from SVMXC__SM_Product_Attributes__c where SVMXC__SM_Product__c =:taProductId];
                     
                     for(SVMXC__SM_Product_Attributes__c eachProductDetail: productDetailsList){
                             
                             if(eachProductDetail.SVMXC__SM_Attribute_Template_Id__c !=taTemplateId){
                                 configuration.isValideTAtemplate = 'NO';
                                 return configuration;
                         }
                     
                     }
                      
                }else if(applicationCriteria.productFamily != null){
                    
                    taProductFamily = applicationCriteria.productFamily;
                    List<SVMXC__SM_Product_Attributes__c> familyDetailsList = [Select Id,Name,SVMXC__SM_Attribute_Template_Id__c from SVMXC__SM_Product_Attributes__c where SVMXC__SM_Product_Family__c =:taProductFamily];
                     
                     for(SVMXC__SM_Product_Attributes__c eachFamiyDetail: familyDetailsList){
                     
                         if(eachFamiyDetail.SVMXC__SM_Attribute_Template_Id__c !=taTemplateId){
                             configuration.isValideTAtemplate = 'NO';
                             return configuration;
                         } 
                     }
                     
                }else{
                    
                    taProductLine = applicationCriteria.productLine;
                    List<SVMXC__SM_Product_Attributes__c> lineDetailsList = [Select Id,Name,SVMXC__SM_Attribute_Template_Id__c from SVMXC__SM_Product_Attributes__c where SVMXC__SM_Product_Line__c =:taProductLine];
                     
                     for(SVMXC__SM_Product_Attributes__c eachLineDetail: lineDetailsList){
                     
                         if(eachLineDetail.SVMXC__SM_Attribute_Template_Id__c !=taTemplateId){
                                 configuration.isValideTAtemplate = 'NO';
                                 return configuration;
                         } 
                     
                     }
                     
                     
                }
            
        }
        
       }
                                                                        
        
             System.debug('Profiles Data PIQ: ' + configuration);
             
        if(configuration.profiles != null)
        saveProfiles(configuration.profiles);
        
        
        if(configuration.templates != null)
            saveProductTemplates(configuration.templates);
        if(configuration.delTemplateIds != null)    
            deleteProductTemplates(configuration.delTemplateIds);
            
            
            if(configuration.taDeletedTemplateIds != null)    
            deleteProductAttributesForDeletedTechnicalAttributeIds(configuration.taDeletedTemplateIds);
            
            if(configuration.taDeletedTemplateIds != null)    
            deleteTechnicalAttributeTemplates(configuration.taDeletedTemplateIds);
            
            
            if(configuration.deletedTACriteriaIds != null)    
            deleteTechnicalAttributesCriteriaIds(configuration.deletedTACriteriaIds);
            
            
           
             System.debug('technicalAttributesTemplate details'  + configuration.technicalAttributesTemplate);  
            if(configuration.technicalAttributesTemplate != null)    
            saveTechnicalAttributesTemplate(configuration.technicalAttributesTemplate);
            System.debug('Profiles Data 1: ' + configuration);
            
            
        
       
            
        return configuration;
    }
    
    public Object getTemplateFromIB(String request) {
        
        GetTemplateFromIBRequest IB = 
                            (GetTemplateFromIBRequest)JSON.deserialize(request, GetTemplateFromIBRequest.class);
        ProductIQUtils objUtils = new ProductIQUtils();   
        return objUtils.getTemplateFromIB(IB.InstalledProductId);        
    }
    
    public void saveProfiles(List<ProductIQConfiguration.Profile> profiles) {     
                                        
        Map<String, List<SVMXC__ProductIQProfile__c>> ibProfileData = getProductIQProfilesData();
        List<SVMXC__ProductIQProfile__c> sProfiles = new List<SVMXC__ProductIQProfile__c>();
        String actions = null; String filters = null; String contents = null; String stdActions = null; String rulesWithObjectInfo = null, search = null; String isTechnicalAttributesEnabled = null, attachment = null, ibEditProces = null, locationEditProces = null;
        String serviceFlowWizardDisplay = null;
        String isAutoSyncEnabled = null;

        for(ProductIQConfiguration.Profile currProfile : profiles) {
           
            stdActions = JSON.serialize(currProfile.stdActions);
            actions = JSON.serialize(currProfile.actions);
            filters = JSON.serialize(currProfile.filters);
            search = JSON.serialize(currProfile.search);
            isTechnicalAttributesEnabled = JSON.serialize(currProfile.isTechnicalAttributesEnabled);
            isAutoSyncEnabled = JSON.serialize(currProfile.isAutoSyncEnabled);
            attachment = JSON.serialize(currProfile.attachment);
            ibEditProces = JSON.serialize(currProfile.ibEditProces);
            locationEditProces = JSON.serialize(currProfile.locationEditProces);
            serviceFlowWizardDisplay = JSON.serialize(currProfile.serviceFlowWizardDisplay);

            rulesWithObjectInfo = JSON.serialize(currProfile.rulesWithObjectInfo);
            contents = (actions != null && actions.length() > 0 ? '"actions":' + actions + ',' : '')
                            + (filters != null && filters.length() > 0 ? '"filters":' + filters  + ',' : '')
                            + (rulesWithObjectInfo != null && rulesWithObjectInfo.length() > 0 ? '"rulesWithObjectInfo":' + rulesWithObjectInfo + ',' : '') 
                            + (search != null && search.length() > 0 ? '"search":' + search + ',' : '[]')
                            + (isTechnicalAttributesEnabled != null ? '"isTechnicalAttributesEnabled":' + isTechnicalAttributesEnabled + ',' : '')
                            + (isAutoSyncEnabled != null ? '"isAutoSyncEnabled":' + isAutoSyncEnabled + ',' : '')
                            + (attachment != null && attachment.length() > 0 ? '"attachment":' + attachment + ',': '[]')
                            + (ibEditProces != null && ibEditProces.length() > 0 ? '"ibEditProces":' + ibEditProces + ',' : '[]')
                            + (locationEditProces != null && locationEditProces.length() > 0 ? '"locationEditProces":' + locationEditProces + ',' : '[]')
                            + (serviceFlowWizardDisplay != null && serviceFlowWizardDisplay.length() > 0 ? '"serviceFlowWizardDisplay":' + serviceFlowWizardDisplay : '[]');
                            
            system.debug('contents: ' + contents);          
            if(contents == null || contents.length() == 0) {
                continue;
            }
            contents = '{' + contents + '}';                
            String profileId = currProfile.profileId;
            SVMXC__ProductIQProfile__c stdProfile;
            SVMXC__ProductIQProfile__c customProfile;
            
            if(ibProfileData.containsKey(profileId)){
                for(SVMXC__ProductIQProfile__c profile : ibProfileData.get(profileId)){
                    if(profile.SVMXC__IsStandard__c){
                        stdProfile = profile;
                    }else{
                        customProfile = profile;
                    }
                }
            }
            
            if(stdProfile == null)
                stdProfile = new SVMXC__ProductIQProfile__c();
            if(customProfile == null)
                customProfile = new SVMXC__ProductIQProfile__c();
            
            //SVMXC__ProductIQProfile__c profile = ibProfileData.containsKey(profileId) ? ibProfileData.get(profileId) : new SVMXC__ProductIQProfile__c();
            customProfile.SVMXC__IsStandard__c = false;
            customProfile.SVMXC__isGlobal__c = false;
            customProfile.SVMXC__Contents__c = contents;
            if(profileId == 'global') {
                customProfile.SVMXC__isGlobal__c = true;
            }else {             
                customProfile.SVMXC__ServiceMax_Profile__c = currProfile.profileId;
            }       
            sProfiles.add(customProfile);
            // PRIQ-1899 - Multiple entries are being made in to 'ProductIQ Profile' table. 
            //Action tab has been removed from Win17 and StdActions would be always null. Hence below code is not required.
            /*if( String.isBlank(stdActions) && stdActions.length() > 0){
                stdActions = '{' + '"actions":' + stdActions + '}';
                
                system.debug('StdActions: ' + stdActions);
                
                stdActions = stdActions.replace('Field Update', 'fieldupdate');
                system.debug('StdActions After Replace: ' + stdActions);
                
                stdProfile.SVMXC__isGlobal__c = false;
                stdProfile.SVMXC__Contents__c = stdActions;
                sProfiles.add(stdProfile);
            }*/
        }
         system.debug('sProfiles: ' + sProfiles); 
        upsert sProfiles;
    }
    public void saveTechnicalAttributesTemplate(ProductIQConfiguration.technicalAttributesTemplate taTemplate){
    
       System.debug(LoggingLevel.Info, 'taTemplate : ' + taTemplate);
       
         System.debug(LoggingLevel.Info, 'templateAttributesDetails : ' + taTemplate.templateAttributesDetails);
       
      
      // System.debug(LoggingLevel.Info, 'applicationCriteria : ' + applicationCriteria);
       
       
       
       SVMXC__SM_Attributes_Template__c atributesTemplate = new SVMXC__SM_Attributes_Template__c( );

          if(taTemplate.templateId != null) {
          atributesTemplate.Id = taTemplate.templateId;
          }
       
       atributesTemplate.SVMXC__SM_Title__c = taTemplate.templateTitle;
       atributesTemplate.SVMXC__SM_Template_Description__c = taTemplate.templateDescription;
       atributesTemplate.SVMXC__SM_Active__c = Boolean.valueOf(taTemplate.templateIsActive);
       atributesTemplate.SVMXC__SM_Attr_Type_Template__c = taTemplate.templateAttributesType;
       atributesTemplate.SVMXC__SM_Template_Json__c = taTemplate.templateAttributesDetails;
       atributesTemplate.SVMXC__SM_Picklist_Id__c = taTemplate.templatePicklistId;
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( atributesTemplate, COMM_SecurityUtils.Access.Upsertable) ) {
             //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            upsert atributesTemplate;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
       
        List<SVMXC__SM_Product_Attributes__c> oldProductAttributesRecs = 
                                            [Select Id from SVMXC__SM_Product_Attributes__c where Id =:atributesTemplate.Id];
       List <ProductIQConfiguration.TAapplicationCriteria> allApplicationCriterias = taTemplate.templateApplicationCriteria;
       List<SVMXC__SM_Product_Attributes__c> allProductAttributes = new List<SVMXC__SM_Product_Attributes__c>();
       
       for(ProductIQConfiguration.TAapplicationCriteria applicationCriteria : allApplicationCriterias){
           
           SVMXC__SM_Product_Attributes__c productAttribute = new SVMXC__SM_Product_Attributes__c();
       
       if(applicationCriteria.criteriaId!= null) {
          productAttribute.Id = applicationCriteria.criteriaId;
          }
          
          
       productAttribute.SVMXC__SM_Attribute_Template_Id__c =   atributesTemplate.Id;
       productAttribute.SVMXC__SM_Product__c =   applicationCriteria.productId; 
       productAttribute.SVMXC__SM_Product_Code__c =   applicationCriteria.productCode; 
       productAttribute.SVMXC__SM_Product_Family__c =   applicationCriteria.productFamily; 
       productAttribute.SVMXC__SM_Product_Line__c =   applicationCriteria.productLine;
       
       allProductAttributes.add(productAttribute);
       }
       upsert allProductAttributes;
       
      /* SVMXC__SM_Product_Attributes__c productAttribute = new SVMXC__SM_Product_Attributes__c();
       
       if(applicationCriteria.productId!= null) {
          productAttribute.Id = applicationCriteria.criteriaId;
          }
       productAttribute.SVMXC__SM_Attribute_Template_Id__c =   atributesTemplate.Id;
       productAttribute.SVMXC__SM_Product__c =   applicationCriteria.productId; 
       productAttribute.SVMXC__SM_Product_Code__c =   applicationCriteria.productCode; 
       productAttribute.SVMXC__SM_Product_Family__c =   applicationCriteria.productFamily; 
       productAttribute.SVMXC__SM_Product_Line__c =   applicationCriteria.productLine;
       upsert productAttribute;
       
       */
      
    }
    public void saveTATemplateCriteria(List<ProductIQConfiguration.Profile> allCriterias){
    
    }
    public void saveProductTemplates(List<ProductIQConfiguration.TemplateHeader> ibTemplates) {
        //insert product template
        Map<String, SVMXC__ProductIQTemplate__c> ibTemplateData = getProductIQTemplatesData();
        List<SVMXC__ProductIQTemplate__c> templates = new List<SVMXC__ProductIQTemplate__c>();
        String templateDetails = null;
        //List of templates that are modified
        List<String> changedTemplates = new List<String>();
        for(ProductIQConfiguration.TemplateHeader currTemplate : ibTemplates) {
            if(currTemplate.template == null) continue; 
            templateDetails = JSON.serialize(currTemplate.template.templateDetails);
            if(templateDetails == null || templateDetails.length() == 0) {
                continue;
            }
            
            String templateID = currTemplate.templateId;
            SVMXC__ProductIQTemplate__c template = ibTemplateData.containsKey(templateID) ? ibTemplateData.get(templateID) : new SVMXC__ProductIQTemplate__c();
            template.Name = currTemplate.templateName;
            template.SVMXC__ProductIQTemplateId__c = currTemplate.templateId;
            template.SVMXC__Contents__c = templateDetails;
            template.SVMXC__TemplateContentDetails__c = JSON.serialize(currTemplate.template.children);
            templates.add(template);
            
            if(template.Id != null) {
                changedTemplates.add(template.Id);
            }
        }
        upsert templates;
        
        //save product configuration
        Map<String, ProductIQConfiguration.Product> productConfiguration = new Map<String, ProductIQConfiguration.Product>();
        for(ProductIQConfiguration.TemplateHeader currTemplate : ibTemplates) {
            ProductIQConfiguration.Template template = currTemplate.template;
            if(template != null && template.children != null && template.children.size() > 0) {
                for(ProductIQConfiguration.Template currTemp : template.children) { 
                    getProductConfiguration(currTemp, productConfiguration);
                }
            }           
        }
        
        //get product configuration information     
        upsertProductConfiguration(productConfiguration);
        //fetch and delete the template detils
        /*deleteProductTemplateDetails(changedTemplates); 
        
        ibTemplateData = getProductIQTemplatesData();
        for(ProductIQConfiguration.TemplateHeader currTemplate : ibTemplates) {
            String templateID = currTemplate.templateId;
            if(currTemplate.template == null) continue; 
            String id = ibTemplateData.get(templateID).Id;
            //insert product template details.
            saveProductTemplateDetails(id, currTemplate.template);
        }*/
        
    }
    
    
    public void upsertProductConfiguration(Map<String, ProductIQConfiguration.Product> productConfiguration) {
        Map<String, SVMXC__ProductConfiguration__c> prodConfigData = getProductConfigurationSF(productConfiguration.keySet());
        List<SVMXC__ProductConfiguration__c> records = new List<SVMXC__ProductConfiguration__c>();
        for(String proId : productConfiguration.keySet()) {
            SVMXC__ProductConfiguration__c proConfig = prodConfigData.containsKey(proId) ? 
                                                        prodConfigData.get(proId) : new SVMXC__ProductConfiguration__c();         
            String contents = JSON.Serialize(productConfiguration.get(proId));
            proConfig.SVMXC__Product__c = proId;
            proConfig.SVMXC__Contents__c = contents;
            records.add(proConfig);
        }
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( records, COMM_SecurityUtils.Access.Upsertable) ) {
             //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
             upsert records;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
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
        
    /*public void saveProductTemplateDetails(String productIQTemplateId, ProductIQConfiguration.Template template) {
        List<SVMXC__ProductIQTemplateDetail__c> templateDetails = new List<SVMXC__ProductIQTemplateDetail__c>();
        Map<String, String> parentExternalIds = new Map<String, String>();
        if(template.children != null && template.children.Size() > 0) {
            getProductTemplateDetails(productIQTemplateId, template.children[0], templateDetails);
            insert templateDetails;
            getParentDetails('', template.children[0], parentExternalIds);
            Map<String, SVMXC__ProductIQTemplateDetail__c> prodTemplateDetials = getProductTemplateDetailsSF(productIQTemplateId);
            for(String currExtId : prodTemplateDetials.keySet()) {
                String parentId = parentExternalIds.get(currExtId); 
                if(prodTemplateDetials.containsKey(currExtId) && prodTemplateDetials.containsKey(parentId)){
                    SVMXC__ProductIQTemplateDetail__c detail = prodTemplateDetials.get(currExtId);
                    detail.SVMXC__ProductIQTemplateDetail__c = prodTemplateDetials.get(parentId).Id;
                }
            }
            update prodTemplateDetials.values();
        }
        
    }
    
    public void getProductTemplateDetails(String productIQTemplateId, ProductIQConfiguration.Template template,
                                                List<SVMXC__ProductIQTemplateDetail__c> templateDetails) {
        
        SVMXC__ProductIQTemplateDetail__c tempDetail = new SVMXC__ProductIQTemplateDetail__c();
        tempDetail.SVMXC__ProductIQTemplate__c = productIQTemplateId;
        tempDetail.SVMXC__Contents__c = JSON.serialize(template.product);
        Datetime objNow = Datetime.now();                
        String extId = GenerateRandomNumber(30);
        tempDetail.SVMXC__ExtId__c = extId;
        //template.externalId = extId;
        if(template.children != null && template.children.size() > 0) {
            for(ProductIQConfiguration.Template currTemp : template.children) {           
                getProductTemplateDetails(productIQTemplateId, currTemp, templateDetails);
            }
        }
        templateDetails.add(tempDetail);        
    }*/
    
    public static string GenerateRandomNumber(integer length) {
        string result = '';
        while(result.length() < length){
            blob privateKey = crypto.generateAesKey(256);
            string randomString = EncodingUtil.base64Encode(crypto.generateMac('hmacSHA512',privateKey,privateKey));
            result += randomString.replaceAll('[^0-9]','');
        }
        result = result.substring(0,length);
        return result;
    }
    
    public void getParentDetails(String parentId, ProductIQConfiguration.Template template, Map<String, String> parentExternalIds) {
        
        //parentExternalIds.put(template.externalId, parentId);
        if(template.children != null && template.children.size() > 0) {
            for(ProductIQConfiguration.Template currTemp : template.children) {           
                //getParentDetails(template.externalId, currTemp, parentExternalIds);
            }
        }       
    }
    
    private void deleteTechnicalAttributeTemplates(List<String> deletedTemplateIds) {
        System.debug('deletedTemplateIds: ' + deletedTemplateIds);
        if(deletedTemplateIds.size() > 0) {
            List<SVMXC__SM_Attributes_Template__c> taTemplates = 
                                            [Select Id from SVMXC__SM_Attributes_Template__c where Id In: deletedTemplateIds];
            
            System.debug('taTemplates: ' + taTemplates);
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SM_Attributes_Template__c' ) ) {  
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                delete taTemplates;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
    } 
    
     private void deleteTechnicalAttributesCriteriaIds(List<String> deletedCriteriaIds) {
        if(deletedCriteriaIds.size() > 0) {
            List< SVMXC__SM_Product_Attributes__c > deleteCriteriasList = 
                                            [Select Id from SVMXC__SM_Product_Attributes__c where Id In: deletedCriteriaIds];
            
           // System.debug('taTemplates: ' + taTemplates);
            delete deleteCriteriasList;
        }
    }
    
     private void deleteProductAttributesForDeletedTechnicalAttributeIds(List<String> deletedTemplateIds) {
        
        System.debug('deleteProductAttributesForDeletedTechnicalAttributeIds: ' + deletedTemplateIds);
        
        if(deletedTemplateIds.size() > 0) {
            List<SVMXC__SM_Product_Attributes__c> productAttributs = 
                                            [Select Id from SVMXC__SM_Product_Attributes__c where SVMXC__SM_Attribute_Template_Id__c In: deletedTemplateIds];
            
            System.debug('deletedTemplateIds: ' + deletedTemplateIds);
            delete productAttributs;
        }
    }
    
    /*
        all the supporting methods goes here
    */
    private void deleteProductTemplates(List<String> deletedTemplateIds) {
        if(deletedTemplateIds.size() > 0) {
            List<SVMXC__ProductIQTemplate__c> ibTemplates = 
                                            [Select Id, SVMXC__ProductIQTemplateId__c from SVMXC__ProductIQTemplate__c where SVMXC__ProductIQTemplateId__c In: deletedTemplateIds];
            delete ibTemplates;
        }
    }    
    
    /*private void deleteProductTemplateDetails(List<String> changedTemplates) {
        List<SVMXC__ProductIQTemplateDetail__c> deleteDetails = [Select Id from SVMXC__ProductIQTemplateDetail__c where 
                                                                        SVMXC__ProductIQTemplate__c =: changedTemplates];
        delete deleteDetails;
    }
    
    private Map<String, SVMXC__ProductIQTemplateDetail__c> getProductTemplateDetailsSF(String productIQTemplateId) {
        List<SVMXC__ProductIQTemplateDetail__c> productTemplateDetails = [Select Id, SVMXC__ExtId__c from SVMXC__ProductIQTemplateDetail__c where     
                                                                        SVMXC__ProductIQTemplate__c =: productIQTemplateId];
        Map<String, SVMXC__ProductIQTemplateDetail__c> extIdTemplateDetails = new Map<String, SVMXC__ProductIQTemplateDetail__c>();
        for(SVMXC__ProductIQTemplateDetail__c currDetail : productTemplateDetails) {
            extIdTemplateDetails.put(currDetail.SVMXC__ExtId__c, currDetail);
        }                                                           
        return extIdTemplateDetails;
    }*/
    
    private string fmtNumByAppendingZero(integer num){
        String returnNumber = String.valueOf(num);
        if(num < 10 && returnNumber.length() == 1){
            returnNumber = 0 + returnNumber;
        }
        return returnNumber;
    }
    
    private Map<String, SVMXC__ProductIQTemplate__c> getProductIQTemplatesData() {
        List<SVMXC__ProductIQTemplate__c> ibTemplates = 
                                            [Select Id, SVMXC__ProductIQTemplateId__c from SVMXC__ProductIQTemplate__c];
        Map<String, SVMXC__ProductIQTemplate__c> result = new Map<String, SVMXC__ProductIQTemplate__c>();
        for(SVMXC__ProductIQTemplate__c currTemplate : ibTemplates) {
            result.put(currTemplate.SVMXC__ProductIQTemplateId__c, currTemplate);
        }
        return result;
    }
    
    /*private List<ProductIQConfiguration.TemplateHeader> getProductIQTemplates() {
        List<SVMXC__ProductIQTemplate__c> ibTemplatesSF = 
                                            [Select Id, Name, SVMXC__ProductIQTemplateId__c, SVMXC__Contents__c, SVMXC__TemplateContentDetails__c from SVMXC__ProductIQTemplate__c];
        List<ProductIQConfiguration.TemplateHeader> ibTemplates = new List<ProductIQConfiguration.IBTemplate>();
        for(SVMXC__ProductIQTemplate__c currTemplate : ibTemplatesSF) {
            ProductIQConfiguration.TemplateHeader ibTemplate = new ProductIQConfiguration.TemplateHeader();
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
        getProductsInfo(ibTemplates);
        return ibTemplates;
    }
    
    private void getProductsInfo(List<ProductIQConfiguration.TemplateHeader> ibTemplates) {
        
        Map<String, ProductIQConfiguration.Product> product = new Map<String, ProductIQConfiguration.Product>();
        for(ProductIQConfiguration.TemplateHeader ibTemplate : ibTemplates) {
            if(ibTemplate.template.children[0] != null) {
                getProductConfiguration(ibTemplate.template.children[0] ,product);
            }
        }
        
        Map<String, SVMXC__ProductConfiguration__c> productInfo = getProductConfigurationSF(product.keySet());
        for(ProductIQConfiguration.TemplateHeader ibTemplate : ibTemplates) {
            
            updateProductConfiguration(ibTemplate.template.children[0], productInfo);
        }
                
    } 
    
    private void updateProductConfiguration(ProductIQConfiguration.Template template, 
                                    Map<String, SVMXC__ProductConfiguration__c> productConfiguration) {
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
        }
        
        if(template.children != null && template.children.size() > 0) {
            for(ProductIQConfiguration.Template currTemp : template.children) {           
                updateProductConfiguration(currTemp, productConfiguration);
            }
        }       
    }*/
    
    private Map<String, List<SVMXC__ProductIQProfile__c>> getProductIQProfilesData() {
        List<SVMXC__ProductIQProfile__c> ibProfiles = 
                                            [Select Id, SVMXC__ServiceMax_Profile__c, SVMXC__IsGlobal__c, SVMXC__IsStandard__c from SVMXC__ProductIQProfile__c];
        Map<String, List<SVMXC__ProductIQProfile__c>> result = new Map<String, List<SVMXC__ProductIQProfile__c>>();
        for(SVMXC__ProductIQProfile__c currProfile : ibProfiles) {
            if(currProfile.SVMXC__IsGlobal__c) {
                result.put('global', new List<SVMXC__ProductIQProfile__c>());
                result.get('global').add(currProfile);
            }
            if(!result.containsKey(currProfile.SVMXC__ServiceMax_Profile__c) || result.get(currProfile.SVMXC__ServiceMax_Profile__c) == null)
                result.put(currProfile.SVMXC__ServiceMax_Profile__c, new List<SVMXC__ProductIQProfile__c>());
            result.get(currProfile.SVMXC__ServiceMax_Profile__c).add(currProfile);
        }
        return result;
    }
    
    private List<InstalligenceLogo> getInstalligenceLogos() {
        List<SObject> lstInstLogosData = [Select Id, Name, DeveloperName from Document 
                                    where Keywords like '%PRODUCTIQ_PRODUCT_ICON%' Order By Name];
        InstalligenceLogo logo = null;
        List<InstalligenceLogo> logos = new List<InstalligenceLogo>();
        for(SObject currRec : lstInstLogosData) {
            logo = new InstalligenceLogo();
            logo.name = (String)currRec.get('Name');
            logo.uniqueName = (String)currRec.get('DeveloperName');
            logo.logoId = (String)currRec.get('Id');
            logos.add(logo);
        }
        return logos;
    }
    
    private List<SForceObject> getObjectDescribes(List<String> objectNames) {
        
        // sObject types to describe                    
        //String[] types = new String[]{objectName};      
        // Make the describe call
        List<SForceObject> objectDescribeInfos = new List<SForceObject>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(objectNames);
        for(Schema.DescribeSobjectResult res : results){
            SForceObject objectDescribeInfo = new SForceObject();
            objectDescribeInfo.objectLabel = res.getLabel();
            objectDescribeInfo.objectAPIName = res.getName();
            objectDescribeInfo.fields = getFields(res);
            objectDescribeInfos.add(objectDescribeInfo);
        }       
        return objectDescribeInfos;
    }
    
    private List<SForceField> getFields(Schema.DescribeSobjectResult objectDescribeRes) {
        
        List<SForceField> allFieldsInfo = new List<SForceField>();
        SForceField field = null;
        Map<String, Schema.SObjectField> objectFields = objectDescribeRes.fields.getMap();
        for (String fieldName : objectFields.keySet()) {
            field = new SForceField();
            Schema.DescribeFieldResult dfr = objectFields.get(fieldName).getDescribe();
            field.fieldAPIName = dfr.getName();
            field.fieldLabel = dfr.getLabel();
            field.type = dfr.getType() + '';
            if(field.type == 'REFERENCE'){              
                field.referenceTo = dfr.getReferenceTo()[0] + '';
            }
            if(field.type == 'PICKLIST'){              
                field.picklistValues = getPickListValues(dfr);
            }
            field.relationshipName = dfr.getRelationshipName();
            field.nameField = dfr.nameField;
            field.fieldLength = dfr.getLength();
            allFieldsInfo.add(field);
        }    
        return allFieldsInfo;
    }
    
    
    private List<SForcePickListValues> getPickListValues(Schema.DescribeFieldResult pickListField){
        
        List<SForcePickListValues> values = new List<SForcePickListValues>();
        
        List<Schema.PicklistEntry> pickListValues = pickListField.getPicklistValues();
        SForcePickListValues pValue = null;
        for( Schema.PicklistEntry f : pickListValues){
         pValue = new SForcePickListValues();
         pValue.fieldLabel = f.getLabel();
         pValue.fieldName = f.getValue();
         values.add(pValue);
        }
        
                
           return values;
        }
    
    private List<ProductIQConfiguration.Profile> getSVMXProfiles() {
        
        List<ProductIQConfiguration.Profile> lstSVMXProfiles = new List<ProductIQConfiguration.Profile>();
        List<SObject> lstProfileData = exexuteSVMXProfilesQuery();
        Map<String, List<SVMXC__ProductIQProfile__c>> ibProfileData = getIBProfilesData();                      
        ProductIQConfiguration.Profile objProfile = null;
        String id, profileName, contents;   
        
        for(SObject currRec : lstProfileData) {
        
            id = (String)currRec.get('Id');                 
            profileName = (String)currRec.get('SVMXC__PROFILE_NAME__c');
            objProfile = new ProductIQConfiguration.Profile(id, profileName);
            if(ibProfileData.containsKey(id)) {
                for(SVMXC__ProductIQProfile__c proIQProfile : ibProfileData.get(id)){
                    contents = proIQProfile.SVMXC__Contents__c;
                    if(contents.length() > 0) {
                        system.debug(LoggingLevel.Debug, 'contents = ' + contents);
                        ProductIQConfiguration.Profile prof = (ProductIQConfiguration.Profile)
                                                                JSON.deserialize(contents, ProductIQConfiguration.Profile.class);
                        if(proIQProfile.SVMXC__IsStandard__c)
                            objProfile.stdActions = prof.actions;
                        else{
                            objProfile.actions = prof.actions;
                            objProfile.filters = prof.filters;
                            objProfile.search = prof.search;
                            objProfile.isTechnicalAttributesEnabled = prof.isTechnicalAttributesEnabled;
                            objProfile.isAutoSyncEnabled = prof.isAutoSyncEnabled;
                            objProfile.attachment = prof.attachment;
                            objProfile.ibEditProces = prof.ibEditProces;
                            objProfile.locationEditProces = prof.locationEditProces;
                            objProfile.serviceFlowWizardDisplay = prof.serviceFlowWizardDisplay;
                        }
                        
                        objProfile.rulesWithObjectInfo = prof.rulesWithObjectInfo;
                    }
                }
            }
            lstSVMXProfiles.add(objProfile);
        }
        
        if(ibProfileData.containsKey('global')) {
            id = 'global'; 
            objProfile = new ProductIQConfiguration.Profile(id, '');
            contents = ibProfileData.get(id)[0].SVMXC__Contents__c;
            if(contents.length() > 0) {
                ProductIQConfiguration.Profile prof = (ProductIQConfiguration.Profile)
                                                        JSON.deserialize(contents, ProductIQConfiguration.Profile.class);
                objProfile.actions = prof.actions;
                objProfile.filters = prof.filters;
                objProfile.isTechnicalAttributesEnabled = prof.isTechnicalAttributesEnabled;
                objProfile.isAutoSyncEnabled = prof.isAutoSyncEnabled;
                objProfile.attachment = prof.attachment;
                objProfile.ibEditProces = prof.ibEditProces;
                objProfile.locationEditProces = prof.locationEditProces;
            }
            lstSVMXProfiles.add(objProfile);
        }                       
        return lstSVMXProfiles;        
    }
    
    private Map<String, List<SVMXC__ProductIQProfile__c>> getIBProfilesData() {
        List<SVMXC__ProductIQProfile__c> ibProfileData = [Select Id, SVMXC__Contents__c, SVMXC__ServiceMax_Profile__c, 
                          SVMXC__IsGlobal__c, SVMXC__IsStandard__c from SVMXC__ProductIQProfile__c];
        Map<String, List<SVMXC__ProductIQProfile__c>> profileProductData = new Map<String, List<SVMXC__ProductIQProfile__c>>();
        for(SVMXC__ProductIQProfile__c currProfile : ibProfileData) {
            if(!currProfile.SVMXC__IsGlobal__c) {
                if(!profileProductData.containsKey(currProfile.SVMXC__ServiceMax_Profile__c) || profileProductData.get(currProfile.SVMXC__ServiceMax_Profile__c) == null)
                    profileProductData.put(currProfile.SVMXC__ServiceMax_Profile__c, new List<SVMXC__ProductIQProfile__c>());
                profileProductData.get(currProfile.SVMXC__ServiceMax_Profile__c).add(currProfile);
            }else {
                profileProductData.put('global', new List<SVMXC__ProductIQProfile__c>());
                profileProductData.get('global').add(currProfile);
            }
            
        }
        return profileProductData;
    }
    
    private List<SObject> exexuteSVMXProfilesQuery() {
        List<SObject> lstProfileData = [Select Id, SVMXC__PROFILE_NAME__c from SVMXC__ServiceMax_Config_Data__c 
                                    where RecordType.Name = 'Configuration Profile' and  SVMXC__Active__c = true and SVMXC__CONFIGURATION_TYPE__c = 'Group' Order By SVMXC__PROFILE_NAME__c];
        return lstProfileData;
    }
    
    private List<IBValueMaps> getIBValueMappings() {
        List<IBValueMaps> lstIBValueMappings = new List<IBValueMaps>();
        List<SObject> lstIBValueMapData = [Select Id, SVMXC__MapID__c, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c    
                                    where RecordType.Name = 'Object Mapping' and  SVMXC__Target_Object_Name__c = 'SVMXC__Installed_Product__c' 
                                    and SVMXC__Source_Object_Name__c = '' Order By SVMXC__Name__c];
        IBValueMaps objValueMap = null;
        String id, valueMapName;                        
        for(SObject currRec : lstIBValueMapData) {
            id = (String)currRec.get('Id');
            valueMapName = (String)currRec.get('SVMXC__MapID__c');
            //objValueMap = new IBValueMaps(id, valueMapName);
            objValueMap = new IBValueMaps(id, valueMapName, (String)currRec.get('SVMXC__Name__c'));
            lstIBValueMappings.add(objValueMap);
        }                       
        return lstIBValueMappings;     
    }
    
    private List<IBActionURL> getIBActionURL(){
        List<IBActionURL> lstIBActionURL = new List<IBActionURL>();
        List<SObject> lstIBActionURLData = [select Id, SVMXC__Name__c, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c 
                                                where RecordType.Name = 'SF Action'and SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c' 
                                                Order By SVMXC__Name__c];
        
        IBActionURL objActionURL = null;
        for(SObject currRec : lstIBActionURLData){
            objActionURL = new IBActionURL((String)currRec.get('Id'), (String)currRec.get('SVMXC__ProcessID__c'), (String)currRec.get('SVMXC__Name__c'));
            lstIBActionURL.add(objActionURL);
        }
        return lstIBActionURL;
    }

    private ProductIQConfiguration.SearchObject getSearchConf(){
        List<SVMXC__ServiceMax_Processes__c> searchQryData = [Select SVMXC__Module__c,SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Module__r.SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where SVMXC__Module__r.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH' and SVMXC__Target_Object_Name__c = 'SVMXC__Installed_Product__c'];

        List<ProductIQConfiguration.Search> searchData = new List<ProductIQConfiguration.Search>();
        Set<String> allUniqueSearchIds = new Set<String>();
        for(SVMXC__ServiceMax_Processes__c currProc : searchQryData){
            String searchId = currProc.SVMXC__Module__r.SVMXC__ProcessID__c;
            if(allUniqueSearchIds.contains(searchId)) continue;
            ProductIQConfiguration.Search search = new ProductIQConfiguration.Search();
            search.searchName = currProc.SVMXC__Module__r.SVMXC__ProcessID__c;
            search.searchLabel = currProc.SVMXC__Module__r.SVMXC__Name__c;
            search.sfdcId = currProc.SVMXC__Module__c;
            Integer moduleCount = [Select count() from SVMXC__ServiceMax_Processes__c  WHERE SVMXC__Module__c =:currProc.SVMXC__Module__c];
            if(moduleCount == 1){
                searchData.add(search);
              }
        }
        ProductIQConfiguration.SearchObject avsearch = new ProductIQConfiguration.SearchObject();
        avsearch.objectName = 'SVMXC__Installed_Product__c';
        avsearch.searches = searchData;
        return avsearch;
    }

    private List<ProductIQConfiguration.IBEditProces> getIBEditProcessConfig(){
        List<SVMXC__ServiceMax_Processes__c> ibEditProcessQryData = [SELECT Id,SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Purpose__c = 'STANDALONE EDIT' AND SVMXC__Page_Layout__r.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c'];

        List<ProductIQConfiguration.IBEditProces> ibEditProcessData = new List<ProductIQConfiguration.IBEditProces>();
        
        for(SVMXC__ServiceMax_Processes__c currProc : ibEditProcessQryData){
            
            ProductIQConfiguration.IBEditProces ibEditProces = new ProductIQConfiguration.IBEditProces();
            ibEditProces.sfdcId = currProc.Id;
            ibEditProces.processId = currProc.SVMXC__ProcessID__c;
            ibEditProces.processName = currProc.SVMXC__Name__c;
            ibEditProces.objectName = 'SVMXC__Installed_Product__c';
            ibEditProcessData.add(ibEditProces);
            
        }
        
        return ibEditProcessData;
    }
    
    private List<ProductIQConfiguration.LocationEditProces> getLocationEditProcessConfig(){
        List<SVMXC__ServiceMax_Processes__c> locationEditProcessQryData = [SELECT Id,SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Purpose__c = 'STANDALONE EDIT' AND SVMXC__Page_Layout__r.SVMXC__Object_Name__c = 'SVMXC__Site__c'];

        List<ProductIQConfiguration.LocationEditProces> locationEditProcessData = new List<ProductIQConfiguration.LocationEditProces>();
        
        for(SVMXC__ServiceMax_Processes__c currProc : locationEditProcessQryData){
            
            ProductIQConfiguration.LocationEditProces locationEditProces = new ProductIQConfiguration.LocationEditProces();
            locationEditProces.sfdcId = currProc.Id;
            locationEditProces.processId = currProc.SVMXC__ProcessID__c;
            locationEditProces.processName = currProc.SVMXC__Name__c;
            locationEditProces.objectName = 'SVMXC__Site__c';
            locationEditProcessData.add(locationEditProces);
            
        }
      
        
        return locationEditProcessData;
    }
    
    private List<ProductIQConfiguration.DataValidationRulesWithObjectInfo> getDataValidationRules(){
        List<ProductIQConfiguration.DataValidationRulesWithObjectInfo> rules = new List<ProductIQConfiguration.DataValidationRulesWithObjectInfo>();
        List<string> lstObjs = new List<String>{'SVMXC__Installed_Product__c','SVMXC__Sub_Location__c','SVMXC__Site__c'};
        List<SObject> lstDVRules = [select id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Parent_Error_Msg__c, SVMXC__ProcessID__c, SVMXC__Source_Object_Name__c, SVMXC__Advance_Expression__c, SVMXC__Message_Type__c from SVMXC__ServiceMax_Processes__c where SVMXC__Source_Object_Name__c IN: lstObjs AND RecordType.Name = 'Business Rule'];
        map<string, List<ProductIQConfiguration.DataValidationRuleInfo>> mpObjRules = new map<string, List<ProductIQConfiguration.DataValidationRuleInfo>>();
        for(SObject DVR: lstDVRules){
            ProductIQConfiguration.DataValidationRuleInfo ruleInfo = new ProductIQConfiguration.DataValidationRuleInfo(
                string.valueOf(DVR.get('SVMXC__ProcessID__c')), string.valueOf(DVR.get('SVMXC__Name__c')), 
                string.valueOf(DVR.get('SVMXC__Description__c')), string.valueOf(DVR.get('SVMXC__Message_Type__c')),
                string.valueOf(DVR.get('SVMXC__Source_Object_Name__c')), string.valueOf(DVR.get('SVMXC__Advance_Expression__c')), 
                string.valueOf(DVR.get('SVMXC__Parent_Error_Msg__c')));
            
            if(!mpObjRules.containsKey(string.valueOf(DVR.get('SVMXC__Source_Object_Name__c'))) || mpObjRules.get(string.valueOf(DVR.get('SVMXC__Source_Object_Name__c'))) == null)
                mpObjRules.put(string.valueOf(DVR.get('SVMXC__Source_Object_Name__c')), new List<ProductIQConfiguration.DataValidationRuleInfo>());
            
            mpObjRules.get(string.valueOf(DVR.get('SVMXC__Source_Object_Name__c'))).add(ruleInfo);
        }
        
        for(string objName :mpObjRules.keyset()){
            ProductIQConfiguration.DataValidationRulesWithObjectInfo obj = new ProductIQConfiguration.DataValidationRulesWithObjectInfo(objName, mpObjRules.get(objName));
            rules.add(obj);
        }
        
        return rules;
    }
    
    public String expressionParser(ProductIQConfiguration.Expression expression, Map<Integer, String> expressions) {
        
        String advancedExpression = '';
        if(expression.exprType == 'expression') {
            expressions.put(expressions.keySet().size(), '');
            advancedExpression = expressions.keySet().size() + '';
        }else if(expression.exprType == 'operator' || expression.exprType == 'operatorroot') {
            if(expression.children != null && expression.children.size() > 0){
                
                for(ProductIQConfiguration.Expression currExpression : expression.children) {
                    if(expression.children.size() > 1 && advancedExpression.length() > 0) {
                        advancedExpression = advancedExpression + ' ' + expression.operator + ' ';
                    }
                    advancedExpression = advancedExpression + expressionParser(currExpression, expressions);                    
                }
                
                if(expression.children.size() > 1) {
                    advancedExpression = '( ' + advancedExpression + ' )';
                }
            } 
        }
        return advancedExpression;
                
    }

    public ProductIQConfiguration.TechnicalAttributePicklistDefinition saveTechnicalAttributePicklistDefinition(String request){
      
      ProductIQConfiguration.TechnicalAttributePicklistDefinition technicalAttributePicklistDefinition = 
                            (ProductIQConfiguration.TechnicalAttributePicklistDefinition)JSON.deserialize(request, ProductIQConfiguration.TechnicalAttributePicklistDefinition.class);
      SVMXC__SM_TA_Picklist_Definition__c picklistDefinition = new SVMXC__SM_TA_Picklist_Definition__c();
      system.debug(technicalAttributePicklistDefinition);
      if(technicalAttributePicklistDefinition != null){
        if(technicalAttributePicklistDefinition.sfdcId != null){
            picklistDefinition.Id = technicalAttributePicklistDefinition.sfdcId;
            technicalAttributePicklistDefinition.isValidPicklistDefinition = true;
            List<SVMXC__SM_TA_Picklist_Definition__c> selectedPicklist = [select Id from SVMXC__SM_TA_Picklist_Definition__c where SVMXC__SM_Name__c = :technicalAttributePicklistDefinition.name]; 
            
            if(!selectedPicklist.isEmpty()){
              String pickListId = String.valueOf(selectedPicklist[0].Id);
              if(!pickListId.equals(technicalAttributePicklistDefinition.sfdcId)){
                technicalAttributePicklistDefinition.isValidPicklistDefinition = false;
                return technicalAttributePicklistDefinition;
              }
              
            }
        }else{
            List<SVMXC__SM_TA_Picklist_Definition__c> selectedPicklist = [select Id from SVMXC__SM_TA_Picklist_Definition__c where SVMXC__SM_Name__c = :technicalAttributePicklistDefinition.name]; 
            if(!selectedPicklist.isEmpty()){
              technicalAttributePicklistDefinition.isValidPicklistDefinition = false;
              return technicalAttributePicklistDefinition;
            }else{
              technicalAttributePicklistDefinition.isValidPicklistDefinition = true;
            }
       }
           
        picklistDefinition.SVMXC__SM_Name__c = technicalAttributePicklistDefinition.name;
        picklistDefinition.SVMXC__SM_Description__c = technicalAttributePicklistDefinition.description;
        picklistDefinition.SVMXC__SM_Values__c = JSON.serialize(technicalAttributePicklistDefinition.picklistValues);
      }

      
      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(picklistDefinition, COMM_SecurityUtils.Access.Upsertable)){
                    upsert picklistDefinition;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }  
      technicalAttributePicklistDefinition.sfdcId = picklistDefinition.Id;
      return technicalAttributePicklistDefinition;
    }
    
   public String deleteTechnicalAttributePicklistDefinition (String picklistId){
      if(!String.isEmpty(picklistId)) {
             SVMXC__SM_TA_Picklist_Definition__c  deletePicklistDefinition = 
                                            [Select Id from SVMXC__SM_TA_Picklist_Definition__c where Id = :picklistId];            

                if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SM_TA_Picklist_Definition__c' ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    delete deletePicklistDefinition;
        }
        return picklistId;
    }
    
    /*
        Translations goes here
    */
    
    public List<Translation> getTranslations() {
        List<Translation> translations = new List<Translation>();
        translations.add(new Translation('NONE', system.Label.COMM002_TAG005));//'--None--'
        translations.add(new Translation('FIELD_UPDATE', system.Label.PRODIQ001_TAG001));//'Field Update'      
        translations.add(new Translation('USERACTIONS_FILTERS', system.Label.PRODIQ001_TAG002));//'User Actions & Filters'
        translations.add(new Translation('EXTERNAL_APP', system.Label.PRODIQ001_TAG003));//'External App'
        translations.add(new Translation('FILTERS', system.Label.COMM001_TAG134));//'Filters'
        translations.add(new Translation('USERACTIONS', system.Label.PRODIQ001_TAG059));//'User Actions'
        translations.add(new Translation('TEMPLATES', system.Label.PRODIQ001_TAG004));//'IB Templates'
        translations.add(new Translation('OTHERSETTINGS', system.Label.PRODIQ001_TAG060 ));//'Other Settings'
        translations.add(new Translation('UAF_GRID_COL_NAME', system.Label.PRODIQ001_TAG061));// 'Name'         
        translations.add(new Translation('UAF_GRID_COL_TYPE', system.Label.PRODIQ001_TAG062));//'Type'         
        translations.add(new Translation('UAF_GRID_COL_ACTION', system.Label.PRODIQ001_TAG063));//'Action'         
        translations.add(new Translation('UAF_GRID_COL_ISGLOBAL', system.Label.PRODIQ001_TAG064));//'Is Global'        
        translations.add(new Translation('SELECT_PROFILE', system.Label.PRODIQ001_TAG005));//'Select a profile'                        
        translations.add(new Translation('SETUP_TITLE', system.Label.PRODIQ001_TAG006));//'ProductIQ Setup'                        
        translations.add(new Translation('TEMPLATE_NAME', system.Label.PRODIQ001_TAG065));//'Template Name'                
        translations.add(new Translation('TEMPLATE_ID', system.Label.PRODIQ001_TAG007));//'Template id'                
        translations.add(new Translation('IB_DISPLAY_TEXT', system.Label.PRODIQ001_TAG008));//'IB Display Text'                
        translations.add(new Translation('LOCATION_DISPLAY_TEXT', system.Label.PRODIQ001_TAG009));//'Location Display Text'                
        translations.add(new Translation('SUB_LOCATION_DISPLAY_TEXT', system.Label.PRODIQ001_TAG010));//'Sub-Location Display Text'                        
        translations.add(new Translation('PRODUCT', system.Label.PRODIQ001_TAG066)); // 'Product'                       
        translations.add(new Translation('ICON', system.Label.PRODIQ001_TAG011)); //'Icon'                     
        translations.add(new Translation('DEFAULT_VALUES', system.Label.PRODIQ001_TAG012));//'Default values'                      
        translations.add(new Translation('VALUE_MAP_OLD_IB', system.Label.PRODIQ001_TAG013));//'Value map for old IB'                      
        translations.add(new Translation('VALUE_MAP_NEW_IB', system.Label.PRODIQ001_TAG014));//'Value map for new IB'                      
        translations.add(new Translation('SELECT_TEMPLATE', system.Label.PRODIQ001_TAG067));//'Select a template'                      
        translations.add(new Translation('PRODUCT_SWAP', system.Label.PRODIQ001_TAG015));//'Product Swap'                      
        translations.add(new Translation('PRODUCT_CONFIGURATION', system.Label.PRODIQ001_TAG068));//'Product Configuration'    
        translations.add(new Translation('SELECTED_EXPR', system.Label.PRODIQ001_TAG017));//'Selected Expression'                      
        translations.add(new Translation('ADD_CONDITION', system.Label.PRODIQ001_TAG018));//'Add Condition'                        
        translations.add(new Translation('ADD_GROUP', system.Label.PRODIQ001_TAG019));//'Add Group'                        
        translations.add(new Translation('CHANGE_GROUP', system.Label.PRODIQ001_TAG020));//'Change Group'                      
        translations.add(new Translation('DELETE_GROUP', system.Label.PRODIQ001_TAG021));//'Delete Group'                              
        translations.add(new Translation('AND', system.Label.PRODIQ001_TAG069));//'And'                                
        translations.add(new Translation('OR', system.Label.PRODIQ001_TAG022));//'Or'                                                  
        translations.add(new Translation('NOT_AND', system.Label.PRODIQ001_TAG023));//'Not And'                                                    
        translations.add(new Translation('NOT_OR', system.Label.PRODIQ001_TAG024));//'Not Or'                                                  
        translations.add(new Translation('SEARCH_EMPTY_TEXT', system.Label.PRODIQ001_TAG053));//'Search'                                                   
        translations.add(new Translation('ADD_PRODUCT', system.Label.PRODIQ001_TAG070));//'Add Product'                                                   
        translations.add(new Translation('DEL_PRODUCT', system.Label.PRODIQ001_TAG074));//Delete Product                                                     
        translations.add(new Translation('ENTER_VALUE', system.Label.PRODIQ001_TAG025));//'enter a value'                                                      
        translations.add(new Translation('OTHER_SET_SWAP_TEXT', system.Label.PRODIQ001_TAG026));//'Automatically copy configuration while swapping products'                               
        translations.add(new Translation('STARTS_WITH', system.Label.COMM002_TAG012));//'Starts With'                                
        translations.add(new Translation('NOT_EQUAL', system.Label.COMM002_TAG007));//'Not Equal'                                
        translations.add(new Translation('LESS_OR_EQUAL', system.Label.COMM002_TAG011));//'Less or Equal To'                                 
        translations.add(new Translation('LESS_THAN', system.Label.COMM002_TAG010));//'Less Than'                                
        translations.add(new Translation('ISNULL', system.Label.COMM002_TAG022));//'Is Null'                                 
        translations.add(new Translation('ISNOTNULL', system.Label.COMM002_TAG023));//'Is Not Null'                                  
        translations.add(new Translation('INCLUDES', system.Label.COMM002_TAG015));//'Includes'                                  
        translations.add(new Translation('GREATER_OR_EQUAL', system.Label.COMM002_TAG009));//'Greater or Equal To'                                   
        translations.add(new Translation('GREATER_THAN', system.Label.COMM002_TAG008));//'Greater Than'                                  
        translations.add(new Translation('EXCLUDES', system.Label.COMM002_TAG016));//'Excludes'                                  
        translations.add(new Translation('EQUALS', system.Label.COMM002_TAG006));//'Equals'                                  
        translations.add(new Translation('DOES_NOT_CONTAIN', system.Label.COMM002_TAG014));//'Does Not Contain'                                  
        translations.add(new Translation('CONTAINS', system.Label.COMM001_TAG013));//'Contains'      
        translations.add(new Translation('CREATE', system.Label.PRODIQ001_TAG071 ));//'Create'
        translations.add(new Translation('CANCEL', system.Label.COMM001_TAG040));//'Cancel'
        translations.add(new Translation('MANDATORY_FIELDS', system.Label.COMM001_TAG073));//'Please enter values for all the mandatory fields'
        translations.add(new Translation('MESSAGE_INFO', system.Label.PRODIQ001_TAG056));//'Info'
        translations.add(new Translation('MESSAGE_SUCCESS', system.Label.COMM001_TAG096));//'Success'
        translations.add(new Translation('MESSAGE_ERROR', system.Label.PRODIQ001_TAG057));//'Error'
        translations.add(new Translation('MESSAGE_CONFIRM', system.Label.PRODIQ001_TAG058));//'Confirm'
        translations.add(new Translation('MESSAGE_PRODUCT', system.Label.PRODIQ001_TAG066));//'Product'
        translations.add(new Translation('STANDARD_ACTIONS', system.Label.PRODIQ001_TAG075));//'Standard Actions'
        translations.add(new Translation('CUSTOM_ACTIONS', system.Label.PRODIQ001_TAG076));//'Custom Actions'
        translations.add(new Translation('HIDE_STANDARD_ACTIONS', system.Label.PRODIQ001_TAG077));//'Hide'
        translations.add(new Translation('DATA_VALIDATION_RULE', system.Label.PRODIQ001_TAG078));//'Data Validation Rules'
        translations.add(new Translation('SELECT_OBJECT', system.Label.PRODIQ001_TAG079));//'Select an Object'
        translations.add(new Translation('RULE_NAME', system.Label.PRODIQ001_TAG080));//'Rule Name'
        translations.add(new Translation('DESCRIPTION', system.Label.PRODIQ001_TAG081));//'Description'
        translations.add(new Translation('MESSAGE_TYPE', system.Label.PRODIQ001_TAG082));//'Message Type'
        translations.add(new Translation('MESSAGE_ERRORS', system.Label.PRODIQ001_TAG083));//'Error(s)'
        translations.add(new Translation('MESSAGE_WARNINGS', system.Label.PRODIQ001_TAG084));//'Warning(s)'
        translations.add(new Translation('CUSTOM_URL', system.Label.PRODIQ001_TAG085));//'Custom URL'
        translations.add(new Translation('SAVE_SUCCESS', system.Label.COMM001_TAG058));//'Record(s) saved successfully'
        translations.add(new Translation('CANCEL', system.Label.PRODIQ001_TAG098));//'Cancel'
        translations.add(new Translation('SELECT_SEARCH', system.Label.PRODIQ001_TAG086));
        translations.add(new Translation('OK_BTN', system.Label.PRODIQ001_TAG112));//'Ok'
        translations.add(new Translation('APPLICATION_CRITERIA', system.Label.PRODIQ001_TAG129));//'Application Criteria ( Select one)'
        translations.add(new Translation('DEFINE_TA_SECTION', system.Label.PRODIQ001_TAG130));//'Define Technical Attribute Section'
        translations.add(new Translation('TA_TEMPLATE', system.Label.PRODIQ001_TAG128));//'Technical Attributes Template'
        translations.add(new Translation('REMOVE_SECTION', system.Label.PRODIQ001_TAG131));//'Remove Section'
        translations.add(new Translation('ADD_SECTION', system.Label.PRODIQ001_TAG132));//'ADD Section'
        translations.add(new Translation('ATTRIBUTE_NAME', system.Label.PRODIQ001_TAG133));//'Attribute Name'
        translations.add(new Translation('TEMPLATE_NAME', system.Label.PRODIQ001_TAG134));//'Template Name'
        translations.add(new Translation('SECTION_NAME', system.Label.PRODIQ001_TAG135));//'Section Name'
        translations.add(new Translation('ENABLE_TECHNICAL_ATTRIBUTES', system.Label.PRODIQ001_TAG136));//'Enable Technical Attributes'
        translations.add(new Translation('TEMPLATE_DESCRIPTION', system.Label.PRODIQ001_TAG137));//'Template Description'
        translations.add(new Translation('TECHNICAL_ATTRIBUTES', system.Label.PRODIQ001_TAG150));//'Techncal Attributes'
        translations.add(new Translation('DESCRIPTION', system.Label.PRODIQ001_TAG153));//'Description'
        translations.add(new Translation('PRODUCT_LINE', system.Label.PRODIQ001_TAG154));//'Product Line'
        translations.add(new Translation('PRODUCT_FAMILY', system.Label.PRODIQ001_TAG155));//'Product Family'
        translations.add(new Translation('FORMATE', system.Label.PRODIQ001_TAG156));//'Formate'
        translations.add(new Translation('TYPE', system.Label.PRODIQ001_TAG157));//'Type'
        translations.add(new Translation('UNIT', system.Label.PRODIQ001_TAG158));//'Unit'
        translations.add(new Translation('READY_ONLY', system.Label.PRODIQ001_TAG159));//'Ready Only'
        translations.add(new Translation('DEFAULT_VALUES', system.Label.PRODIQ001_TAG160));//'Default Values'
        translations.add(new Translation('TEMPLATE_SAVE_UNSUCCESSFULL', system.Label.PRODIQ001_TAG161));//'Save unsuccessful. Template for existing product, product family, or product line already exists.'
        translations.add(new Translation('SELECT_SFM_FOR_OVERVIEW_LAYOUT', system.Label.PRODIQ001_TAG162));//'Select SFM for Overview Layout  '
        translations.add(new Translation('ENABLE_ATTACHMENTS_DOWNLOAD_DURING_SYNC', system.Label.PRODIQ001_TAG163));//'Enable attachments download during sync '
        translations.add(new Translation('DOWNLOAD_ONLY_THESE_FILES_TYPE', system.Label.PRODIQ001_TAG164));//'Download only these files types (comma separated)'
        translations.add(new Translation('ENTER_MAXIMUM_FILES_SIZE_TO_DOWNLOAD', system.Label.PRODIQ001_TAG165));//'Enter maximum file size to download (MB)  '
        translations.add(new Translation('INSTALLED_PRODUCT', system.Label.PRODIQ001_TAG166));//'Installed Product'
        translations.add(new Translation('LOCATION', system.Label.PRODIQ001_TAG167));//'Location'
        translations.add(new Translation('ATTACHMENTS', system.Label.PRODIQ001_TAG168));//'Attachments'
        translations.add(new Translation('RESTRICTED_RELEASE_FEATURE', system.Label.CONF032_TAG069));//'* - Restricted Release Feature. Contact support to participate in the program'
        translations.add(new Translation('LAYOUT_AND_ACTION', system.Label.PRODIQ001_TAG169));//'Layout And Action '
        translations.add(new Translation('TOO_LONG', system.Label.PRODIQ001_TAG170));//'TOO LONG'
        translations.add(new Translation('MANDATORY_FIELDS_TA_TEMPLATE', system.Label.PRODIQ001_TAG171));//'Please fill required fields in Technical Attributes template.'
        translations.add(new Translation('MISSING_OR_INCORRECT_ENTRY', system.Label.PRODIQ001_TAG172));//'Missing or Incorrect Entry.'
        translations.add(new Translation('SELECT', system.Label.PRODIQ001_TAG173));//'Select...'
        translations.add(new Translation('PICKLIST_NAME', system.Label.PRODIQ001_TAG174));//'Picklist Name'
        translations.add(new Translation('PICKLIST_DESCRIPTION', system.Label.PRODIQ001_TAG175));//'Picklist Description'
        translations.add(new Translation('APPLY', system.Label.PRODIQ001_TAG176));//'Apply'
        translations.add(new Translation('PICKLIST_VALUES', system.Label.PRODIQ001_TAG177));//'Picklist Values' 
        translations.add(new Translation('PICKLIST_CHECKBOX_FIELD_NAME', system.Label.PRODIQ001_TAG178));//'Use first value as a default value' 
        translations.add(new Translation('DELETE', system.Label.PRODIQ001_TAG179));//'Delete'
        translations.add(new Translation('EDIT', system.Label.PRODIQ001_TAG180));//'Edit'
        translations.add(new Translation('CONFIRM_DELETE', system.Label.PRODIQ001_TAG181));//'Confirm Delete'
        translations.add(new Translation('ARE_YOU_SURE', system.Label.PRODIQ001_TAG182));//'Are you sure?'
        translations.add(new Translation('PICKLIST_SELECTION', system.Label.PRODIQ001_TAG183));//'Picklist Selection'
        translations.add(new Translation('PICKLIST_DEFINATION', system.Label.PRODIQ001_TAG184));//'Picklist Defination'
        translations.add(new Translation('ADD', system.Label.PRODIQ001_TAG185));//'Picklist Defination'
        translations.add(new Translation('SERVICE_FLOW_WIZARD_DISPLAY', system.Label.PRODIQ001_TAG186));//'Service Flow Wizard Display'
        translations.add(new Translation('ENABLE_OPEN_TREE_VIEW_ON_IB', system.Label.PRODIQ001_TAG187));//'Enable 'Open Tree View' action on Installed Product Record'
        translations.add(new Translation('ENABLE_OPEN_TREE_VIEW_ON_LOCATION', system.Label.PRODIQ001_TAG188));//'Enable 'Open Tree View' action on Location Record'
        translations.add(new Translation('ENABLE_OPEN_TREE_VIEW_ON_WO', system.Label.PRODIQ001_TAG189));//'Enable 'Open Tree View' action on Work Order Record'
        translations.add(new Translation('PICKLIST_DISPLAY_MESSAGE', system.Label.PRODIQ001_TAG190));//'Enter values, each separated by a new line.'
        translations.add(new Translation('PICKLIST_ERROR_MESSAGE', system.Label.PRODIQ001_TAG191));//'Picklist not selected.'
        translations.add(new Translation('SAVE', system.Label.PRODIQ001_TAG192));//'Save'
        translations.add(new Translation('BACK_TO_SETUP_HOME', system.Label.PRODIQ001_TAG193));//'Back To Setup Home'
        translations.add(new Translation('PICKLIST_EXITS_ERROR_MESSAGE', system.Label.PRODIQ001_TAG194));//'Picklist Name already exists.'
        translations.add(new Translation('PRODUCT_LIST', system.Label.PRODIQ001_TAG195));//'Product List'
        translations.add(new Translation('GO', system.Label.PRODIQ001_TAG139));//'Product List'
        translations.add(new Translation('NEXT', system.Label.PRODIQ001_TAG196));//'Next'
        translations.add(new Translation('PREVIOUS', system.Label.PRODIQ001_TAG197));//'Previous'
        translations.add(new Translation('DUPLICATE_ATTRIBUTES', system.Label.PRODIQ001_TAG207));//'Duplicate Attributes'
        translations.add(new Translation('FILTER_NAME_ERROR', system.Label.PRODIQ001_TAG209));//'Please enter filter name.'
        translations.add(new Translation('ATTRIBUTE_NAME_ALREADY_EXISTS', system.Label.PRODIQ001_TAG212));//'Attribute name already exists.'
        translations.add(new Translation('ATTRIBUTE_NAME_AND_FORMATE_REQUIRED', system.Label.PRODIQ001_TAG213));//'Attribute Name and Format are required fields in Technical Attributes template'.

        translations.add(new Translation('ATTACHMENT_SETTING_TITLE', system.Label.PRODIQ001_TAG217));//Settings for Attachment download No records found
        translations.add(new Translation('SFILE_SETTING_TITLE', system.Label.PRODIQ001_TAG218));//Settings for Salesforce Files download
        translations.add(new Translation('SFILE_TAGS_TYPES', system.Label.PRODIQ001_TAG219));// Download Files containing these tags (comma separated)

        translations.add(new Translation('AUTO_SYNC_TITLE', system.Label.PRODIQ001_TAG220));// Data Download

        translations.add(new Translation('AUTO_SYNC_CHECKBOX_TITLE', system.Label.PRODIQ001_TAG221));// Auto Sync On

        
        return translations; 
    }
    
    /* 
        all the request and response declarations goes here
    */            
    public virtual class AbstractResponse{
        
        public Boolean status = true;
        public String message = '';
        public AbstractResponse(){
            
        }       
    }
    
    public class GetSetupMetadataResponse extends AbstractResponse{
        public List<ProductIQConfiguration.Profile> svmxProfiles; 
        public List<IBValueMaps> ibValueMaps;
        public List<IBActionURL> ibActionURLs;
        public List<ProductIQConfiguration.DataValidationRulesWithObjectInfo> dataValidationRules;
        public List<SForceObject> sforceObjectDescribes;  
        public List<InstalligenceLogo> installigenceLogos;
        public List<ProductIQConfiguration.TemplateHeader> ibTemplates;
        public List<Translation> translations;        
        public List<ProductIQConfiguration.Field> productDisplayFields;
        public List<ProductIQConfiguration.Field> productSearchFields;
        public ProductIQConfiguration.SearchObject availableSearchProc;
        public List<ProductIQConfiguration.IBEditProces> availableIBEditProcess;
        public List<ProductIQConfiguration.LocationEditProces> availableLocationEditProcess;
        public Integer totalTAtemplates;
        public GetSetupMetadataResponse(){
            
        }
       
        public void setSVMXProfiles(List<ProductIQConfiguration.Profile> svmxProfiles) {
            this.svmxProfiles = svmxProfiles;
        }
        
        public void setIBValueMaps(List<IBValueMaps> ibValueMaps) {
            this.ibValueMaps = ibValueMaps;
        }
        
        public void setIBActionURL(List<IBActionURL> ibActionURLs){
            this.ibActionURLs = ibActionURLs;
        }
        
        public void setDataValidationRules(List<ProductIQConfiguration.DataValidationRulesWithObjectInfo> dataValidationRules){
            this.dataValidationRules = dataValidationRules;
        }
        
        public void setSForceObjectDescribes(List<SForceObject> sforceObjectDescribes) {
            this.sforceObjectDescribes = sforceObjectDescribes;
        }
        
        public void setInstalligenceLogos(List<InstalligenceLogo> installigenceLogos) {
            this.installigenceLogos = installigenceLogos;
        }
        
        public void setIBTemplates(List<ProductIQConfiguration.TemplateHeader> ibTemplates) {
            this.ibTemplates = ibTemplates;
        }
        
        public void setTranslations(List<Translation> translations) {
            this.translations = translations;
        }


        public void setAvailableIBEditProcess(List<ProductIQConfiguration.IBEditProces> availableIBEditProcess) {
            this.availableIBEditProcess = availableIBEditProcess;
        }
        
        public void setAvailableLocationEditProcess(List<ProductIQConfiguration.LocationEditProces> availableLocationEditProcess) {
            this.availableLocationEditProcess = availableLocationEditProcess;
        }

        public void setTotalTAtemplates(Integer totalTAtemplates){
          this.totalTAtemplates = totalTAtemplates;
        }
    }
    
    public class SForceObject {
        public String objectLabel;
        public String objectAPIName;
        public List<SForceField> fields;
    }
    
    public class SForceField {
        public String fieldLabel;
        public String fieldAPIName;
        public String type;
        public String referenceTo;
        public String relationshipName;
        public boolean nameField; 
        public Integer fieldLength; 
        public List<SForcePickListValues> picklistValues;
        
          
    }
     public class SForcePickListValues {
        public String fieldLabel;
        public String fieldName;
        
          
    }
    
    public class SVMXProfile {
        public String profileId;
        public String profileName;
        public SVMXProfile(String id, String profileName) {
            this.profileId = id;
            this.profileName = profileName;
        }
    }
    
    public class IBValueMaps {
        public String id;
        public String valueMapName;
        public String valueMapProcessName;
        public IBValueMaps(String id, String valueMapName) {
            this.id = id;
            this.valueMapName = valueMapName;
        }
        public IBValueMaps(String id, String valueMapName, string valueMapProcessName) {
            this.id = id;
            this.valueMapName = valueMapName;
            this.valueMapProcessName = valueMapProcessName;
        }
    }
    
    public class IBActionURL {
        public string id;
        public string actionURLName;
        public string actionURLProcessName;
        
        public IBActionURL(string id, string actionURLName){
            this.id = id;
            this.actionURLName = actionURLName;
        }
        
        public IBActionURL(string id, string actionURLName, string actionURLProcessName){
            this.id = id;
            this.actionURLName = actionURLName;
            this.actionURLProcessName = actionURLProcessName;
        }
    }
    
    public class InstalligenceLogo {
        public String name;
        public String uniqueName;
        public String logoId;
    }
    
    public class GetTemplateFromIBRequest {
        public String InstalledProductId;
    }
    
    public class Translation {
        public String Key;
        public String Text;
        
        public Translation(String k, String t){
            this.Key = k;
            this.Text = t;
        }
    }
    
}