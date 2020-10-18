/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class COMM_FileHandlerUtilities implements utility methods which is used across all apex class for file system.
*
* @author Soumyaranjan Pati
* @version V.11
* @since 2018
*/
/*****************************************************************************************************
*    ID        Name                     Date            Comment
*****************************************************************************************************
*              Soumyaranjan Pati        3rd Jan 2018     Created. 
*****************************************************************************************************/

public class COMM_FileHandlerUtilities {
    
    public static boolean fileSettingForTestClass = false; //This variable is used only test class
    /** Name - createContentVersionInstance
    * This method is used to create ContentVersion instance. 
    * 
    * @param contentVersionId(null or Id), filename(String), documentData(string format) and ContentDocumentId(Null or Id for creation of different version).
    * @return Constructed ContentVersion instance.
    *
    *  contentVersionId -: ContentVersion id for update operation.
    *  fileName -: File/Attachment/Document name.
    *  documentData -: Actual data to be stored in ContentVersion.
    *  contentDocumentId -: ContentDocument id for creation of new version.
    * 
    * @exception no.
    */
    
    public static ContentVersion createContentVersionInstance(Id contentVersionId, String fileName, String documentData, Id contentDocumentId) { 
        //documentData = EncodingUtil.urlDecode(documentData, 'UTF-8');
        
        ContentVersion cv = new ContentVersion();
        if(contentVersionId != null)
            cv.Id = contentVersionId;
        if(contentDocumentId != null)
            cv.ContentDocumentId = contentDocumentId;
        if(!String.isBlank(fileName) && !String.isBlank(documentData)){
            cv.VersionData = Blob.valueof(documentData);
            cv.Title = fileName;
            if(contentVersionId == null){
                cv.PathOnClient = filename;
                cv.IsMajorVersion = false;
            }
        }
        return cv;
    }
    
    /** Name - createContentDocumentLink
    * This method is used to create ContentDocumentLink  instance. 
    * 
    * @param recordId and ContentDocumentId.
    * @return Constructed ContentDocumentLink  instance.
    * 
    * recordId -: Any object record id to link with ContentDocument
    * contentDocumentId -: ContentDocument Id that will share with records.
    * 
    * @exception no.
    */
    
    public static ContentDocumentLink createContentDocumentLink(Id recordId, Id contentDocumentId) { 
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        if(recordId != null && contentDocumentId != null){
            cdl.ContentDocumentId = ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'I';
            
            
        }
        return cdl;
    }
    /** Name - createContentDocumentLinkOrgUsers
    * This method is used to create ContentDocumentLink  instance. 
    * 
    * @param recordId and ContentDocumentId.
    * @return Constructed ContentDocumentLink  instance.
    * 
    * recordId -: Any object record id to link with ContentDocument
    * contentDocumentId -: ContentDocument Id that will share with records.
    * 
    * @exception no.
    */
    
    public static ContentDocumentLink createContentDocumentLinkOrgUsers(Id recordId, Id contentDocumentId) { 
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        if(recordId != null && contentDocumentId != null){
            cdl.ContentDocumentId = ContentDocumentId;
            cdl.LinkedEntityId = UserInfo.getOrganizationId();
            cdl.ShareType = 'C';
            
            
        }
        return cdl;
    }
    
    
    /** Name - insertOneContentVersion
    * This method is used to insert ContentVersion record. 
    * 
    * @param ContentVersionInstances.
    * @return inserted ContentVersion id.
    * 
    * 
    * @exception no.
    */
    
    public static Id insertOneContentVersion(ContentVersion ContentVersionInstances) { 
        Id returnId;
        List<ContentVersion> listContentVersionInstances = new List<ContentVersion>();
        listContentVersionInstances.add(ContentVersionInstances);
        try{
            if(listContentVersionInstances.size()>0){
                // DML statement
                Database.SaveResult[] srList = null;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listContentVersionInstances, COMM_SecurityUtils.Access.Createable)){
                    
                    srList = Database.insert(listContentVersionInstances, false);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        returnId = sr.getId();
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ContentVersion fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception e '+e);
        }
        return returnId;
    }
    /** Name - insertListOfContentVersion
    * This method is used to insert ContentVersion records. 
    * 
    * @param ContentVersionInstances.
    * @return inserted ContentVersion ids.
    * 
    * 
    * @exception no.
    BAC-2276
    */
    
