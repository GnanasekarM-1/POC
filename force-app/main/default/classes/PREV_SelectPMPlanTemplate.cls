/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * This class we are using in 
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
public with sharing class PREV_SelectPMPlanTemplate
{
  public List<TemplateDetail> tableDetail= new List<TemplateDetail>();
  public String strTemplateType{get; set;}
  
    public PREV_SelectPMPlanTemplate(ApexPages.StandardController controller) 
    {
        templateTypeOptns.add(new SelectOption('None',getTAG022()));
        templateTypeOptns.add(new SelectOption('Time/Frequency',getTAG054()));
        templateTypeOptns.add(new SelectOption('Condition/Criteria',getTAG055()));
    }  
  public List<SelectOption> templateTypeOptns = new List<SelectOption>();
  public List<SelectOption> getTemplateTypeOptns (){return templateTypeOptns;}
  public void setTemplateTypeOptns (List<SelectOption> tempOptn){templateTypeOptns = tempOptn;}
  public PREV_SelectPMPlanTemplate(){}
  public pageReference proceed()
  {
   
   PageReference pr = null;
   System.debug('strTemplateType: '+strTemplateType);
   if(strTemplateType != 'None')
   {
     
     if(strTemplateType == 'Time/Frequency')
     {
       String url= '/apex/OBJ_New_PMPlan_Template';
       pr = new PageReference(url);
     }
     if(strTemplateType == 'Condition/Criteria')
     {
       String  url= '/apex/PREV_SetupPMPlanTemplate';
       pr = new PageReference(url);
     }
   }
   return pr;
  }
  public class TemplateDetail
  {
        public String name{get;set;}
        public String description{get;set;}
        public String docurl{get;set;}
        public String urltitle{get;set;}
        TemplateDetail(String name,String description,String docurl,String urltitle)
        {
          this.name = name;
          this.description = description;
          this.docurl = docurl;
          this.urltitle = urltitle;
        }
  }
  public List<TemplateDetail> getTabledetail()
  {
    if(tableDetail.isEmpty())
    {
      
      TemplateDetail detail1 = new TemplateDetail(getTAG054(),getTAG056(),getHLPURL1(),getTAG058());
      TemplateDetail detail2 = new TemplateDetail(getTAG055(),getTAG057(),getHLPURL2(),getTAG059());
      
      tableDetail.add(detail1);
      tableDetail.add(detail2);
    }
    return tableDetail;
  }
  public string getTAG051(){return string.escapeSingleQuotes(system.label.CONF036_TAG051);}//Select Preventive Maintenance Plan Template Type
  public string getTAG052(){return string.escapeSingleQuotes(system.label.CONF036_TAG052);}//Template Type  
  public string getTAG053(){return string.escapeSingleQuotes(system.label.CONF036_TAG053);}//Available PM Plan Templates
  public string getTAG054(){return string.escapeSingleQuotes(system.label.CONF036_TAG054);}//Time/Frequency Based  
  public string getTAG055(){return string.escapeSingleQuotes(system.label.CONF036_TAG055);}//Condition/Criteria Based
  public string getTAG056(){return string.escapeSingleQuotes(system.label.CONF036_TAG056);}//Time/Frequency Based description
  public string getTAG057(){return string.escapeSingleQuotes(system.label.CONF036_TAG057);}//Condition/Criteria Based description
  public string getTAG058(){return string.escapeSingleQuotes(system.label.CONF036_TAG058);}//Time/Frequency Based Preventive Maintenance
  public string getTAG059(){return string.escapeSingleQuotes(system.label.CONF036_TAG059);}//Condition/Criteria Based Preventive Maintenance.
  public string getHLPURL1(){return string.escapeSingleQuotes(system.label.CONF036_HLPURL1);}//User doc url TimeBased.htm
  public string getHLPURL2(){return string.escapeSingleQuotes(system.label.CONF036_HLPURL2);}//User doc url PMConditionBased.htm  
  public string getHLPURL3(){return string.escapeSingleQuotes(EncodingUtil.urlEncode(system.label.CONF036_HLPURL3, 'UTF-8'));}//PM overview document  
    
  //Existing Tag
  public string getTAG074(){return string.escapeSingleQuotes(system.label.CONF018_TAG074);}//Continue 
  public string getTAG028(){return string.escapeSingleQuotes(system.label.CONF018_TAG028);}//Cancel
  public string getTAG010(){return string.escapeSingleQuotes(system.label.CONF018_TAG010);}//Description  
  public string getTAG022(){return string.escapeSingleQuotes(system.label.CONF018_TAG022);} //NOne  
  public String getHELPTITLE() {return string.escapeSingleQuotes(system.label.COMM001_TAG064);} //Help 
    
}