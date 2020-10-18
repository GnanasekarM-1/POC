@isTest
public class WORD_ManageZoneDefinition_UT 
{
//Commented by Bala: Issue while creating package

    static testMethod void WORD_ManageZoneDefinitionTest() 
    {
        SVMXC__Territory__c objTerr = new SVMXC__Territory__c();
        objTerr.Name = 'Mysore';
        insert objTerr;
        WORD_ManageZoneDefinition objZoneDef = new WORD_ManageZoneDefinition();
        WORD_ManageZoneDefinition.polygon objPolygon = new WORD_ManageZoneDefinition.polygon();
        WORD_ManageZoneDefinition.circle objcircle = new WORD_ManageZoneDefinition.circle();
        WORD_ManageZoneDefinition.rectangle objrectangle = new WORD_ManageZoneDefinition.rectangle();
        WORD_ManageZoneDefinition.latLng objlatLng = new WORD_ManageZoneDefinition.latLng();
        datetime dtStartdate = datetime.newInstance(2013, 03, 1);
        datetime dtenddate = datetime.newInstance(2013, 03, 3);
        string strselWO='createddate'+','+objTerr.id;
        WORD_ManageZoneDefinition.GetWO(string.valueof(dtStartdate),string.valueof(dtenddate),strselWO);
        objZoneDef.getTAG001();
        objZoneDef.getlstTerritory();
        objZoneDef.onChangeTerritory1();
        objZoneDef.getstrSelectedTerritory();
        objZoneDef.setstrSelectedTerritory(strselWO);
        objZoneDef.getlstWOfield();
        
        WORD_ManageZoneDefinition.getZones(objTerr.id);
        
        string strpolyg = '[{\"id\":2,\"latLng\":[{\"lat\":13.31479411223821,\"lng\":78.94775390625},{\"lat\":13.058074727480722,\"lng\":78.343505859375},{\"lat\":12.404388944669792,\"lng\":78.662109375},{\"lat\":11.68451427712824,\"lng\":78.453369140625},{\"lat\":12.243391505623274,\"lng\":79.12353515625},{\"lat\":11.942601073545658,\"lng\":79.837646484375},{\"lat\":12.951029216018357,\"lng\":79.62890625}],\"fillColor\":\"#1E90FF\",\"clickable\":false}]';
        string strCircle = '[{"id":4,"center":{"lat":11.706030770773825,"lng":76.1572265625},"radius":50023.03489581493,"fillColor":"#1E90FF"}]';
        string strRect = '[{"id":6,"ne":{"lat":10.466205555063882,"lng":79.178466796875},"sw":{"lat":10.14193168613103,"lng":77.71728515625},"fillColor":"#1E90FF"}]';
        String strDelete='abc;def';
        
        WORD_ManageZoneDefinition.SaveZones(objTerr.id,strpolyg,strCircle,strRect,strDelete);
        WORD_ManageZoneDefinition.getOrganizationAddress();
        string strpolygonval = '{\"latLng\":[{\"lng\":78.94775390625,\"lat\":13.31479411223821},{\"lng\":78.343505859375,\"lat\":13.058074727480722},{\"lng\":78.662109375,\"lat\":12.404388944669792},{\"lng\":78.453369140625,\"lat\":11.68451427712824},{\"lng\":79.12353515625,\"lat\":12.243391505623274},{\"lng\":79.837646484375,\"lat\":11.942601073545658},{\"lng\":79.62890625,\"lat\":12.951029216018357}],\"id\":\"2\",\"fillColor\":\"#1E90FF\",\"clickable\":false}';
        
        string strCircleval = '{\"radius\":50023.03489581493,\"id\":\"4\",\"fillColor\":\"#1E90FF\",\"center\":{\"lng\":76.1572265625,\"lat\":11.706030770773825}}';
        
        string strRectval = '{\"sw\":{\"lng\":77.71728515625,\"lat\":10.14193168613103},\"ne\":{\"lng\":79.178466796875,\"lat\":10.466205555063882},\"id\":\"6\",\"fillColor\":\"#1E90FF\"}';
        
        SVMXC__Territory_Coverage__c objTerCov = new SVMXC__Territory_Coverage__c();
        objTerCov.SVMXC__Type__c ='City';
        objTerCov.SVMXC__Value__c ='Mysore';
         objTerCov.SVMXC__Territory__c = objTerr.id;
        insert objTerCov;
        SVMXC__Territory_Coverage__c objTerCov1 = new SVMXC__Territory_Coverage__c();
        objTerCov1.SVMXC__Type__c ='State';
        objTerCov1.SVMXC__Value__c ='Karnataka';
         objTerCov1.SVMXC__Territory__c = objTerr.id;
        insert objTerCov1;
        SVMXC__Territory_Coverage__c objTerCov2 = new SVMXC__Territory_Coverage__c();
        objTerCov2.SVMXC__Type__c ='Country';
        objTerCov2.SVMXC__Value__c ='India';
        objTerCov2.SVMXC__Territory__c = objTerr.id;
        insert objTerCov2;
        SVMXC__Territory_Coverage__c objTerCov3 = new SVMXC__Territory_Coverage__c();
        objTerCov3.SVMXC__Type__c ='Zip';
        objTerCov3.SVMXC__Value__c ='570008';
        objTerCov3.SVMXC__Territory__c = objTerr.id;
        insert objTerCov3;
       
        WORD_ManageZoneDefinition.getAddress(objTerr.id);        
        SVMXC__Service_Zone__c  objZone1 = new SVMXC__Service_Zone__c ();
        objZone1.SVMXC__Zone_Type__c = 'Polygon';
        objZone1.SVMXC__Zone_Definition__c = strpolygonval;
        objZone1.SVMXC__Territory__c = objTerr.id;
        objZone1.SVMXC__Zone_Name__c = 'objZone1Name';
        insert objZone1;
        SVMXC__Service_Zone__c  objZone2 = new SVMXC__Service_Zone__c ();
        objZone2.SVMXC__Zone_Type__c = 'Circle';
        objZone2.SVMXC__Zone_Definition__c = strCircleval;
        objZone2.SVMXC__Territory__c = objTerr.id;
        objZone2.SVMXC__Zone_Name__c = 'objZone2Name';
        insert objZone2;
        SVMXC__Service_Zone__c  objZone3 = new SVMXC__Service_Zone__c ();
        objZone3.SVMXC__Zone_Type__c = 'Rectangle';
        objZone3.SVMXC__Zone_Definition__c = strRectval;
        objZone3.SVMXC__Territory__c = objTerr.id;
        objZone3.SVMXC__Zone_Name__c = 'objZone3Name';
        insert objZone3;
       
        String strDelete1='abc;'+objZone3.id;
        WORD_ManageZoneDefinition.SaveZones(objTerr.id,strpolyg,strCircle,strRect,strDelete1);
        WORD_ManageZoneDefinition.getZones(objTerr.id);
    }
}