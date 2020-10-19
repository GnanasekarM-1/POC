trigger SVMX_ValidateTagInstKeyTrigger on SVMXC__ServiceMax_Tags__c (before insert, before update)
{
    SVMXC.COMM_Utils commUtil = new SVMXC.COMM_Utils();
    for(Integer i = 0; i < Trigger.new.size(); i++)
    {
        /* If no installation key is given, the data must adhere to min-length requirements */
        if(Trigger.new[i].SVMXC__Installation_Key__c == null)
        {
            if(Trigger.new[i].SVMXC__Language__c == 'Master' && Trigger.new[i].Name.length() < 8)
            {
                Trigger.new[i].Name.addError(System.Label.CONF014_TAG009); // 'Tag ID should be at least 8 characters long.'
            }
        }
        else /* If installation key IS given make sure the key is valid for the org and hasn't expired */
        {
            commUtil.SVMX_IsValidInstallationKey(Trigger.new[i].SVMXC__Installation_Key__c, Trigger.new[i]);
            Trigger.new[i].SVMXC__Installation_Key__c = null;
        }
        
        /* Update first 255 char from Tag Value to Tag Text to perform search on first 255 char for ServiceMax Transalation Workbench */
        if(Trigger.new[i].SVMXC__Tag_Value__c != NULL && Trigger.new[i].SVMXC__Tag_Value__c.length() > 0)
        {
            if(Trigger.new[i].SVMXC__Tag_Value__c.length() < 255)
                Trigger.new[i].SVMXC__Tag_Text__c = Trigger.new[i].SVMXC__Tag_Value__c;
            else
                Trigger.new[i].SVMXC__Tag_Text__c = Trigger.new[i].SVMXC__Tag_Value__c.substring(0, 255);
        }
    }
}