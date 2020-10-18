@isTest
private class DCON_DeployUserSetting_UT
{
static testMethod void Dcon_DeployUserSetting_UT_Test()
{


Dcon_DeployUserSetting.DCUserSettings obj1 = new Dcon_DeployUserSetting.DCUserSettings();
obj1.rootName = 'configuration';
obj1.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('version','2'));
obj1.ismodified = true;
Dcon_DeployUserSetting.DCUserSettings obj2 = new Dcon_DeployUserSetting.DCUserSettings();
obj2.rootName = 'workOrderSettings';
obj2.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('autorefresh','false'));
obj2.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('refreshtime','7'));
//obj2.ismodified = false;
Dcon_DeployUserSetting.DCUserSettings obj3 = new Dcon_DeployUserSetting.DCUserSettings();
obj3.rootName = 'selectedcolumns';

//Dcon_DeployUserSetting.DCUserSettings obj4 = new Dcon_DeployUserSetting.DCUserSettings();
//obj4.rootName = 'Name';
//obj4.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('name','Name'));
//obj4.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('width','145.78841309823676'));
obj3.Values = '<column name=\"Name\" width=\"145.78841309823777\"/> \n'+'<column name=\"SVMXC__Company__c\" width=\"141.26784214945777\"/> ';
//obj3.Values = ;
//Dcon_DeployUserSetting.DCUserSettings obj5 = new Dcon_DeployUserSetting.DCUserSettings();
//obj5.rootName = 'Name';
//obj5.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('name','SVMXC__Company__c'));
//obj5.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('width','145.78841309823676'));

//obj3.lstChildDCUserSettings.add(obj4);
//obj3.lstChildDCUserSettings.add(obj5);
obj3.ismodified = true;
//obj5.ismodified = true;
Dcon_DeployUserSetting.DCUserSettings obj6 = new Dcon_DeployUserSetting.DCUserSettings();
obj6.rootName = 'rules';
//Dcon_DeployUserSetting.DCUserSettings obj6a = new Dcon_DeployUserSetting.DCUserSettings();
//obj6a.rootName = 'rule';
Dcon_DeployUserSetting.DCUserSettings obj7 = new Dcon_DeployUserSetting.DCUserSettings();
obj7.rootName = 'Call';
obj7.Values = '<row property=\"Subject111111\" type=\"EVENT\" fieldType=\"combobox\" compare=\"matches\" value=\"Call\"/>';

obj7.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('name','Call'));
obj7.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('color','16750848'));

Dcon_DeployUserSetting.DCUserSettings obj8 = new Dcon_DeployUserSetting.DCUserSettings();
obj8.rootName = 'Critical Work Orders';
obj8.Values = '<row property=\"Subject1111\" type=\"EVENT\" fieldType=\"combobox\" compare=\"matches\" value=\"Email\"/>';
obj8.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('name','Critical Work Orders'));
obj8.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('status','TAG168'));

Dcon_DeployUserSetting.DCUserSettings obj7a = new Dcon_DeployUserSetting.DCUserSettings();
obj7a.rootName = 'Low Priority Work Orders';
obj7a.Values = '<row property=\"SVMXC__Priority__c\" type=\"\" fieldType=\"\" compare=\"matches\" value=\"Low\"/> ';

obj7a.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('name','Low Priority Work Orders'));
obj7a.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('color','16737555'));
obj7a.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('status','TAG168'));


obj6.lstChildDCUserSettings.add(obj8);
obj6.lstChildDCUserSettings.add(obj7a);
obj7.ismodified = true;
obj8.ismodified = true;
obj2.lstChildDCUserSettings.add(obj3);
obj2.lstChildDCUserSettings.add(obj6);
obj3.ismodified = true;
obj6.ismodified = true;
//obj6a.ismodified = true;

Dcon_DeployUserSetting.DCUserSettings obj22 = new Dcon_DeployUserSetting.DCUserSettings();
obj22.rootName = 'technicianSettings';
obj22.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('id','technicianSettings'));
obj22.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('view','team'));
obj22.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('map','false'));
obj22.ismodified = true;
obj1.lstChildDCUserSettings.add(obj2);
obj1.lstChildDCUserSettings.add(obj22);
obj2.ismodified = true;
Dcon_DeployUserSetting.DCUserSettings obj33 = new Dcon_DeployUserSetting.DCUserSettings();
obj33.rootName = 'selectedcolumns';
obj33.values = '<column name=\"Name\" width=\"177\"/> ';
obj33.ismodified = true;
obj22.lstChildDCUserSettings.add(obj33);
Dcon_DeployUserSetting.DCUserSettings obj44 = new Dcon_DeployUserSetting.DCUserSettings();
obj44.rootName = 'rules';
obj44.ismodified = true;

Dcon_DeployUserSetting.DCUserSettings obj7b = new Dcon_DeployUserSetting.DCUserSettings();
obj7b.rootName = 'Test123';
obj7b.ismodified = true;
obj7b.Values = '<row property=\"SubTest123\" type=\"EVENT\" fieldType=\"combobox\" compare=\"matches\" value=\"Test\"/>';

obj7b.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('name','Test123'));
obj7b.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('Test','7777777'));
obj44.lstChildDCUserSettings.add(obj7);
obj44.lstChildDCUserSettings.add(obj7b);

obj22.lstChildDCUserSettings.add(obj44);
//obj33.Values = '<column name=\"Name\" width=\"145.78841309823777\"/> \n'+'<column name=\"SVMXC__Company__c\" width=\"141.26784214945777\"/> ';

obj33.ismodified = true;

