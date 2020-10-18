public with sharing class TechnicalAttributeConfiguration {

     public class MetaData {
        public String isTechnicalAttributesEnabled;
        public String isProductIQEnabled;
        public Map <String, String> translations;
        public String timeZone;
        public String instanceName;//Added as part of BAC-5346 by Nidhi
        public MetaData(){
            
        }
     }

     public class AttributesTemplateInstance {
        public AttributesTemplateInstanceObject attributesTemplateInstance;
        public Boolean isTemplateFound;
        public Integer totalHistoryRecords;
        public String lastHistoryId;
        public Datetime lastHistoryCapturedOn;
        public AttributesTemplateInstance(){
            
        }
     }


    public class AttributesTemplateInstanceObject {
        public String sfdcId;
        public String attributesPayload;
        public String installedProductId;
        public String templateId;
        public DateTime capturedOn;
        public Boolean isNew;
        public Datetime lmd;
        
        public AttributesTemplateInstanceObject() {
            
        }
        
        public AttributesTemplateInstanceObject(String sfdcId, String attributesPayload, String installedProductId, String templateId, DateTime capturedOn, Boolean isNew, Datetime lmd) {
            this.sfdcId = sfdcId;
            this.attributesPayload = attributesPayload;
            this.installedProductId = installedProductId;
            this.templateId = templateId;
            this.capturedOn = capturedOn;
            this.isNew = isNew;
            this.lmd = lmd;
        }
    }

    public class ProductDetails {

        public String pId;
        public String pLine;
        public String pFamily;

        public ProductDetails(){

        }
    }

    public class TAtemplate{
        public String sfdcId;
        public String title;
        public String templateJSON;
        public Boolean isTemplateFound;

        public TAtemplate(){

        }
    }

    public class TAHistory{
        public String sfdcId;
        public String attributesPayload;
        public Datetime capturedOn;
        public String ibId;
        public String instanceTemplateId;

        public TAHistory(){

        }
    }

    public class TAHistoryRequestObject{
        public Datetime capturedOn;
        public String ibId;
        public String instanceTemplateId;
        public Integer index;

        public TAHistoryRequestObject(){
        }
    }

    public class IbTechnicalAttributeObject{
        public String name;
        public String value;
        public Datetime createdDate;
        public String attributeExtId;
        public String ibId;
        public Boolean isActive;

        public IbTechnicalAttributeObject(){

        }
    }

    public class IbInstancePayload{
        public List<AttributesCategory> fields;
        public Map<String,AttributesPicklist> picklist;
        public IbInstancePayload(){

        }
    }

    public class AttributesCategory{
        public String title;
        public String description;
        public List<Attribute> technicalAttributes;

        public AttributesCategory(){

        }
    }

    public class Attribute{

        public String label;
        public String sequence;
        public String defaultValue;
        public String unit;
        public String readOnly;
        public String format;
        public String type;
        public String req;
        public String minNumber;
        public String maxNumber;
        public String picklistId;
        public String picklistSfId;
        public Attribute(){

        }
    }
     public class AttributesPicklist{
        public List<String> values;
        public Boolean setDefaultValue;
        public AttributesPicklist(){

        }
    }
}