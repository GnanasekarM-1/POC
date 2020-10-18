public class SGAT_WebServicesDef {

    public class SVMXMap
    {
        public String key;
        public String value;
        public list<sObject> records;
        public list<String> values;
        public list<SVMXMap> valueMap;

        public SVMXMap()
        {
            values = new list<String>();
            valueMap = new list<SVMXMap>();
        }
        public SVMXMap(String key, String value)
        {
            this.key = key;
            this.value = value;
            values = new list<String>();
            valueMap = new list<SVMXMap>();
        }
        public SVMXMap(String key, String value, List<String> values)
        {
            this.key = key;
            this.value = value;
            this.values = values;
            valueMap = new list<SVMXMap>();
        }
    }

    public class SGAT_Request {
        public list<SVMXMap> valueMap;

        public SGAT_Request(List<SVMXMap> valueMap) {
            this.valueMap = valueMap;
        }
    }

    public class SGAT_Response {
        public list<SVMXMap> valueMap;

        public SGAT_Response(List<SVMXMap> valueMap) {
            this.valueMap = valueMap;
        }
    }

    public class SGAT_QueryRequest {
        public Integer limitResources{get;set;}
        public List<SGAT_Query> queries{get;set;}

        public SGAT_QueryRequest(Integer limitResources, List<SGAT_Query> queries) {
            this.limitResources = limitResources;
            this.queries = queries;
        }
    }

    public class SGAT_QueryResponse {
        public String name{get;set;}
        public List<sObject> records{get;set;}
        public String lastId{get;set;}
        public String error{get;set;}

        public SGAT_QueryResponse(String name, List<sObject> records, String lastId, String error) {
            this.name = name;
            this.records = records;
            this.lastId = lastId;
            this.error = error;
        }
    }

    public class SGAT_Query {
        public String name{get;set;}
        public String query{get;set;}
        public Boolean allRows{get;set;}

        public SGAT_Query(String name, String query, Boolean allRows) {
            this.name = name;
            this.query = query;
            this.allRows = allRows;
        }
    }
}