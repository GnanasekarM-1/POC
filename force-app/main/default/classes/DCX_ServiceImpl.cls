/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This is the class which provides implementation for all the DC HTML rest services defined in the 
 * DispatchConsoleServiceBase base class. 
 *
 * @author Servicemax
 * @version 
 * @since 2019
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
                Madhusudhan HK          April 2019
                Vinay Vijay             Apr-Aug 2019
 *****************************************************************************************************/
public class DCX_ServiceImpl extends DCX_ServiceBase
{
    public DCX_ServiceImpl(RestRequest req, RestResponse res)
    {
        super(req, res);
    }
    

    override public Object retrievePageOfWorkOrders()
    {
        long s = DateTime.Now().getTime();  
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {    
            String viewId = super.request.params.get('viewId');
            String isInitial = super.request.params.get('isInitial');
            String dispatch = super.request.params.get('dispatchStatus');
            String wo = super.request.params.get('invisibleWorkOrderIds');
            String pageSize = super.request.params.get('pageSize');
            String sortField = super.request.params.get('sortField'); 
            String isQueue1 = super.request.params.get('isQueue'); 
            Boolean sortOrder = true; 
            if(super.request.params.get('isAscending') != null)
                sortOrder = Boolean.valueOf(super.request.params.get('isAscending'));
            String searchField = super.request.params.get('searchField');
            String searchFieldValue = super.request.params.get('searchFieldValue');
            List<String> invisibleWorkOrderIds;
            List<String> dispatchStatus;
            Boolean isInit = false;
            Boolean isQueue = false;
            if(isInitial != null)
                isInit = Boolean.valueOf(isInitial);
            if(isQueue1 != null)
                isQueue = Boolean.valueOf(isQueue1);
            if(dispatch != null)
                dispatchStatus = dispatch.split(',');
            if(wo != null)
                invisibleWorkOrderIds = wo.split(',');
    //        if(pageSize == null)
    //            pageSize = '200';
            if(sortField == null)
                sortField = 'Name';
            if(searchField == null)
                searchField = '';
            if(searchFieldValue == null)
                searchFieldValue = '';
            long e1 = DateTime.Now().getTime();
            DCX_WOServiceManager.workorderDCx data = DCX_ServiceManager.retrieveWorkOrders(viewId,isInit,isQueue,dispatchStatus,invisibleWorkOrderIds,pageSize,sortField,sortOrder,searchField,searchFieldValue);
            long e2 = DateTime.Now().getTime();
            System.debug('initializations: '+(e1-s));
            System.debug('execution: '+(e2-e1));
            if(data.soql.contains('Please select a different view')) {
                response.message = data.soql;  
                data.soql = null; 
                //response.success = false;
                //response.errorCode = 500;
            }
            response.content = data;
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
        
    }
        
    /*override public Object retrievePageOfWorkOrdersJsr()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try {
            long s = DateTime.Now().getTime();       
            String viewId = super.request.params.get('viewId');
            String isInitial = super.request.params.get('isInitial');
            String dispatch = super.request.params.get('dispatchStatus');
            String wo = super.request.params.get('invisibleWorkOrderIds');
            String pageSize = super.request.params.get('pageSize');
            String sortField = super.request.params.get('sortField'); 
            Boolean sortOrder = true;
            if(super.request.params.get('isAscending') != null)
                sortOrder = Boolean.valueOf(super.request.params.get('isAscending'));
            String searchField = super.request.params.get('searchField');
            String searchFieldValue = super.request.params.get('searchFieldValue');
            List<String> invisibleWorkOrderIds;
            List<String> dispatchStatus;
            Boolean isInit = false;
            if(isInitial != null)
                isInit = Boolean.valueOf(isInitial);
            if(dispatch != null)
                dispatchStatus = dispatch.split(',');
            if(wo != null)
                invisibleWorkOrderIds = wo.split(',');
            if(pageSize == null)
                pageSize = '200';
            if(sortField == null)
                sortField = 'Name';
            if(searchField == null)
                searchField = '';
            if(searchFieldValue == null)
                searchFieldValue = '';
            long e1 = DateTime.Now().getTime();
            DCxWOServiceManager.workorderDCx data = 
                DCxServiceManager.retrieveWorkOrdersJsr(viewId,isInit,dispatchStatus,invisibleWorkOrderIds,pageSize,sortField,sortOrder,searchField,searchFieldValue);
            long e2 = DateTime.Now().getTime();
            System.debug('initializations: '+(e1-s));
            System.debug('execution: '+(e2-e1));
            response.content = data;
            response.message = 'Success';
            response.success = true;
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }*/

     override public Object fetchSchedulerData() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            response.content = DCX_SchedulerServiceManager.fetchSchedulerData();
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object schedulerDataNew() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            response.content = DCX_SchedulerServiceManager.fetchSchedulerDataNew();
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }
    
    override public Object fetchEventsOnLaunch() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            response.content = DCX_EventServiceManager.fetchEventsOnLaunch();
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object fetchMetaData() {
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        try {
            DCX_MetaDataServiceManager.metaDataSetting response = DCX_ServiceManager.fetchMetaData();
            resp.content = response;
        } catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    } 
 
   /* override public Object getSkills() {
       DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            list<DCON_MultiCriteriaTechMatch_WS.skill> resp = SVMXC.DCON_MultiCriteriaTechMatch_WS.getSkillDetails();
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
    
    /***********************************SERVICES CALLED AFTER DC LAUNCH***********************************/

