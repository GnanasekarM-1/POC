/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Custom controller class for Launching Servicemax Help URL specific to User language.
 * 
 * @author Sachin S
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              SACHIN S               04 SEP 2015     Created. 
 *****************************************************************************/
public with sharing class SVMX_LaunchHelp {
    Static final String subModuleId = 'HELPSC1'; //Submodule ID to get Launch URL specific to user language

     /**
     * The method is invoked from the visualforce page 'SVMX_LaunchHelp' on load.
     * @return Servicemax help URL is returned specific to User language. 
     */    
    public pageReference getHelpURL() {
        String helpURL; 
        List<SVMXC.COMM_TagWebServices.TagsMap> urlTagsMap = SVMXC.COMM_TagWebServices.TagdataforSubmodule(submoduleid); 
        for(SVMXC.COMM_TagWebServices.TagsMap urlTag : urlTagsMap){
            System.debug(LoggingLevel.DEBUG, 'HELPSC1 Tags : ' +  urlTag);
            if(urlTag.Key.equals('HLPURL')){
               HelpURL = urlTag.Value;
               break;
            }   
        }
        PageReference redirectURL = new PageReference(helpURL);
        return redirectURL ;
    }
}