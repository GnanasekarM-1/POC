@isTest
(SeeAllData= false)
public class WSCH_CRUD_Helper_UT {

    public static Event createEvent(){
        Event testEvent = new Event();
        testEvent.Subject = 'TestEvent' + String.valueOf(System.Datetime.now());
        testEvent.StartDateTime = System.Datetime.now();
        testEvent.EndDateTime = System.Datetime.now().addMinutes(20);
        testEvent.DurationInMinutes = 20;
        Database.insert(testEvent);
        return testEvent;
    }
    
    static testMethod void testFetchSFEventObjectById(){
        Event tstEventActual = createEvent();
        Event tstEventExpected = new Event();
        Test.startTest();
            tstEventExpected = WSCH_CRUD_Helper.fetchSFEventObjectById(String.valueOf(tstEventActual.id));
            tstEventExpected = WSCH_CRUD_Helper.fetchSFEventObjectById(String.valueOf(tstEventActual.id), '');
        Test.stopTest();
        System.assertEquals(tstEventExpected.Subject, tstEventActual.Subject);
    }
    static testMethod void testUpsertEvents(){
        Event tstEvntUpsert =  createEvent();
        DateTime actualDT = tstEvntUpsert.EndDateTime;
        tstEvntUpsert.EndDateTime = tstEvntUpsert.EndDateTime.addMinutes(40);
        tstEvntUpsert.DurationInMinutes += 40;
        Set<String> setIds = new Set<String>();
        setIds.add(tstEvntUpsert.Id);
        Test.startTest();
            WSCH_CRUD_Helper.upsertEvents(tstEvntUpsert);
            WSCH_CRUD_Helper.fetchListSFEvent(setIds);
        Test.stopTest();
        System.assertEquals(actualDT.addMinutes(40), tstEvntUpsert.EndDateTime);
    }
    static testMethod void testDeleteEvents(){
        Event tstEvntDel =  createEvent();
        List<Event> tstListEvntDel = new List<Event>();
        tstListEvntDel.add(createEvent());
        tstListEvntDel.add(createEvent());
        Id tstEventID = tstEvntDel.id;
        Profile usrProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<String> sysAdmProfile = new List<String>{String.valueOf(usrProfile)};
		List<User> usrList = [SELECT ID, UserName FROM User WHERE ProfileId NOT IN :sysAdmProfile AND isActive=true LIMIT 1];
        User crdUser = new User();
        If(usrList.isEmpty()){
            crdUser = [SELECT ID, UserName FROM User WHERE Id =: UserInfo.getUserId()];
        }
        else{
            crdUser = usrList[0];
        }
        System.debug('CRUD USER: ' + crdUser.UserName);
        System.runAs(crdUser) {
            WSCH_CRUD_Helper.deleteEvents(tstEvntDel);
            WSCH_CRUD_Helper.deleteListEvents(tstListEvntDel);
        }
        System.assertEquals(null,WSCH_CRUD_Helper.fetchSFEventObjectById(String.valueOf(tstEventID)));
    }
    static testMethod void testUpsertSObject(){
        Event tstEventActual = createEvent();
        tstEventActual.Subject = 'MODIFIED';
        List<Event> tstEventToUpsert = new List<Event>();
        tstEventToUpsert.add(tstEventActual);
        Test.startTest();
            WSCH_CRUD_Helper.upsertListEvents(tstEventToUpsert);
        Event tstEventExpected = (Event) tstEventToUpsert[0];
        Test.stopTest();
        System.assertEquals('MODIFIED', tstEventExpected.Subject);
    }
    static testMethod void testFetchSObject(){
        Event tstEventActual = createEvent();
        List<sObject> tstEventExpected = new List<sObject>();
        Test.startTest();
            tstEventExpected = WSCH_CRUD_Helper.fetchSObject(String.valueOf(tstEventActual.id), 'Subject', 'Event');
        Test.stopTest();
        System.assertEquals(tstEventExpected[0].id, tstEventActual.id);
    }
}