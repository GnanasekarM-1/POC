global class ApexCoverageListener implements Schedulable {
    
    private String sessionId = null;
    
    global ApexCoverageListener( String sessionId ) {
        this.sessionId = sessionId;
    }
    
    global void execute( SchedulableContext context ) {
        
        Datetime startTime = System.now();
        Datetime lastExecutedDatetime = startTime.addMinutes( ( 5 * -1) );
        
        Map<Id,ApexClass> modifiedApexClassMap = new Map<Id, ApexClass>();
        modifiedApexClassMap.putAll( [SELECT Id, Name, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM ApexClass WHERE LastModifiedDate >= :lastExecutedDatetime ] );
        
        List<String> utToClassList = new List<String>();
        for( ApexClass modifiedApexClass : modifiedApexClassMap.values() ) {
            if( modifiedApexClass.Name.endsWith( '_UT' ) ) {
                utToClassList.add( modifiedApexClass.Name.substring(0, modifiedApexClass.Name.length() - 3) );
            }
        }
        
        if( !utToClassList.isEmpty() ) {
            modifiedApexClassMap.putAll( [SELECT Id, Name, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM ApexClass WHERE Name IN :utToClassList ] );    
        }
        
        if( !modifiedApexClassMap.isEmpty() ) {
            processCodeCoverage( modifiedApexClassMap, false );
        }
        
        System.abortJob( context.getTriggerId() );
        
        Integer minutes = Math.mod( startTime.minute() + 5, 60 );
        
        while( Math.mod(minutes,5) != 0 ) {
            minutes = Math.mod( minutes + 1, 5 );
        }
        
        if( startTime.hour() == 3 && minutes == 10 ) {
            
            modifiedApexClassMap = new Map<Id, ApexClass>();
            modifiedApexClassMap.putAll( [SELECT Id, Name, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM ApexClass] );
            processCodeCoverage( modifiedApexClassMap, true );
        }
        
        String schedule = '0 ' + String.valueOf( minutes ) + ' * * * ?';
        System.schedule('Apex Coverage Listener', schedule, new ApexCoverageListener( sessionId ) );    
        
        if( Math.mod( minutes, 10 ) == 0 ) {
            verifySession(sessionId);    
        }        
    }
    
    @future(callout=true)
    private static void verifySession( String sessionId ) {
                
        HttpRequest queryReq = new HttpRequest();
        queryReq.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v34.0/tooling/query/?q=' + EncodingUtil.urlEncode('SELECT count() FROM ApexClass', 'UTF-8'));
        
        queryReq.setHeader('Authorization', 'OAuth ' + sessionId );
        queryReq.setHeader('Content-Type', 'application/json');
        queryReq.setTimeout(110000);
        queryReq.setMethod('GET');
        
        Http h = new Http();
        HttpResponse queryRes = h.send(queryReq);
    }
    
    private void processCodeCoverage( Map<Id, ApexClass> modifiedApexClassMap, Boolean runAllTest ) {
        
        List<String> utApexClassList = new List<String>();
        for( ApexClass modifiedApexClass : modifiedApexClassMap.values() ) {
            
            if( modifiedApexClass.Name.equalsIgnoreCase('WSCH_Provider_SP_Appointments_Calendar') ) {
                utApexClassList.add( 'WSCH_Provider_SP_Appointment_Calendar_UT' );
            } else if( modifiedApexClass.Name.equalsIgnoreCase( 'IPRD_CoverageByCounters_SContract' ) ||
                     modifiedApexClass.Name.equalsIgnoreCase( 'IPRD_CoverageByCounters_Warranty' ) ) {
                utApexClassList.add( modifiedApexClass.Name + 'UT' );
            } else {
                utApexClassList.add( modifiedApexClass.Name + '_UT' );
            }
        }
        
        Map<Id, ApexClass> utApexClassMap = new Map<Id, ApexClass>();
        utApexClassMap.putAll( [ SELECT Id FROM ApexClass WHERE Name IN :utApexClassList ] );
        
        if( !utApexClassMap.isEmpty() ) {
            
            List<ApexTestQueueItem> apexTestQueueItemList = new List<ApexTestQueueItem>();
            for( ApexClass utClass : utApexClassMap.values() ) {
                apexTestQueueItemList.add( new ApexTestQueueItem( ApexClassId = utClass.Id ) );
            }
            
            Database.insert( (List<SObject>) apexTestQueueItemList, false);
            
            Set<Id> parentJobIdList = new Set<Id>();
            List<ApexTestQueueItem> itemList = [ SELECT ParentJobId FROM ApexTestQueueItem WHERE Id = :apexTestQueueItemList];
            for( ApexTestQueueItem item : itemList ) {
                parentJobIdList.add(item.ParentJobId);
            }
            
            Integer minutes = Math.mod( System.now().minute() + ( (runAllTest) ? 10 : 1 ), 60 );
            
            String schedule = '0 ' + String.valueOf( minutes ) + ' * * * ?';            
            System.schedule('Apex Test Queue Scheduler' + ( (runAllTest) ? ' RunAllTest' : ''), schedule, new ApexTestQueueListener( parentJobIdList.clone(), sessionId, modifiedApexClassMap, runAllTest ) );
        }
    }
}