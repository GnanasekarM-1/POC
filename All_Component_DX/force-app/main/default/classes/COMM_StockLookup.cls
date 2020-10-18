public with sharing class COMM_StockLookup{
    
    /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/
    
    public Id recordId{get;set;}
    public Id productId{get;set;}
    public Id siteId{get;set;}
    public String radius {get;set;}
    public String prodName{get;set;}
    public String reqQty{get;set;}
    public String curLocation{get;set;}
    public String strJSONLstProdStock {get;set;}
    public String strJSONLstMesssage {get;set;}
    public String strErrorMesssage {get;set;}
    public String requestStockId{get;set;}
    public String recordLineId{get;set;}
    public boolean isUpdateSuccessfully{get;set;}
    public String requestType{get;set;}
    public list<selectOption> lstunit = new list<selectOption>();
    public list<selectOption> lstOption = new list<selectOption>();
    public list<SVMXC__Product_Stock__c> lstProdStock = new list<SVMXC__Product_Stock__c>();
    public list<SVMXC__Site__c> lstLocation = new list<SVMXC__Site__c>();
    public String strGoogleUrl{get;set;} //Added for BAC-6155
   
    public list<SVMXC__Product_Stock__c> getLstProdStock() {
        return lstProdStock;
    }
    
    public list<SelectOption> getlstunit() {
        lstunit.add(new SelectOption('Kilometers', System.Label.SVMXC.SLKPSC1_LAB020));
        lstunit.add(new SelectOption('Miles', System.Label.SVMXC.SLKPSC1_LAB025));   
        return lstunit;
    }
    
    public SVMXC__Site__c getLocation() {
        if(lstLocation.size()>0)
            return lstLocation[0];
        else return null;
    }
    
    public list<SelectOption> getlstOption() {
        lstOption.add(new SelectOption('Both', System.Label.SVMXC.SLKPSC1_LAB024)); 
        lstOption.add(new SelectOption('Map', System.Label.SVMXC.SLKPSC1_LAB019));
        lstOption.add(new SelectOption('Grid', System.Label.SVMXC.SLKPSC1_LAB023));   
        return lstOption;
    }
    
    public COMM_StockLookup(){
        //Get it from ServiceMax properties Config Setting // Added for BAC-6155
        SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('MAPS_API_KEY_CORE');
        if (objProperties != null && objProperties.SVMXC__Value__c != null) {
            strGoogleUrl = 'https://maps.googleapis.com/maps/api/js?key='+objProperties.SVMXC__Value__c;
        }   
        
        // End for BAC-6155
        radius = '50';
        curLocation = '';
        strJSONLstProdStock = 'None';
        isUpdateSuccessfully =false;
        recordLineId = ApexPages.currentPage().getParameters().get('SVMX_Id');
        
        map<String,String> mapTags =new map<String,String>();
        mapTags.put('MSG008',system.label.SVMXC.SLKPSC1_MSG008);
        mapTags.put('MSG009',system.label.SVMXC.SLKPSC1_MSG009);
        mapTags.put('MSG010',system.label.SVMXC.SLKPSC1_MSG010);
        mapTags.put('MSG011',system.label.SVMXC.SLKPSC1_MSG011);
        mapTags.put('MSG012',system.label.SVMXC.SLKPSC1_MSG012);
        mapTags.put('MSG013',system.label.SVMXC.SLKPSC1_MSG013);
        mapTags.put('MSG014',system.label.SVMXC.SLKPSC1_MSG014);
        mapTags.put('MSG022',system.label.SVMXC.SLKPSC1_MSG022);
        
        strJSONLstMesssage = JSON.serialize(mapTags);
        requestType = ApexPages.currentPage().getParameters().get('SVMX_Type');
        if(requestType !=null && recordLineId !=null){
            if(requestType.toUpperCase() == 'PR'){
                List<String> queryFields = new List<String> {'SVMXC__Parts_Request__c', 'SVMXC__Product__c', 'SVMXC__Product__r.Name', 'SVMXC__Quantity_Required2__c', 'SVMXC__Parts_Request__r.SVMXC__Required_At_Location__c'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Parts_Request_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                list<SVMXC__Parts_Request_Line__c>  lstRecords = [SELECT SVMXC__Parts_Request__c, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Quantity_Required2__c,SVMXC__Parts_Request__r.SVMXC__Required_At_Location__c FROM SVMXC__Parts_Request_Line__c WHERE Id =: recordLineId]; //SDL-SVMX-READ-FLS-ENFORCED 
                
                if(lstRecords.size()>0 && lstRecords[0].SVMXC__Product__c != null){      
                    recordId = lstRecords[0].SVMXC__Parts_Request__c;
                    productId = lstRecords[0].SVMXC__Product__c;
                    prodName = lstRecords[0].SVMXC__Product__r.Name;
                    reqQty = String.valueof(lstRecords[0].SVMXC__Quantity_Required2__c);
                    siteId = lstRecords[0].SVMXC__Parts_Request__r.SVMXC__Required_At_Location__c;
                }
            }
            else if(requestType.toUpperCase() == 'SVO'){
                List<String> queryFields = new List<String> {'Id', 'SVMXC__Product__c', 'SVMXC__Product__r.Name', 'SVMXC__Requested_Quantity2__c', 'SVMXC__Requested_Location__c'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                list<SVMXC__Service_Order_Line__c>  lstRecords = [SELECT Id, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Requested_Quantity2__c, SVMXC__Requested_Location__c FROM SVMXC__Service_Order_Line__c WHERE Id =: recordLineId]; //SDL-SVMX-READ-FLS-ENFORCED
                
                if(lstRecords.size()>0 && lstRecords[0].SVMXC__Product__c != null){      
                    recordId = lstRecords[0].id;
                    productId = lstRecords[0].SVMXC__Product__c;
                    prodName = lstRecords[0].SVMXC__Product__r.Name;
                    reqQty = String.valueof(lstRecords[0].SVMXC__Requested_Quantity2__c);
                    siteId = lstRecords[0].SVMXC__Requested_Location__c;
                }
            }
            
            if((siteId != null && requestType.toUpperCase() == 'SVO') || (requestType.toUpperCase() == 'PR')){
                List<String> queryFields = new List<String> {'SVMXC__Street__c', 'SVMXC__City__c', 'SVMXC__State__c', 'SVMXC__Zip__c', 'SVMXC__Country__c'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstLocation = [SELECT SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c FROM SVMXC__Site__c WHERE Id =: siteId limit 1]; //SDL-SVMX-READ-FLS-ENFORCED
                if(lstLocation.size() > 0)
                {
                    if (lstLocation[0].SVMXC__Street__c != null) 
                        curLocation += lstLocation[0].SVMXC__Street__c + ' ';
                    if (lstLocation[0].SVMXC__City__c != null) 
                        curLocation += lstLocation[0].SVMXC__City__c + ' ';
                    if (lstLocation[0].SVMXC__State__c != null) 
                        curLocation += lstLocation[0].SVMXC__State__c + ' ';
                    if (lstLocation[0].SVMXC__Zip__c != null)
                        curLocation += lstLocation[0].SVMXC__Zip__c + ' ';
                    if (lstLocation[0].SVMXC__Country__c != null) 
                        curLocation += lstLocation[0].SVMXC__Country__c + ' ';
                }
            }
        }
        else strErrorMesssage ='Error';
    }
    
    public void FindStock(){ 
        String userId = UserInfo.getUserId();
        List<String> queryFields = new List<String> {'Id', 'SVMXC__Location__c', 'SVMXC__Quantity2__c', 'SVMXC__Location__r.Name', 'SVMXC__Location__r.SVMXC__Street__c', 'SVMXC__Location__r.SVMXC__City__c', 'SVMXC__Location__r.SVMXC__State__c',   'SVMXC__Location__r.SVMXC__Zip__c', 'SVMXC__Location__r.SVMXC__Country__c', 'SVMXC__Location__r.SVMXC__Site_Phone__c', 'SVMXC__Location__r.SVMXC__Latitude__c', 'SVMXC__Location__r.SVMXC__Longitude__c', 'SVMXC__Location__r.SVMXC__Service_Engineer__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        lstProdStock = [SELECT Id, SVMXC__Location__c, SVMXC__Quantity2__c, SVMXC__Location__r.Name, SVMXC__Location__r.SVMXC__Street__c, SVMXC__Location__r.SVMXC__City__c, SVMXC__Location__r.SVMXC__State__c,   SVMXC__Location__r.SVMXC__Zip__c, SVMXC__Location__r.SVMXC__Country__c, SVMXC__Location__r.SVMXC__Site_Phone__c,SVMXC__Location__r.SVMXC__Latitude__c, SVMXC__Location__r.SVMXC__Longitude__c, SVMXC__Location__r.SVMXC__Service_Engineer__c FROM SVMXC__Product_Stock__c WHERE SVMXC__Location__r.SVMXC__Latitude__c != null and SVMXC__Location__r.SVMXC__Longitude__c != null and SVMXC__Product__c =:ProductId AND SVMXC__Status__c = 'Available' AND SVMXC__Quantity2__c > 0 AND SVMXC__Location__r.SVMXC__Service_Engineer__c !=: userId Order By SVMXC__Location__r.Name]; //SDL-SVMX-READ-FLS-ENFORCED
        strJSONLstProdStock = JSON.serialize(lstProdStock);
    }   
    
    public pageReference RequestStock(){
        if(requestType.toUpperCase() == 'PR'){
            try{
                List<String> queryFields = new List<String> {'Id', 'SVMXC__Requested_From__c'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Parts_Request__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                list<SVMXC__Parts_Request__c> lstPartRequest = [select Id,SVMXC__Requested_From__c from SVMXC__Parts_Request__c where Id =:recordId limit 1]; //SDL-SVMX-READ-FLS-ENFORCED
                new ApexPages.Message(ApexPages.Severity.ERROR, 'my '+lstPartRequest[0]+'error msg'); 
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPartRequest, COMM_SecurityUtils.Access.Updateable ) ) {
                    
                    lstPartRequest[0].SVMXC__Requested_From__c = requestStockId;
                    update lstPartRequest; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    isUpdateSuccessfully =true;
                } else {
                    strErrorMesssage = System.Label.COMM001_TAG142;
                    isUpdateSuccessfully =false;
                }
                
            }
            catch (Exception ex){
                if(ex.getTypeName() == 'System.DmlException')
                    strErrorMesssage =ex.getDmlMessage(0);
                else strErrorMesssage =ex.getMessage();
                isUpdateSuccessfully =false;
            } 
        }
        else if(requestType.toUpperCase() == 'SVO'){
            try{
                List<String> queryFields = new List<String> {'Id', 'SVMXC__From_Location__c'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                list<SVMXC__Service_Order_Line__c> lstWOrder = [select Id, SVMXC__From_Location__c from SVMXC__Service_Order_Line__c where Id =:recordId limit 1]; //SDL-SVMX-READ-FLS-ENFORCED
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWOrder, COMM_SecurityUtils.Access.Updateable ) ) {
                    
                    lstWOrder[0].SVMXC__From_Location__c = requestStockId;
                    update lstWOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    isUpdateSuccessfully =true;
                } else {
                    strErrorMesssage = System.Label.COMM001_TAG142;
                    isUpdateSuccessfully =false;
                }
            }
            catch (Exception ex){
                if(ex.getTypeName() == 'System.DmlException')
                    strErrorMesssage =ex.getDmlMessage(0);
                else strErrorMesssage =ex.getMessage();
                isUpdateSuccessfully =false;
            } 
        }
        return null;
    }
}