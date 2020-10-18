@isTest
public class CONF_ManageViews_UT
{   
    public static testMethod void test_CONF_ManageViews() {
        List<SVMXC__ServiceMax_Processes__c> lstPros = new List<SVMXC__ServiceMax_Processes__c>{};
        List<SVMXC__ServiceMax_Config_Data__c> lstConf = new List<SVMXC__ServiceMax_Config_Data__c>{};
        SVMXC__ServiceMax_Processes__c newPros;
        SVMXC__ServiceMax_Config_Data__c newConf;
        CONF_ManageViews manViw;
        PageReference pr;
        integer ind=0;
        
        for(Integer i = 0; i < 30; i++){
            newPros= new SVMXC__ServiceMax_Processes__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'View Definition' Limit 1].Id, SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c', SVMXC__IsStandard__c = true, SVMXC__Rule_Type__c='Custom View', SVMXC__Select__c = false);        
            lstPros.add(newPros);       
        }
        insert lstPros;
  
        manViw = new CONF_ManageViews();
        system.assertEquals(manViw.chkCustlst,true);
        system.assertEquals(manViw.chkStrdlst,false);
        
        for(Integer i = 0; i < 30; i++)
            lstpros.get(i).SVMXC__IsStandard__c =false;
        update lstpros;
        manViw.getqueryResult();
        system.assertEquals(manViw.chkCustlst,false);
        system.assertEquals(manViw.chkStrdlst,true);
    
        for(Integer i = 0; i < 15; i++)
            lstpros.get(i).SVMXC__IsStandard__c = true;
        update lstpros;
        manViw.getqueryResult();
        system.assertEquals(manViw.chkCustlst,false);
        system.assertEquals(manViw.chkStrdlst,false);
             
