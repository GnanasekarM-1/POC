global with sharing class TechnicalAttribute {

    public TechnicalAttribute() {

    }
    @RemoteAction
    global static String JsrGetMetadata(String requestStr){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();     
        return JSON.serialize(taImpl.getMetaData());
     }

    @RemoteAction
    global static String JsrGetAttributesTemplateInstanceForIB(String ibId){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();     
        return JSON.serialize(taImpl.getAttributesTemplateInstanceForIB(ibId));
     }

    @RemoteAction
    global static String JsrSaveTechnicalAttributeDetails(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl(TechnicalAttributeImpl.source.WEB);     
        return JSON.serialize(taImpl.saveTechnicalAttributeDetails(request));
     }
     
    @RemoteAction
    global static String JsrGetAllAttributesforIB(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllAttributesforIB(request));
    }

    @RemoteAction
    global static String JsrGetInstalledProductforTechnicalAttribute(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getInstalledProductforTechnicalAttribute(request));
    }

    @RemoteAction
    global static String JsrGetAllProductFilter(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllProductFilter(request));
    }

    @RemoteAction
    global static String JsrGetAllProductOperator(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllProductOperator(request));
    }

    @RemoteAction
    global static String JsrGetAllAttributeOperator(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllAttributeOperator(request));
    }

    @RemoteAction
    global static String JsrGetAllAdditionalFilter(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllAdditionalFilter(request));
    }

    @RemoteAction
    global static String JsrGetPossibleFirstColumns(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getPossibleFirstColumns(request));
    }

    @RemoteAction
    global static String JsrGetIBDetails(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getIBDetails(request));
    }

    @RemoteAction
    global static String JsrGetAllHistoryGroupByRecord(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllHistoryGroupByRecord(request));
    }

    @RemoteAction
    global static String JsrGetAllHistoryGroupByAttribute(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllHistoryGroupByAttribute(request));
    }

    @RemoteAction
    global static String JsrFilterProductName(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.filterProductName(request));
    }

    @RemoteAction
    global static String JsrGetAllTags(String request){     
        TechnicalAttributeImpl taImpl = new TechnicalAttributeImpl();
        return JSON.serialize(taImpl.getAllTags(request));
    }

}