    public static List<Id> insertListOfContentVersion(List<ContentVersion> listContentVersionInstances) { 
        List<Id> returnIds = new List<Id>();
        try{
            if(listContentVersionInstances.size()>0){
                // DML statement
                Database.SaveResult[] srList = null;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listContentVersionInstances, COMM_SecurityUtils.Access.Createable)){
                    
                    srList = Database.insert(listContentVersionInstances, false);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        returnIds.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ContentVersion fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception e '+e);
        }
        return returnIds;
    }
    /** Name - updateContentVersion
    * This method is used to bulk update ContentVersion records. 
    * 
    * @param listContentVersionInstances.
    * @return inserted ContentVersion ids.
    * 
    * listContentVersionInstances -: List of ContentVersion instances to update.
    * @exception no.
    */
    
    public static List<Id> updateContentVersion(List<ContentVersion> listContentVersionInstances) { 
        List<Id> listofReturnIds = new List<Id>();
        try{
            if(listContentVersionInstances.size()>0){
                // DML statement
                Database.SaveResult[] srList = null;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listContentVersionInstances, COMM_SecurityUtils.Access.Updateable)){
                    
                    srList = Database.update(listContentVersionInstances, false);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        listofReturnIds.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ContentVersion fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        return listofReturnIds;
    }
    
    /** Name - deleteContentVersion
    * This method is used to bulk delete ContentDocument and related ContentVersion records. 
    * 
    * @param listContentDocument.
    * @return no.
    * 
    * listContentDocument -: List of ContentDocuments to delete
    * @exception no.
    */
    
    public static void deleteContentVersion(List<ContentDocument> listContentDocument) { 
        List<Id> listofReturnIds = new List<Id>();
        if(listContentDocument.size()>0){
            
            try{
                if(COMM_SecurityUtils.getInstance().isDeletableObject( 'ContentDocument' ) ) {
                    // DML statement        
                    Database.DeleteResult[] DR_Dels = Database.delete(listContentDocument);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }catch(Exception e){
                System.debug('Exception e'+e);
            }
        }
    }
    
    /** Name - deleteContentDocumentLInk
    * This method is used to bulk delete ContentDocumentLink records. 
    * 
    * @param listContentDocumentLinkIds.
    * @return no.
    * 
    * listContentDocumentLinkIds -: List of ContentDocumentslink ids to delete that ContentDocumentLink 
    * @exception no.
    */
    
    public static void deleteContentDocumentLink(List<ContentDocumentLink> listContentDocumentLinkIds) { 
        List<Id> listofReturnIds = new List<Id>();
        if(listContentDocumentLinkIds.size()>0){
            
            try{
                Database.DeleteResult[] drList;
                if(COMM_SecurityUtils.getInstance().isDeletableObject( 'ContentDocumentLink' ) ) {
                    // DML statement        
                    drList = Database.delete(listContentDocumentLinkIds);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                // Iterate through each returned result
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully deleted ContentDocumentLink with ID: ' + dr.getId());
                        listofReturnIds.add(dr.getId());
                    }else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ContentDocumentLink fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }catch(Exception e){
                System.debug('Exception e'+e);
            }
        }
    }
    
    /** Name - deleteContentDocument
    * This method is used to bulk delete ContentDocument records. 
    * 
    * @param listContentDocumentIds.
    * @return no.
    * 
    * listContentDocumentIds -: List of ContentDocument ids to delete that ContentDocument
    * @exception no.
    */
    
    public static void deleteContentDocument(List<Id> listContentDocumentIds) { 
        if(listContentDocumentIds.size()>0){
            List<ContentDocument> listContentDocuments = new List<ContentDocument>();
            for(Id cdId: listContentDocumentIds){
                ContentDocument cvTemp = new ContentDocument();
                cvTemp.Id = cdId; 
                listContentDocuments.add(cvTemp);
            }
            try{
                Database.DeleteResult[] drList;
                if(COMM_SecurityUtils.getInstance().isDeletableObject( 'ContentDocument' ) ) {
                    // DML statement
                    
                    drList = Database.delete(listContentDocuments);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
            }catch(Exception e){
                System.debug('Exception e'+e);
            }
        }
    }
    
    /** Name - insertContentDocumentLink
    * This method is used to bulk insert ContentDocumentLink records. 
    * 
    * @param listContentDocumentLinkInstances.
    * @return inserted ContentDocumentLink ids.
    * 
    * listContentDocumentLinkInstances -: list of ContentDocumentLink instance to insert.
    * @exception no.
    */
    
    public static List<Id> insertContentDocumentLink(List<ContentDocumentLink> listContentDocumentLinkInstances) { 
        List<Id> listofReturnIds = new List<Id>();
        try{
            if(listContentDocumentLinkInstances.size()>0){
                // DML statement
                Database.SaveResult[] srList = null;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listContentDocumentLinkInstances, COMM_SecurityUtils.Access.Createable)){
                    
                    srList = Database.insert(listContentDocumentLinkInstances, false);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        listofReturnIds.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ContentDocumentLink fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception e'+e);
        }
        return listofReturnIds;
    }
    
    /** Name - insertOneContentDocumentLink
    * This method is used to insert ContentDocumentLink record. 
    * 
    * @param contentDocumentLinkInstances.
    * @return inserted ContentDocumentLink ids.
    * 
    * contentDocumentLinkInstances -: ContentDocumentLink instance to insert.
    * @exception no.
    */
    
    public static Id insertOneContentDocumentLink(ContentDocumentLink contentDocumentLinkInstances) { 
        Id returnId;
        List<ContentDocumentLink> listContentDocumentLinkInstances = new List<ContentDocumentLink>();
        listContentDocumentLinkInstances.add(contentDocumentLinkInstances);
        try{
            if(listContentDocumentLinkInstances.size()>0){
                // DML statement
                Database.SaveResult[] srList = null;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listContentDocumentLinkInstances, COMM_SecurityUtils.Access.Createable)){
                    
                    srList = Database.insert(listContentDocumentLinkInstances, false);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        returnId = sr.getId();
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ContentDocumentLInk fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception e'+e);
        }
        return returnId;
    }
    
    /** Name - insertContentDocumentLinks
    * This method is used to bulk insert ContentDocumentLink records. 
    * 
    * @param insertContentDocumentLink.
    * @return inserted ContentDocumentLinks.
    * 
    * insertContentDocumentLink -: list of ContentDocumentLink instances to insert.
    * @exception no.
    */
    
    public static Database.SaveResult[] insertContentDocumentLinks(List<ContentDocumentLink> listContentDocumentLinkInstances) { 
        Database.SaveResult[] srList = null;
        try{
            if(listContentDocumentLinkInstances.size()>0){
                // DML statement
                
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listContentDocumentLinkInstances, COMM_SecurityUtils.Access.Createable)){
                    
                    srList = Database.insert(listContentDocumentLinkInstances, false);
                    
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
            }
        }catch(Exception e){
            System.debug('Exception e'+e);
            return null;
        }
        return srList;
    }
    
    /** Name - getContentDocumentsLinks
    * This method is used to retrieve ContentDocumentId from ContentVersion. 
    * This method going to use for createContentDocumentLink method for Adding permission to the file. 
    *
    * @param listContentVersionIds.
    * @return Map of ContentVersionId and ContentDocumentId.
    * 
    * listContentVersionIds -: list of ContentVersion ids to get the ContentDocument ids
    * @exception no.
    */
    
    public static Map<Id,ContentDocumentLink> getContentDocumentsLinks(List<Id> listContentDocumentLinkIds) { 
        Map<Id,ContentDocumentLink> mapReturnData = new Map<Id,ContentDocumentLink>();
        if(listContentDocumentLinkIds.size()>0){
            //Check Field Security Check
            List<String> queryFieldsDT = new List<String> {'id', 'ContentDocumentId', 'LinkedEntityId'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentDocumentLink', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            //End of Check Field Security Check
            for(ContentDocumentLink cdl:[select id,ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where Id IN: listContentDocumentLinkIds]){
                mapReturnData.put(cdl.id,cdl);
            }
        }
        return mapReturnData;
    }
    /** Name - getAllContentDocumentsLinks
    * This method is used to retrieve ContentDocumentLinks. 
    *  
    *
    * @param listContentDocumentIds and listParentIds.
    * @return List of ContentDocumentLinks.
    * 
    * listContentDocumentIds -: list of ContentDocument ids
    * listParentIds -: list of salesforce object ids
    * @exception no.
    */
    
    public static List<ContentDocumentLink> getAllContentDocumentsLinks(List<Id> listContentDocumentIds, List<Id> listParentIds) { 
        List<ContentDocumentLink> listReturnData = new List<ContentDocumentLink>();
        
        //Check Field Security Check
        String cdlWhereCondition = '';
        List<String> queryFieldsDT = new List<String> {'id', 'ContentDocumentId', 'LinkedEntityId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentDocumentLink', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        //End of Check Field Security Check
        if(listContentDocumentIds != null && listParentIds != null && listContentDocumentIds.size()>0 && listParentIds.size()>0){
            cdlWhereCondition = 'ContentDocumentId IN:listContentDocumentIds and LinkedEntityId IN:listParentIds';  
        }
        if((listContentDocumentIds != null && listContentDocumentIds.size()>0) && (listParentIds == null || (listParentIds != null && listParentIds.size() == 0))){
            cdlWhereCondition = 'ContentDocumentId IN:listContentDocumentIds';
        }
        if((listParentIds != null && listParentIds.size()>0) && (listContentDocumentIds == null || (listContentDocumentIds != null && listContentDocumentIds.size() == 0))){
            cdlWhereCondition = 'LinkedEntityId IN:listParentIds';
        }
        try{
            if(cdlWhereCondition != '' && cdlWhereCondition != null){
                for(ContentDocumentLink cdl:Database.query('Select Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where '+cdlWhereCondition+'')){
                    listReturnData.add(cdl);
                }
            }
        }catch(Exception e){
            System.debug('Exception in Contentdocumentlink query '+e);
        }
        return listReturnData;
    }
    /** Name - getContentDocumentsId
    * This method is used to retrieve ContentDocumentId from ContentVersion. 
    * This method going to use for createContentDocumentLink method for Adding permission to the file. 
    *
    * @param listContentVersionIds.
    * @return Map of ContentVersionId and ContentDocumentId.
    * 
    * listContentVersionIds -: list of ContentVersion ids to get the ContentDocument ids
    * @exception no.
    */
    
    public static Map<Id,Id> getContentDocumentsId(List<Id> listContentVersionIds) { 
        Map<Id,Id> mapReturnData = new Map<Id,Id>();
        if(listContentVersionIds.size()>0){
            //Check Field Security Check
            List<String> queryFieldsDT = new List<String> {'id', 'ContentDocumentId'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            //End of Check Field Security Check
            for(ContentVersion cv:[select id,ContentDocumentId from ContentVersion where Id IN: listContentVersionIds]){
                mapReturnData.put(cv.id,cv.ContentDocumentId);
            }
        }
        return mapReturnData;
    }
    
    
    /** Name - getContentVersions
    * This method is used to retrieve ContentDocumentId from ContentVersion. 
    * This method going to use for createContentDocumentLink method for Adding permission to the file. 
    *
    * @param fieldSet and whereClause.
    * @return List of ContentVersions.
    * 
    * fieldSet -: List of fields that need to add SOQL select statement.
    * whereClause -: whereClause that need to add SOQL where condition as a String format. 
    *
    * @exception no.
    */
    
    public static List<ContentVersion> getContentVersions(List<String> fieldSet, String whereClause) { 
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        String fields = 'Id';
        if( fieldSet != null ) {
            
            for( String fieldName : fieldSet ) {
                System.debug('Field Name - ' + fieldName);
                
                if( fieldName == null || fieldName == '')
                    continue;
                fields = fields + ', ' + fieldName;
            }    
        }
        String queryString = 'SELECT ' + fields + ' FROM ContentVersion';
        
        if(!String.isBlank(whereClause)) {
            queryString = queryString + ' WHERE ' + whereClause;
        }
        //Check Field Security Check
        
        //if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', fields, COMM_SecurityUtils.Access.Accessible ) ) {
        //throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        //}
        //End of Check Field Security Check
        System.debug('getContentVersions---queryString '+queryString);
        List<SObject> listContentVersionData = Database.query(queryString);
        for(SObject sobj:listContentVersionData){
            listContentVersion.add((ContentVersion) sobj);
        }
        return listContentVersion;
    }
    /** Name - getContentVersionDetails
    * This method is used to retrieve VersionData and id from ContentVersion. 
    * 
    * @param cvId.
    * @return ContentVersion details.
    * 
    * cvId -: ContentVersion id as a string format.
    * @exception no.
    */
    
    public static ContentVersion getContentVersionDetails(String cvId) { 
        
        List<ContentVersion> lstcvDetails = new List<ContentVersion>();
        
        //Check Field Security Check
        List<String> queryFieldsDT = new List<String> {'Id', 'VersionData', 'ContentDocumentId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        //End of Check Field Security Check
        if(!String.isBlank(cvId)){
        System.debug('cvId '+cvId);
            lstcvDetails = [select Id, ContentDocumentId, VersionData from ContentVersion where Id =: cvId limit 1];
            System.debug('lstcvDetails '+lstcvDetails);
            if(lstcvDetails.size() > 0){
                    return lstcvDetails[0];
                }else{
                    return null;
                }
        }else{
            return null;
        }
    }
    /** Name - getContentVersionsfromContentDocument
    * This method is used to retrieve data from ContentDocument. 
    * 
    *
    * @param fieldSet and whereClause.
    * @return List of ContentDocument.
    * 
    * fieldSet -: List of fields that need to add SOQL select statement.
    * whereClause -: whereClause that need to add SOQL where condition as a String format. 
    *
    * @exception no.
    */
    
    public static List<ContentDocument> getContentVersionsfromContentDocument(List<String> fieldSet, String whereClause) { 
        List<ContentDocument> listContentDocuments = new List<ContentDocument>();
        String fields = 'Id';
        if( fieldSet != null ) {
            
            for( String fieldName : fieldSet ) {
                System.debug('Field Name - ' + fieldName);
                
                if( fieldName == null || fieldName == '')
                    continue;
                fields = fields + ', ' + fieldName;
            }    
        }
        String queryString = 'SELECT ' + fields + ' FROM ContentDocument';
        
        if(!String.isBlank(whereClause)) {
            queryString = queryString + ' WHERE ' + whereClause;
        }
        //Check Field Security Check
        
        //if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', fields, COMM_SecurityUtils.Access.Accessible ) ) {
        //throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        //}
        //End of Check Field Security Check
        System.debug('getContentVersionsfromContentDocument---queryString '+queryString);
        List<SObject> listContentDData = Database.query(queryString);
        for(SObject sobj:listContentDData){
            listContentDocuments.add((ContentDocument) sobj);
        }
        return listContentDocuments;
    }
    /** Name - getContentDocumentData
    * This method is used to share ContentVersion with parent record ids. 
    * 
    *
    * @param client request that contains map of ContentVersion with Parentrecord ids.
    * @return map of ContentVersionId with ContentDocumentId.
    * 
    * 
    * @exception no.
    */
    
    public static Map<Id,Id> getContentDocumentData(Map<Id,Id> mapContentVersionWithParentIds) { 
        Map<Id,Id> returnRecords = new Map<Id,Id>();
        List<Id> listContentVersionIds = new List<Id>();
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        try{
            listContentVersionIds.addAll(mapContentVersionWithParentIds.keySet());
            Map<Id,Id> mapContentVersionWIthDocumentIds = getContentDocumentsId(listContentVersionIds);
            if(mapContentVersionWIthDocumentIds != null && mapContentVersionWIthDocumentIds.size() > 0){
                for(Id cvId : mapContentVersionWIthDocumentIds.keySet()){
                    ContentDocumentLink tempCDL =new ContentDocumentLink();
                    tempCDL.ContentDocumentId = mapContentVersionWIthDocumentIds.get(cvId);
                    tempCDL.LinkedEntityId = mapContentVersionWithParentIds.get(cvId);
                    tempCDL.ShareType = 'I';
                    tempCDL.Visibility = 'AllUsers';
                    listContentDocumentLink.add(tempCDL);
                }
            }
            List<Id> listContentDocumentLinkIds = insertContentDocumentLink(listContentDocumentLink);
            returnRecords.putAll(mapContentVersionWIthDocumentIds);
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        return returnRecords;
    }
    /** Name - getContentDocumentLinkDetails
    * This method is used to retrieve VersionData and id from ContentVersion related to ContentDocumentLInk. 
    * 
    * @param cdlId.
    * @return ContentDocumentLink details.
    * 
    * cvId -: ContentDocumentLink id as a string format.
    * @exception no.
    */
    public static ContentDocumentLink getContentDocumentLinkDetails(String cdlId) { 
        
        List<ContentDocumentLink> lstcdlDetails = new List<ContentDocumentLink>();
        
        //Check Field Security Check
        List<String> queryFieldsDT = new List<String> {'Id', 'ContentDocumentId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentDocumentLink', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        //End of Check Field Security Check
        if(!String.isBlank(cdlId)){
            System.debug('ContentDocumentLink id '+cdlId);
            lstcdlDetails = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE Id =: cdlId limit 1];
            System.debug('lstcvDetails link '+lstcdlDetails);
            if(lstcdlDetails.size() > 0){
                    return lstcdlDetails[0];
                }else{
                    return null;
                }
        }else{
            return null;
        }
    }
    /** Name - getContentVersionsfromContentDocumentLink
    * This method is used to retrieve data from ContentDocumentLink. 
    * 
    *
    * @param fieldSet and whereClause.
    * @return List of ContentDocument.
    * 
    * fieldSet -: List of fields that need to add SOQL select statement.
    * whereClause -: whereClause that need to add SOQL where condition as a String format. 
    *
    * @exception no.
    */
    
    public static List<ContentDocumentLink> getContentVersionsfromContentDocumentLink(List<String> fieldSet, String whereClause) { 
        List<ContentDocumentLink> listContentDocumentLinks = new List<ContentDocumentLink>();
        String fields = 'Id';
        if( fieldSet != null ) {
            
            for( String fieldName : fieldSet ) {
                System.debug('Field Name - ' + fieldName);
                
                if( fieldName == null || fieldName == '')
                    continue;
                fields = fields + ', ' + fieldName;
            }    
        }
        String queryString = 'SELECT ' + fields + ' FROM ContentDocumentLink';
        
        if(!String.isBlank(whereClause)) {
            queryString = queryString + ' WHERE ' + whereClause;
        }
        //Check Field Security Check
        
        //if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', fields, COMM_SecurityUtils.Access.Accessible ) ) {
        //throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        //}
        //End of Check Field Security Check
        System.debug('getContentVersionsfromContentDocumentLink---queryString '+queryString);
        List<SObject> listContentDData = Database.query(queryString);
        for(SObject sobj:listContentDData){
            listContentDocumentLinks.add((ContentDocumentLink) sobj);
        }
        return listContentDocumentLinks;
    }
    /** Name - checkFileSetting
    * This method is used to check whether SVMX file is enables or not. 
    * 
    *
    * @param no.
    * @return true or false.
    * 
    * 
    * @exception no.
    */
    
    public static boolean checkFileSetting() { 
        Boolean returnValue = false;
        
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        String settingValue = commManageSetting.SVMX_getGlobalSettingList('GLOB001_GBL037');
        if(!String.isBlank(settingValue)){
            returnValue = Boolean.valueOf(settingValue);
        }
        if(Test.isRunningTest()){
            return fileSettingForTestClass; // Added for test class
        }
        return returnValue;
    }
    
    /** Name - createContentVersionInstance
    * This method is used to create ContentVersion instance. 
    * 
    * @param contentVersionId(null or Id), filename(String), documentData(string format) and ContentDocumentId(Null or Id for creation of different version).
    * @return Constructed ContentVersion instance.
    *
    *  contentVersionId -: ContentVersion id for update operation.
    *  fileName -: File/Attachment/Document name.
    *  documentData(Blob) -: Actual data to be stored in ContentVersion.
    *  contentDocumentId -: ContentDocument id for creation of new version.
    * 
    * @exception no.
    */
    public static ContentVersion createContentVersionInstance(Id contentVersionId, String fileName, Blob documentData, Id contentDocumentId) { 
        ContentVersion cv = new ContentVersion();
        if(contentVersionId != null)
            cv.Id = contentVersionId;
        if(contentDocumentId != null)
            cv.ContentDocumentId = contentDocumentId;
        if(!String.isBlank(fileName) && documentData != null){
            cv.VersionData = documentData;
            cv.Title = fileName;
            if(contentVersionId == null){
                cv.PathOnClient = filename;
                cv.IsMajorVersion = false;
            }
        }
        return cv;
    }
}