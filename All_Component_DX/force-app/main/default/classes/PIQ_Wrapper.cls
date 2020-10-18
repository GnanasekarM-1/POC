public with sharing class PIQ_Wrapper {


    public class PIQ_Response{
        public boolean success{get;set;}
        public String code{get;set;}
        public String error{get;set;}
        public String message{get;set;}
        public List<SVMXC__Installed_Product__c> lstInstalledProducts{get;set;}
    }


    public class PIQ_Request{
        public String value{get;set;}
        public expression expression{get;set;}
        public String operator{get;set;}
        public list<String> lstFields{get;set;}
    }

    public class PIQ_IBDetailsReq{
        public list<Id> lstIbs{get;set;}
        public list<String> lstFields{get;set;}
    }
    public class expression{
        public List<attribute> lstTechnicalAttributes{get;set;}
        public List<attribute> lstProductAttributes{get;set;}
        public List<attribute> lstInstalledBaseAttributes{get;set;}
        public expression(){
            lstTechnicalAttributes = new List<attribute>();
            lstProductAttributes = new List<attribute>();
            lstInstalledBaseAttributes = new List<attribute>();
        }
    }

    public class attribute{
        public String field{get; set;}
        public String key{get; set;}
        public String type{get; set;}
        public String operator{get; set;}
        public String value{get; set;}
        public boolean active{get; set;}

        public list<attribute> lstFields{get; set;}

        public attribute(String type, String key, String operator, String value){
            if(type == 'FIELD'){
                this.field = key;
                this.operator = operator;
                this.value = value;
            }
            else if(type == 'ATTRIBUTE'){
                this.key = key;
                this.operator = operator;
                this.value = value;
            }
        }

        public attribute(String key, String operator, String value){
            this.key = key;
            this.operator = operator;
            this.value = value;
        }

        public attribute(String key, String value){
            this.key = key;
            this.value = value;
        }

        public attribute(String key, boolean active){
            this.key = key;
            this.value = key;
            this.active = active;
        }
    }

    public class jsrData{
        public object data;
        public String message;
        public Boolean success = true;
    }

    public PIQ_Wrapper() {

    }

    /*********** Display History Page Request and Response structures ******** */

    //History Request
    public class PIQ_History_Request{
        public List<String> ibIdList;
        public List<String> attributeNameList;
        public String startDate;
        public String endDate;
    }

    //History Response
    public class PIQ_History_Response{
        public boolean success{get;set;}
        public String code{get;set;}
        public String error{get;set;}
        public String message{get;set;}
        public List<HistoryWrapper> historyWrapperList;
    }

    public class AttributeCapturedOn{
        public string capturedOnDate;
        public string attributeValue;

        public AttributeCapturedOn(String capturedOnDate, String attributeValue){
            this.capturedOnDate = capturedOnDate;
            this.attributeValue = attributeValue;
        }
    }

    public class IBWrapper{
        public string ibId;
        public string ibName;
        public string attributeLabel;
        public List<AttributeCapturedOn> attrValues;

        public IBWrapper(string ibId, string ibName, string attributeLabel, List<AttributeCapturedOn> attrValues){
            this.ibId = ibId;
            this.ibName = ibName;
            this.attributeLabel = attributeLabel;
            this.attrValues = attrValues;
        }
    }

    public class HistoryWrapper{
        public String attributeName;
        public String installedProdId;
        public String installedProdName;
        List<IBWrapper> ibWrapperList;

        public HistoryWrapper(string attributeName, string installedProdId, string installedProdName, List<IBWrapper> ibWrapperList){
            this.attributeName = attributeName;
            this.installedProdId = installedProdId;
            this.installedProdName = installedProdName;
            this.ibWrapperList = ibWrapperList;
        }
    }

}