/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class COMM_FileHandlerUtilities_UT is to cover test code coverage for COMM_FileHandlerUtilities class.
*
* @author Soumyaranjan Pati
* @version 1.05
* @since 2018
*/
/*****************************************************************************************************
*    ID        Name                     Date            Comment
*****************************************************************************************************
*              Soumyaranjan Pati        3rd Jan 2018     Created. 
*****************************************************************************************************/
@isTest
public with sharing class COMM_FileHandlerUtilities_UT {
    
    static testMethod void testContentVersion() {
        Boolean isSalesforceFileEnable = COMM_FileHandlerUtilities.checkFileSetting();
        Account acc = new Account();
        acc.Name = 'ServiceMax';
        insert acc;
        List<Id> listContentVersionIds = new List<Id>();
        
        listContentVersionIds.add(COMM_FileHandlerUtilities.insertOneContentVersion(COMM_FileHandlerUtilities.createContentVersionInstance(null,'Test File','Test Data',null)));
		List<ContentVersion> listContentVersionInstances = new List<ContentVersion>();
		listContentVersionInstances.add(COMM_FileHandlerUtilities.createContentVersionInstance(null,'Test File','Test Data',null));
        List<Id> lstCVIds = COMM_FileHandlerUtilities.insertListOfContentVersion(listContentVersionInstances);
        Id oneCVId = COMM_FileHandlerUtilities.insertOneContentVersion(COMM_FileHandlerUtilities.createContentVersionInstance(null,'Test File','Test Data',null));
        
        
        System.assertNotEquals(listContentVersionIds.size(), 0, 'Successfully listContentVersionIds returning values');
        List<id> lstCDIds = new List<Id>();
        List<ContentDocumentLink> lstCDLIds = new List<ContentDocumentLink>();
        if(oneCVId != null){
            ContentVersion cvDetails = COMM_FileHandlerUtilities.getContentVersionDetails(String.valueOf(oneCVId));
            
            Map<Id,Id> mapCVWithParentIdstemp = new Map<Id,Id>();
            mapCVWithParentIdstemp.put(oneCVId,acc.id);
            Map<Id,Id> mapCVIds = COMM_FileHandlerUtilities.getContentDocumentData(mapCVWithParentIdstemp);
            
            List<id> lstParentIds = new List<Id>();
            lstParentIds.add(acc.id);
            for(Id ids:mapCVIds.keySet()){
                lstCDIds.add(mapCVIds.get(ids));
            }
            lstCDLIds = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(null,lstParentIds);
            lstCDLIds = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(lstCDIds,null);
            lstCDLIds = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(lstCDIds,lstParentIds);
        }
        Map<Id,Id> mapCVIds = COMM_FileHandlerUtilities.getContentDocumentsId(listContentVersionIds);
        
        System.assertNotEquals(mapCVIds.size(), 0, 'Successfully returning values');
        
        List<ContentDocumentLink> listContentDocLink = new List<ContentDocumentLink>();
        
        ContentDocumentLink cdlSingleInstance =  new ContentDocumentLink();
        
        for(Id ids:listContentVersionIds){
            listContentDocLink.add(COMM_FileHandlerUtilities.createContentDocumentLink(acc.id,mapCVIds.get(ids)));
            listContentDocLink.add(COMM_FileHandlerUtilities.createContentDocumentLinkOrgUsers(acc.id,mapCVIds.get(ids)));
            cdlSingleInstance = COMM_FileHandlerUtilities.createContentDocumentLink(acc.id,mapCVIds.get(ids));
        }
        List<Id> listContentVersionLinkIds = COMM_FileHandlerUtilities.insertContentDocumentLink(listContentDocLink);
        
        System.assertNotEquals(listContentVersionLinkIds.size(), 0, 'Successfully ContentDocumentLink returning values');
        
        Database.SaveResult[] listContentVersionLinkIdsDetails = COMM_FileHandlerUtilities.insertContentDocumentLinks(listContentDocLink);
        ContentDocumentLink cdlDetails = COMM_FileHandlerUtilities.getContentDocumentLinkDetails(String.valueOf(listContentVersionLinkIds[0]));
        Id cdlId = COMM_FileHandlerUtilities.insertOneContentDocumentLink(cdlSingleInstance);
		 List<String> fieldSet = new List<String>();
                    fieldSet.add('ContentDocumentId');
                    String whereClause = 'LinkedEntityId = \'' + acc.id + '\' order by ContentDocument.LatestPublishedVersion.CreatedDate DESC';
        List<ContentDocumentLink> cdlDetailsa = COMM_FileHandlerUtilities.getContentVersionsfromContentDocumentLink(fieldSet, whereClause);
        Map<Id,ContentDocumentLink> mapidWithCDL = COMM_FileHandlerUtilities.getContentDocumentsLinks(listContentVersionLinkIds);
        
        COMM_FileHandlerUtilities.deleteContentDocumentLink(lstCDLIds);
        
        COMM_FileHandlerUtilities.deleteContentDocument(lstCDIds);
        
        List<ContentVersion> lstCVDatatoUpdate = new List<ContentVersion>();
        List<String> listString = new List<String>();
        listString.add('VersionData');
        lstCVDatatoUpdate = COMM_FileHandlerUtilities.getContentVersions(listString,'id != null');
        COMM_FileHandlerUtilities.updateContentVersion(lstCVDatatoUpdate);
        
		List<String> listStrings = new List<String>();
		listStrings.add('LatestPublishedVersionId');
		List<ContentDocument> lstCdDetails = COMM_FileHandlerUtilities.getContentVersionsfromContentDocument(listStrings,'id != null');
      
        List<ContentDocument> lstCdlVDatatoDelete = new List<ContentDocument>();
        
        lstCdlVDatatoDelete.add(new ContentDocument(id=mapCVIds.get(listContentVersionIds[0])));
        COMM_FileHandlerUtilities.deleteContentVersion(lstCdlVDatatoDelete);
        lstCdlVDatatoDelete.get(0).id = null;
        COMM_FileHandlerUtilities.deleteContentVersion(lstCdlVDatatoDelete);
        
    }
    
}