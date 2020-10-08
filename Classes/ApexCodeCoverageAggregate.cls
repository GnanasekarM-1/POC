public class ApexCodeCoverageAggregate {
 
    public class Attributes {
        public String type;
        public String url;
    }
 
    public class Records {
        public Attributes attributes;
        public String Id;
        public String ApexClassOrTriggerId;
        public Integer NumLinesCovered;
        public Integer NumLinesUncovered;
    }
 
    public Integer size;
    public Integer totalSize;
    public Boolean done;
    public Object queryLocator;
    public List<Records> records;
    public String entityTypeName;
}