global class WSCH_Utils_API {
    
    global class SVMXException extends Exception {}
    /*
     * Basic skill information
     */
    global class Skill
    {
        WebService string skillId { get; set; }
        WebService String skillName { get; set; }
        WebService Boolean isSkillMandatory { get; set; }
        WebService Integer skillLevel { get; set; }
        
        global Skill() {
        }

        global Skill (string skillId, String skillName, Boolean isSkillMandatory, Integer skillLevel) {
            this.skillId = skillId;
            this.skillName = skillName;
            this.isSkillMandatory = isSkillMandatory;
            this.skillLevel = skillLevel;
        }
    }
    
    /*
     * This class holds the work order related skills
     */
    global class WorkOrderSkill {
        webservice Id workOrderId { get; set; }
        // for now skillSet is not exposed
        // webservice String skillSet { get; set; }
        webservice list<Skill> lstSkills { get; set; }
        
        global WorkOrderSkill() {
            this.lstSkills = new list<Skill>();
        }
        
        /*
        global WorkOrderSkill(Id workOrderId, String skillSet) {
            this.workOrderId = workOrderId;
            this.skillSet = skillSet;
        }
        */
        
        global WorkOrderSkill(Id workOrderId, List<Skill> lstSkills) {
            this.workOrderId = workOrderId;
            this.lstSkills = lstSkills;
        }

        /*
        global WorkOrderSkill(Id workOrderId, String skillSet, List<Skill> lstSkills) {
            this.workOrderId = workOrderId;
            this.skillSet =  skillSet;
            this.lstSkills = lstSkills;
        }
        */

        private void formatSkillsFromInternal(List<DCON_MultiCriteriaTechMatch_WS.skill> lstSkillInternal) {
            if (lstSkillInternal != null) {
                for (DCON_MultiCriteriaTechMatch_WS.skill skillInternal : lstSkillInternal) {
                    this.lstSkills.add(new Skill (skillInternal.skillId, skillInternal.skillName, skillInternal.isSkillMandatory, skillInternal.skillLevel));
                }
            }   
        }

        private List<DCON_MultiCriteriaTechMatch_WS.skill> formatSkillsToInternal() {
            List<DCON_MultiCriteriaTechMatch_WS.skill> lstSkillInternal = new List<DCON_MultiCriteriaTechMatch_WS.skill>();

            if (this.lstSkills != null) {
                for (Skill skill : this.lstSkills) {
                    lstSkillInternal.add(new DCON_MultiCriteriaTechMatch_WS.skill (skill.skillId, skill.skillName, skill.isSkillMandatory, skill.skillLevel));
                }
            }

            return lstSkillInternal;
        }
    }
    
    /*
     * Desc  : Get the list of Skills for the WorkOrder Id (bulkified)
     * Input : List of Work Order Ids
     * Output: Returns a list of WorkOrderSkill structure with the Work Order Id and Skills
     */
    WebService static List<WorkOrderSkill> getWorkOrderSkills(List<Id> lstWorkOrderId) 
    {
        WorkOrderSkill workOrderSkill =  new WorkOrderSkill();
        List<WorkOrderSkill> lstWorkOrderSkill = new List<WorkOrderSkill>();

        try
        {
            // call the internal method
            List<DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill> mapWOIdSkill;
            mapWOIdSkill = DCON_MultiCriteriaTechMatch_WS.getSkillsForGivenWOIds(lstWorkOrderId);
            System.debug('Result:' + mapWOIdSkill);
            if (mapWOIdSkill != null) {
                // convert the output of internal method to WorkOrderSkill format
                for (DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill woIdSkill : mapWOIdSkill) {
                    workOrderSkill.workOrderId = woIdSkill.key;
                    workOrderSkill.formatSkillsFromInternal(woIdSkill.lstSkill);
                    lstWorkOrderSkill.add(workOrderSkill);   
                }
            }
            
            return lstWorkOrderSkill;
        }
        catch(Exception ex) {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCON_MultiCriteriaTechMatch_WS.SVMXException(ex.getMessage());
        }
    }
    
    /*
     * Desc  : Update the Work Order object with the Skill information (bulkified)
     * Input : List of WorkOrderSkill structure with the Work Order Id and Skills,
     *         Flag to indicate whether the skills to be appended or overrittedn with the existing skill information on the Work Order 
     * Output: none
     */

    Webservice static void setWorkOrderSkills(List<WorkOrderSkill> lstWorkOrderSkill, boolean appendSkill) 
    {
        DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill woIdSkill = new DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill();
        List<DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill> mapWOIdSkill = new  List<DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill>();
        System.debug('Result1:' + lstWorkOrderSkill);
        try {
            if (lstWorkOrderSkill != null) {
                // convert the WorkOrderSkill structure to input required by the internal method
                for (WorkOrderSkill workOrderSkill : lstWorkOrderSkill) {
                    woIdSkill.key = workOrderSkill.workOrderId;
                    woIdSkill.lstSkill = workOrderSkill.formatSkillsToInternal();
                    mapWOIdSkill.add(woIdSkill);   
                }
                
                // call the internal method to either append or overwrite based on the input control
                if (appendSkill) {
                    // option 1: not efficient; unnecessary SOQL
                    // call decodeSkillObjMapToJSON
                    // call putSkillsForGivenWOIds
                    // option 2: modify putSkillsForGivenWOIds to append or add update DML to decodeSkillObjMapToJSON
                    // appendSkillsForGivenWOIds 
                    DCON_MultiCriteriaTechMatch_WS.appendSkillsForGivenWOIds(mapWOIdSkill);
                }
                else {
                    DCON_MultiCriteriaTechMatch_WS.putSkillsForGivenWOIds(mapWOIdSkill);
                }
            }
        }
        catch(Exception ex) {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCON_MultiCriteriaTechMatch_WS.SVMXException(ex.getMessage());
        }
    }
    
    //DNS-572: This is a utility function provided to customers as an option to update their 'home lat/lng' fields
    //For a 'Technician' check if any 'Current active homebase' location exists or not, if exists update the same as 'home lat/lng' fields
    //else copy the 'Current lat/lng' field values as 'Home lat/lng' field values
    //This method will update technicians 'home lat/lng' fields by their service team wise
    global void updateTechHomelatlog(List<SVMXC__Service_Group__c> listServiceTeamId)
    {
        try
        {
            if(listServiceTeamId != null && listServiceTeamId.size() > 0)
            {
                List<SVMXC__Service_Group_Site__c> listTechHomeBase = new List<SVMXC__Service_Group_Site__c>();
                List<SVMXC__Service_Group_Members__c> listTech = new List<SVMXC__Service_Group_Members__c>();
                List<SVMXC__Service_Group_Members__c> listTechId = new List<SVMXC__Service_Group_Members__c>();
                Map<String, SVMXC__Service_Group_Site__c> mapTempTechHB = new Map<String, SVMXC__Service_Group_Site__c>();
                SVMXC__Service_Group_Site__c tempHomeBaseLoc = new SVMXC__Service_Group_Site__c();

                //get list of technician id's for a given service team
                for(SVMXC__Service_Group__c servTeam: listServiceTeamId)
                {
                    listTechId = [SELECT Id FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Service_Group__c =:servTeam.id];
                
                    //check if a technician is 'active'
                    listTech = [SELECT Id, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Zip__c FROM SVMXC__Service_Group_Members__c WHERE Id IN :listTechId AND SVMXC__Active__c = true];
                    
                    //get the 'current active home base' address for active technician's
                    listTechHomeBase = [SELECT SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Technician_Equipment__c, SVMXC__Zip__c FROM SVMXC__Service_Group_Site__c WHERE SVMXC__Technician_Equipment__c IN :listTech AND SVMXC__Latitude__c != NULL AND SVMXC__Longitude__c != NULL AND SVMXC__IsCurrent__c = true AND RecordType.Name='Home Bases'];
                    
                    if(listTechHomeBase != null && listTechHomeBase.size()>0)
                    {
                        for(SVMXC__Service_Group_Site__c hb: listTechHomeBase)
                        {
                            mapTempTechHB.put(hb.SVMXC__Technician_Equipment__c, hb);
                        }
                    }
                    
                    //if technician is active, only then update 'home lat/lng' fields
                    if(listTech != null && listTech.size()>0)
                    {
                        for(SVMXC__Service_Group_Members__c tech: listTech)
                        {
                            if(mapTempTechHB.get(tech.id) != NULL)
                            {
                                tempHomeBaseLoc = mapTempTechHB.get(tech.id);
                                tech.SVMXC__Latitude_Home__c = tempHomeBaseLoc.SVMXC__Latitude__c;
                                tech.SVMXC__Longitude_Home__c = tempHomeBaseLoc.SVMXC__Longitude__c;
                            }
                            else
                            {
                                tech.SVMXC__Latitude_Home__c = tech.SVMXC__Latitude__c;
                                tech.SVMXC__Longitude_Home__c = tech.SVMXC__Longitude__c;   
                            }
                        }
                    }
                    //update technican object with 'home lat/lng' values
                    if(listTech.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( listTech, COMM_SecurityUtils.Access.Updateable) ) {
                            update listTech; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                    listTechId.clear();
                    listTech.clear();
                    listTechHomeBase.clear();
                }
            }           
        }
        catch (Exception ex)
        {
            throw new SVMXException(ex.getmessage());
        }
    }
    
    //DNS-572: This is a utility function provided to customers as an option to update their 'home lat/lng' fields
    //For a 'Technician' check if any 'Current active homebase' location exists or not, if exists update the same as 'home lat/lng' fields
    //else copy the 'Current lat/lng' field values as 'Home lat/lng' field values
    //This method will update all existing technicians 'home lat/lng' fields
    global void updateTechHomelatlog()
    {
        try
        {
            List<SVMXC__Service_Group_Site__c> listTechHomeBase = new List<SVMXC__Service_Group_Site__c>();
            List<SVMXC__Service_Group_Members__c> listTech = new List<SVMXC__Service_Group_Members__c>();
            Map<String, SVMXC__Service_Group_Site__c> mapTempTechHB = new Map<String, SVMXC__Service_Group_Site__c>();
            SVMXC__Service_Group_Site__c tempHomeBaseLoc = new SVMXC__Service_Group_Site__c();

            //get list of all the active technician's       
            listTech = [SELECT Id, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Zip__c FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Active__c = true];
                
            //get the 'current active home base' address for a technician
            listTechHomeBase = [SELECT SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Technician_Equipment__c, SVMXC__Zip__c FROM SVMXC__Service_Group_Site__c WHERE SVMXC__Latitude__c != NULL AND SVMXC__Longitude__c != NULL AND SVMXC__IsCurrent__c = true AND RecordType.Name='Home Bases'];
            
            if(listTechHomeBase != null && listTechHomeBase.size() > 0)
            {
                for(SVMXC__Service_Group_Site__c hb: listTechHomeBase)
                {
                    mapTempTechHB.put(hb.SVMXC__Technician_Equipment__c, hb);
                }
            }
            
            //if technician is active, only then update 'home lat/lng' fields
            Integer cntlimit = 0;
            if(listTech != null && listTech.size() > 0)
            {
                List<SVMXC__Service_Group_Members__c> tempListTech = new List<SVMXC__Service_Group_Members__c>();
                for(SVMXC__Service_Group_Members__c tech: listTech)
                {
                    tempListTech.add(tech);
                    cntlimit++;
                    if(mapTempTechHB.get(tech.id) != NULL)
                    {
                        tempHomeBaseLoc = mapTempTechHB.get(tech.id);
                        tech.SVMXC__Latitude_Home__c = tempHomeBaseLoc.SVMXC__Latitude__c;
                        tech.SVMXC__Longitude_Home__c = tempHomeBaseLoc.SVMXC__Longitude__c;
                    }
                    else
                    {
                        tech.SVMXC__Latitude_Home__c = tech.SVMXC__Latitude__c;
                        tech.SVMXC__Longitude_Home__c = tech.SVMXC__Longitude__c;   
                    }
                    if(cntlimit == 200)
                    {
                        cntlimit = 0;
                        //update technican object with 'home lat/lng' values
                        if(tempListTech.size() > 0) {
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( tempListTech, COMM_SecurityUtils.Access.Updateable) ) {
                                update tempListTech; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                            }
                        }
                        tempListTech.clear();
                    }
                }
                //if the technican list is less than specified limit (i.e 200)
                if(cntlimit < 200)
                {
                    //update technican object with 'home lat/lng' values
                    if(tempListTech.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( tempListTech, COMM_SecurityUtils.Access.Updateable) ) {
                            update tempListTech; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            throw new SVMXException(ex.getmessage());
        }
    }
}