global class ApexTestQueueListener implements Schedulable {
    
    private static Set<String> IgnoreApexClass = new Set<String> {
        'ApexTestQueueListener',
            'ApexCoverageListener',
            'PopulateCoverage',
            'CodeCoverageClass',
            'ConcurrentSessionsPolicyCondition',
            'CONF_SetupScheduledSFM_anc',
            'CONF_SetupScheduledSFM_anc1',
            'CreateDependency',
            'createtimesheetHeader',
            'CustomWSClass',
            'FirstClass',
            'generateDynamicVfComponentError',
            'InstalligenceConfiguration',
            'InstalligenceSetupImpl',
            'IPRD_CreateInitial',
            'WSCH_SettingValidator',
            'WSCH_Provider_ECO_StubsV1',
            'WSCH_Provider_ECO_ServiceV1',
            'WSCH_BookJobCalloutHook',
            'AutomatedTestingScheduler',
            'IoTCustomImplementation',
            'WSCH_FutureCallTest',
            'testAnc',
            'WSCH_TechnicianTriggerHandler',
            'ChangePasswordController',
            'ChangePasswordControllerTest',
            'ForgotPasswordController',
            'ForgotPasswordControllerTest',
            'generateDynamicVfComponentError',
            'MyProfilePageController',
            'MyProfilePageControllerTest',
            'SFM_ScheduledBatch_LargeData',
            'SiteLoginController',
            'SiteRegisterController',
            'TestClassForUT',
            'USER_LicenseAssignment',
            'WSCH_CustomHookFactory'
    };
    
    private Boolean runAllTest = false;
    private String sessionId = null;
	private Set<Id> parentJobIdList = new Set<Id>();
    private Map<Id, ApexClass> modifiedApexClassMap = new Map<Id, ApexClass>();
    
    global ApexTestQueueListener( Set<Id> jobIdSet, String sessionId, Map<Id, ApexClass> modifiedApexClassMap, Boolean runAllTest ) {
        
        this.runAllTest = runAllTest;
        this.parentJobIdList = jobIdSet;
        this.sessionId = sessionId;
        this.modifiedApexClassMap = modifiedApexClassMap;
    }
    
    global void execute( SchedulableContext context ) {
        
        Datetime lastFiveMin = System.now().addMinutes(-5);
        List<ApexTestQueueItem> apexTestQueueItemList = [SELECT Status, ApexClassId, ParentJobId FROM ApexTestQueueItem WHERE Status != 'Completed' AND Status != 'Failed' AND Status != 'Aborted' AND ( ParentJobId IN :parentJobIdList OR SystemModstamp > :lastFiveMin ) ];
        
        System.abortJob( context.getTriggerId() );
        
        for( ApexTestQueueItem item : apexTestQueueItemList ) {
            parentJobIdList.add(item.ParentJobId);
        }
        
        if( !apexTestQueueItemList.isEmpty() ) {
            
            Integer minutes = Math.mod( System.now().minute() + 1, 60);            
            String schedule = '0 ' + String.valueOf( minutes ) + ' * * * ?';
            System.schedule('Apex Test Queue Scheduler', schedule, new ApexTestQueueListener( parentJobIdList.clone(), sessionId, modifiedApexClassMap, runAllTest ) );    
        } else {
            processTestResult( parentJobIdList, sessionId, modifiedApexClassMap.keySet(), runAllTest );
        }
    }
    
    @future(callout=true)
    private static void processTestResult( Set<Id> parentJobIdList, String sessionId, Set<Id> modifiedApexClassId, Boolean runAllTest ) {
        
        ApexTestResult[] results = [ SELECT Outcome, MethodName, Message, StackTrace, AsyncApexJobId, ApexClass.Id, ApexClass.Name, ApexClass.LengthWithoutComments FROM ApexTestResult WHERE AsyncApexJobId IN :parentJobIdList];
		Set<String> failedApexClassSet = new Set<String>();
        for (ApexTestResult atr : results) {
            
            System.debug(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
            if (atr.message != null) {
                System.debug(atr.Message + '\n at ' + atr.StackTrace);
            }
            if( atr.Outcome.equalsIgnoreCase('FAIL') ) {
                failedApexClassSet.add( atr.ApexClass.Name.substring(0, atr.ApexClass.Name.length() - 3) );
            }
        }
        
        String query = null;
        if( runAllTest ) {
            query = 'SELECT Id, ApexClassOrTriggerId, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate';
        } else {
            query = 'SELECT Id, ApexClassOrTriggerId, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate WHERE ';
            
            for(Id apexClassId : modifiedApexClassId ) {
                query += 'ApexClassOrTriggerId=\'' + apexClassId + '\' OR ';
            }
            
            query = query.substring(0, query.length() - 3);    
        }
        
        
        Http h = new Http();
        HttpRequest queryReq = new HttpRequest();
        queryReq.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v34.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        
        queryReq.setHeader('Authorization', 'OAuth ' + sessionId );
        queryReq.setHeader('Content-Type', 'application/json');
        queryReq.setTimeout(110000);
        queryReq.setMethod('GET');
        
        HttpResponse queryRes = h.send(queryReq);
        String response = queryRes.getBody();
        
        System.debug('RESPONSE: ' + response);
        
        ApexCodeCoverageAggregate acc = (ApexCodeCoverageAggregate) System.JSON.deserialize(response, ApexCodeCoverageAggregate.class);
        
        List<Id> apexClassId = new List<Id>();
        for( ApexCodeCoverageAggregate.Records r : acc.records ) {            
            apexClassId.add( r.ApexClassOrTriggerId );
        }
        
        Map<Id, ApexClass> apexClassMap = new Map<Id, ApexClass>();
        apexClassMap.putAll( [SELECT Id, Name, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM ApexClass WHERE Id IN :apexClassId ] );
        
        List<SVMXC__Coverage_Summary__c> coverageSummaryList = [SELECT Id FROM SVMXC__Coverage_Summary__c WHERE SVMXC__Coverage_On__c = TODAY];
        
        SVMXC__Coverage_Summary__c coverageSummary = null;
        if( coverageSummaryList.isEmpty() ) {
            
            coverageSummary = new SVMXC__Coverage_Summary__c();
            coverageSummary.SVMXC__Coverage_On__c = System.today();
            
            insert coverageSummary;
        } else {
            coverageSummary = coverageSummaryList.get(0);
        }
        
        List<SVMXC__Coverage_Details__c> detailList = new List<SVMXC__Coverage_Details__c>();
        Map<String, SVMXC__Coverage_Details__c> classCoverageDetailsMap = new Map<String, SVMXC__Coverage_Details__c>();
        
        for( SVMXC__Coverage_Details__c coverageDetails : [SELECT Id, Name, SVMXC__Coverage_Summary__c, SVMXC__Previous_Coverage__c FROM SVMXC__Coverage_Details__c WHERE SVMXC__Coverage_Summary__c = :coverageSummary.Id ]) {
            classCoverageDetailsMap.put( coverageDetails.Name, coverageDetails);
        }
        
        for( ApexCodeCoverageAggregate.Records r : acc.records ) {
            
            Decimal covered = r.NumLinesCovered;
            Decimal uncovered = r.NumLinesUncovered;
            Decimal percent = 0.00;
            
            if( covered != 0 || uncovered != 0 ) {
                percent = (covered / (covered + uncovered) * 100).setScale(2);     
            }
            
            ApexClass modifiedApexClass = apexClassMap.get( r.ApexClassOrTriggerId );
            if( modifiedApexClass != null ) {
                
                if( IgnoreApexClass.contains(modifiedApexClass.Name) || ( covered == 0 && uncovered == 0 ) ) {
                    continue;
                }
                
            	SVMXC__Coverage_Details__c details = new SVMXC__Coverage_Details__c();
                if( classCoverageDetailsMap.containsKey( modifiedApexClass.Name ) ) {
                    details = classCoverageDetailsMap.get(modifiedApexClass.Name);
                }
                
                details.SVMXC__Unit_Test_Failed__c = false;
                if( failedApexClassSet.contains( modifiedApexClass.Name ) ) {
                    details.SVMXC__Unit_Test_Failed__c = true;
                }
                
                details.Name = modifiedApexClass.Name;
                if( details.Name.indexOf('_') != -1 && details.Name.indexOf('_') < 8 ) {
                	details.SVMXC__Module__c = details.Name.substring(0, details.Name.indexOf('_') );    
                }
                
                details.SVMXC__Code_Coverage__c = percent;
                if( details.SVMXC__Coverage_Summary__c == null ) {
                	details.SVMXC__Coverage_Summary__c = coverageSummary.Id;    
                }
                details.SVMXC__Class_Created_By__c = modifiedApexClass.CreatedById;
                details.SVMXC__Class_Modified_By__c = modifiedApexClass.LastModifiedById;
                details.SVMXC__Class_Modified_On__c = modifiedApexClass.LastModifiedDate;
                details.SVMXC__Covered_Lines__c = covered;
                details.SVMXC__Total_Lines__c = (covered + uncovered);
                if( details.SVMXC__Previous_Coverage__c == null || details.SVMXC__Previous_Coverage__c < details.SVMXC__Code_Coverage__c ) {
                    details.SVMXC__Previous_Coverage__c = percent;
                }
                
                if( covered != 0 || (covered == 0 && details.Id == null ) ) {
                	detailList.add( details );    
                }
            }
        }
        
        upsert detailList;
    }
}