     override public Object getViewDefinition()
    {
        DCX_Wrapper.INTF_getViewDefinition_WS_Object request = new DCX_Wrapper.INTF_getViewDefinition_WS_Object();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try{
            request = (DCX_Wrapper.INTF_getViewDefinition_WS_Object)deserializeRequestTo(DCX_Wrapper.INTF_getViewDefinition_WS_Object.class);
            INTF_WebServicesDef.INTF_Request wrapper = new INTF_WebServicesDef.INTF_Request();
            List<INTF_WebServicesDef.INTF_StringListMap> reqStringMap = 
                new List<INTF_WebServicesDef.INTF_StringListMap>();
            reqStringMap = request.stringMap;
            List<String> userId = new List<String>();
            userId.add(Userinfo.getUserId());
            INTF_WebServicesDef.INTF_StringListMap userReq = 
                new INTF_WebServicesDef.INTF_StringListMap('USERID',userId);
            reqStringMap.add(userReq);
            wrapper.stringListMap = reqStringMap; 
            INTF_WebServicesDef.INTF_Response resp  = 
                SVMXC.INTF_WebServicesDef.INTF_getViewDefinition_WS(wrapper);
            response.content = resp;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object getViewWOCount()
    {
        DCX_Wrapper.DCON_ViewWoCount_WS_Object request = new DCX_Wrapper.DCON_ViewWoCount_WS_Object();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try{
            request = (DCX_Wrapper.DCON_ViewWoCount_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_ViewWoCount_WS_Object.class);
            List<DCX_Wrapper.ViewWoCountResponse> responseList = new List<DCX_Wrapper.ViewWoCountResponse>();
            for (String viewId : request.viewIds) {
                if(viewId.length() >= 15) {
                    DCX_Wrapper.ViewWoCountReq wrapper = new DCX_Wrapper.ViewWoCountReq();
                   wrapper.viewId = viewId; 
                   DCX_Wrapper.ViewWoCountResponse resp  = SVMXC.DCX_WOServiceManager.DCON_ViewWoCount_WS(wrapper);
                   responseList.add(resp);
                }
            }
            response.content = responseList;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;

    }
    
    override public Object fetchEvents() {
        DCX_Wrapper.EventDataRequest request = new DCX_Wrapper.EventDataRequest();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            request = (DCX_Wrapper.EventDataRequest)deserializeRequestTo(DCX_Wrapper.EventDataRequest.class); 
            response.content =  DCX_EventServiceManager.fetchEvents1(Userinfo.getUserId(),request.startDate,request.endDate,'ALL',request.tzDtFormat,request.techIds); 
           // response.content =  DCX_ServiceManager.fetchEvents(request.startDate,request.endDate,request.tzDtFormat,request.techIds);
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object fetchEventsAndWOInfo() {
        DCX_Wrapper.EventDataRequest request = new DCX_Wrapper.EventDataRequest();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            request = (DCX_Wrapper.EventDataRequest)deserializeRequestTo(DCX_Wrapper.EventDataRequest.class); 
            response.content =  
                DCX_EventServiceManager.fetchEventsAndWOInfo(Userinfo.getUserId(),request.startDate,
                                                             request.endDate,'ALL',request.tzDtFormat,
                                                             request.techIds); 
           // response.content =  DCX_ServiceManager.fetchEvents(request.startDate,request.endDate,request.tzDtFormat,request.techIds);
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }
    
    override public Object retrieveEventsAndWOInfoForIds() {
        DCX_Wrapper.EventDataRequest request = new DCX_Wrapper.EventDataRequest();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            request = (DCX_Wrapper.EventDataRequest)deserializeRequestTo(DCX_Wrapper.EventDataRequest.class); 
            response.content =  
                DCX_EventServiceManager.fetchEventsAndWOInfoForIds(Userinfo.getUserId(),request.tzDtFormat,
                                                                    request.eventIds); 
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }
    
    override public Object retrieveEventForIds() {
        DCX_Wrapper.EventDataRequest request = new DCX_Wrapper.EventDataRequest();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            request = (DCX_Wrapper.EventDataRequest)deserializeRequestTo(DCX_Wrapper.EventDataRequest.class); 
            response.content =  
                DCX_EventServiceManager.fetchEventsForIds(Userinfo.getUserId(),request.tzDtFormat,
                                                                    request.eventIds); 
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object retrieveEventIds() {
        DCX_Wrapper.EventDataRequest request = new DCX_Wrapper.EventDataRequest();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            request = (DCX_Wrapper.EventDataRequest)deserializeRequestTo(DCX_Wrapper.EventDataRequest.class); 
            response.content =  
                DCX_EventServiceManager.fetchEventIds(Userinfo.getUserId(),request.startDate,
                                                             request.endDate,'ALL',request.tzDtFormat,
                                                             request.techIds); 
           // response.content =  DCX_ServiceManager.fetchEvents(request.startDate,request.endDate,request.tzDtFormat,request.techIds);
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }
/*
    override public Object fetchEvents1() {
        DCX_Wrapper.EventDataRequest request = new DCX_Wrapper.EventDataRequest();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try {
            request = (DCX_Wrapper.EventDataRequest)deserializeRequestTo(DCX_Wrapper.EventDataRequest.class);  
            response.content =  DCX_EventServiceManager.fetchEvents1(Userinfo.getUserId(),request.startDate,request.endDate,'ALL',request.tzDtFormat,request.techIds);
            response.message = 'Success';
            response.success = true;
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }
*/
     override public Object saveUserSettings() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try {
            String usrSetting = request.requestBody.toString();
            DCX_ServiceManager.saveUserSettings(usrSetting);
            //response.content = request.requestBody;
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }
    
     override public Object getViewData() {
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        try{
            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('objectname', super.request.params.get('OBJECTNAME')));
            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('viewid', super.request.params.get('VIEWID')));
            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('recordlimit', super.request.params.get('RECORDLIMIT')));
            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('latitude', super.request.params.get('LATITUDE')));
            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('longitude', super.request.params.get('LONGITUDE')));
            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('radius', super.request.params.get('RADIUS')));
            SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request(null, null, null, stringMap);
            SVMXC.DCX_ServiceManager dcMap = new SVMXC.DCX_ServiceManager();
            
            string objectname = super.request.params.get('OBJECTNAME');
            string viewId = super.request.params.get('VIEWID');
            string recordlimit1 = super.request.params.get('RECORDLIMIT');
            string latitude1 = super.request.params.get('LATITUDE');
            string longitude1 = super.request.params.get('LONGITUDE');
            string radius1 = super.request.params.get('RADIUS');
            
            Integer recordlimit = Integer.valueof(recordlimit1);
            Double latitude = Double.valueof(latitude1);
            Double longitude = Double.valueof(longitude1);
            Double radius = Double.valueof(radius1);
            
            SVMXC.INTF_WebServicesDef.INTF_Response response = dcMap.getMapData(objectname,viewId,recordlimit,latitude,longitude,radius);
            resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
    override public Object MCTMDetail() {
        String WOId = super.request.params.get('woId');
        list<string> WOIds = new list<string>();
        WOIds.add(WOId);
       DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try{
            DCX_MultiCriteriaTechMatch.MCTMDetails resp = DCX_MultiCriteriaTechMatch.getMCTMDetails(WOIds);
            response.content = resp; 
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    
    override public Object techInfo() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
            resp.message = 'Succes';
            resp.success = true;
        try {
           DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object request = new DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object();
            request = (DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object.class);
            list<DCON_Service_Org_WS.Technician_WP> response = DCON_Service_Org_WS.DCON_Retrieve_TechnicianInfo_Tree_WS(request.keyValPairs,request.techIds,userId);
            resp.content = response;
        } catch (Exception ex) {
            setFailureResponse(resp, ex);    
        }
        return resp;
       //DCON_Retrieve_TechnicianInfo_Tree_WS 
    }
    override public Object keywordSearch() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
            resp.message = 'Succes';
            resp.success = true;
         //DCX_Wrapper.DCON_Keyword_Search_WS_Object request = new DCX_Wrapper.DCON_Keyword_Search_WS_Object();
        //request = (DCX_Wrapper.DCON_Keyword_Search_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_Keyword_Search_WS_Object.class);
        try {
            String keyword = super.request.params.get('keyword');
            String findWhat = super.request.params.get('findWhat');
            String keywordMatch = super.request.params.get('keywordMatch');
            String searchType = super.request.params.get('searchType');
            
            list<String> response = DCX_WOServiceManager.DCON_Keyword_Search_WS(userId,keyword,findWhat,keywordMatch,searchType);
            resp.content = response;
        } catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
       //DCON_Retrieve_TechnicianInfo_Tree_WS 
    }
    
  /*  override public Object updateWOTech() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
            resp.message = 'Succes';
            resp.success = true;
        try{
            DCX_Wrapper.UpdateWOTech_Object request = new DCX_Wrapper.UpdateWOTech_Object();
        request = (DCX_Wrapper.UpdateWOTech_Object)deserializeRequestTo(DCX_Wrapper.UpdateWOTech_Object.class);
        
            SVMXC.DCX_Wrapper.UnAssignTechToWO_Request req = new SVMXC.DCX_Wrapper.UnAssignTechToWO_Request();
            req.UserId = userId;
            req.WorkOrderIds = request.WorkOrderIds;
            req.TechnicianId = request.TechnicianId;
            req.timeZone = request.timeZone;
            req.EventList = request.EventList;
            req.setOwner = request.setOwner;
             req.lstKeyValue = request.lstKeyValue;
            req.isUpdate = request.isUpdate;
            
            SVMXC.DCX_Wrapper.unassignAssign_WP response = SVMXC.DCX_WOServiceManager.DCON_Update_WOTech_WS(req);
            resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }*/
    
    override public Object assignWOTeam() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        DCX_Wrapper.assignWOResponse assignWOTeamResp = new DCX_Wrapper.assignWOResponse();
        try{
            DCX_Wrapper.AssignWOTeam_Object request = new DCX_Wrapper.AssignWOTeam_Object();
        request = (DCX_Wrapper.AssignWOTeam_Object)deserializeRequestTo(DCX_Wrapper.AssignWOTeam_Object.class);
        DCX_WOServiceManager.assignWOTeam_Request re = new DCX_WOServiceManager.assignWOTeam_Request();
         re.WorkOrderIds = request.WorkOrderIds;
       re.TeamId =request.TeamId;
        re.SetOwner =request.SetOwner;
        re.dispatchStatus =request.dispatchStatus;
         re.unassignWorkorder =request.unassignWorkorder;
            assignWOTeamResp.statusMessage = DCX_WOServiceManager.assignWOTeam(re);
         //  assignWOTeamResp.statusMessage = SVMXC.DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Team_WS(userId,request.WorkOrderIds,request.TeamId,request.SetOwner);
            assignWOTeamResp.woInfo = DCX_EventServiceManager.retrieveWorkOrdersForIds(request.WorkOrderIds);
            resp.content = assignWOTeamResp;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
     override public Object assignWOTech() {
       String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        DCX_Wrapper.assignWOResponse assignWOTeamResp = new DCX_Wrapper.assignWOResponse();
        try{
            DCX_Wrapper.AssignWOTeam_Object request = new DCX_Wrapper.AssignWOTeam_Object();
        request = (DCX_Wrapper.AssignWOTeam_Object)deserializeRequestTo(DCX_Wrapper.AssignWOTeam_Object.class);
        DCX_WOServiceManager.assignWOTeam_Request re = new DCX_WOServiceManager.assignWOTeam_Request();
         re.WorkOrderIds = request.WorkOrderIds;
       re.TeamId =request.TeamId;
        re.SetOwner =request.SetOwner;
        re.dispatchStatus =request.dispatchStatus;
         re.unassignWorkorder =request.unassignWorkorder;
            assignWOTeamResp.statusMessage = DCX_WOServiceManager.assignWOTech(re);
         //  assignWOTeamResp.statusMessage = SVMXC.DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Team_WS(userId,request.WorkOrderIds,request.TeamId,request.SetOwner);
            assignWOTeamResp.woInfo = DCX_EventServiceManager.retrieveWorkOrdersForIds(request.WorkOrderIds);
            resp.content = assignWOTeamResp;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
     override public Object unassignWO() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        DCX_Wrapper.deleteEventsResponse delResponse = new DCX_Wrapper.deleteEventsResponse();
        resp.message = 'Success';
        resp.success = true;
        try{
            DCX_Wrapper.UnassignWO_Object request = new DCX_Wrapper.UnassignWO_Object();
            request = (DCX_Wrapper.UnassignWO_Object)deserializeRequestTo(DCX_Wrapper.UnassignWO_Object.class);
             DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
            delResponse.delEventIds = WOUtil.DCON_Unassign_Work_Order_WS(userId,request.WorkOrderIds);
            
            //delResponse.delEventIds = SVMXC.DCX_WOServiceManager.DCON_Unassign_Work_Order_WS(userId,request.WorkOrderIds);
            delResponse.woInfo = DCX_EventServiceManager.retrieveWorkOrdersForIds(request.WorkOrderIds);
            resp.content = delResponse;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    override public Object unassignJDMWO() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        try{
            DCX_Wrapper.UnassignJDMWO_Object request = new DCX_Wrapper.UnassignJDMWO_Object();
        request = (DCX_Wrapper.UnassignJDMWO_Object)deserializeRequestTo(DCX_Wrapper.UnassignJDMWO_Object.class);
        SVMXC.DCON_Work_Order_WS.DCTech_WO_WP req = new SVMXC.DCON_Work_Order_WS.DCTech_WO_WP();
            req.WorkOrderId = request.WorkOrderId;
            req.TechId = request.TechId;
            req.OwnerId = request.OwnerId;
            req.isEarlierEvents = request.isEarlierEvents;
            req.EventStartDtTm = request.EventStartDtTm;
            req.timeZone = request.timeZone;
            req.eventId = request.eventId;
            req.isDeleteAllEvents = request.isDeleteAllEvents;
            req.deleteSingleEventId = request.deleteSingleEventId;
            req.isUnassignTech = request.isUnassignTech;
            
            SVMXC.DCON_Work_Order_WS.DCTech_WO_Response_WP response = SVMXC.DCON_Work_Order_WS.DCON_AES_Delete_Tech_Events(req);
            resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
   /*  override public Object assignWOTOMutliTech() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        try{
            DCX_Wrapper.AssignWOTOMutliTech_Object request = new DCX_Wrapper.AssignWOTOMutliTech_Object();
        request = (DCX_Wrapper.AssignWOTOMutliTech_Object)deserializeRequestTo(DCX_Wrapper.AssignWOTOMutliTech_Object.class);
            List<String> response = SVMXC.DCON_Work_Order_WS.DCON_Assign_Work_Order_To_MultiTech_WS2(userId,request.WorkOrderIds,request.TechnicianId,request.timeZone,request.EventList,request.setOwner,request.lstKeyValue);
            resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }*/

    override public Object unassignWOTOMutliTech() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        DCX_Wrapper.workorder_WP updatedWorkOrderObj = new DCX_Wrapper.workorder_WP();
        List<String> woIds = new List<String>();
        try{
        DCX_Wrapper.AssignWOTOMutliTech_Object req = new DCX_Wrapper.AssignWOTOMutliTech_Object();
        req = 
            (DCX_Wrapper.AssignWOTOMutliTech_Object)deserializeRequestTo(DCX_Wrapper.AssignWOTOMutliTech_Object.class);
            //SVMXC.DCON_Work_Order_WS.unassignAssign_WP  response = 
                //SVMXC.DCON_Work_Order_WS.upsertEventOnTechChange(userId,request.WorkOrderIds,request.TechnicianId,request.timeZone,request.EventList,request.setOwner,request.lstKeyValue);
        DCX_EventServiceManager.eventUpsertTechChangeResponse  response = 
            DCX_EventServiceManager.upsertEventOnTechChange(req.EventList,req.WorkOrderId,
                                                            req.timeZone,req.lstKeyValue,
                                                            req.TechnicianId,
                                                            req.updatePrimaryTech,
                                                            req.deleteEventForOtherTechs,
                                                            req.techSFId,
                                                            req.updateWorkOrder,
                                                            req.woFields);
        woIds.add(req.WorkOrderId);
        updatedWorkOrderObj.workorder_O = DCX_EventServiceManager.retrieveWorkOrdersForIds(woIds,response.settingValues,req.woFields).get(req.WorkOrderId);
        response.objWorkOrder = updatedWorkOrderObj;
        resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
    override public Object resetWO() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        try{
            DCX_Wrapper.ResetWO_Object request = new DCX_Wrapper.ResetWO_Object();
        request = (DCX_Wrapper.ResetWO_Object)deserializeRequestTo(DCX_Wrapper.ResetWO_Object.class);
            string  response = SVMXC.DCON_Work_Order_WS.DCON_RESET_WO_Time(request.WorkOrderIds);
            resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }

    override public object fetchEventWOInfo() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.eventWODataRequest request = new DCX_Wrapper.eventWODataRequest();
            request = (DCX_Wrapper.eventWODataRequest)deserializeRequestTo(DCX_Wrapper.eventWODataRequest.class);
            response.content = DCX_EventServiceManager.GetEventWOInfo_WS(request.eventIds,userId,request.keyValPairs,request.viewId,request.dispatchStatus,request.timeZoneDateTimeFormat,request.workOrderIds);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object fetchWOEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.woEventsRequest req = new DCX_Wrapper.woEventsRequest();
            req = (DCX_Wrapper.woEventsRequest)deserializeRequestTo(DCX_Wrapper.woEventsRequest.class);
            response.content = DCX_EventServiceManager.DCON_Retrieve_WO_Events_WS(userId,req.startDate,req.endDate,req.timeZone,req.woId);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object fetchUpdatedEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.updateDeleteEventsRequest req = new DCX_Wrapper.updateDeleteEventsRequest(); 
            req = (DCX_Wrapper.updateDeleteEventsRequest)deserializeRequestTo(DCX_Wrapper.updateDeleteEventsRequest.class);
            response.content = DCON_Event_WS.Retrieve_Updated_Events_WS(userId,req.startDate,req.endDate,req.eventType,req.timeZoneDateTimeFormat,req.lastRetrievedDate,req.technicianIds);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object fetchDeletedEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.updateDeleteEventsRequest req = new DCX_Wrapper.updateDeleteEventsRequest();
            req = (DCX_Wrapper.updateDeleteEventsRequest)deserializeRequestTo(DCX_Wrapper.updateDeleteEventsRequest.class);
            response.content = DCON_Event_WS.Retrieve_Deleted_Events_WS(userId,req.startDate,req.endDate,req.eventType,req.timeZoneDateTimeFormat,req.lastRetrievedDate,req.technicianIds);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object createEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        DCX_Wrapper.workorder_WP updatedWorkOrderObj = new DCX_Wrapper.workorder_WP();
        String woId;
        List<String> woIds = new List<String>();
        response.message = 'Success';
        response.success = true;
        try{
        DCX_Wrapper.UpsertEventsRequest req = new DCX_Wrapper.UpsertEventsRequest();
            req = (DCX_Wrapper.UpsertEventsRequest)deserializeRequestTo(DCX_Wrapper.UpsertEventsRequest.class);
            //response.content = DCON_Event_WS.DCON_Create_Events_WS3(userId,req.events,req.timeZone,req.lstKeyValue);
            DCX_CommonServiceManager.DCEvent_WO_WP resp = 
                DCX_EventServiceManager.createEvents(req.events,req.timeZone,req.lstKeyValue,
                                                     req.techId,req.updatePrimaryTech,
                                                     req.deleteEventForOtherTechs,
                                                     req.techSFId,req.woFields);
            for(Event oEvent: req.events) {
                woId = String.valueOf(oEvent.whatId);
            }
            woIds.add(woId);
            updatedWorkOrderObj.workorder_O = DCX_EventServiceManager.retrieveWorkOrdersForIds(woIds,resp.settingValues,req.woFields).get(woId);
            resp.objWorkOrder = updatedWorkOrderObj;
            response.content = resp;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object upsertEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.upsertEventsRequest req = new DCX_Wrapper.upsertEventsRequest();
            req = (DCX_Wrapper.upsertEventsRequest)deserializeRequestTo(DCX_Wrapper.upsertEventsRequest.class);
            response.content = DCX_EventServiceManager.DCX_Upsert_Events_WS4(userId,req.events,req.timeZone,req.lstKeyValue,req.techId,req.techSFId,req.woFields);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object deleteEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.deleteEventsRequest req = new DCX_Wrapper.deleteEventsRequest(); 
            req = (DCX_Wrapper.deleteEventsRequest)deserializeRequestTo(DCX_Wrapper.deleteEventsRequest.class);
            response.content = DCX_EventServiceManager.DCX_Delete_Events_WS(userId,req.eventIds);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object eventExistInBusinessHour() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            String techId = super.request.params.get('techId');
            String startDate = super.request.params.get('startDate');
            String timeZoneKey = super.request.params.get('timeZoneKey');
            response.content = DCON_Configuration_WS.EventExistinBusinessHour(techId,DateTime.Valueof(startDate),timeZoneKey);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object eventSubjectDefinition() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            String woId = super.request.params.get('woId');
            //response.content = DCON_Event_WS.DCON_Event_SubjectDef(woId + ','+userId);
            response.content = DCX_ServiceManager.eventSubject(woId + ','+userId );
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object fetchAllEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.allEventsRequest req = new DCX_Wrapper.allEventsRequest(); 
            req = (DCX_Wrapper.allEventsRequest)deserializeRequestTo(DCX_Wrapper.allEventsRequest.class);
            response.content = DCX_EventServiceManager.DCON_Fetch_All_Events_WS(req.woIds,userId,req.technicianIds,req.timeZoneDateTimeFormat);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public object fetchEventWarnings() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_EventServiceManager.DCEventWarningReq_WP req = new DCX_EventServiceManager.DCEventWarningReq_WP();
            req = (DCX_EventServiceManager.DCEventWarningReq_WP)deserializeRequestTo(DCX_EventServiceManager.DCEventWarningReq_WP.class);
            response.content = DCX_EventServiceManager.DCX_EventWarnings_WS(req);
        }
        catch(Exception ex){
            //setFailureResponse(response, ex);
        }
        return response;
    }

    override public object fetchOvernightEvents() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCON_Event_WS.Overnight_Events_Input_WP req = new DCON_Event_WS.Overnight_Events_Input_WP();
            req = (DCON_Event_WS.Overnight_Events_Input_WP)deserializeRequestTo(DCON_Event_WS.Overnight_Events_Input_WP.class);
            response.content = DCON_Event_WS.DCON_Retrieve_Overnight_Events_WS(req);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object getTechWorkingHours()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object request = new DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object();
            request = (DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object.class);
            DCX_SchedulerServiceManager.Tech_WorkingHours resp  = 
                DCX_SchedulerServiceManager.DCX_Retrieve_Tech_WorkingHrs_WS(request.lsttechId,request.startdate,request.enddate);
            response.content = resp;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object getQualifiedTechList()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_MultiCriteriaTechMatch.MCTM_Request request = new DCX_MultiCriteriaTechMatch.MCTM_Request();
            request = (DCX_MultiCriteriaTechMatch.MCTM_Request)deserializeRequestTo(DCX_MultiCriteriaTechMatch.MCTM_Request.class);
            response.content = DCX_MultiCriteriaTechMatch.getQualifiedTechList(request);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
/*
  override public Object getQualifiedTechList()
  {
      DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
      response.message = 'Success';
      response.success = true;
      try{
          DCON_MultiCriteriaTechMatch_WS.MCTM_Request request = new DCON_MultiCriteriaTechMatch_WS.MCTM_Request();
          request = (DCON_MultiCriteriaTechMatch_WS.MCTM_Request)deserializeRequestTo(DCON_MultiCriteriaTechMatch_WS.MCTM_Request.class);
          response.content = DCON_MultiCriteriaTechMatch_WS.getQualifiedTechList(request);
      }
      catch(Exception ex){
          setFailureResponse(response, ex);
      }
      return response;
  }
*/  
    override public Object advTechSearch() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try{
            DCX_Wrapper.advTechSearchRequest request = new DCX_Wrapper.advTechSearchRequest();
            request = (DCX_Wrapper.advTechSearchRequest)deserializeRequestTo(DCX_Wrapper.advTechSearchRequest.class);
            DCX_MultiCriteriaTechMatch.MCTM_Response resp = DCX_MultiCriteriaTechMatch.advTechSearch(request);
            response.content = resp; 
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object getListOfTechScheduled()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Success';
        response.success = true;
        try{
            DCX_Wrapper.scheduledTechniciansRequest request = new DCX_Wrapper.scheduledTechniciansRequest();
            request = (DCX_Wrapper.scheduledTechniciansRequest)deserializeRequestTo(DCX_Wrapper.scheduledTechniciansRequest.class);
            response.content = DCX_EventServiceManager.getListOfTechScheduled(request.workOrderIds);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    
    override public Object getWOforMutliAssign()
    {
       String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Success';
        resp.success = true;
        try{
               DCX_Wrapper.getWOforMutliAssign_Object request = new DCX_Wrapper.getWOforMutliAssign_Object();
        request = (DCX_Wrapper.getWOforMutliAssign_Object)deserializeRequestTo(DCX_Wrapper.getWOforMutliAssign_Object.class);
        
            DCX_WOServiceManager.DCON_WO_MultiAssign_Request  req = new DCX_WOServiceManager.DCON_WO_MultiAssign_Request();
        req.workOrderIds = request.workOrderIds;
        req.technicianIds = request.technicianIds;
        req.operationType = request.operationType;
        req.timezone = request.timezone;
        req.Eventlist = request.Eventlist;
        req.lstKeyValue = request.lstKeyValue;
        req.EventIds = request.EventIds;
        req.techSFId = request.techSFId;
       // req.getworkOrderIds = request.getworkOrderIds;
       // req.getEventlist = request.getEventlist;
       // req.setEventlist = request.setEventlist;
            
            DCX_WOServiceManager.DCON_WO_MultiAssign_Response   response = DCX_WOServiceManager.DCX_Manage_Work_Order_MultiAssign_WS(req);
            resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
    override public Object getEventHover()
    {
       String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.message = 'Succes';
        resp.success = true;
        try{
            
            DCX_Wrapper.getEventHover_Object request = new DCX_Wrapper.getEventHover_Object();
        request = (DCX_Wrapper.getEventHover_Object)deserializeRequestTo(DCX_Wrapper.getEventHover_Object.class);
            list<String> response = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_Work_Order_EventHover(request.WorkOrderId);
            resp.content = response;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
     override public Object getDependencyDetails()
    {
        DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object request = new DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try{
            request = (DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object.class);
            DCX_WOServiceManager.Workorder_Dependency_Request wrapper = 
                new DCX_WOServiceManager.Workorder_Dependency_Request();
            wrapper.lstSFEvent = request.lstSFEvent; 
            wrapper.lstSVMXEvent = request.lstSVMXEvent; 
            wrapper.timeZone = request.timeZone; 
            wrapper.userId = UserInfo.getUserId(); 
            wrapper.listWOIds = request.listWOIds; 
            List<DCX_WOServiceManager.Dependency_Details> resp  = 
                SVMXC.DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(wrapper);
            response.content = resp;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    
     override public Object getDependencyCheck()
    {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.getDependencyCheck_Object request = new DCX_Wrapper.getDependencyCheck_Object();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        response.message = 'Succes';
        response.success = true;
        try{
            request = (DCX_Wrapper.getDependencyCheck_Object)deserializeRequestTo(DCX_Wrapper.getDependencyCheck_Object.class);
            DCON_WO_Dependency_WS.Workorder_Dependency_Request wrapper = 
                new DCON_WO_Dependency_WS.Workorder_Dependency_Request();
            wrapper.lstSFEvent = request.lstSFEvent; 
            wrapper.lstSVMXEvent = request.lstSVMXEvent; 
            wrapper.timeZone = request.timeZone; 
            wrapper.userId = userId; 
            wrapper.listWOIds = request.listWOIds; 
            DCON_WO_Dependency_WS.Workorder_Dependency_Response  resp  = 
                SVMXC.DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(wrapper);
            response.content = resp;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public Object retriveWO(){
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try{
            
            string woIds = super.request.params.get('woIds');
             DCON_Work_Order_WS.getWoRequest wrapper =  new DCON_Work_Order_WS.getWoRequest();
             wrapper.WOId = woIds;
            
           // SVMXC.DCON_Work_Order_WS.getWoResponse  response = DCON_Work_Order_WS.DCON_Retrieve_WO_WS(woIds);
            resp.content = DCON_Work_Order_WS.DCON_Retrieve_WO_WS(wrapper);
            resp.message = 'Succes';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return response;
    }
    
     override public Object getWObyIds() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try{
            DCX_Wrapper.getWObyIdsObject request = new DCX_Wrapper.getWObyIdsObject();
        request = (DCX_Wrapper.getWObyIdsObject)deserializeRequestTo(DCX_Wrapper.getWObyIdsObject.class);
            List<DCON_Work_Order_WS.workorder_WP> response = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WO_WS(userId,request.timeZone,request.workorderIds);
            resp.content = response;
            resp.message = 'Succes';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }

    override public Object retrieveWorkOrdersforIds(){
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try{
            DCX_Wrapper.workOrdersForIds request = new DCX_Wrapper.workOrdersForIds();
            request = (DCX_Wrapper.workOrdersForIds)deserializeRequestTo(DCX_Wrapper.workOrdersForIds.class);
            resp.content = 
                DCX_EventServiceManager.retrieveWorkOrdersForIds(request.workorderIds);
            resp.message = 'Success';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
     void setFailureResponse(DCX_Wrapper.DCX_Response response, Exception ex){
        system.debug('Exception Type Cause = '+ex.getTypeName());
        System.debug('Exception Type Cause = ' + ex.getLineNumber());
        System.debug('Exception Type Cause = ' + ex.getMessage());
        response.success = false;
        response.errorCode = 500;
        response.message = ex.getMessage();
    }
    override public Object restoreUserSetting(){
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try{
            boolean response = DCX_SettingServiceManager.restoreUserSettings();
            resp.content = response;
            resp.message = 'Success';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
   /* override public Object restoreUserSetting(){
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try{
            
            resp.content = DCON_Configuration_WS.DCON_Restore_DCSettings_WS(userId);
            resp.message = 'Succes';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return response;
    }
*/

    override public Object getEventHoverRules() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try{
            resp.content = SVMXC.DCX_EventServiceManager.getEventHoverRules();
            resp.message = 'Succes';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
    override public Object createLJSEvent() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            DCX_Wrapper.createLJSEvent_object req = new DCX_Wrapper.createLJSEvent_object();
            req = (DCX_Wrapper.createLJSEvent_object)deserializeRequestTo(DCX_Wrapper.createLJSEvent_object.class);
            DCX_AES_EventServiceManager.AES_Request wrapper =  new DCX_AES_EventServiceManager.AES_Request();
            wrapper.UserId =userId ;
               wrapper.timeZone = req.timeZone;
              wrapper.lstEvent =  req.lstEvent;
        wrapper.lsttechId =   req.lsttechId;
        wrapper.eventMinDuration = req.eventMinDuration;
        wrapper.isTechWorkingHrsEnabled =req.isTechWorkingHrsEnabled;
        wrapper.isMachineWorkingHrsEnabled= req.isMachineWorkingHrsEnabled;
        wrapper.isOverlappingEnabled =req.isOverlappingEnabled;
        wrapper.isCalculateEndTime=req.isCalculateEndTime;
        wrapper.lstKeyValue =req.lstKeyValue;
        wrapper.updatePrimaryTech =req.updatePrimaryTech;
        //wrapper.IsdeleteEvents= req.IsdeleteEvents;
        wrapper.deleteEventForOtherTechs= req.deleteEventForOtherTechs;
      //  wrapper.deleteEventForOtherTechs = req.deleteEventForOtherTechs;
        wrapper.techSFId = req.techSFId;
        DCX_AES_EventServiceManager.AES_Response ljsResp = DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(wrapper);
        DCX_Wrapper.workorder_WP updatedWorkOrderObj = new DCX_Wrapper.workorder_WP(); 
        String woId;
        List<String> woIds = new List<String>();
        for(Event oEvent: req.lstEvent) {
            woId = String.valueOf(oEvent.whatId);
        }
        woIds.add(woId);
        updatedWorkOrderObj.workorder_O = DCX_EventServiceManager.retrieveWorkOrdersForIds(woIds).get(woId);
        ljsResp.objWorkOrder = updatedWorkOrderObj;
            response.content = ljsResp;
            response.message = 'Success';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

     override public Object listDispatcher() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        DCX_Wrapper.SVMX_StringMap stringMap = new DCX_Wrapper.SVMX_StringMap( 'ID',userId);
        try{
            resp.content = DCX_WOServiceManager.SVMX_getDispatcherList_WS(stringMap);
            resp.message = 'Succes';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }

override public Object fetchDCXSetting() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
       
        try{
            resp.content = DCX_ServiceManager.fetchDCXSetting();
            resp.message = 'Succes';
            resp.success = true;
        }catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
    
    override public object deleteAESEvent() {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        DCX_Wrapper.deleteAESEventsResponse delResp = new DCX_Wrapper.deleteAESEventsResponse();
        try{
       
            DCX_Wrapper.deleteJDMEvent req = new DCX_Wrapper.deleteJDMEvent();
            List<String> woIds = new List<String>();
            List<String> woFields = new List<String>();
            req = (DCX_Wrapper.deleteJDMEvent)deserializeRequestTo(DCX_Wrapper.deleteJDMEvent.class);
            DCON_Work_Order_WS.DCTech_WO_WP wrapper =  new DCON_Work_Order_WS.DCTech_WO_WP();

            wrapper.EventStartDtTm =req.EventStartDtTm;
            wrapper.WorkOrderId =req.WorkOrderId;
            wrapper.TechId =req.TechId;
            wrapper.isDeleteAllEvents =req.isDeleteAllEvents;
            wrapper.timeZone= req.timeZone;
            wrapper.eventId= req.eventId;
            wrapper.isUnassignTech=req.isUnassignTech;
            wrapper.OwnerId=req.OwnerId;
            wrapper.isEarlierEvents= req.isEarlierEvents;
            wrapper.deleteSingleEventId = req.deleteSingleEventId;
            woIds.add(req.WorkOrderId);
            DCX_EventServicemanager.DCX_EventServiceManager_Util eventsUtil = new DCX_EventServicemanager.DCX_EventServiceManager_Util();
            DCX_EventServicemanager.DCTech_WO_Response_WP delEventsResp = eventsUtil.deleteAESEvents(req);
            delResp.woInfo = DCX_EventServiceManager.retrieveWorkOrdersForIds(woIds,delEventsResp.settingValues,woFields);
            delEventsResp.settingValues = null;
            delResp.eventsResponse = delEventsResp;
            response.content = delResp;
            response.message = 'Success';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    
     override public Object singleWODetails(){
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try{
            String userId = UserInfo.getUserId();
            string woId = super.request.params.get('woId');
            Boolean isInitial = Boolean.valueOf(super.request.params.get('isInitial'));
            
           // SVMXC.DCON_Work_Order_WS.getWoResponse  response = DCON_Work_Order_WS.DCON_Retrieve_WO_WS(woIds);
            DCX_WOServiceManager.workorderDCx data =  DCX_ServiceManager.singleWO(woId,isInitial);
            system.debug('data '+data);
            resp.content =data;
            resp.message = 'Succes';
            resp.success = true;
        }catch (Exception ex) {
             system.debug('data '+ex);
            setFailureResponse(resp, ex);
        }
        return resp;
    }

    override public Object fetchTechnicianDetails() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try {
            DCX_Wrapper.technicianIds request = new DCX_Wrapper.technicianIds();
            request = (DCX_Wrapper.technicianIds)deserializeRequestTo(DCX_Wrapper.technicianIds.class);
            //response.content = DCX_SchedulerServiceManager.fetchTechDetails(request.techIds,request.techFields);
            response.content = DCX_SchedulerServiceManager.fetchTechDetails(request);
            response.message = 'Success';
            response.success = true;
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public Object fetchDeltaEventsAndWOInfo() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try {
            DCX_Wrapper.DeltaEventRequest request = new DCX_Wrapper.DeltaEventRequest();
            request = (DCX_Wrapper.DeltaEventRequest)deserializeRequestTo(DCX_Wrapper.DeltaEventRequest.class);
            response.content = DCX_EventServiceManager.fetchDeltaEventsAndWOInfo(request.startDate,request.endDate,request.lastFetchedDateTime,request.tzDtFormat,request.techIds);
            response.message = 'Success';
            response.success = true;
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    
    }

   /* override public Object fetchUserSettings() {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try {
            DCxCommonServiceManager.UserSetting usrSetting = 
                SVMXC.DCxServiceManager.fetchUserSettings();
            response.content = usrSetting;
            response.message = 'Success';
            response.success = true;
        } catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }*/
    
   override public Object deployUserSetting() {
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        try {
            DCX_Wrapper.diployUserSettingObject request = 
            new DCX_Wrapper.diployUserSettingObject();
            request = (DCX_Wrapper.diployUserSettingObject)deserializeRequestTo(DCX_Wrapper.diployUserSettingObject.class);
            boolean response = DCX_SettingServiceManager.deployUserSetting(request.settings,request.userids);
            resp.content = response;
            resp.message = 'Succes';
            resp.success = true;
        } catch (Exception ex) {
            setFailureResponse(resp, ex);
        }
        return resp;
    }
   
/*
    override public Object getViews()
    {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            
            response.content = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_Views_WS(userId); 
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
        
    } 

   
    override public Object getServiceDocument(){
        Map<String, String> serviceDoc = new Map<String, String>();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try {
            serviceDoc.put('RETRIVE_VIEWS', '/svmx/DispatchConsoleServiceIntf/DCON_Retrieve_Views_WS');
            serviceDoc.put('RETRIVE_WORKORDER', '/svmx/DispatchConsoleServiceIntf/DCON_Retrieve_Work_Orders_WS2');
            response.content = serviceDoc;
            response.message = 'Succes';
            response.success = true;
        } catch (Exception ex) {
            setFailureResponse(response, ex);    
        }
        return response;
    } 
    
    override public Object getTags()
    {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            List<COMM_TagWebServices.TagsMap> resp = SVMXC.DCON_Configuration_WS.DCON_Retrieve_Display_Tags_WS(userId);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public Object getEvents()
    {
        long t1 = DateTime.now().getTime();
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            DCX_Wrapper.DCON_Retrieve_Events_WS_Object request = 
                new DCX_Wrapper.DCON_Retrieve_Events_WS_Object();
            request = 
                (DCX_Wrapper.DCON_Retrieve_Events_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_Retrieve_Events_WS_Object.class);
            
       /* String StartDate = super.request.params.get('stDate');
        String EndDate = super.request.params.get('edDate');
        String tz = super.request.params.get('tz');
        String TechIds = super.request.params.get('techIds');
        String Status = super.request.params.get('status');
        List<String> TechnicianIds = new List<String>();
         TechnicianIds = TechIds.split(',');
        system.debug('StartDate :'+StartDate);
        system.debug('EndDate :'+EndDate);
        system.debug('tz :'+tz);
        system.debug('TechIds :'+TechIds);
        system.debug('Status :'+Status);
        system.debug('TechnicianIds :'+TechnicianIds);*/
/*        system.debug('request.startDate' +request.startDate);
        system.debug('request.endDate' +request.endDate);
        system.debug('request.eventType' +request.eventType);
        system.debug('request.timeZoneFormat' +request.timeZoneFormat);
        system.debug('request.technicianIds' +request.technicianIds);
       
            List<DCON_Event_WS.Events_WP> resp  = SVMXC.DCON_Event_WS.DCON_Retrieve_Events_WS(UserInfo.getUserId(),request.startDate,request.endDate,request.eventType,request.timeZoneFormat,request.technicianIds);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        long t2 = DateTime.now().getTime();
        system.debug('DCON_Retrieve_Events_WS time taken : '+(t2-t1));
        return response;
    }
*/    
/*    
     override public Object fetchTechnicians() {
        String searchType = super.request.params.get('searchType');
        String teamsTerritories = super.request.params.get('teamsTerritories');
        List<String> tList = new List<String>();
        if(teamsTerritories != null)
            tList = teamsTerritories.split(',');
        return DCxServiceManager.fetchTechnicians(searchType,tList);
    }*/
     /*override public Object getWorkorders()
    { 
       DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{ 
            DCX_Wrapper.DCON_Retrieve_Work_Orders_WS2_Object request = new DCX_Wrapper.DCON_Retrieve_Work_Orders_WS2_Object();
            system.debug('Request data before '+ request);
            request = (DCX_Wrapper.DCON_Retrieve_Work_Orders_WS2_Object)deserializeRequestTo(DCX_Wrapper.DCON_Retrieve_Work_Orders_WS2_Object.class);
            //Object resp = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WS2(request.keyValPairs,request.UserId,request.ViewId,request.DispatchStatus,request.timeZone,request.workorderIds);
            // Boniface Lobo
            //         
            system.debug('Request data  after'+ request);
            list<DCON_Work_Order_WS.workorder_WP> resp = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WS2(request.keyValPairs,request.UserId,request.ViewId,request.DispatchStatus,request.timeZone,request.workorderIds);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/

   /* override public Object getWorkorderids()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            DCX_Wrapper.DCON_Retrieve_AllWorkOrder_Ids_WS_Object request = new DCX_Wrapper.DCON_Retrieve_AllWorkOrder_Ids_WS_Object();
            request = (DCX_Wrapper.DCON_Retrieve_AllWorkOrder_Ids_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_Retrieve_AllWorkOrder_Ids_WS_Object.class);  
            List<DCON_Work_Order_WS.workorder_WP> resp  = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_AllWorkOrder_Ids_WS(request.keyValPairs,request.UserId,request.ViewId,request.DispatchStatus,request.timeZone);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;

    }*/ 
  /*  override public Object getGP1Response()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try {
            String userId = UserInfo.getUserId();
            String resp = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(userId);
            List<DCON_Configuration_WS.SVMX_StringMap> resp1 = SVMXC.DCON_Configuration_WS.DCON_Retrieve_Settings_WS(userId);
            DCON_Work_Order_WS.workorderInfo_WP resp2 = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_Work_Order_Info();
            List<DCON_Configuration_WS.SVMX_StringMap> resp3 = SVMXC.DCON_Configuration_WS.DCON_GetAllTimeZone_WS(userId);
            List<COMM_TagWebServices.TagsMap> resp4 = SVMXC.DCON_Configuration_WS.DCON_Retrieve_Display_Tags_WS(userId);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch (Exception ex) {
            setFailureResponse(response, ex);
        }
        return response;
    }*/
   /* override public Object getSettings()
    {
        
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response(); 
        try{
            List<DCON_Configuration_WS.SVMX_StringMap> resp = SVMXC.DCON_Configuration_WS.DCON_Retrieve_Settings_WS(userId); 
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    } */
  /*  override public Object getWorkorderInfp()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            DCON_Work_Order_WS.workorderInfo_WP resp = SVMXC.DCON_Work_Order_WS.DCON_Retrieve_Work_Order_Info();
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/ 
   /* override public Object DCON_Retrieve_User_Settings_WS()
    {
        
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            String resp = SVMXC.DCON_Configuration_WS.DCON_Retrieve_User_Settings_WS(userId);
            system.debug('Parse Before ' +System.now());
            String jsonContent = XmlParser.xmlToJson(resp);
            system.debug('Parse After ' +System.now());
            response.content = jsonContent;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/

    

   /* override public Object getTimeZones()
    {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            List<DCON_Configuration_WS.SVMX_StringMap> resp = SVMXC.DCON_Configuration_WS.DCON_GetAllTimeZone_WS(userId);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
   /* override public Object getLocalDate()
    {
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            String resp = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(userId);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
    /*override public Object getSkillDetails()
    {
        List<DCON_MultiCriteriaTechMatch_WS.skill> resp = SVMXC.DCON_MultiCriteriaTechMatch_WS.getSkillDetails();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
  /*  override public Object getObjectFieldList()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            DCON_Configuration_WS.SVMX_Response resp = SVMXC.DCON_Configuration_WS.DCON_getObjectFieldList_WS();
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
   /* override public Object getTechnicians()
    {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            String userId = UserInfo.getUserId();
            DCX_Wrapper.DCON_Retrieve_Technician_Tree_WS_Object request = new DCX_Wrapper.DCON_Retrieve_Technician_Tree_WS_Object();
            request = (DCX_Wrapper.DCON_Retrieve_Technician_Tree_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_Retrieve_Technician_Tree_WS_Object.class);
            List<DCON_Service_Org_WS.Technician_WP> resp = SVMXC.DCON_Service_Org_WS.DCON_Retrieve_Technician_Tree_WS(request.UserId,request.SearchType,request.RetrieveAllRecords,request.timeZone,request.ServiceTeamTerr);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
   /*override public Object getTechDetails()
   {
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            DCX_Wrapper.getTechDetails_Object request = new DCX_Wrapper.getTechDetails_Object();
            request = (DCX_Wrapper.getTechDetails_Object)deserializeRequestTo(DCX_Wrapper.getTechDetails_Object.class);  
            DCON_Service_Org_WS.getTechDetailsReq obj = new  DCON_Service_Org_WS.getTechDetailsReq();
            obj.lstTechIds = request.lstTechIds;
            List<DCON_Service_Org_WS.getTechDetailsResponse> resp = SVMXC.DCON_Service_Org_WS.getTechDetails(obj);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
   /* override public Object getTeam()
    {
        long t1 = DateTime.now().getTime();
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            List<SVMXC__Service_Group__c> resp = SVMXC.DCON_Service_Org_WS.DCON_Retrieve_Team_Tree_WS(userId, true);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        long t2 = DateTime.now().getTime();
        system.debug('DCON_Retrieve_Team_Tree_WS1 time taken : '+(t2-t1));
        return response;
    }*/
  /*  override public Object getTerritory()
    {
        long t1 = DateTime.now().getTime();
        String userId = UserInfo.getUserId();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();      
        try{
            List<SVMXC__Territory__c> resp = SVMXC.DCON_Service_Org_WS.DCON_Retrieve_Territory_Tree_WS(userId,true);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        long t2 = DateTime.now().getTime();
        system.debug('DCON_Retrieve_Territory_Tree_WS time taken : '+(t2-t1));
        return response;
    }*/
    
    
   /* override public Object SFM_getObjectFieldList_WS()
    {
        DCX_Wrapper.SFM_getObjectFieldList_WS_Object request = new DCX_Wrapper.SFM_getObjectFieldList_WS_Object();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            request = (DCX_Wrapper.SFM_getObjectFieldList_WS_Object)deserializeRequestTo(DCX_Wrapper.SFM_getObjectFieldList_WS_Object.class);
            SFM_WrapperDef.SFM_Request wrapper = new SFM_WrapperDef.SFM_Request();
            wrapper.stringMap = request.stringMap;      
            system.debug('stringMap' +request.stringMap);
            SFM_WrapperDef.SFM_Response_ObjectFields resp  = 
                SVMXC.SFM_WebServicesDef.SFM_getObjectFieldList_WS(wrapper);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;

    }*/
   
    
  /*  override public Object getDependencyDetails()
    {
        DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object request = new DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            request = (DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object.class);
            DCON_WO_Dependency_WS.Workorder_Dependency_Request wrapper = 
                new DCON_WO_Dependency_WS.Workorder_Dependency_Request();
            wrapper.lstSFEvent = request.lstSFEvent; 
            wrapper.lstSVMXEvent = request.lstSVMXEvent; 
            wrapper.timeZone = request.timeZone; 
            wrapper.userId = request.userId; 
            wrapper.listWOIds = request.listWOIds; 
            List<DCON_WO_Dependency_WS.Dependency_Details> resp  = 
                SVMXC.DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(wrapper);
            response.content = resp;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/
   
  /* */
  /*   override public Object DCON_Update_User_Settings_WS()
    {
            
        DCX_Wrapper.DCON_Update_User_Settings_WS_Object request = new DCX_Wrapper.DCON_Update_User_Settings_WS_Object();
        DCX_Wrapper.DCX_Response response = new DCX_Wrapper.DCX_Response();
        try{
            request = (DCX_Wrapper.DCON_Update_User_Settings_WS_Object)deserializeRequestTo(DCX_Wrapper.DCON_Update_User_Settings_WS_Object.class);
            String resp  = SVMXC.DCON_Configuration_WS.DCON_Update_User_Settings_WS(request.UserId,request.UserSettings);
            String jsonContent = XmlParser.xmlToJson(resp);
            response.content = jsonContent;
            response.message = 'Succes';
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }*/

    
    
    
   
    
    
   /* override public Object INTF_getViewData_WS() {
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('objectname', super.request.params.get('OBJECTNAME')));
        
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('viewid', super.request.params.get('VIEWID')));
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('recordlimit', super.request.params.get('RECORDLIMIT')));
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('latitude', super.request.params.get('LATITUDE')));
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('longitude', super.request.params.get('LONGITUDE')));
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('radius', super.request.params.get('RADIUS')));
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request(null, null, null, stringMap);
        SVMXC.INTF_CustomViewUtils dcMap = new SVMXC.INTF_CustomViewUtils();
        SVMXC.INTF_WebServicesDef.INTF_Response response = dcMap.getViewData1(request);
        DCX_Wrapper.DCX_Response resp = new DCX_Wrapper.DCX_Response();
        resp.content = response;
        resp.message = 'Succes';
        resp.success = true;

        return resp;
    }*/
 }