Dcon_DeployUserSetting.DCUserSettings obj55 = new Dcon_DeployUserSetting.DCUserSettings();
obj55.rootName = 'keywordSettings';
obj55.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('id','keywordSettings'));
obj55.ismodified = false;
obj1.lstChildDCUserSettings.add(obj55);
Dcon_DeployUserSetting.DCUserSettings obj66 = new Dcon_DeployUserSetting.DCUserSettings();

obj66.rootName = 'selectedcolumns';
obj66.ismodified = false;
obj55.lstChildDCUserSettings.add(obj66);
Dcon_DeployUserSetting.DCUserSettings obj77 = new Dcon_DeployUserSetting.DCUserSettings();
obj77.rootName = 'teamKeywordSettings';
obj77.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('id','teamKeywordSettings'));
obj77.ismodified = false;
obj1.lstChildDCUserSettings.add(obj77);
Dcon_DeployUserSetting.DCUserSettings obj88 = new Dcon_DeployUserSetting.DCUserSettings();
obj88.rootName = 'selectedcolumns';
obj88.ismodified = false;
obj77.lstChildDCUserSettings.add(obj88);
Dcon_DeployUserSetting.DCUserSettings obj99 = new Dcon_DeployUserSetting.DCUserSettings();
obj99.rootName = 'techKeywordSettings';
obj99.attributesStrMap.add(new Dcon_DeployUserSetting.stringMap('id','techKeywordSettings'));
obj99.ismodified = false;
obj1.lstChildDCUserSettings.add(obj99);
Dcon_DeployUserSetting.DCUserSettings obj100 = new Dcon_DeployUserSetting.DCUserSettings();
obj100.rootName = 'selectedcolumns';
obj100.ismodified = false;
obj99.lstChildDCUserSettings.add(obj100);

user u1= [Select SVMXC__Dispatch_Console_Settings__c from user where id = : userinfo.GetuserId()];
Dom.Document doc1 = new Dom.Document();
    if(u1.SVMXC__Dispatch_Console_Settings__c != null){
       doc1.load(u1.SVMXC__Dispatch_Console_Settings__c);

        //Retrieve the root element for this document.
        Dom.XMLNode XMLrootNode = doc1.getRootElement();
        System.debug('++++:  '+Dcon_DeployUserSetting.getModifiedUserSetting(XMLrootNode,obj1,u1.SVMXC__Dispatch_Console_Settings__c));
    }
    else
    {
            Dom.XMLNode XMLrootNode = doc1.getRootElement();
    System.debug('++++:  '+Dcon_DeployUserSetting.getModifiedUserSetting(XMLrootNode,obj1,''));
    }
        //try{

//}catch(exception e){system.debug('Info: '+e.getStackTraceString());}
//======================================================//
    }

    static testMethod void testCoverage()
    {
        Test.startTest();
        
        DCON_DeployUserSetting deployUserSetting = new DCON_DeployUserSetting();
        DCON_DeployUserSetting.removeXMLInString('nodeName', '<nodeName attribute=""></nodeName>', 'attribute' );
        DCON_DeployUserSetting.getXMLInString( 'nodeName',  '<nodeName attribute=""></nodeName>' );
        DCON_DeployUserSetting.getXMLInString1( 'nodeName',  '<nodeName attribute=""></nodeName>' );
        DCON_DeployUserSetting.getDefaultUserSettings();
        
        map<string,string> mapNodeName  = new map<string, string>();
        String userXml1 = 'config';
        mapNodeName.put('configuration', 'configuration');
        DCON_DeployUserSetting.getUnmodifiedNode(userXml1, mapNodeName);
        
        mapNodeName.put('rules', 'rules');
        DCON_DeployUserSetting.getUnmodifiedNode('rules', mapNodeName);
        
        mapNodeName.put('selectedcolumns', 'selectedcolumns');
        DCON_DeployUserSetting.getUnmodifiedNode('selectedcolumns', mapNodeName);
        
        map<string,map<string,string>> mapNodeNameNode1 = new map<string,map<string,string>>();
        map<string,string> map1 = new map<string,string>();
        map1.put('rules', 'rules');
        mapNodeNameNode1.put('rules', map1);
        string strtorepl = '<rules>';
        DCON_DeployUserSetting.addUnmodifiedNodetoXMLString( mapNodeNameNode1, strtorepl);
        DCON_DeployUserSetting.getXMLInString('configuration', 'test<configuration>test<configuration/>');

        
        DCON_Configuration_WS.SVMX_StringMap dcUserSetReq = new DCON_Configuration_WS.SVMX_StringMap('UT','UTVALUE');
        User u2 = [SELECT id,LocaleSidKey from User where id != :UserInfo.getUserId() limit 1];
        User u = [SELECT id,LocaleSidKey from User where id = :UserInfo.getUserId()];        
        dcUserSetReq.woViewType = 'All';
        dcUserSetReq.columnInfo = 'Account';
        dcUserSetReq.Key = 'work';
        dcUserSetReq.Value = '1234';
        dcUserSetReq.ValueList = new List<String>{u2.Id};
        dcUserSetReq.dcSetting = new Dcon_DeployUserSetting.DCUserSettings();
        dcUserSetReq.Value = u.Id;
        DCON_Configuration_WS.SVMX_Response resp = DCON_DeployUserSetting.deploySelectivelyDCUSerSetting(dcUserSetReq);
        
        Dcon_DeployUserSetting.DCUserSettings dcUsrSet = new Dcon_DeployUserSetting.DCUserSettings();
        dcUsrSet.rootName = 'configuration';
        dcUsrSet.Values = 'rule';
        dcUsrSet.rulType = 'node';
        dcUsrSet.ismodified = true;
        String result = DCON_DeployUserSetting.BuildXMLFromWrp(dcUsrSet);
    
        Test.stopTest();
    }
    
}