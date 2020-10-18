public with sharing class SGAT_SyncGatewayImpl extends ComRestBase {
    public SGAT_SyncGatewayImpl(RestRequest req, RestResponse res) {
        super(req, res, '/svmx/SGAT_SyncGatewayIntf');
    }

    override public Object invokeMethod(ComRestMethodInfo mi) {
        Object res = null;
        DateTime dt = DateTime.now();
        if(mi.MethodName.equals('SGExecuteQuery'))
            res = SGExecuteQuery();
        else if(mi.MethodName.equals('SGDisplayTags'))
            res = getCustomLabels();
        else if(mi.MethodName.equals('SGDeleteRecords'))
            res = deleteRecords();
        system.debug('Total time taken to execute the service: ' + (DateTime.now().getTime() - dt.getTime()));
        return res;
    }

    public Object deleteRecords() {
      SGAT_WebServicesDef.SGAT_Request request = (SGAT_WebServicesDef.SGAT_Request)deserializeRequestTo(SGAT_WebServicesDef.SGAT_Request.class);
      if(!isRequestValid(request)) {
           return errorResponse('Request not Valid');
      }
      SGAT_WebServicesDef.SGAT_Response response = new SGAT_WebServicesDef.SGAT_Response(new List<SGAT_WebServicesDef.SVMXMap>());

      for (SGAT_WebServicesDef.SVMXMap eachObject : request.valueMap) {
        SGAT_WebServicesDef.SVMXMap objVM = new SGAT_WebServicesDef.SVMXMap();
        objVM.key = eachObject.key;
        objVM.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        response.valueMap.add(objVM);
        List<sObject> lstRecordsToDelete = new List<sObject>();
        List<SGAT_WebServicesDef.SVMXMap> errorIdsValueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        List<String> deleteSuccessIds = new List<String>();
        Type ty = Type.forName('Schema.'+ eachObject.key );
        if (ty == null) {
          for (String recordIdToDelete: eachObject.values) {
            addErrorValueMap(recordIdToDelete, new List<String>{'invalid object.'}, errorIdsValueMap);
          }
        } else {
          Schema.SObjectType obj = ((SObject)(ty.newInstance())).getSObjectType();
          for (String recordIdToDelete: eachObject.values) {
            try {
              lstRecordsToDelete.add(obj.newSObject(recordIdToDelete));
            } catch (Exception ex) {
              addErrorValueMap(recordIdToDelete, new List<String>{'invalid id.'}, errorIdsValueMap);
              system.debug('Error: ' + ex.getMessage());
            }
          }
          for (Database.DeleteResult deleteResult: Database.delete(lstRecordsToDelete, false)) {
              if (deleteResult.isSuccess()) {
                deleteSuccessIds.add(deleteResult.getId());
              } else {
                List<String> errorMessages = new List<String>();
                for (Database.Error err: deleteResult.getErrors()) {
                  errorMessages.add(err.getMessage());
                }
                addErrorValueMap(deleteResult.getId(), errorMessages, errorIdsValueMap);
              }
          }
        }

        if (deleteSuccessIds != null && deleteSuccessIds.size() > 0) {
          SGAT_WebServicesDef.SVMXMap successVM = new SGAT_WebServicesDef.SVMXMap();
          successVM.key = 'success';
          successVM.values = deleteSuccessIds;
          objVM.valueMap.add(successVM);
        }
        if (errorIdsValueMap != null && errorIdsValueMap.size() > 0) {
          SGAT_WebServicesDef.SVMXMap errorVM = new SGAT_WebServicesDef.SVMXMap();
          errorVM.key = 'error';
          errorVM.valueMap = errorIdsValueMap;
          objVM.valueMap.add(errorVM);
        }
      }

      return response;
    }

    private void addErrorValueMap(String idWithError, List<String> errors, List<SGAT_WebServicesDef.SVMXMap> errorIdsValueMap) {
      SGAT_WebServicesDef.SVMXMap errorVM = new SGAT_WebServicesDef.SVMXMap();
      errorVM.key = idWithError;
      errorVM.values = errors;
      errorIdsValueMap.add(errorVM);
    }

    public Object SGExecuteQuery() {
        SGAT_WebServicesDef.SGAT_Request request = (SGAT_WebServicesDef.SGAT_Request)deserializeRequestTo(SGAT_WebServicesDef.SGAT_Request.class);
        SGAT_WebServicesDef.SGAT_Response resp = getQueriedData(request);
        return resp;
    }

    public SGAT_WebServicesDef.SGAT_Response getQueriedData(SGAT_WebServicesDef.SGAT_Request request) {
        if(!isRequestValid(request)) {
             return errorResponse('Request not Valid');
        }

        Double resourceLimit = 80.0;
        List<SGAT_WebServicesDef.SVMXMap> lstQueriesVM = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SVMXMap singleQueryVM = new SGAT_WebServicesDef.SVMXMap();
        boolean isSingleQueryRequest = true;

        List<SGAT_WebServicesDef.SVMXMap> lstSvmxMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SGAT_Response res = new SGAT_WebServicesDef.SGAT_Response(lstSvmxMap);
        for(SGAT_WebServicesDef.SVMXMap svmxMap: request.valueMap) {
            if(svmxMap.key == 'query' && svmxMap.value != null) {
                singleQueryVM = svmxMap;
            } else if (svmxMap.key == 'RESOURCE_PERCENT' && svmxMap.value != null) {
                resourceLimit = Double.valueOf(svmxMap.value);
            } else if (svmxMap.key == 'QUERIES' && svmxMap.valueMap != null && svmxMap.valueMap.size() > 0) {
                lstQueriesVM.addAll(svmxMap.valueMap);
                isSingleQueryRequest = false;
            }
        }
        system.debug('Resource Limit: ' + resourceLimit);
        system.debug('Queries ValueMap: ' + lstQueriesVM);
        if (lstQueriesVM != null && lstQueriesVM.size() > 0) {
            queryData(lstQueriesVM, lstSvmxMap, resourceLimit);
        }

        if (isSingleQueryRequest && singleQueryVM != null && singleQueryVM.key == 'query') {
          String query = singleQueryVM.value;
          List<String> ids = (List<String>) singleQueryVM.values;
          SGAT_WebServicesDef.SVMXMap resSvmxMap = getSingleQueryData(query, ids, resourceLimit);
          if (resSvmxMap != null) {
              lstSvmxMap.add(resSvmxMap);
          }
        }

        return res;
    }

    private SGAT_WebServicesDef.SVMXMap getSingleQueryData(String query, List<String> ids, Double resourceLimit) {
        SGAT_WebServicesDef.SVMXMap resSvmxMap = new SGAT_WebServicesDef.SVMXMap();
        resSvmxMap.key = 'DATA';
        query = query.replace('({{ids}})', ' :ids');
        List<sObject> recordsData = new List<sObject>();
        for (SObject[] records: Database.query(query)) {
          recordsData.addAll(records);
          if (isLimitReached(resourceLimit)) {
              if(recordsData != null && recordsData.size() > 0) {
                  SGAT_WebServicesDef.SVMXMap lastIdSvmxMap = new SGAT_WebServicesDef.SVMXMap('LAST_ID', recordsData[recordsData.size() - 1].Id);
                  resSvmxMap.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
                  resSvmxMap.valueMap.add(lastIdSvmxMap);
              }
              system.debug('Limit Reached!!');
              break;
          }
        }

        resSvmxMap.records = recordsData;
        return resSvmxMap;
    }

    public void queryData(List<SGAT_WebServicesDef.SVMXMap> lstQueriesVM, List<SGAT_WebServicesDef.SVMXMap> lstSvmxMap, Double resourceLimit) {
        for (SGAT_WebServicesDef.SVMXMap eachQueryVM: lstQueriesVM) {
            Boolean isDeleted = false;
            if (isLimitReached(resourceLimit)) {
                system.debug('Limit Reached!!');
                return;
            }
            if (eachQueryVM.key != null && eachQueryVM.value != null) {
                system.debug('Object key: ' + eachQueryVM.key);
                system.debug('Object Query: ' + eachQueryVM.value);
                SGAT_WebServicesDef.SVMXMap eachQueryDataVM = new SGAT_WebServicesDef.SVMXMap(eachQueryVM.key, eachQueryVM.value);
                try {
                    Double remainingQueryLimit = Limits.getLimitQueryRows() * (resourceLimit / 100) - Limits.getQueryRows();
                    system.debug('Remaining query limit: ' + remainingQueryLimit);
                    if (remainingQueryLimit <= 0) {
                        return;
                    }
                    String SOQLQuery = eachQueryVM.value;
                    system.debug('SOQL from request: ' + SOQLQuery);
                    if (eachQueryVM.valueMap != null && eachQueryVM.valueMap.size() > 0) {
                        for (SGAT_WebServicesDef.SVMXMap lastIdVM: eachQueryVM.valueMap) {
                            if (lastIdVM.key == 'LAST_ID' && lastIdVM.value != null) {
                                if (SOQLQuery.toLowercase().contains('where')) {
                                    SOQLQuery = SOQLQuery + ' AND Id > \'' + lastIdVM.value + '\'';
                                } else {
                                    SOQLQuery = SOQLQuery + ' WHERE Id > \'' + lastIdVM.value + '\'';
                                }
                            } else if (lastIdVM.key == 'IS_DELETED' && lastIdVM.value != null) {
                                isDeleted = Boolean.valueOf(lastIdVM.value);
                            }
                        }
                    }

                    SOQLQuery = SOQLQuery + ' ORDER BY ID LIMIT ' + Integer.valueOf(remainingQueryLimit);

                    if (isDeleted) {
                        SOQLQuery = SOQLQuery + ' ALL ROWS';
                    }
                    system.debug('SOQL prepared: ' + SOQLQuery);
                    eachQueryDataVM.records = new List<sObject>();
                    boolean isLastIdAdded = false;

                    for (SObject[] recordsData: Database.query(SOQLQuery)) {
                      system.debug('Records queried for key: ' + eachQueryVM.key + ' :with size of: ' + recordsData.size());
                      eachQueryDataVM.records.addAll(recordsData);
                      if (isLimitReached(resourceLimit)) {
                          if(recordsData != null && recordsData.size() > 0) {
                              addLastIdResponseVM(recordsData[recordsData.size() - 1].Id, eachQueryDataVM);
                          }
                          isLastIdAdded = true;
                          system.debug('Limit Reached!!');
                          break;
                      }
                    }
                    system.debug('Number of Rows queried: ' + eachQueryDataVM.records.size());
                    if (eachQueryDataVM.records.size() >= remainingQueryLimit && !isLastIdAdded) {
                        if (eachQueryDataVM.records != null && eachQueryDataVM.records.size() > 0)
                            addLastIdResponseVM(eachQueryDataVM.records[eachQueryDataVM.records.size() - 1].Id, eachQueryDataVM);
                    }
                } catch (Exception ex) {
                    SGAT_WebServicesDef.SVMXMap errorVM = new SGAT_WebServicesDef.SVMXMap('ERROR', ex.getMessage());
                    eachQueryDataVM.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
                    eachQueryDataVM.valueMap.add(errorVM);
                }
                lstSvmxMap.add(eachQueryDataVM);
            }
        }
    }

    private void addLastIdResponseVM(String lastId, SGAT_WebServicesDef.SVMXMap eachQueryDataVM) {
        SGAT_WebServicesDef.SVMXMap lastIdVM = new SGAT_WebServicesDef.SVMXMap('LAST_ID', lastId);
        eachQueryDataVM.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        eachQueryDataVM.valueMap.add(lastIdVM);
    }

    public boolean isLimitReached(Double resourceLimit) {
        Double heapLimitAllowed = 50.0;
        if(resourceLimit < 70) {
            heapLimitAllowed = resourceLimit / 2;
        }
        system.debug('Heap Limit allowed: ' + heapLimitAllowed);

        if ((((Double)Limits.getCpuTime() / (Double)Limits.getLimitCpuTime()) * 100 >= resourceLimit) || (((Double)Limits.getQueryRows()/(Double)Limits.getLimitQueryRows()) * 100 >= resourceLimit) || (((Double)Limits.getHeapSize()/((Double)Limits.getLimitHeapSize())) * 100 >= heapLimitAllowed)) {
            return true;
        }
        return false;
    }

    private boolean isRequestValid(SGAT_WebServicesDef.SGAT_Request request) {
        if(request == null || request.valueMap == null || request.valueMap.size() == 0)
          return false;
        return true;
    }

    private SGAT_WebServicesDef.SGAT_Response errorResponse(String errorMessage) {
        SGAT_WebServicesDef.SVMXMap svmxMap = new SGAT_WebServicesDef.SVMXMap('ERROR', errorMessage);
        List<SGAT_WebServicesDef.SVMXMap> lstMaps = new List<SGAT_WebServicesDef.SVMXMap>();
        lstMaps.add(svmxMap);
        return new SGAT_WebServicesDef.SGAT_Response(lstMaps);
    }

    public SGAT_WebServicesDef.SGAT_Response getCustomLabels() {
        SGAT_WebServicesDef.SGAT_Response response = new SGAT_WebServicesDef.SGAT_Response((new COMM_TagsDefinition()).getFSAPhoneTags());
        return response;
    }
}