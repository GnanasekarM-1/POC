/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The INVT_SpareParts_Wrapper is a wrapper class for wrapping the data retrieved from the Service class which 
 * is used during the Spare Part Config create or edit
 * 
 *
 * @author Anchal
 * @version 39
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anchal               7 June 2017       Created.
 *****************************************************************************************************/
public with sharing class INVT_SpareParts_Wrapper {
    
     public class ObjectInfo {
        public String Id;
        public String name;
        public String fieldtype;
        public ObjectInfo() {}
        
     }
     
     public class LocatePart{
         public String isenabled;
         public String radius;
         public String distanceinunit;
         public String[] locationtype;
         public String inventoryprocess;
         public List <ObjectInfo> listlocationtype; 
         public LocatePart(){
         }
     }
     
     public class columnData{
         public String sequence;
         public String fieldname;
         public String objectname;
         public String fieldtype;
         public String showlabel;
         public columnData(){}
     }
     
     public class DownloadCriteria{
         public Boolean includeserializedstock;
         public String productstockstatus;
         public String quantityfield;
         
         public DownloadCriteria(){
         }
     }  
     
     
      public class DownloadCriteriatemp{
         public Boolean includeserializedstock;
         public String productstockstatus;
         public String quantityfield;
         
         public DownloadCriteriatemp(){
         }
     }  
     
     public class Layout{
         public List<columnData> partsfields;
         public List<columnData> partsdetailfields;
         public List<DownloadCriteria> downloadcriteria;
         public String attachmentfilename;
         public Layout(){
         }
     }
     
     
     public class SpareParts_Request {
        public String profileid;
        public Layout layout;
        public LocatePart locatepartsetup;
        public SpareParts_Request(){
           
        }
     }
    
    public class SpareParts_Response {
        public Boolean success ;
        public Boolean warning ;
        public List<ObjectInfo> profilelist;
        public String profileid;
        public Layout layout;
        public LocatePart locatepartsetup;
        public List<String> messagelist ;
        public List <ObjectInfo> liststockinventoryprocess ; 
        public List <ObjectInfo> listproductfields ; 
        public List <ObjectInfo> listproductstockstatus ; 
        public List <ObjectInfo> listquantityfields ;
        public List <ObjectInfo> listserializedoptions ;  
        public SpareParts_Response(){ 
            messagelist = new List<String>();
        }
    }
}