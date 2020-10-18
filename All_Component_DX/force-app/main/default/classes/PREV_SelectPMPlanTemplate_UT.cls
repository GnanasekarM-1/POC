/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 *  PREV_SelectPMPlanTemplate_UT is for unit testing of the class PREV_SelectPMPlanTemplate
 *
 * @author Jaysukh Patel vf page PREV_SelectPMPlanTemplate as a contoller, which provide a all detail to render the UI.
 * @version 19.3
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Jaysukh Patel        17th September  2019     Created. 
 *****************************************************************************************************/
@isTest(seeAllData=false)
public class PREV_SelectPMPlanTemplate_UT{
    
    static testMethod void conf_PM_plan_unitTest()
    {
         Test.startTest();
         PREV_SelectPMPlanTemplate prev_selectPMPlanTemplate = new PREV_SelectPMPlanTemplate();
         prev_selectPMPlanTemplate.strTemplateType = 'Time/Frequency' ;
         prev_selectPMPlanTemplate.proceed(); 
         prev_selectPMPlanTemplate.strTemplateType = 'Condition/Criteria' ;
         prev_selectPMPlanTemplate.proceed();
         prev_selectPMPlanTemplate.getTabledetail();
         
         PM_Plan_Template__c obj1 = new PM_Plan_Template__c();
         obj1.name = 'Template 1';
         
        
         Test.setCurrentPage(Page.PREV_SelectPMPlanTemplate);
         ApexPages.StandardController stdSetController = new ApexPages.StandardController(obj1);

         PREV_SelectPMPlanTemplate ext = new PREV_SelectPMPlanTemplate(stdSetController);
         
         
         List<SelectOption> templateTypeOptns = new List<SelectOption>();
         templateTypeOptns.add(new SelectOption('Time/Frequency','Time/Frequency Based'));
         templateTypeOptns.add(new SelectOption('Condition/Criteria','Condition/Criteria Based'));
         prev_selectPMPlanTemplate.setTemplateTypeOptns(templateTypeOptns);
         prev_selectPMPlanTemplate.getTemplateTypeOptns();
         prev_selectPMPlanTemplate.getTAG051();
         prev_selectPMPlanTemplate.getTAG052();
         prev_selectPMPlanTemplate.getTAG053();
         prev_selectPMPlanTemplate.getTAG074();
         prev_selectPMPlanTemplate.getTAG028();
         prev_selectPMPlanTemplate.getTAG010();
         prev_selectPMPlanTemplate.getHLPURL3();
         prev_selectPMPlanTemplate.getHELPTITLE();
         Test.stopTest();
    }
   
}