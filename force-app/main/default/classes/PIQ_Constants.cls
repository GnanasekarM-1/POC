public with sharing class PIQ_Constants {
    public static final String FILTER_PRODUCTNAME = 'PRODUCTNAME';
    public static final String FILTER_PRODUCTFAMILY = 'PRODUCTFAMILY';
    public static final String FILTER_PRODUCTLINE = 'PRODUCTLINE';
    
    public static final String FILTER_TECHNICALATTRIBUTE = 'TECHNICALATTRIBUTE';
    public static final String FILTER_INSTALLEDPRODUCT = 'INSTALLEDPRODUCT';

    public static final String FILTER_IBNAME = 'NAME';
    public static final String FILTER_IBASSETTAG = 'ASSETTAG';
    public static final String FILTER_IBSERIALNO = 'SERIALNUMBER';

    public static final String OPERATOR_EQUALTO = 'equlato';
    public static final String OPERATOR_NOTQUALTO = 'notequlato';
    public static final String OPERATOR_GREATERTHAN = 'greaterthan';
    public static final String OPERATOR_GREATERTHANEQUAL = 'greaterthanequalto';
    public static final String OPERATOR_LESSTHAN = 'lessthan';
    public static final String OPERATOR_LESSTHANEQUAL = 'lessthanequalto';
    public static final String OPERATOR_CONTAINS = 'contains';
    public static final String OPERATOR_NOTCONTAINS = 'notcontains';
    public static final String OPERATOR_ISNULL = 'isnull';

    public static final String ERROR_MAXIMUMFILTERREACHED = system.label.PRODIQ002_TAG057; //Maximum number of filter condition reached, please reduce the filter on technical attributes.'

}