global class OFFL_Settings_WS 
{
    global class SettingMap
    {
        webservice String key {get;set;}
        webservice String value{get;set;}
        
        global SettingMap(String k,String v)
        {
            key = k;
            value = v;
        }
        
    }
    
    webservice static List<SettingMap> getSettingList()
    {
        /*List<SettingMap> SMapLst = new List<SettingMap>();
        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('GLOB001');  
        system.debug('AllSubModuleSettings'+AllSubModuleSettings);
        if(AllSubModuleSettings.containsKey('GBL012') && AllSubModuleSettings.get('GBL012') != null)
        {
            SettingMap SMap = new SettingMap('GBL012',AllSubModuleSettings.get('GBL012'));
            SMapLst.add(SMap);
        }
        return SMapLst;*/
            
            List<SettingMap> SMapLst = new List<SettingMap>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            Map<String, String> svmxSettingListFinal=new Map<String, String>();
            Map<String, String> svmxSettingListOFFL015=new Map<String, String>();
            Map<String, String> svmxSettingListGLOB001=new Map<String, String>();
            Map<String, String> svmxSettingListOFFL002=new Map<String, String>();
            Map<String, String> svmxSettingListOFFL005=new Map<String, String>();
            list<string> lstSubModules = new list<string>{'GLOB001','OFFL015','OFFL002','OFFL005'};
            map<string, Map<String, String>> mapSetting = commSettings.SVMX_getSettingList(lstSubModules);
            if(mapSetting.containsKey('GLOB001'))
            {
                svmxSettingListGLOB001.putAll(mapSetting.get('GLOB001'));
            }
            if(mapSetting.containsKey('OFFL015'))
            {
                 svmxSettingListOFFL015.putAll(mapSetting.get('OFFL015'));
            }
            if(mapSetting.containsKey('OFFL002'))
            {
                 svmxSettingListOFFL002.putAll(mapSetting.get('OFFL002'));
            }
            if(svmxSettingListGLOB001.containsKey('GBL012'))
            {
              svmxSettingListFinal.put('GBL012', svmxSettingListGLOB001.get('GBL012'));
            }
            else
            {
               svmxSettingListFinal.put('GBL012', '2048');
            }
            if(svmxSettingListOFFL015.containsKey('SET001'))
            {
                if(svmxSettingListOFFL015.get('SET001').toUpperCase()=='TRUE')
                 svmxSettingListFinal.put('OFFL015_SET001', '1');
                 else
                 svmxSettingListFinal.put('OFFL015_SET001', '0');
            }
            else
            {
              svmxSettingListFinal.put('OFFL015_SET001', '1');
            }
            if(svmxSettingListOFFL015.containsKey('SET002'))
            {
                if(svmxSettingListOFFL015.get('SET002').toUpperCase()=='TRUE')
                  svmxSettingListFinal.put('OFFL015_SET002', '1');
                  else
                  svmxSettingListFinal.put('OFFL015_SET002', '0');
            }
            else
            {
                 svmxSettingListFinal.put('OFFL015_SET002', '1');
            }
            if(svmxSettingListOFFL002.containsKey('SET001'))
            {
                svmxSettingListFinal.put('OFFL002_SET001', svmxSettingListOFFL002.get('SET001'));
            }
            else
            {
              svmxSettingListFinal.put('OFFL002_SET001', '256');
            }
            if(svmxSettingListOFFL002.containsKey('SET002'))
            {
                svmxSettingListFinal.put('OFFL002_SET002', svmxSettingListOFFL002.get('SET002'));
            }
            if(svmxSettingListOFFL005.containsKey('SET001'))
            {
                if(svmxSettingListOFFL005.get('SET001').toUpperCase()=='TRUE')
                   svmxSettingListFinal.put('OFFL005_SET001', '1');
                else
                   svmxSettingListFinal.put('OFFL005_SET001', '0');
            }
            else
            {
              svmxSettingListFinal.put('OFFL005_SET001', '0');
            }
                  
            system.debug('SettingIds:'+mapSetting);
            system.debug('SettingIds123:'+svmxSettingListFinal);
            if(svmxSettingListFinal.containsKey('GBL012') && svmxSettingListFinal.get('GBL012') != null)
            {
                SettingMap SMap = new SettingMap('GBL012',svmxSettingListFinal.get('GBL012'));
                SMapLst.add(SMap);
            }
            if(svmxSettingListFinal.containsKey('OFFL015_SET001') && svmxSettingListFinal.get('OFFL015_SET001') != null)
            {
                SettingMap SMap = new SettingMap('OFFL015_SET001',svmxSettingListFinal.get('OFFL015_SET001'));
                SMapLst.add(SMap);
            }
            if(svmxSettingListFinal.containsKey('OFFL015_SET002') && svmxSettingListFinal.get('OFFL015_SET002') != null)
            {
                SettingMap SMap = new SettingMap('OFFL015_SET002',svmxSettingListFinal.get('OFFL015_SET002'));
                SMapLst.add(SMap);
            }
            if(svmxSettingListFinal.containsKey('OFFL002_SET001') && svmxSettingListFinal.get('OFFL002_SET001') != null)
            {
                SettingMap SMap = new SettingMap('OFFL002_SET001',svmxSettingListFinal.get('OFFL002_SET001'));
                SMapLst.add(SMap);
            }
            if(svmxSettingListFinal.containsKey('OFFL002_SET002') && svmxSettingListFinal.get('OFFL002_SET002') != null)
            {
                SettingMap SMap = new SettingMap('OFFL002_SET002',svmxSettingListFinal.get('OFFL002_SET002'));
                SMapLst.add(SMap);
            }
            if(svmxSettingListFinal.containsKey('OFFL005_SET001') && svmxSettingListFinal.get('OFFL005_SET001') != null)
            {
                SettingMap SMap = new SettingMap('OFFL005_SET001',svmxSettingListFinal.get('OFFL005_SET001'));
                SMapLst.add(SMap);
            }
            system.debug('SettingListMap : '+SMapLst);
            return SMapLst;
            
        
    }
    WebService static String DCON_Retrieve_StaticResource_WS()
    {
        String UserSettings;
        try
        {
            List<StaticResource> DefaultSetting = new List<StaticResource>();
            DefaultSetting = [Select Name, Body From StaticResource where Name= 'SVMX_OFFL_LkpConfig'];
              if(DefaultSetting.isEmpty() == false)
               {
                  for(StaticResource sr: DefaultSetting)
                    {
                      if(sr.Name == 'SVMX_OFFL_LkpConfig')
                      UserSettings = sr.Body.toString();
                    }
                }
              else
                {
                   UserSettings = '';
                }
        }
        catch(exception ex){}
        return UserSettings;
     }
    
    static testMethod void OFFL_Settings_WS_test()
    {
        try
        {
            
            List<SettingMap> SMapLst = OFFL_Settings_WS.getSettingList();
            system.assert(SMapLst!=null,true);
            String sBody = OFFL_Settings_WS.DCON_Retrieve_StaticResource_WS();
        }
        catch(exception ex){}
    }
}