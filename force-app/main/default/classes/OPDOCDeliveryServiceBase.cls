public virtual class OPDOCDeliveryServiceBase extends SVMXRestBase{
  
  protected OPDOCDeliveryServiceBase(RestRequest req, RestResponse res){
    super(req, res, 'OPDOCDeliveryServiceIntf');
  }
  
  protected OPDOCDeliveryServiceBase(){}
  
  override public Object invokeMethod(SVMXRestMethodInfo mi){
    Object res = null;
    
    if(mi.MethodName.equals('getTemplate')) res = getTemplate();
    else if(mi.MethodName.equals('getTemplateOlder')) res = getTemplateOlder();
    else if(mi.MethodName.equals('getTemplateOldest')) res = getTemplateOldest();
    
    else if(mi.MethodName.equals('submitDocument')) res = submitDocument();
    else if(mi.MethodName.equals('submitDocumentOlder')) res = submitDocumentOlder();
    else if(mi.MethodName.equals('submitDocumentOldest')) res = submitDocumentOldest();
      
    else if(mi.MethodName.equals('createPDF')) res = createPDF();
    else if(mi.MethodName.equals('createPDFOlder')) res = createPDFOlder();
    else if(mi.MethodName.equals('createPDFOldest')) res = createPDFOldest();
          
    else if(mi.MethodName.equals('submitQuery')) res = submitQuery();
    else if(mi.MethodName.equals('submitQueryOlder')) res = submitQueryOlder();
    else if(mi.MethodName.equals('submitQueryOldest')) res = submitQueryOldest();
          
    else if(mi.MethodName.equals('getUserInfo')) res = getUserInfo();
    else if(mi.MethodName.equals('getUserInfoOlder')) res = getUserInfoOlder();
    else if(mi.MethodName.equals('getUserInfoOldest')) res = getUserInfoOldest();
          
    else if(mi.MethodName.equals('getDocumentData')) res = getDocumentData();
    else if(mi.MethodName.equals('getDocumentDataOlder')) res = getDocumentDataOlder();
    else if(mi.MethodName.equals('getDocumentDataOldest')) res = getDocumentDataOldest();
          
    else if(mi.MethodName.equals('getDocumentMetadata')) res = getDocumentMetadata();
    else if(mi.MethodName.equals('getDocumentMetadataOlder')) res = getDocumentMetadataOlder();
    else if(mi.MethodName.equals('getDocumentMetadataOldest')) res = getDocumentMetadataOldest();
          
    else res = invokeMissingMethod();
    
    return res;
  }
  
  public virtual Object getTemplate() { return null; }
  public virtual Object getTemplateOlder() { return getTemplate(); }
  public virtual Object getTemplateOldest() { return getTemplateOlder(); }
  
  public virtual Object submitDocument() { return null; }
  public virtual Object submitDocumentOlder() { return submitDocument(); }
  public virtual Object submitDocumentOldest() { return submitDocumentOlder(); }
  
  public virtual Object createPDF() { return null; }
  public virtual Object createPDFOlder() { return createPDF(); }
  public virtual Object createPDFOldest() { return createPDFOlder(); }
  
  public virtual Object submitQuery() { return null; }
  public virtual Object submitQueryOlder() { return submitQuery(); }
  public virtual Object submitQueryOldest() { return submitQueryOlder(); }
  
  public virtual Object getUserInfo() { return null; }
  public virtual Object getUserInfoOlder() { return getUserInfo(); }
  public virtual Object getUserInfoOldest() { return getUserInfoOlder(); }
  
  public virtual Object getDocumentData() { return null; }
  public virtual Object getDocumentDataOlder() { return getDocumentData(); }
  public virtual Object getDocumentDataOldest() { return getDocumentDataOlder(); }
  
  public virtual Object getDocumentMetadata() { return null; }
  public virtual Object getDocumentMetadataOlder() { return getDocumentMetadata(); }
  public virtual Object getDocumentMetadataOldest() { return getDocumentMetadataOlder(); }  
  
}