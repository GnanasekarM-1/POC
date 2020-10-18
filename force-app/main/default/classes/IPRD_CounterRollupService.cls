/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The CounterRollupService implements the interface class SFM_ScheduledBatchInterface.
 * The interface method is invoked through Scheduled SFM for calcualating the counter roll up. 
 * Counter roll up is calculated for each of the definitions defined for the IBs which are covered under 
 * Service Contract.
 * 
 * @author Sachin S
 * @version 15.39100
 * @since 2015
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              SACHIN S               18 JUN 2015     Created. 
 *              Soumyaranjan            13th July 2018  Security Scanned
 *****************************************************************************/
 /* Security Scanned */
public with sharing class IPRD_CounterRollupService implements SVMXC.SFM_ScheduledBatchInterface {
    //Constants
    static final String RECORD_IDS = 'RECORDIDS';
    static final String RECORD_TYPE_READING ='Reading';
    static final String STRING_DELIMITER = '-';
    static final String COUNTER_TYPE_DECREASING = 'Decreasing';
    static final String COUNTER_TYPE_INCREASING = 'Increasing';
    
     /**
     * The interface method parses the request to get the Service Contract Ids and processes it.
     *
     * @param This will be of type SFM_Request which will have all the Service Contract Ids   
     * @return This wil be  of type SFM_Response which will have map of Service contract Ids and 
     *         associated counter roll up records
     */
    public SVMXC.SFM_WrapperDef.SFM_Response executeService(SVMXC.SFM_WrapperDef.SFM_Request sfmReq){
        System.debug(LoggingLevel.DEBUG, 'SFM Request ' + sfmReq);
        //Map to hold all the Sevice contract and associated Counter Roll up Records
        Map<String,Set<String>> contractRollupMap = new Map<String,Set<String>>();

        //Creating the response object instance to return the request status and response
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        objResponse.success = true;
        objResponse.message = '';       
        
        try{
            if(sfmReq != null && !sfmReq.stringListMap.isEmpty()){
                SVMXC.SFM_WrapperDef.SFM_StringListMap objStringListMap = sfmReq.stringListMap[0];            
                if(objStringListMap != null && objStringListMap.key != null && objStringListMap.key.equalsIgnoreCase(RECORD_IDS) && objStringListMap.valueList != null){
                   if(objStringListMap.valueList.size() > 0){
                      System.debug(LoggingLevel.DEBUG, 'Service Contract Record Ids: ' + objStringListMap.valueList);
                      /*Parsed request will be handled in a different method, which 
                        validates and creates the Roll up Records */
                      contractRollupMap = processCounterRollup(objStringListMap.valueList); 
                   }
                }
            }
        }catch( QueryException ex) {
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, 'Query Exception in executeService for Counter Rollup :' + ex.getMessage() );            
        }catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Exception thrown in executeService for Counter Rollup : ' + ex.getMessage());
        } 

        //The returned map 'contractRollupMap' is added to the response object    
        for(String key : contractRollupMap.keyset()){
            Set<String> rollupIds = contractRollupMap.get(key);
            System.debug(LoggingLevel.DEBUG, 'Service Contract Id :' + key + ' Rollup Record Ids : ' + rollupIds);
            List<String> tempList =  new List<String>(); 
            tempList.addAll(rollupIds);
            SVMXC.SFM_WrapperDef.SFM_StringListMap tempObject = new SVMXC.SFM_WrapperDef.SFM_StringListMap(key, tempList);
            objResponse.StringLstMap.add(tempObject);
        }

        System.debug(LoggingLevel.DEBUG, 'Response of CounterRollupService: ' + objResponse);          
        return objResponse;
    }

    /*  This method takes a list of Service Contract Ids as parameter, processes it 
     *  and creates counter roll up for each of the Service Contracts
     *  @return Returns Service Contracts and the newly created Counter Roll up Record Ids
     */
    Map<String,Set<String>> processCounterRollup(List<String> listServiceContractIds){
        
        //Map to hold Service Contract and newly created Roll up Records Ids
        Map<String,Set<String>> contractRollupMap = new Map<String,Set<String>>();
        //Set to remove duplicates from the List of Service Contract Ids
        Set<String> setServiceContractIds = new Set<String>(listServiceContractIds);
        //List to hold all the newly created counter roll up records
        List<SVMXC__Counter_Rollup__c> counterRollupList = new List<SVMXC__Counter_Rollup__c>();
        //Map to hold Installed Product Ids of the Covered products and the associated Service Contract ID 
        Map<Id,Id> iBServiceContractMap = new Map<Id,Id>();
        //Map to hold Service Contract Id and the Covered Product Record which will have the Parent Service Contract fields 
        Map<Id,SVMXC__Service_Contract_Products__c> serviceContractMap = new Map<Id,SVMXC__Service_Contract_Products__c>();

        /* Looping through all the covered Products of the Service Contracts 
         * to create ServiceContractMap and iBServiceContractMap
         */
        for(SVMXC__Service_Contract_Products__c covProd : [SELECT SVMXC__Installed_Product__c,SVMXC__Service_Contract__r.SVMXC__Counter_Usages_Processed_Until__c,SVMXC__Service_Contract__c,SVMXC__Service_Contract__r.SVMXC__Start_Date__c,
                                                             SVMXC__Service_Contract__r.SVMXC__End_Date__c FROM SVMXC__Service_Contract_Products__c WHERE SVMXC__Service_Contract__c IN : setServiceContractIds AND SVMXC__Service_Contract__c != NULL]){
            if(!serviceContractMap.containsKey(covProd.SVMXC__Service_Contract__c))
                serviceContractMap.put(covProd.SVMXC__Service_Contract__c,covProd);
            iBServiceContractMap.put(covProd.SVMXC__Installed_Product__c,covProd.SVMXC__Service_Contract__c);
        }
        
        /*Querying all the Counter Reading Records of installed Products which is 
          marked either latest or not associated to counter roll up records*/
        List<SVMXC__Counter_Details__c> counterReadingList = [SELECT SVMXC__Counter_Definition__c,SVMXC__Counter_Rollup__c,SVMXC__Reading_Date__c,SVMXC__Installed_Product__c,SVMXC__Last_Reading__c,SVMXC__Counter_Definition__r.Name,SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c,SVMXC__Counter_Definition__r.SVMXC__Max_Value__c,
                                                                SVMXC__Counter_Definition__r.SVMXC__Min_Value__c,SVMXC__Counter_Type__c,SVMXC__Is_Latest__c,SVMXC__Counter_Reading__c FROM SVMXC__Counter_Details__c WHERE RecordType.DeveloperName =: RECORD_TYPE_READING AND SVMXC__Installed_Product__c IN : iBServiceContractMap.keySet() AND SVMXC__Installed_Product__c != NULL AND 
                                                                SVMXC__Counter_Definition__c != NULL AND (SVMXC__Is_Latest__c = true OR SVMXC__Counter_Rollup__c = null)];
        //This set holds the unique combination of Service Contract Id and Counter Defintions Ids of the IBs
        Set<String> serviceCountDefSet = new Set<String>(); 
        //This holds the latest counter reading value for each unique key combination of Service Contract Id and Counter Defintion Ids
        Map<String,double> latestCounterReadingMap = new Map<String,double>();
        //This holds all the latest counter reading records for each unique key combintaion of Service contract Id and Counter Defintion Ids
        Map<String,List<SVMXC__Counter_Details__c>> counterReadingMap = new Map<String,List<SVMXC__Counter_Details__c>>();
        
        /* Looping through all the Counter Reading Records
         * 1. Checks if the counter reading falls between the Start and End Date of the Service Contract 
         * 2. Checks if the counter reading falls between the last run date and the current running date
         * 3. Calculates the total reading of each definiton for various IBs under the Service Contract
         */
        for(SVMXC__Counter_Details__c readingRec : counterReadingList){
            if(iBServiceContractMap.containsKey(readingRec.SVMXC__Installed_Product__c) && iBServiceContractMap.get(readingRec.SVMXC__Installed_Product__c) != null){
                Id serviceContractId = iBServiceContractMap.get(readingRec.SVMXC__Installed_Product__c);
                string uniqueKey = serviceContractId + STRING_DELIMITER + readingRec.SVMXC__Counter_Definition__c;
                Datetime startDate;
                Datetime endDate;   
                System.debug(LoggingLevel.DEBUG, 'Current Counter Reading Record: ' + readingRec);  
                if(serviceContractMap.containsKey(serviceContractId) && serviceContractMap.get(serviceContractId) != null){
                    SVMXC__Service_Contract_Products__c covProduct = serviceContractMap.get(serviceContractId);
                    Datetime contractStartDate = (DateTime)covProduct.SVMXC__Service_Contract__r.SVMXC__Start_Date__c; 
                    if(covProduct.SVMXC__Service_Contract__r.SVMXC__Counter_Usages_Processed_Until__c != null)
                        startDate = covProduct.SVMXC__Service_Contract__r.SVMXC__Counter_Usages_Processed_Until__c;
                    else
                        startDate = contractStartDate;
                    endDate = (DateTime)covProduct.SVMXC__Service_Contract__r.SVMXC__End_Date__c; 
                }                 
                
                if(startDate != null && endDate != null && startDate <= System.now() && (endDate+1) >= System.now())  
                        serviceCountDefSet.add(uniqueKey); 
            
                if((startDate != null && (readingRec.SVMXC__Reading_Date__c >= startDate && 
                    readingRec.SVMXC__Reading_Date__c <= System.now())) && (endDate != null && readingRec.SVMXC__Reading_Date__c <= (endDate+1))){
                    System.debug(LoggingLevel.DEBUG, 'Counter Reading Record for the current duration : ' + readingRec + ' ' +readingRec.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c);                           
                    double counterVal = (readingRec.SVMXC__Counter_Reading__c != null)?readingRec.SVMXC__Counter_Reading__c:0;                  
                    System.debug('Reading Check : ' + readingRec.SVMXC__Last_Reading__c  + ' ' + readingRec.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c) ; 
                    if(readingRec.SVMXC__Last_Reading__c != null)
                      counterVal -= readingRec.SVMXC__Last_Reading__c;
                    else if(readingRec.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c.equalsIgnoreCase(COUNTER_TYPE_DECREASING) &&
                            readingRec.SVMXC__Counter_Definition__r.SVMXC__Max_Value__c != null)
                      counterVal -= readingRec.SVMXC__Counter_Definition__r.SVMXC__Max_Value__c; 
                    else if(readingRec.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c.equalsIgnoreCase(COUNTER_TYPE_INCREASING) &&
                            readingRec.SVMXC__Counter_Definition__r.SVMXC__Min_Value__c != null )
                      counterVal -= readingRec.SVMXC__Counter_Definition__r.SVMXC__Min_Value__c;  

                    if(latestCounterReadingMap.containsKey(uniqueKey)){
                       counterVal = math.abs(counterVal) + latestCounterReadingMap.get(uniqueKey) ;
                    }
                    latestCounterReadingMap.put(uniqueKey,math.abs(counterVal)); 
                    List<SVMXC__Counter_Details__c> tempList = new List<SVMXC__Counter_Details__c>();
                    if(counterReadingMap.containsKey(uniqueKey)){
                        tempList = counterReadingMap.get(uniqueKey); 
                    }
                    tempList.add(readingRec);
                    counterReadingMap.put(uniqueKey,tempList);
                }
                
            }

        }

        //This holds all the Service Contract records which needs to be updated with Roll up Processed Date
        List<SVMXC__Service_Contract__c> serviceContractUpdateList = new List<SVMXC__Service_Contract__c>();
        //Set to identify if the Service Contract record is already added to the update list
        Set<Id> ServiceContractIds = new Set<Id>();

        /* This Loops through all the Service Contract and Counter Definition unique combination
         *  1. Creates the Counter roll up instance for each unqiue combination
         *  2. Puts the calculated counter reading value to the roll up record for the current duration
         *  3. Updates the Service contract last reading date as the current date.
         */
        for(String counterKey : serviceCountDefSet){
            if(counterKey.contains(STRING_DELIMITER) && counterKey.split(STRING_DELIMITER).size() == 2){
                List<String> keyList = counterKey.split(STRING_DELIMITER);
                Id serviceContractId = keyList[0];
                Id counterDefId = keyList[1];
                System.debug(LoggingLevel.DEBUG, 'serviceContractId: ' + serviceContractId + ' counterDefId : ' + counterDefId);                       
                SVMXC__Counter_Rollup__c rollupInstance = new SVMXC__Counter_Rollup__c ();
                rollupInstance.SVMXC__Counter_Definition__c = counterDefId;
                rollupInstance.SVMXC__Service_Contract__c = serviceContractId;
                rollupInstance.SVMXC__Period_To__c = system.now();    
                if(serviceContractMap.containsKey(serviceContractId)){
                    SVMXC__Service_Contract_Products__c covProduct = serviceContractMap.get(serviceContractId);
                    if(covProduct.SVMXC__Service_Contract__r.SVMXC__Counter_Usages_Processed_Until__c != null)
                       rollupInstance.SVMXC__Period_From__c = covProduct.SVMXC__Service_Contract__r.SVMXC__Counter_Usages_Processed_Until__c;
                    else{
                       Datetime dt = (DateTime)covProduct.SVMXC__Service_Contract__r.SVMXC__Start_Date__c; 
                       System.debug('Period From ::: ' + dt);
                       rollupInstance.SVMXC__Period_From__c = dt;     
                    }
                }
                if(latestCounterReadingMap.containsKey(counterKey))
                    rollupInstance.SVMXC__Total_Usage_Count__c = latestCounterReadingMap.get(counterKey);
                else
                    rollupInstance.SVMXC__Total_Usage_Count__c = 0;
                if(!ServiceContractIds.contains(serviceContractId)){    
                    SVMXC__Service_Contract__c serviceContractRec = new SVMXC__Service_Contract__c(Id = serviceContractId);
                    ServiceContractIds.add(serviceContractId);              
                    serviceContractRec.SVMXC__Counter_Usages_Processed_Until__c = rollupInstance.SVMXC__Period_To__c;  
                    serviceContractUpdateList.add(serviceContractRec); 
                }
    
                counterRollupList.add(rollupInstance);    
            }    
        }
        
        //Inserts all the counter roll up records
        if(!counterRollupList.isEmpty()){
            //insert counterRollupList;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( counterRollupList, COMM_SecurityUtils.Access.Createable ) ) {
                ///SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                insert counterRollupList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }

        //Updates all the Service Contract Records
        if(!serviceContractUpdateList.isEmpty()){
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( serviceContractUpdateList, COMM_SecurityUtils.Access.Updateable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                update serviceContractUpdateList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
            
        
        //Re using the list to hold the updated counter reading records with the Roll up Record Ids
        counterReadingList = new List<SVMXC__Counter_Details__c>();

        //Looping through newly inserted roll up records for mapping the counter reading records to the related roll up records
        for(SVMXC__Counter_Rollup__c rollupRec : counterRollupList){
            String counterKey = rollupRec.SVMXC__Service_Contract__c + STRING_DELIMITER + rollupRec.SVMXC__Counter_Definition__c;
            if(counterReadingMap.containsKey(counterKey)){
                for(SVMXC__Counter_Details__c counterRec : counterReadingMap.get(counterKey)){
                    counterRec.SVMXC__Counter_Rollup__c = rollupRec.id;
                    counterReadingList.add(counterRec);
                }
            }
            //Creates a map of Service Contract Records and the newly inserted roll up record Ids            
            Set<String> tempSet = new Set<String>();
            if(contractRollupMap.containsKey(rollupRec.SVMXC__Service_Contract__c)){
               tempSet = contractRollupMap.get(rollupRec.SVMXC__Service_Contract__c);     
            }
            tempSet.add(rollupRec.Id);
            contractRollupMap.put(rollupRec.SVMXC__Service_Contract__c,tempSet);
        }

        //updating counter reading records with newly inserted roll up record Ids
        if(!counterReadingList.isEmpty()){
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( counterReadingList, COMM_SecurityUtils.Access.Updateable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                update counterReadingList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            system.debug(LoggingLevel.DEBUG, 'counterReadingList: ' + counterReadingList);
        }              

        return contractRollupMap;       
    }
}