        for(SVMXC__ServiceMax_Processes__c newPros1 : manViw.LstCustViwCnfgr){
            if(ind<8){
                newConf = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [SELECT Id FROM RecordType WHERE Name ='Expressions' Limit 1].Id, SVMXC__Expression_Type__c = 'SRCH_Object_Fields', SVMXC__Expression_Rule__c = newPros1.Id ) ;   

            }
            else{
                newConf = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [SELECT Id FROM RecordType WHERE Name ='View Access' Limit 1].Id, SVMXC__Dispatch_Process__c = newPros1.Id ) ;
            }
            lstConf.add(newConf);
            ind++;
        }     
        insert lstConf;
        
        manViw.strEditRView = 'View';
        //If at a time no process have value "True" for its IsSelected property
        
        pr = manViw.ViewREditProcess();
        system.assertEquals(pr,null);
        //If at a only one process have value "True" for its IsSelected property
    
        manViw.getLstStdViwCnfgr().get(0).SVMXC__Select__c = True;
        pr = manViw.ViewREditProcess();
        system.assertNotEquals(pr,null);
        //If at a time more than one process have value "True" for its IsSelected property
        
        for(integer i=0;i<10;i++)
            manViw.getLstStdViwCnfgr().get(i).SVMXC__Select__c = True;
        pr = manViw.ViewREditProcess();
        system.assertEquals(pr,null);                   
        
        manViw.strEditRView = 'Edit';
        //If at a time no process have value "True" for its IsSelected property
        
        pr = manViw.ViewREditProcess();
        system.assertEquals(pr,null);
        //If at a only one process have value "True" for its IsSelected property
        
        manViw.getLstCustViwCnfgr().get(0).SVMXC__Select__c = True;
        pr = manViw.ViewREditProcess();
        system.assertNotEquals(pr,null);
        //If at a time more than one process have value "True" for its IsSelected property
        
        for(integer i=0;i<10;i++)
            manViw.getLstCustViwCnfgr().get(i).SVMXC__Select__c = True;
        pr = manViw.ViewREditProcess();
        system.assertEquals(pr,null); 
        
        for(integer i=0;i<10;i++){
            manViw.getLststdViwCnfgr().get(i).SVMXC__Select__c = false;
            manViw.getLstCustViwCnfgr().get(i).SVMXC__Select__c = false;
        }
        
        pr = manViw.managePermission();
        system.assertNotEquals(pr,null);
        
        manViw.strEditRView = 'Clone1';
        //If at a time no process have value "True" for its IsSelected property
        
        pr = manViw.cloneProcess();
        system.assertEquals(pr,null);
        //If at a only one process have value "True" for its IsSelected property
        
        manViw.getLstStdViwCnfgr().get(0).SVMXC__Select__c = true;
        system.assertEquals(manViw.getLstStdViwCnfgr().get(0).SVMXC__Select__c, true);
        pr = manViw.cloneProcess();
        system.assertNotEquals(pr,null);
        //If at a time more than one process have value "True" for its IsSelected property
        
        for(integer i=0;i<10;i++)
            manViw.getLstStdViwCnfgr().get(i).SVMXC__Select__c = true;
        pr = manViw.cloneProcess();
        system.assertEquals(pr,null);                   
        
        manViw.strEditRView = 'Clone2';
        //If at a time no process have value "True" for its IsSelected property
        
        pr = manViw.cloneProcess();
        system.assertEquals(pr,null);
        //If at a only one process have value "True" for its IsSelected property
        
        manViw.getLstCustViwCnfgr().get(0).SVMXC__Select__c = True;
        pr = manViw.cloneProcess();
        system.assertNotEquals(pr,null);
        //If at a time more than one process have value "True" for its IsSelected property
        
        for(integer i=0;i<10;i++)
            manViw.getLstCustViwCnfgr().get(i).SVMXC__Select__c = True;
        pr = manViw.cloneProcess();
        system.assertEquals(pr,null); 
        
       for(integer i=0;i<10;i++){
            manViw.getLststdViwCnfgr().get(i).SVMXC__Select__c = false;
            manViw.getLstCustViwCnfgr().get(i).SVMXC__Select__c = false;
        }
        
        pr = manViw.backToSetup();
        system.assertNotEquals(pr,null);        
        //If at a time no process have value "True" for its IsSelected property
        
        pr = manViw.deletPross();
        system.assertEquals(manViw.getLstCustViwCnfgr().size(),15);
        //If at a time more than one process have value "True" for its IsSelected property
        
        for(integer i=0;i<12;i++)
            manViw.getLstCustViwCnfgr().get(i).SVMXC__Select__c = True;
        pr = manViw.deletPross();
        system.assertEquals(manViw.getLstCustViwCnfgr().size(),3);
            
        pr = manViw.newPrcss();
        system.assertNotEquals(pr,null);
   
        delete manViw.getLstCustViwCnfgr().get(0);
        manViw.getLstCustViwCnfgr().get(0).SVMXC__Select__c = True; 
        pr = manViw.deletPross();
        system.assertEquals(manViw.getLstCustViwCnfgr().size(),3);

        system.assertEquals(lstpros.size(),30);
        manViw.setLststdViwCnfgr(lstpros);
        system.assertEquals(manViw.getLststdViwCnfgr().size(), 30);
        manViw.setLstCustViwCnfgr(lstpros);
        system.assertEquals(manViw.getLstCustViwCnfgr().size(), 30);
        
        //calling tags
        manViw.getHLPURL();
        manViw.getTAG001();
        manViw.getTAG002();
        manViw.getTAG003();
        manViw.getTAG004();
        manViw.getTAG005();
        manViw.getTAG006();
        manViw.getTAG007();
        manViw.getTAG008();
        manViw.getTAG009();
        manViw.getTAG010();
        manViw.getTAG011();
        manViw.getTAG013();
        manViw.getTAG014();
        manViw.getTAG015();
        manViw.getTAG016();
        manViw.getTAG017();
        manViw.getTAG018();
        manViw.getTAG019();
        manViw.getTAG020();
        manViw.getTAG021();
        manViw.getTAG022();
        manViw.getTAG023();
    }
}