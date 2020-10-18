global class DCON_DeployUserSetting
{
    public static integer count = 0;
    public static string userXML = '';
    public static string tempUserXML = '';
    public static string UserXMLtoGetTeamTerr = '';
    public static map<string , map<string,string>> mapParentChildNameNode = new map<string , map<string,string>>();
    public static map<string,string> maptest = new map<string,string>();
    global DCON_DeployUserSetting(){}
        
    //Wrapper class for DC UI Settings
    global class DCUserSettings
    {
        webservice String rootName{get;set;}
        webservice list<stringMap> attributesStrMap{get;set;}
        webservice String Values{get;set;}
        webservice String rulType{get;set;} 
        webservice boolean ismodified{get;set;}
        webservice list<DCUserSettings> lstChildDCUserSettings {get;set;}
        global DCUserSettings()
        {
            attributesStrMap = new list<stringMap>();
            lstChildDCUserSettings = new list<DCUserSettings>();
        }
        
        
    }
    //Wrapper to hold Key value
    global class stringMap
    {
        webservice String key{get;set;}
        webservice String value{get;set;}
        global stringMap(){}
        global stringMap(String key, String value)
        {
            this.key = key;
            this.value = value;
        }
        
    }
    //Webservice to deploy settings
    
    public static DCON_Configuration_WS.SVMX_Response deploySelectivelyDCUSerSetting(DCON_Configuration_WS.SVMX_StringMap dcUserSetReq)
    {
        DCON_Configuration_WS.SVMX_Response response = new DCON_Configuration_WS.SVMX_Response();
        DCUserSettings dcUISetting = new DCUserSettings();
         List<String> lstUserIds = new  List<String> ();
        if(dcUserSetReq.ValueList != null)
        {
        
            lstUserIds = dcUserSetReq.ValueList;
        
        }
        dcUISetting = dcUserSetReq.dcSetting;
        System.debug(logginglevel.warn,'++++ dcUISetting:  '+dcUserSetReq.dcSetting);
        dcUISetting.rootname ='configuration';
        dcUISetting.ismodified = true;
        List<User> allDispatchers = [Select Id, SVMXC__Dispatch_Console_Settings__c from User where Id IN :lstUserIds];
        userXML = '';
        List<User> superDispUser = [Select Id, SVMXC__Dispatch_Console_Settings__c from User where Id =:Userinfo.getUserId()];
        for(User DispatcherRec:allDispatchers)
        {
            Integer indexOfViewStartTag = 0;
            Integer indexOfviewCloseTag = 0;
            Integer indexOfTeamStartTag = 0;
            Integer indexOfTeamCloseTag = 0;
            Integer indexOfTerrStartTag = 0;
            Integer indexOfTerrCloseTag = 0;
            Integer indexToAppendViewTags = 0;
            Integer indexToAppendViewTags1 = 0;
            Integer indexToAppendViewTags2 = 0;
            String firstPartOfUserXML = '';
            String lastPartOfUserXML = '';
            String middlePartOfUserXML = ''; 
            String firstPartOfUserXML1 = '';
            String lastPartOfUserXML1 = '';
            String middlePartOfUserXML1 = '';      
            String firstPartOfUserXML2 = '';
            String lastPartOfUserXML2 = '';
            String middlePartOfUserXML2 = '';   
            
            userXML = DispatcherRec.SVMXC__Dispatch_Console_Settings__c;
            //System.debug(logginglevel.warn,'++++ userXML:  '+userXML);
            if(userXML== null || userXML.length()==0)
                userXML = getDefaultUserSettings();
            if(userXML== null)
                userXML = '';
//userXML = superDispUser[0].SVMXC__Dispatch_Console_Settings__c;
            System.debug(logginglevel.warn,'++++ userXML: before '+userXML);
            
            /* Made changes to remove the sorting views and view color tags before deploying *******/
            if(!String.isBlank(userXML))
            {
                if(userXML.contains('<sortedviews>') || userXML.contains('</sortedviews>') || userXML.contains('<viewcounter>') || userXML.contains('</viewcounter>'))
                {
                    indexOfViewStartTag = userXML.indexOf('<sortedviews>');
                    indexOfviewCloseTag = userXML.indexOf('</viewcounter>') + '</viewcounter>'.length();
                    System.debug('indexOfViewStartTag:'+ indexOfViewStartTag);
                    System.debug('indexOfviewCloseTag:'+ indexOfviewCloseTag);
                    
                    firstPartOfUserXML = userXML.subString(0,indexOfViewStartTag-1);
                    lastPartOfUserXML = userXML.subString(indexOfviewCloseTag,userXML.length());
                    middlePartOfUserXML = userXML.subString(indexOfViewStartTag,indexOfviewCloseTag);
                    userXML = firstPartOfUserXML + lastPartOfUserXML;
                
                    //System.debug(logginglevel.warn,'++++ firstPartOfUserXML:  '+firstPartOfUserXML);
                    //System.debug(logginglevel.warn,'++++ lastPartOfUserXML:  '+lastPartOfUserXML);
                    //System.debug(logginglevel.warn,'++++ middlePartOfUserXML:  '+middlePartOfUserXML);
                    //System.debug(logginglevel.warn,'++++ userXML: after '+userXML);
                }
                if(userXML.contains('<collapsedTeam>') || userXML.contains('</collapsedTeam>'))
                {
                    indexOfTeamStartTag = userXML.indexOf('<collapsedTeam>');
                    indexOfTeamCloseTag = userXML.indexOf('</collapsedTeam>') + '</collapsedTeam>'.length();
                    System.debug('indexOfTeamStartTag:'+ indexOfTeamStartTag);
                    System.debug('indexOfTeamCloseTag:'+ indexOfTeamCloseTag);
                    
                    firstPartOfUserXML1 = userXML.subString(0,indexOfTeamStartTag-1);
                    lastPartOfUserXML1 = userXML.subString(indexOfTeamCloseTag,userXML.length());
                    middlePartOfUserXML1 = userXML.subString(indexOfTeamStartTag,indexOfTeamCloseTag);
                    userXML = firstPartOfUserXML1 + lastPartOfUserXML1;
                
                    System.debug(logginglevel.warn,'++++ firstPartOfUserXML1:  '+firstPartOfUserXML1);
                    System.debug(logginglevel.warn,'++++ lastPartOfUserXML1:  '+lastPartOfUserXML1);
                    System.debug(logginglevel.warn,'++++ middlePartOfUserXML1:  '+middlePartOfUserXML1);
                    System.debug(logginglevel.warn,'++++ userXML1: after '+userXML);
                }
                if(userXML.contains('<collapsedTerritory>') || userXML.contains('</collapsedTerritory>'))
                {
                    indexOfTerrStartTag = userXML.indexOf('<collapsedTerritory>');
                    indexOfTerrCloseTag = userXML.indexOf('</collapsedTerritory>') + '</collapsedTerritory>'.length();
                    System.debug('indexOfTerrStartTag:'+ indexOfTerrStartTag);
                    System.debug('indexOfTerrCloseTag:'+ indexOfTerrCloseTag);
                    
                    firstPartOfUserXML2 = userXML.subString(0,indexOfTerrStartTag-1);
                    lastPartOfUserXML2 = userXML.subString(indexOfTerrCloseTag,userXML.length());
                    middlePartOfUserXML2 = userXML.subString(indexOfTerrStartTag,indexOfTerrCloseTag);
                    userXML = firstPartOfUserXML2 + lastPartOfUserXML2;
                
                    System.debug(logginglevel.warn,'++++ firstPartOfUserXML2:  '+firstPartOfUserXML2);
                    System.debug(logginglevel.warn,'++++ lastPartOfUserXML2:  '+lastPartOfUserXML2);
                    System.debug(logginglevel.warn,'++++ middlePartOfUserXML2:  '+middlePartOfUserXML2);
                    System.debug(logginglevel.warn,'++++ userXML2: after '+userXML);
                }
            }   
            /*****************************************************************************************/
            
            Dom.Document doc1 = new Dom.Document();
            doc1.load(userXML);

            //Retrieve the root element for this document.
            Dom.XMLNode XMLrootNode = doc1.getRootElement();
            UserXMLtoGetTeamTerr =userXML;
            string modifiedXML = getModifiedUserSetting(XMLrootNode,dcUISetting,userXML);
            //System.debug(logginglevel.warn,'++++ modifiedXML:before:  '+modifiedXML);
            
            /*Appending removed sorting and color views to user XML after deploy ******/
            if(!String.isBlank(modifiedXML) && !String.isBlank(middlePartOfUserXML))
            {   
                indexToAppendViewTags = modifiedXML.indexof('<rules>');
                modifiedXML = modifiedXML.subString(0,indexToAppendViewTags-1) + middlePartOfUserXML + modifiedXML.subString(indexToAppendViewTags,modifiedXML.length());
            }
            //System.debug(logginglevel.warn,'++++ modifiedXML:after  '+modifiedXML);
            if(!String.isBlank(modifiedXML) && !String.isBlank(middlePartOfUserXML1))
            {   
                indexToAppendViewTags1 = modifiedXML.indexof('</team>');
                modifiedXML = modifiedXML.subString(0,indexToAppendViewTags1-1) + middlePartOfUserXML1 + modifiedXML.subString(indexToAppendViewTags1,modifiedXML.length());
            }
            //System.debug(logginglevel.warn,'++++ modifiedXML:after1  '+modifiedXML);
            if(!String.isBlank(modifiedXML) && !String.isBlank(middlePartOfUserXML2))
            {   
                indexToAppendViewTags2 = modifiedXML.indexof('</territory>');
                modifiedXML = modifiedXML.subString(0,indexToAppendViewTags2-1) + middlePartOfUserXML2 + modifiedXML.subString(indexToAppendViewTags2,modifiedXML.length());
            }
            //System.debug(logginglevel.warn,'++++ modifiedXML:after2  '+modifiedXML);
            
            if(modifiedXML!= null && modifiedXML != '')
            DispatcherRec.SVMXC__Dispatch_Console_Settings__c = modifiedXML;
        }
        try
        {
            if(lstUserIds.size() >0) 
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(allDispatchers, COMM_SecurityUtils.Access.Updateable)){
                    update allDispatchers; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                response.success = true;
            }
            else
                response.success = false;
        }
        catch(exception ex)
        {
            response.success = false;
        }
            return response;
    }
    
    //Method to modify User setting(Target XML) of Dispatcher Using Super Dispatcher settings
    public static string getModifiedUserSetting(Dom.XmlNode xmlRootInfo,DCUserSettings wrapDCSettingToReplace, string strUserXML)
    {
        Dom.XmlNode xmlRoot;
        if(xmlRootInfo != null)
            xmlRoot = xmlRootInfo;
        else
        {
            //If There is no User XML, Build XML using wrapper
            String str = BuildXMLFromWrp(wrapDCSettingToReplace);
            If(str == null)
                str='';
            //System.debug(logginglevel.warn,'==== str'+str);
            return str;
        }
        if(strUserXML != null)
            userXML = strUserXML;
        else
            userXML = '';
        
        //String strtoReplace = '<';
        //String strclosingTag = '<';
        String strtoReplace = '';
        String strclosingTag = '';
        String strRuleNodeCheck = '';            
        count = count + 1;
        
        string startTag = getstartEndTag(wrapDCSettingToReplace,xmlRoot,strtoReplace,true);
        string endTag = getstartEndTag(wrapDCSettingToReplace,xmlRoot,strtoReplace,false);
        if(startTag != null)
            strtoReplace += startTag;
        if(endTag != null)
            strclosingTag += endTag;
        
        //System.debug(logginglevel.warn,'count: '+count);
        System.debug(logginglevel.warn,'wrapDCSettingToReplace: '+wrapDCSettingToReplace);
        System.debug(logginglevel.warn,'Home &&&& Wrapper : '+count+' : '+wrapDCSettingToReplace.rootName);
        
        //System.debug(logginglevel.warn,'Home &&&& Wrapper : '+count+' : '+wrapDCSettingToReplace.rootName);
        
        //If there is no wrapper data, USer XML is returned unmodified
        if(wrapDCSettingToReplace == null)
        {   
            return userXML;
        }
        
        //adding all attributes in Wrapper to map, which is used to compare with User XML Node's attribute
        map<string, string> mapAttributes = new map<string, string>();
        if(wrapDCSettingToReplace.attributesStrMap != null && wrapDCSettingToReplace.attributesStrMap.size() >0)
            mapAttributes = getAttributeMap(wrapDCSettingToReplace.attributesStrMap);
        
        System.debug(logginglevel.warn,'@@@@ mapAttributes '+mapAttributes);
        
        //Loop through all user XML attributes and add it to Target XML if wrapper doesnot have modified data else modify accordingly
        if(xmlRoot != null) 
        {               
            for(integer i =0;i<xmlRoot.getAttributeCount();i++)
            {  
                //If wrapper has current attribute updated update the value.
                if(mapAttributes != null && mapAttributes.containskey(xmlRoot.getAttributeKeyAt(i).trim()))
                {
                    //System.debug(logginglevel.warn,'@@@@ mapAttributes '+mapAttributes);
                    strtoReplace += ' '+xmlRoot.getAttributeKeyAt(i)+'='+'\"'+mapAttributes.get(xmlRoot.getAttributeKeyAt(i))+'\" ';
                    //mapAttributes.remove(mapAttributes.get(xmlRoot.getAttributeKeyAt(i).trim()));
                    mapAttributes.remove(xmlRoot.getAttributeKeyAt(i).trim());
                   // System.debug(logginglevel.warn,'@@@@ mapAttributes '+mapAttributes);
                }
                else
                    strtoReplace += ' '+xmlRoot.getAttributeKeyAt(i)+'=\"'+xmlRoot.getAttributeValue(xmlRoot.getAttributeKeyAt(i),null)+'\" ' ;
            }
        }
        System.debug(logginglevel.warn,'@@@@ mapAttributes '+mapAttributes);
        if(mapAttributes.size() >0)
        {
            for(string attributeKey: mapAttributes.keyset())
            strtoReplace += ' '+attributeKey +'=\"'+mapAttributes.get(attributeKey)+'\" ' ;
        }
        if(!(wrapDCSettingToReplace.rootName.equals('skills') || wrapDCSettingToReplace.rootName.equals('productExpertise') || wrapDCSettingToReplace.rootName.equals('eligibility') ||wrapDCSettingToReplace.rootName.equals('prefTech')))
        strtoReplace+= '> \n' ;
        //System.debug(logginglevel.warn,'@@@@ strtoReplace Atrr : '+strtoReplace);
        
        //Add all values to target XML
        if(wrapDCSettingToReplace.values != null)
        {            
            strtoReplace += ' ' + wrapDCSettingToReplace.values;            
        }
        //if Wrapper doesnt have current node child or not modified then add User setting XM node child data to Target XML
        else if(wrapDCSettingToReplace.ismodified == false )
        {
            if(wrapDCSettingToReplace.rootName.trim().equals('advncedTechSearch'))
            {
                strtoReplace = '<advncedTechSearch>\n<skills show="true" includeForSearch="true"/>\n<productExpertise show="true" includeForSearch="true"/> \n<eligibility show="true" includeForSearch="true"/>\n <prefTech show="true" includeForSearch="true"/>\n</advncedTechSearch>';
            }
            else if(xmlRoot != null)
            {
                /*for(Dom.XmlNode XMLChldNode: xmlRoot.getChildElements())
                {
                  
                    System.debug(logginglevel.warn,'???? XMLChldNode node:  ' +count+' : '+XMLChldNode.getName() +'  wrapDCSettingToReplace.rootName  '+wrapDCSettingToReplace.rootName);
                    System.debug(logginglevel.warn,'???? Wrapper : '+count+' : '+wrapDCSettingToReplace.rootName);
                    //System.debug(logginglevel.warn,'???? strtoReplace : '+count+' : '+strtoReplace);
                    
                    
                    strtoReplace=strtoReplace.trim();
                    if(userXML != null)
                    { 
                        //Get XML node in XML string format
                        string strXML = getXMLInString(XMLChldNode.getName(),userXML).trim();
                        //System.debug(logginglevel.warn,'???? strXML : '+count+' : '+strXML);
                        if(strXML.startsWithIgnoreCase(strtoReplace))
                        {
                            //string str = strtoReplace;
                            //integer pos = strXML.length()- strtoReplace.length();
                            strXML = strXML.substring(strtoReplace.length(),strXML.length());
                            System.debug(logginglevel.warn,'???? strtoReplace : '+strtoReplace+'strXML '+strXML);
                        }
                        if(strXML != null)
                        strtoReplace += ' ' + strXML;
                    }
                }
                */
                strtoReplace=strtoReplace.trim();
                System.debug(logginglevel.warn,'???? xmlRoot node:  ' +count+' : '+xmlRoot.getName() +'  wrapDCSettingToReplace.rootName  '+wrapDCSettingToReplace.rootName);
                
                System.debug(logginglevel.warn,'???? strtoReplace : '+count+' : '+strtoReplace);
                string strXML;
                if((wrapDCSettingToReplace.rootName.trim().equals('team') 
                    ||wrapDCSettingToReplace.rootName.trim().equals('territory')))                    
                    strXML = getXMLInString1(wrapDCSettingToReplace.rootName.trim(),
                    UserXMLtoGetTeamTerr).trim();//Get XML node in XML string format

                else if(userXML != null)
                { 
                    //Get XML node in XML string format
                    strXML = getXMLInString(xmlRoot.getName(),userXML).trim();
                }
                System.debug(logginglevel.warn,'???? strXML : '+count+' : '+strXML);
                //if(strXML.startsWithIgnoreCase(strtoReplace))
                
                    //string str = strtoReplace;
                    //integer pos = strXML.length()- strtoReplace.length();
                    //strXML = strXML.substring(strtoReplace.length(),strXML.length());
                    System.debug(logginglevel.warn,'???? strtoReplace : '+strtoReplace+' strXML  '+strXML);
                    //strXML = strXML.substring(strXML.indexOf('>')+1);
                    System.debug(logginglevel.warn,'???? strtoReplace : '+strtoReplace+'strXML '+strXML);
                
                
                if(strXML != null)
                    strtoReplace = strXML;
            
                else
                    strtoReplace='';
                
            }
             
            //}

            // strtoReplace = strtoReplace +'\n' + strclosingTag;
            System.debug(logginglevel.warn,' @@@@ strtoReplace Val : '+strtoReplace); 
            return strtoReplace;
            
        }
        //if Wrapper  current node has children and its modified then update or add User setting XML node child data to Target XML
        
        else if(wrapDCSettingToReplace.lstChildDCUserSettings != null && wrapDCSettingToReplace.lstChildDCUserSettings.size() > 0)
        {
            
            
            tempUserXML = userXML;
            string parentName='';
            //System.debug(logginglevel.warn,'**** strtoReplace Val : '+strtoReplace);
            mapParentChildNameNode.clear();
            if(wrapDCSettingToReplace.lstChildDCUserSettings != null)
            {
                for(DCUserSettings objWrp: wrapDCSettingToReplace.lstChildDCUserSettings)
                {
                    map<string,string> mapWrpNameNodeName = new map<string,string>();
                    map<string,string> mapNodeNameNode = new map<string,string>();
                    map<string,string> mapNodeNameId = new map<string,string>();
           
                    // mapWrpNameNodeName.clear();
                    //System.debug(logginglevel.warn,'*** Wrapper : '+count+' : '+objWrp.rootName);
                    // if(wrapDCSettingToReplace.rootName=='rules')
                    if(!mapWrpNameNodeName.containskey(objwrp.RootName))
                    {
                        if(objwrp!= null && objwrp.rulType!= null && objwrp.rulType.equalsIgnoreCase('rule'))
                        mapWrpNameNodeName.put(objwrp.RootName.trim(),'rule');
                        else
                        mapWrpNameNodeName.put(objwrp.RootName.trim(),objwrp.RootName.trim());
                    }
                    if(xmlRoot != null)   
                    {
                        for(Dom.XmlNode XMLChldNode: xmlRoot.getChildElements())
                        {
                            System.debug(logginglevel.warn,'**** XMLChldNode node:  ' +count+' : '+XMLChldNode.getName()+'  *** Wrapper : '+count+' : '+objWrp.rootName);
                                                        
                            // 026098 rules of workorder settings are comparing with rules of technician settings in second iteration of wrapper so added below line 'tempUserXML = userXML;'  
                            tempUserXML = userXML; 
                            String strID ;
                           
                            if(XMLChldNode.getAttributeCount() > 0)
                            {
                                
                                strID = XMLChldNode.getAttributeKeyAt(0);
                                //System.debug(logginglevel.warn,'**** XMLChldNode Name:  ' +count+' : '+XMLChldNode.getAttributeValue(strID, null));
                            }
                            if(XMLChldNode != null && objWrp != null &&(objWrp.rootName != null && objWrp.rootName.trim().equalsIgnoreCase(XMLChldNode.getname().trim()) || ( objWrp.rootName.trim() != null && strID != null && objWrp.rootName.trim().equalsIgnoreCase(XMLChldNode.getAttributeValue(strID, null).trim()))))
                            {
                                System.debug(logginglevel.warn,'<<<< ');
                                
                                if(strID != null && XMLChldNode.getAttributeValue(strID, null) != null && userXML != null && XMLChldNode.getName()!= null)
                                {
                                    if(!((XMLChldNode.getname().trim().equals('skills') || XMLChldNode.getname().trim().equals('productExpertise') || XMLChldNode.getname().trim().equals('eligibility') ||XMLChldNode.getname().trim().equals('prefTech'))||((objWrp.rootName.trim().equals('team') ||objWrp.rootName.trim().equals('territory'))&& objWrp.ismodified == false)))
                                    {
                                        removeXMLInString(XMLChldNode.getName().trim(),userXML.trim(),XMLChldNode.getAttributeValue(strID, null).trim());
                                        System.debug(logginglevel.warn,'<<<< ');
                                    }
                                    System.debug(logginglevel.warn,'<<<< ');
                                }
                                if(userXML!= null && XMLChldNode != null && objWrp!= null)
                                {
                                    strtoReplace += ' '+ getModifiedUserSetting(XMLChldNode,objWrp,userXML);
                                    System.debug(logginglevel.warn,'<<<< ');
                                }
                                System.debug(logginglevel.warn,'<<<< mapWrpNameNodeName Val : '+count+' : '+mapWrpNameNodeName);
                                if(mapWrpNameNodeName.containsKey(objwrp.RootName.trim()))
                                {
                                    mapWrpNameNodeName.remove(objwrp.RootName.trim());
                                    //System.debug(logginglevel.warn,'wrapper Removed'); 
                                }
                                if( strID != null && XMLChldNode.getAttributeValue(strID, null)!= null)
                                {
                                    
                                    if(mapNodeNameId.containsKey(XMLChldNode.getAttributeValue(strID, null).trim()))
                                        mapNodeNameId.remove(XMLChldNode.getAttributeValue(strID, null).trim());
                                    if(mapNodeNameNode.containsKey(XMLChldNode.getAttributeValue(strID, null).trim()))
                                        mapNodeNameNode.remove(XMLChldNode.getAttributeValue(strID, null).trim());
                                    
                                    System.debug(logginglevel.warn,'wrapper Removed'+' '+XMLChldNode.getAttributeValue(strID, null)); 
                                    
                                }
                                else if(XMLChldNode.getname()!= null)
                                {
                                    
                                    if(mapNodeNameId.containsKey(XMLChldNode.getname().trim()))
                                        mapNodeNameId.remove(XMLChldNode.getname().trim());
                                    if(mapNodeNameNode.containsKey(XMLChldNode.getname().trim()))
                                        mapNodeNameNode.remove(XMLChldNode.getname().trim());
                                    System.debug(logginglevel.warn,'wrapper Removed'+' '+XMLChldNode.getname()); 
                                    
                                }
                                
                            }
                            else
                            {
                                if(!(((XMLChldNode.getname().trim().equals('skills') || XMLChldNode.getname().trim().equals('productExpertise') || XMLChldNode.getname().trim().equals('eligibility') ||XMLChldNode.getname().trim().equals('prefTech')))||(XMLChldNode.getname().trim().equals('team') ||XMLChldNode.getname().trim().equals('territory'))&& objWrp.ismodified == false))
                                {
                                
                                    if( strID != null && XMLChldNode.getAttributeValue(strID, null)!= null)
                                    {
                                        string key ;

                                        if(XMLChldNode.getAttributeValue(strID, null).trim()!= null && XMLChldNode.getAttributeValue(strID, null).trim() !='')
                                            key = XMLChldNode.getAttributeValue(strID, null).trim();
                                        else
                                            key = XMLChldNode.getname().trim();
                                        
                                        if(key != null && !mapNodeNameId.containskey(key))
                                        {
                                            
                                            mapNodeNameId.put(key,XMLChldNode.getname().trim());
                                        }
                                        System.debug(logginglevel.warn,'@@@@ strID'+' '+strID+' XMLChldNode.getAttributeValue(strID, null) '+XMLChldNode.getAttributeValue(strID, null)+' XMLChldNode.getname() '+XMLChldNode.getname()); 
                                        
                                        if(key != null && !mapNodeNameNode.containskey(key))
                                        {
                                            mapNodeNameNode.put(key,getUnmodifiedNode(tempUserXML,mapNodeNameId)); 
                                        }
                                        
                                        
                                        if(XMLChldNode.getparent().getname().trim().equals('rules'))
                                        {    
                                            strRuleNodeCheck = 'rules';
                                            if(XMLChldNode.getparent().getparent() != null)
                                            {
                                                
                                                parentName = XMLChldNode.getparent().getparent().getAttributeValue('id', null).trim();                  
                                                
                                            }
                                        }
                                    
                                          

                                    }
                                    else if(XMLChldNode.getname()!= null)
                                    {
                                        if(!mapNodeNameId.containskey(XMLChldNode.getname().trim()))
                                            mapNodeNameId.put(XMLChldNode.getname().trim(),XMLChldNode.getname().trim());
                                         System.debug(logginglevel.warn,'@@@@ strID'+' '+strID+' XMLChldNode.getname '+XMLChldNode.getname()); 
                                        if(!mapNodeNameNode.containskey(XMLChldNode.getname().trim()))
                                            mapNodeNameNode.put(XMLChldNode.getname().trim(),getUnmodifiedNode(tempUserXML.trim(),mapNodeNameId)); 
                                    
                                        if(XMLChldNode.getparent().getname()!= null)
                                        {    
                                            strRuleNodeCheck = XMLChldNode.getparent().getname().trim();
                                            if(XMLChldNode.getparent().getparent() != null)
                                            {
                                                
                                                parentName = XMLChldNode.getparent().getparent().getname().trim();                  
                                                
                                            }
                                        }
                                    }
                                }

                            }
                        
                        }
                        
                    }
                    else
                    {
                        Dom.XmlNode n;
                        strtoReplace += ' '+ getModifiedUserSetting(n,objWrp,'');                       
                    }
                    
                    System.debug(logginglevel.warn,'mapNodeNameId Val : '+count+' : '+mapNodeNameId); 
                    System.debug(logginglevel.warn,'mapNodeNameNode Val : '+count+' : '+mapNodeNameNode); 
                    if(parentName != null && parentName != '')
                    mapParentChildNameNode.put(parentName,mapNodeNameNode);
                    System.debug(logginglevel.warn,'mapParentChildNameNode Val : '+count+' : '+mapParentChildNameNode);
                    //================
                    String str;
                    System.debug(logginglevel.warn,'mapWrpNameNodeName Val : '+count+' : '+mapWrpNameNodeName); 
                    if(mapWrpNameNodeName != null && (!mapWrpNameNodeName.isempty()))                   
                        str = addWrapNodeToTargetXML(mapWrpNameNodeName,objWrp);
                    mapWrpNameNodeName.clear();
                    if(str != null)
                        strtoReplace += str;
                    ////System.debug(logginglevel.warn,'strtoReplace Val : '+strtoReplace);        
                }
                    
            }   
            
        }
        if(!(wrapDCSettingToReplace.rootName.trim().equals('advncedTechSearch')&&wrapDCSettingToReplace.ismodified==false))
        strtoReplace = strtoReplace +'\n' + strclosingTag;

        //System.debug(logginglevel.warn,'@@@@ strtoReplace Val : '+strtoReplace);
        System.debug(logginglevel.warn,'@@@@ mapParentChildNameNode Val : '+Count+'  '+mapParentChildNameNode);
        if(mapParentChildNameNode != null &&  !mapParentChildNameNode.isempty())
        {
            string str = addUnmodifiedNodetoXMLString(mapParentChildNameNode,strtoReplace);
            mapParentChildNameNode.clear();
            if(str!= null)
                strtoReplace = str;
        }
        return strtoReplace;
    }
    public static  string addWrapNodeToTargetXML(map<string,string> mapWrpParentName,DCUserSettings wrpObj)
    {
        String strtoReplace = '';
        String str = '';
        System.debug(logginglevel.warn,'!!!! mapWrpParentName Val : '+Count+' : '+mapWrpParentName);
        System.debug(logginglevel.warn,'!!!! wrpObj Val : '+Count+' : '+wrpObj);
        //strtoReplace += '\n<'+mapWrpParentName.get(wrpObj.rootName);\
        
        if(wrpObj.rootName.trim().equals('advncedTechSearch') && wrpObj.ismodified== false)
        {
            strtoReplace = '\n<advncedTechSearch>\n<skills show="true" includeForSearch="true"/>\n<productExpertise show="true" includeForSearch="true"/> \n<eligibility show="true" includeForSearch="true"/>\n <prefTech show="true" includeForSearch="true"/>\n</advncedTechSearch>\n';
            return strtoReplace;
        }
        Dom.XmlNode XMLNode;
        if(wrpObj.rulType != null)
            strtoReplace += '\n<'+'rule';
        else
            strtoReplace += '\n'+getstartEndTag(wrpObj,XMLNode,str,true);
        
            
        if(wrpObj.attributesStrMap != null)
        {
            for(stringMap atrrMap: wrpObj.attributesStrMap)
            {
                strtoReplace += ' '+atrrMap.Key + ' = \"' + atrrMap.Value + '\"';
            }
        }
        if(!(wrpObj.rootName.equals('skills') || wrpObj.rootName.equals('productExpertise') || wrpObj.rootName.equals('eligibility') ||wrpObj.rootName.equals('prefTech')))
        strtoReplace += '>';
        if(wrpObj.values != null)
        {       
            strtoReplace += ' ' + wrpObj.values;        
        }
        
        if(wrpObj.lstChildDCUserSettings != null && wrpObj.lstChildDCUserSettings.size() > 0)
        {
            for(DCUserSettings objWrp: wrpObj.lstChildDCUserSettings)
            {               
                if(objWrp != null)
                    strtoReplace += ' ' + addWrapNodeToTargetXML(new map<string,string> (), objWrp);
            }
        }
        if(wrpObj.rulType != null)          
            strtoReplace += '\n</rule>\n';
        else
             strtoReplace += '\n'+getstartEndTag(wrpObj,XMLNode,str,false)+'\n';
        System.debug(logginglevel.warn,'!!!! strtoReplace Val : '+Count+' : '+strtoReplace);
        return strtoReplace;
    }
    public static  string addUnmodifiedNodetoXMLString(map<string,map<string,string>> mapNodeNameNode1, string strtorepl)
    {
        //string strtoReplace;
        //System.debug(logginglevel.warn,'~~~~ strtorepl Val : '+count+'   '+strtorepl);
        System.debug(logginglevel.warn,'~~~~ mapNodeNameNode1 Val : '+count+'   '+mapNodeNameNode1);
        string strtemp ;
        for(string str: mapNodeNameNode1.keyset())
        {   
            string unMod='';
            map<string, string> maptemp = new map<string,string>();
            maptemp = mapNodeNameNode1.get(str);
            //System.debug(logginglevel.warn,'~~~~ str Val : '+str);
            //System.debug(logginglevel.warn,'~~~~ maptemp Val : '+maptemp);
            for(string str2: maptemp.keyset())
            {
                if(maptemp.get(str2) != null)
                    unMod += maptemp.get(str2);
                //System.debug(logginglevel.warn,'%%%% userXML Val : '+userXML);
                //System.debug(logginglevel.warn,'%%%% maptemp.get(str2) Val : '+maptemp.get(str2));
                if(userXML.contains(maptemp.get(str2).trim()))
                {
                    userXML = userXML.replace(maptemp.get(str2).trim(),'');
                    //System.debug(logginglevel.warn,'%%%% Contains XML String');
                }
            }
            //System.debug(logginglevel.warn,'~~~~ unMod Val : '+unMod);
            integer strpos = strtorepl.indexOf(str);
            if(strtorepl.trim().contains('<rules>'))
            {
                integer strPosRule = strtorepl.trim().indexOf('<rules>',strpos)+'<rules>'.length();
                if(unMod != null)
                strtemp = strtorepl.substring(0,strPosRule+1) + unMod +  strtorepl.substring(strPosRule);
                
            }
            //System.debug(logginglevel.warn,'~~~~ strtemp Val : '+strtemp);
        }
        
        return strtemp;
    }
    public static  string getUnmodifiedNode(string UserXML1,map<string,string> mapNodeName)
    {
        //System.debug(logginglevel.warn,'^^^^ strtoReplace Val : '+UserXML1);
        System.debug(logginglevel.warn,'^^^^ mapNodeName Val : '+count+'  '+mapNodeName);       
        string strunmodified='';
        for(String nodeNam: mapNodeName.keySet())
        {
            string str='';
            System.debug(logginglevel.warn,'^^^^ nodeNam Val : '+nodeNam);
            if(nodeNam.startswith('configuration'))
                continue;             
            if(nodeNam.startswith('rules'))
                continue;
            if(nodeNam.startswith('selectedcolumns'))
                continue;
            if(UserXML1!= null)
            {
                //if(UserXML1.startswith('<'+nodeNam))
                    
                str = getXMLInString1(mapNodeName.get(nodeNam),UserXML1);
                System.debug(logginglevel.warn,'^^^^ str Val before : '+str);
                if(!str.containsIgnoreCase(nodeNam.trim()))
                {
                    System.debug(logginglevel.warn,'^^^^ str Val before : '+str);
                    str = '';  
                }   
                else                    
                    UserXML1.replace(str,'');
            }
            ////System.debug(logginglevel.warn,'strtoReplace Val : '+strtoReplace); 
            if(str != null)
                strunmodified=strunmodified+str;
        }
        System.debug(logginglevel.warn,'^^^^ strunmodified Val : '+strunmodified);
        return strunmodified;
    }
    public static  void removeXMLInString(String nodeName, String strUserXML,string attribute) 
    {
        //System.debug(logginglevel.warn,'$$$$ nodeName Val : '+nodeName);     
        //System.debug(logginglevel.warn,'$$$$ strUserXML Val : '+strUserXML);    
        string XMLString ='';       
        if(strUserXML != null && strUserXML.length()>0)
        {
            integer strBeggingOfNode = strUserXML.indexOf('<'+nodeName);
            
            string XMLendString = '/'+nodeName+'>';
            integer strEndOfNode = strUserXML.indexOf('/'+nodeName+'>') + XMLendString.length();
            
            if(strUserXML != null && strUserXML.length()>0 && strEndOfNode > 0 && strUserXML.length() > strEndOfNode && strBeggingOfNode > = 0)
            {
            
                if(nodeName.startswith('configuration'))
                    return;             
                if(nodeName.startswith('rules'))
                    return;
            
                if(nodeName.startswith('grid'))
                    return;     
                //System.debug(logginglevel.warn,'strBeggingOfNode: strEndOfNode Val : '+strBeggingOfNode+' : '+strEndOfNode);   
                if(strUserXML != null && strUserXML.length()>0 && strEndOfNode > 0 && strUserXML.length() > strEndOfNode && strBeggingOfNode > = 0 && strBeggingOfNode< strEndOfNode)
                {
                    String XMLStr;
                    XMLStr = strUserXML.subString(strBeggingOfNode, strEndOfNode);
                    if(attribute != '')
                    {
                        if(strUserXML != null && strUserXML.length()>0 && strEndOfNode > 0 && strUserXML.length() > strEndOfNode )
                        userXML = strUserXML.subString(strEndOfNode).trim();
                    }
                    if(XMLStr!= null &&  !XMLStr.containsIgnoreCase(attribute))
                    {  
                        if(strUserXML != null && strUserXML.length()>0 && strEndOfNode > 0 && strUserXML.length() > strEndOfNode )          
                            userXML = strUserXML.subString(strEndOfNode).trim();
                        //System.debug(logginglevel.warn,'==== userXML Val : '+userXML);
                        //if(userXML.startswith('<grid>') )
                        if(userXML.startswith('</grid>') )
                            userXML = userXML.subString('</grid>'.length());
                        //if(userXML.startswith('<rules>') )
                        //    return;
                        if(userXML.startswith('</rules>') )
                        {
                            integer EndOfNode = userXML.indexOf('</grid>') + '</grid>'.length();
                            //System.debug(logginglevel.warn,'</rules>: '+EndOfNode); 
                            userXML = userXML.subString(userXML.indexOf('</grid>')+'</grid>'.length());
                        }
                    }
                }
                    //System.debug(logginglevel.warn,'$$$$ userXML Val : '+userXML);   
                }
            }
       // return XMLString +'\n';
    }
    
    public static  String getXMLInString(String nodeName, String strUserXML) 
    {
        System.debug(logginglevel.warn,'nodeName Val : '+nodeName);     
        System.debug(logginglevel.warn,'strUserXML Val : '+strUserXML);    
        string XMLString ='';       
        
        if(strUserXML != null && strUserXML.length()>0)
        {
            integer strBeggingOfNode = strUserXML.indexOf('<'+nodeName);
            //integer strEndOfNode = strUserXML.indexOf('/'+nodeName+'>');
            string XMLendString = '/'+nodeName+'>';
            integer strEndOfNode ;
            if(strBeggingOfNode >=0)
                strEndOfNode = strUserXML.indexOf(XMLendString,strBeggingOfNode) ;
            
            if(strBeggingOfNode >=0 && strEndOfNode <= 0)
            {
                XMLendString = '/>' ;
                strEndOfNode = strUserXML.indexOf(XMLendString,strBeggingOfNode); 
            }
            
            if(strEndOfNode>=0)
                strEndOfNode += XMLendString.length();
            
            System.debug(logginglevel.warn,'Start string : '+strBeggingOfNode+'  : End string '+strEndOfNode); 
            System.debug(logginglevel.warn,'end string : '+XMLendString+'Start string : '+'<'+nodeName); 
            
            if(strUserXML != null && strUserXML.length()>0 && strEndOfNode > 0 && strUserXML.length() > strEndOfNode && strBeggingOfNode > = 0 && strBeggingOfNode< strEndOfNode)
            {
                System.debug(logginglevel.warn,'strUserXML Val : '+strUserXML+'  '+strUserXML.length());   
                System.debug(logginglevel.warn,'strBeggingOfNode: strEndOfNode Val : '+strBeggingOfNode+' : '+strEndOfNode);  
                
                XMLString = strUserXML.subString(strBeggingOfNode, strEndOfNode);
                
                userXML = strUserXML.subString(strEndOfNode).trim();
                
                System.debug(logginglevel.warn,'==== userXML Val : '+userXML);
                
                if(userXML.startswith('</grid>') )
                    userXML = userXML.subString('</grid>'.length());
                if(userXML.startswith('</rules>') )
                {
                    integer EndOfNode = userXML.indexOf('</grid>') + '</grid>'.length();
                    System.debug(logginglevel.warn,'</rules>: '+EndOfNode); 
                    userXML = userXML.subString(userXML.indexOf('</grid>')+'</grid>'.length());
                }
                System.debug(logginglevel.warn,'+++userXML Val : '+userXML);   
            }
        }
        
        if(XMLString == null)
            XMLString = '';
        System.debug(logginglevel.warn,'+++XMLString Val : '+XMLString);   

        return XMLString +'\n';
    }
    public static  String getXMLInString1(String nodeName, String strUserXML)
    {
        //System.debug(logginglevel.warn,'nodeName Val : '+nodeName);     
        //System.debug(logginglevel.warn,'strUserXML Val : '+strUserXML);    
        string XMLString ='';
        
        if(strUserXML != null && strUserXML.length()>0)
        {
            integer strBeggingOfNode;
            if(nodeName.equalsIgnoreCase('rule'))
                strBeggingOfNode = strUserXML.indexOf('<'+nodeName+' ');
            else
                strBeggingOfNode = strUserXML.indexOf('<'+nodeName);    
            //integer strBeggingOfNode = strUserXML.indexOf('<'+nodeName);
            //integer strEndOfNode = strUserXML.indexOf('/'+nodeName+'>');
            string XMLendString = '/'+nodeName+'>';
            integer strEndOfNode = strUserXML.indexOf('/'+nodeName+'>') + XMLendString.length();
            
            //System.debug(logginglevel.warn,'Start string : '+'<'+nodeName +'  : End string '+XMLendString); 
            //System.debug(logginglevel.warn,'end string : '+strUserXML.indexOf('/'+nodeName+'>') +'  :  '+strEndOfNode); 
            if(strUserXML != null && strUserXML.length()>0 && strEndOfNode > 0 && strUserXML.length() > strEndOfNode && strBeggingOfNode > = 0 && strBeggingOfNode< strEndOfNode)
            {
                //  System.debug(logginglevel.warn,'strUserXML Val : '+strUserXML+'  '+strUserXML.length());   
                System.debug(logginglevel.warn,'strBeggingOfNode: strEndOfNode Val : '+strBeggingOfNode+' : '+strEndOfNode);   
                XMLString = strUserXML.subString(strBeggingOfNode, strEndOfNode);
                
                tempUserXML = strUserXML.subString(strEndOfNode).trim();
                ////System.debug(logginglevel.warn,'==== tempUserXML Val : '+tempUserXML);
                if(tempUserXML.startswith('</grid>') )
                    tempUserXML = tempUserXML.subString('</grid>'.length());
                if(tempUserXML.startswith('</rules>') )
                {
                    integer EndOfNode = tempUserXML.indexOf('</grid>') + '</grid>'.length();
                    System.debug(logginglevel.warn,'</rules>: '+EndOfNode); 
                    tempUserXML = tempUserXML.subString(tempUserXML.indexOf('</grid>')+'</grid>'.length());
                }
                //System.debug(logginglevel.warn,'+++tempUserXML Val : '+tempUserXML);   
            }
            
        }
        
        //userXML.trim().replace(XMLString.trim(),'');
        if(XMLString == null)
            XMLString = '';
        return XMLString +'\n';
    }
   //Returns all the attribute and corresponding values
    public Static map<string, string> getAttributeMap(list<stringMap> attributesMap)
    {
        map<string, string> mapAttribute = new map<string, string>();
        for(stringMap strmap: attributesMap)
        {
            mapAttribute.put(strmap.key.trim(),strmap.value.trim());            
        }
        return mapAttribute;
    }
    //Returns Start or end Tag for the Wrapper and XML node.If isStartTag is true start tag else end tag
    public static string getstartEndTag(DCUserSettings wrapDCSettingToReplace,Dom.XmlNode xmlRoot,string strtoReplace,boolean isStartTag)
    {
        strtoReplace = '<';
        string strclosingTag;
        //Based on the current root name Start and end tags are decided
        if(wrapDCSettingToReplace.rootName=='configuration')
        {
            strtoReplace = strtoReplace+'configuration ';
            strclosingTag = '</configuration>';
        }
        else if(wrapDCSettingToReplace.rootName=='workOrderSettings')
        {
            strtoReplace = strtoReplace+'grid ';//id=\"workOrderSettings\"';
            strclosingTag = '</grid>\n';
        }
        else if(wrapDCSettingToReplace.rootName=='technicianSettings')
        {
            strtoReplace = strtoReplace+'grid ';//id=\"technicianSettings\"';
            strclosingTag = '</grid>\n';
        }
        else if(wrapDCSettingToReplace.rootName=='keywordSettings')
        {
            strtoReplace = strtoReplace+'grid ';//id=\"keywordSettings\"';
            strclosingTag = '</grid>\n';
        }
        
        else if(wrapDCSettingToReplace.rootName=='teamKeywordSettings')
        {
            strtoReplace = strtoReplace+'grid ';//id=\"teamKeywordSettings\"';
            strclosingTag = '</grid>\n';
        }
        else if(wrapDCSettingToReplace.rootName=='techKeywordSettings')
        {
            strtoReplace = strtoReplace+'grid ';//id=\"techKeywordSettings\"';
            strclosingTag = '</grid>\n';
        }
        else if(wrapDCSettingToReplace.rootName=='appDimensions')
        {
            strtoReplace = strtoReplace+'appDimensions';
            strclosingTag = '</appDimensions>';
        }
        else if(wrapDCSettingToReplace.rootName=='selectedcolumns')
        {
            strtoReplace = strtoReplace+'selectedcolumns';
            strclosingTag = '</selectedcolumns>'+'\n';//</grid>';
        }
        else if(wrapDCSettingToReplace.rootName=='rules')
        {
            strtoReplace = strtoReplace+'rules';
            strclosingTag = '</rules>'+'\n';//</grid>';
        }
        else if(wrapDCSettingToReplace.rootName=='rule')
        {
            strtoReplace = strtoReplace+'rule';
            strclosingTag = '</rule>';
        }
        else if(wrapDCSettingToReplace.rootName=='column')
        {
            strtoReplace = strtoReplace+'column';
            strclosingTag = '</column>';
        }
        else if(wrapDCSettingToReplace.rootName=='productExpertise')
        {
            strtoReplace = strtoReplace+'productExpertise';
            strclosingTag = '/>';
        }
        else if(wrapDCSettingToReplace.rootName=='eligibility')
        {
            strtoReplace = strtoReplace+'eligibility';
            strclosingTag = '/>';
        }
        else if(wrapDCSettingToReplace.rootName=='prefTech')
        {
            strtoReplace = strtoReplace+'prefTech';
            strclosingTag = '/>';
        }
        else if(wrapDCSettingToReplace.rootName=='skills')
        {
            strtoReplace = strtoReplace+'skills';
            strclosingTag = '/>';
        }
        else if(wrapDCSettingToReplace.rootName != null)     
        {
            if(wrapDCSettingToReplace.rulType != null && wrapDCSettingToReplace.rulType == 'rule')
            {
                strtoReplace = strtoReplace+'rule ';
                strclosingTag = '</rule>';
            }
            else
            {
                strtoReplace = strtoReplace+wrapDCSettingToReplace.rootName+' ';
                strclosingTag = '</'+wrapDCSettingToReplace.rootName+'>';
            }
        }
        else if(xmlRoot != null && xmlRoot.getName().equalsIgnoreCase('rule'))
        {
            
            strtoReplace = strtoReplace+'rule ';
            strclosingTag = '</rule>';//+strclosingTag;
        }
        //System.debug(logginglevel.warn,'{{}}strtoReplace: '+strtoReplace);
        //System.debug(logginglevel.warn,'{{}}strclosingTag: '+strclosingTag);
        if(isStartTag)
            return strtoReplace;
        else
            return strclosingTag;
            
    }
    
    public static string BuildXMLFromWrp(DCUserSettings wrapDCSettingToReplace)
    {
        //String strtoReplace = '<';
        //String strclosingTag = '<';
        String strtoReplace = '';
        String strclosingTag = '';
       // System.debug(logginglevel.warn,'count: '+count);
        //System.debug(logginglevel.warn,'wrapDCSettingToReplace: '+wrapDCSettingToReplace);
        //System.debug(logginglevel.warn,'==== Wrapper : '+count+' : '+wrapDCSettingToReplace.rootName);
        
        
        Dom.XmlNode xmlRoot;
        string startTag = getstartEndTag(wrapDCSettingToReplace,xmlRoot,strtoReplace,true);
        string endTag = getstartEndTag(wrapDCSettingToReplace,xmlRoot,strtoReplace,false);
        
        if(startTag != null)
            strtoReplace += startTag;
        if(endTag != null)
            strclosingTag += endTag;
        map<string, string> mapAttributes = new map<string, string>();
            
        //adding all attributes in Wrapper to map
        if(wrapDCSettingToReplace.attributesStrMap != null && wrapDCSettingToReplace.attributesStrMap.size() >0)
            mapAttributes = getAttributeMap(wrapDCSettingToReplace.attributesStrMap);
        //System.debug(logginglevel.warn,'==== mapAttributes : '+count+' : '+mapAttributes);
        for(String str: mapAttributes.keyset())
            strtoReplace += str+'='+'\"'+mapAttributes.get(str)+'\" ';
        strtoReplace+= '> \n' ;
        //System.debug(logginglevel.warn,'==== strtoReplace : '+count+' : '+strtoReplace);
        
        if(wrapDCSettingToReplace.values != null)
        {
        
            strtoReplace += ' ' + wrapDCSettingToReplace.values;
        
        }
        //System.debug(logginglevel.warn,'==== strtoReplace : '+count+' : '+strtoReplace);
        for(DCUserSettings objWrp: wrapDCSettingToReplace.lstChildDCUserSettings)
        {
            strtoReplace = strtoReplace +'\n' +BuildXMLFromWrp(objWrp);
        }
         strtoReplace = strtoReplace +'\n' + strclosingTag;
         //System.debug(logginglevel.warn,'==== strtoReplace : '+count+' : '+strtoReplace);
         return strtoReplace;
    }
    public static string getDefaultUserSettings()
    {
        StaticResource sr = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name ='DCON_UI_Settings'];

           blob tempBlob = sr.Body;

           String tempString ='';
           tempString = tempBlob.toString();
           System.debug('tempString  '+tempString);
           if(tempString ==null)
               tempString ='';
        return tempString;
    }
    
    
}