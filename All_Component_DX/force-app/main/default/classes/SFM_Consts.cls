/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The SFM_Consts class includes all constants used accross SFM services.
 * classes.
 *
 * @author Ramachandra Mohan
 * @version 15.39100
 * @since 2015
 */
/*****************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************
 *              Ramachandra Mohan       10 Jun 2015     Created. 
 *  SFMDZ-684   Ramachandra Mohan       24 Jul 2018     Added current record consts.
 *****************************************************************************/

public with sharing class SFM_Consts {
    
    public static final Integer MIN_TEXT_LENGTH         = 8;
    public static final Integer MAX_TEXT_LENGTH         = 255;
    public static final Integer MAX_PROCESSID_LENGTH    = 50;    
    
    public static final String ACTION_TYPE_SET_VALUE        = 'Set Value';
    public static final String ACTION_TYPE_SET_ATTRIBUTE    = 'Set Attribute';
        
    public static final String KEY_RECORD_ID                = 'RECORDID';
    public static final String KEY_PROCESS_ID               = 'PROCESSID';
    public static final String KEY_ALIAS_NAME               = 'ALIASNAME';
    public static final String KEY_OBJECT_API_NAME          = 'OBJECTAPINAME';
    public static final String KEY_FIELD_UPDATE_RULE_IDS    = 'FIELDUPDATERULEIDS';
    
    public static final String EXPRESSION_TYPE_FIELD_UPDATE_RULE = 'Field_Update_Rule';
    
    public static final String RECORD_TYPE_BUSINESS_RULE            = 'Business Rule';
    public static final String RECORD_TYPE_FIELD_UPDATES            = 'Field Updates';    
    public static final String RECORD_TYPE_PROCESS_BUSINESS_RULE    = 'Process Business Rule';
    
    public static final String RULE_TYPE_FIELD_UPDATE_RULE      = 'Field Update Rule';

    public static final String SVMX_CURRENT_RECORD              = 'SVMX.CURRENTRECORD';
    public static final String SVMX_CURRENT_RECORD_HEADER       = 'SVMX.CURRENTRECORDHEADER';
    public static final String CURRENT_RECORD                   = 'CURRENTRECORD';
    public static final String CURRENT_RECORD_HEADER            = 'CURRENTRECORDHEADER';
    public static final String CURRENT_RECORD_FUNCTION          = 'Current Record';
    public static final String CURRENT_RECORD_HEADER_FUNCTION   = 'Current Record Header';
    public static final String USERTRUNK                        = 'User Trunk';
    public static final String SVMX_USERTRUNK                   = 'SVMX.USERTRUNK';
    public static final String CURRENTUSER                      = 'Current User';
    public static final String SVMX_CURRENTUSER                 = 'SVMX.CURRENTUSERID';
    public static final String SVMX_NOW                         = 'SVMX.NOW';
    public static final String OWNER                            = 'Owner';
    public static final String SVMX_OWNER                       = 'SVMX.OWNER';
    public static final String NOW                              = 'Now';
    public static final String TODAY                            = 'Today';
    public static final String TOMORROW                         = 'Tomorrow';
    public static final String YESTERDAY                        = 'Yesterday';
    public static final String SETNULL                          = 'NULL';
    public static final String SVMX_SETNULL                     = 'SVMX.SETNULL';
    public static final String OUTPUT_DOCUMENT 					= 'OUTPUT DOCUMENT' ;
    public static final String CHECKLIST 						= 'CHECKLIST' ;
}