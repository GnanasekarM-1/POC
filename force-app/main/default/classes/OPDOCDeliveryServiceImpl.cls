public class OPDOCDeliveryServiceImpl extends OPDOCDeliveryServiceBase{

    public OPDOCDeliveryServiceImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
    public OPDOCDeliveryServiceImpl(){
       /**
        * The empty constructor is introduced so that the service methods can be consumed from VF page.
        */
    }
    
    override public Object getTemplate() {
    
        OPDOC_DeliveryImpl.GetTemplateRequest gtr = 
            (OPDOC_DeliveryImpl.GetTemplateRequest)
                deserializeRequestTo(OPDOC_DeliveryImpl.GetTemplateRequest.class);
        OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
        return JSON.serialize(objDocDelImpl.getTemplate(gtr));
    }

    override public Object submitDocument() {
    
        OPDOC_DeliveryImpl.SubmitDocumentRequest gtr = 
          (OPDOC_DeliveryImpl.SubmitDocumentRequest)
          deserializeRequestTo(OPDOC_DeliveryImpl.SubmitDocumentRequest.class);
        OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
        return JSON.serialize(objDocDelImpl.submitDocument(gtr));
    }
    
    override public Object createPDF() {
    
        OPDOC_DeliveryImpl.CreatePDFRequest gpr = 
            (OPDOC_DeliveryImpl.CreatePDFRequest)
            deserializeRequestTo(OPDOC_DeliveryImpl.CreatePDFRequest.class);
        OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
        return JSON.serialize(objDocDelImpl.createPDF(gpr));        
    }

    override public Object submitQuery() {
    
        OPDOC_DeliveryImpl.SubmitQueryRequest sqr = 
            (OPDOC_DeliveryImpl.SubmitQueryRequest)
            deserializeRequestTo(OPDOC_DeliveryImpl.SubmitQueryRequest.class);
        OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
        return JSON.serialize(objDocDelImpl.submitQuery(sqr));        
    }

    override public Object getUserInfo() {
    
        OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();    
        return JSON.serialize(objDocDelImpl.getUserInfo());        
    }

    override public Object getDocumentData() {
    
        OPDOC_DeliveryImpl.GetDocumentDataRequest ddr = 
            (OPDOC_DeliveryImpl.GetDocumentDataRequest)
            deserializeRequestTo(OPDOC_DeliveryImpl.GetDocumentDataRequest.class);
        OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
        return JSON.serialize(objDocDelImpl.getDocumentData(ddr));        
    }

    override public Object getDocumentMetadata() {
    
        OPDOC_DeliveryImpl.GetDocumentMetadataRequest dmr = 
            (OPDOC_DeliveryImpl.GetDocumentMetadataRequest)
            deserializeRequestTo(OPDOC_DeliveryImpl.GetDocumentMetadataRequest.class);
        OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
        return JSON.serialize(objDocDelImpl.getDocumentMetadata(dmr));        
    }    
}