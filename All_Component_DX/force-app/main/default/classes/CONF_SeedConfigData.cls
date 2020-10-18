public  with sharing class CONF_SeedConfigData
{
    public class DataLoadException extends Exception {}
    public SVMXC__ServiceMax_Processes__c IKeyConfig = new SVMXC__ServiceMax_Processes__c();
    public Boolean JobDone = false;
    public Boolean JobAlreadyDone = false;

                // Constructor: Reads XML file
    public CONF_SeedConfigData()
    {
    }

    /****=====================================================================****/

    public PageReference BackToHomePage()
    {
        return null; 
    }

    /****=====================================================================****/

    public Boolean getJobDone()
    {
    return JobDone;
    }

    /****=====================================================================****/

    public Boolean getJobAlreadyDone()
    {
    return JobAlreadyDone;
    }

    /****=====================================================================****/

    public SVMXC__ServiceMax_Processes__c getIKeyConfig()
    {
    return IKeyConfig;
    }

    /****=====================================================================****/

    public void setIKeyConfig(SVMXC__ServiceMax_Processes__c myConf)
    {
    IKeyConfig = myConf;
    }

   
    public void SeedConfigData()
    {
    }

    public Boolean BuildMapsAndExistingData()
    {
    return true;
    }

    /****=====================================================================****/

            // Get all record type IDs we care about
    public Boolean SVMX_GetRecordTypes()
    {
    return true;
    }

    /****=====================================================================****/

            // Process the XML stream and update global array of SObjects for insert/update
    public Boolean SVMX_LoadConfigXML()
    {
    return true;
    }

    /****=====================================================================****/
    public void SVMX_ProcessRecord(String LevelTwoName, SObject nextRec, XmlStreamReader reader)
    {
    }

    /****=====================================================================****/
    public Map<String,ID> SVMX_LoadModules()
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/

    public Map<String,ID> SVMX_LoadSubmodules(Map<String,ID> ModuleMap)
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/

    public  Map<String,ID> SVMX_LoadSettings(Map<String,ID> SubmoduleMap)
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/
    public Map<String,ID> SVMX_LoadObjectMappings()
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/

    public Map<String,ID> SVMX_LoadFieldMappings(Map<String,ID> ObjectMap)
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/

    public Map<String,ID> SVMX_LoadConfigProfiles()
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/

    public Map<String,ID> SVMX_LoadSettingValues(Map<String,ID> ConfigProfileMap, Map<String,ID> SettingMap)
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/

    public Map<String,ID> SVMX_LoadDisplayTags(Map<String,ID> SubmoduleMap)
    {
    Map<String,ID> IDMap = new Map<String,ID>();
    return IDMap;
    }

    /****=====================================================================****/

    public Boolean SVMX_TransferSettings()
    {
    return true;
    }

    /****=====================================================================****/

    public Boolean SVMX_ResetXMLData()
    {
    return true;
    }

    /****=====================================================================****/

    public void SVMX_DebugDataSet(String StageName)
    {
    }
}