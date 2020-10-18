@isTest(SeeAllData=true)
private class SFM_GetObjectFieldList_UT
{
    static testMethod void SFM_getObjectFieldList_Test()
    {
//-----------------DATA PREPARATION PART FOR METHOD ONE----------------------------------------------------------------------------//
        //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj1= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'EXPRESSION');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj11= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_stringMapObj1 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_stringMapObj1.add(wrapper_strMapObj1);
        wrapperList_stringMapObj1.add(wrapper_strMapObj11);
        System.assertnotEquals(wrapper_strMapObj1, wrapper_strMapObj11);
        
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req1 = new SFM_WrapperDef.SFM_Request();
        req1.setstringMap(wrapperList_stringMapObj1);
        System.assertEquals(true, req1 != null);
        
        //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj2= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'SEARCH');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj22= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj2 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj2.add(wrapper_strMapObj2);
         wrapperList_strMapObj2.add(wrapper_strMapObj22);
         System.assertnotEquals(wrapper_strMapObj2, wrapper_strMapObj22);
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req2 = new SFM_WrapperDef.SFM_Request();
        req2.setstringMap(wrapperList_strMapObj2);
        
        //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj3= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'LOOKUPCONFIG');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj33= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj3 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj3.add(wrapper_strMapObj3);
        wrapperList_strMapObj3.add(wrapper_strMapObj33);
        System.assertnotEquals(wrapper_strMapObj3, wrapper_strMapObj33);
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req3 = new SFM_WrapperDef.SFM_Request();
        req3.setstringMap(wrapperList_strMapObj3);
        
        //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj4= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'SOURCEOBJECTUPDATE');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj44= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj4 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj4.add(wrapper_strMapObj4);
        wrapperList_strMapObj4.add(wrapper_strMapObj44);
        System.assertnotEquals(wrapper_strMapObj4, wrapper_strMapObj44);
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req4 = new SFM_WrapperDef.SFM_Request();
        req4.setstringMap(wrapperList_strMapObj4);
        
        //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj5= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'MAPPING');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj55= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj5 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj5.add(wrapper_strMapObj5);
        wrapperList_strMapObj5.add(wrapper_strMapObj55);
        System.assertnotEquals(wrapper_strMapObj5, wrapper_strMapObj55);
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req5 = new SFM_WrapperDef.SFM_Request();
        req5.setstringMap(wrapperList_strMapObj5);
        
         //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        wrapper_strMapObj5= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'SCREEN');
        wrapper_strMapObj55= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Site__c');
        wrapperList_strMapObj5 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj5.add(wrapper_strMapObj5);
        wrapperList_strMapObj5.add(wrapper_strMapObj55);
        System.assertnotEquals(wrapper_strMapObj5, wrapper_strMapObj55);
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req6 = new SFM_WrapperDef.SFM_Request();
        req6.setstringMap(wrapperList_strMapObj5);
        
         //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        wrapper_strMapObj5= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'REPORTDESIGNER');
        wrapper_strMapObj55= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Site__c');
        wrapperList_strMapObj5 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj5.add(wrapper_strMapObj5);
        wrapperList_strMapObj5.add(wrapper_strMapObj55);
        System.assertnotEquals(wrapper_strMapObj5, wrapper_strMapObj55);
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req7 = new SFM_WrapperDef.SFM_Request();
        req7.setstringMap(wrapperList_strMapObj5);
        
        //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj8= new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE' , 'EXPRESSIONFORBIZRULE');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj88= new SFM_WrapperDef.SFM_StringMap('OBJECTNAME' , 'SVMXC__Service_Order__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_stringMapObj8 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_stringMapObj8.add(wrapper_strMapObj8);
        wrapperList_stringMapObj8.add(wrapper_strMapObj88);
        System.assertnotEquals(wrapper_strMapObj8, wrapper_strMapObj88);
        
      //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request req8 = new SFM_WrapperDef.SFM_Request();
        req8.setstringMap(wrapperList_stringMapObj8);
        System.assertEquals(true, req8 != null);
        
         //------------------------INSTANCIATING THE OBJECT---------------------------------//
         SFM_getObjectFieldList FieldList_Obj = new SFM_getObjectFieldList();
         
         //-------------------------CALLING THE METHOD ONE OF THIS OBJECT-----------------------//
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj1 = FieldList_Obj.getObjectFieldList(req1);
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj2 = FieldList_Obj.getObjectFieldList(req2);
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj3 = FieldList_Obj.getObjectFieldList(req3);
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj4 = FieldList_Obj.getObjectFieldList(req4);
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj5 = FieldList_Obj.getObjectFieldList(req5);
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj6 = FieldList_Obj.getObjectFieldList(req6);
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj7 = FieldList_Obj.getObjectFieldList(req7);
        SFM_WrapperDef.SFM_Response_ObjectFields wrapper_resObjFieldObj8 = FieldList_Obj.getObjectFieldList(req8);

       
    }//METHOD
    static testMethod void getSortableFields_Test(){
	    set<String> sets = new set<String>();
		sets.add('SVMXC__Service_Order__c');
		SFM_GetObjectFieldList fs = new SFM_GetObjectFieldList();
		fs.getSortableFields(sets);
    }	
}//CLASS