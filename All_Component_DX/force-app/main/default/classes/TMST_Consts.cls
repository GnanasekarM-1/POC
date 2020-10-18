/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The TMST_Consts class includes all constants used accross different Timesheet
 * classes.
 *
 * @author Ramachandra Mohan
 * @version 15.39100
 * @since 2015
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              Ramachandra Mohan      28 Jan 2015     Created. 
 * 018085       Ramachandra Mohan      09 Jul 2015     Created new field for Max Integer Value.
 * 018085       Ramachandra Mohan      13 Jul 2015     Updated max integer value to 99 as field configured for length 2.
 * BAC-5189     Soumyaranjan Pati      9th Sept 2019   Configuration Profile Setting to Filter Which Users have Timesheets Processed
 * BAC-5411    Soumyaranjan Pati        9th Dec 2019    Created a new variable for Open
 *****************************************************************************/

public with sharing class TMST_Consts {

    /**
     * String static instance variable to hold record type 'Timesheet'.
     */
    public static final String RECORD_TYPE_TIMESHEET                = 'Timesheet';
    public static final String RECORD_TYPE_SCHEDULE                 = 'Schedule';
    public static final String RECORD_TYPE_TIMESHEET_ACCESS         = 'Timesheet Access';
    public static final String RECORD_TYPE_CONFIGURATION_PROFILE    = 'Configuration Profile';
    public static final String RECORD_TYPE_CONFIGURATION_ACCESS    = 'Configuration Access'; // Added for BAC-5189
    public static final String CONFIGURATION_TYPE_GROUP             = 'Group';
        
    public static final String SCHEDULE_TYPE_TIMESHEET_AUTOFILL     = 'TimesheetAutofill';
    public static final String SCHEDULE_TYPE_TIMESHEET_HEADER       = 'TimesheetHeader';
    public static final String STRING_OPEN = 'Open'; //Added for BAC-5411
    public static final string EVENT_TYPE_BOTH  = 'Both';
    
    public static final String NAMESPACE    = 'SVMXC__';    
    
    public static final String EMPTY          = '';
    public static final String COMMA          = ',';
    public static final String NEWLINE        = '\n';
    public static final String LINE_BREAK     = '<br>';
    public static final String SEMICOLON      = ';';
    
    public static final Integer MAX_BATCH_LIMIT = 5;
    public static final Integer MIN_DATE_VALUE          = 1;
    public static final Integer MAX_DATE_VALUE          = 31;
    public static final Integer MIN_TEXT_LENGTH         = 8;
    public static final Integer MAX_TEXT_LENGTH         = 255;
    public static final Integer MAX_LONG_TEXT_LENGTH    = 32000;
    public static final Integer MAX_INTEGER_VALUE       = 99;
    
    public static final Integer MIN_RUN_EVERY_DAY_VALUE         = 1;
    public static final Integer MAX_RUN_EVERY_DAY_VALUE         = 6;
    public static final Integer MIN_RUN_EVERY_WEEKLY_VALUE      = 1;
    public static final Integer MAX_RUN_EVERY_WEEKLY_VALUE      = 4;
    public static final Integer MIN_RUN_EVERY_MONTH_VALUE       = 1;
    public static final Integer MAX_RUN_EVERY_MONTH_VALUE       = 12;
    
    
        
    public static final String TMST001_TAG001    = 'TMST001_TAG001';
    public static final String TMST001_TAG002    = 'TMST001_TAG002';
    public static final String TMST001_TAG003    = 'TMST001_TAG003';
    public static final String TMST001_TAG004    = 'TMST001_TAG004';
    public static final String TMST001_TAG005    = 'TMST001_TAG005';
    public static final String TMST001_TAG006    = 'TMST001_TAG006';
    public static final String TMST001_TAG007    = 'TMST001_TAG007';
    public static final String TMST001_TAG008    = 'TMST001_TAG008';
    public static final String TMST001_TAG009    = 'TMST001_TAG009';
    public static final String TMST001_TAG010    = 'TMST001_TAG010';
    public static final String TMST001_TAG011    = 'TMST001_TAG011';
    public static final String TMST001_TAG012    = 'TMST001_TAG012';
    public static final String TMST001_TAG013    = 'TMST001_TAG013';
    public static final String TMST001_TAG014    = 'TMST001_TAG014';
    public static final String TMST001_TAG015    = 'TMST001_TAG015';
    public static final String TMST001_TAG016    = 'TMST001_TAG016';
    public static final String TMST001_TAG017    = 'TMST001_TAG017';
    public static final String TMST001_TAG018    = 'TMST001_TAG018';
    
    public static final String TMST001_TAG020    = 'TMST001_TAG020';
    public static final String TMST001_TAG021    = 'TMST001_TAG021';
    public static final String TMST001_TAG022    = 'TMST001_TAG022';
    public static final String TMST001_TAG023    = 'TMST001_TAG023';
    public static final String TMST001_TAG024    = 'TMST001_TAG024';
    public static final String TMST001_TAG025    = 'TMST001_TAG025';
    public static final String TMST001_TAG026    = 'TMST001_TAG026';
    public static final String TMST001_TAG027    = 'TMST001_TAG027';
    public static final String TMST001_TAG028    = 'TMST001_TAG028';
    public static final String TMST001_TAG029    = 'TMST001_TAG029';
    public static final String TMST001_TAG030    = 'TMST001_TAG030';
    
    public static final String PERIOD_DAILY        = 'Daily';
    public static final String PERIOD_WEEKLY       = 'Weekly';
    public static final String PERIOD_MONTHLY      = 'Monthly';
    public static final String PERIOD_BI_MONTHLY   = 'Bi-Monthly';
    
    public static final String RUN_TYPE_DAY_OF_WEEK    = 'Day of Week';
    public static final String RUN_TYPE_DATE_OF_MONTH  = 'Date of Month';
    
    public static final Map<String, String> PERIOD_RUN_TYPE_MAP = new Map<String, String> { 
        PERIOD_DAILY       => RUN_TYPE_DAY_OF_WEEK,
        PERIOD_WEEKLY      => RUN_TYPE_DAY_OF_WEEK, 
        PERIOD_MONTHLY     => RUN_TYPE_DATE_OF_MONTH,
        PERIOD_BI_MONTHLY  => RUN_TYPE_DATE_OF_MONTH 
    };
    
    public static final Map<Integer, String> WEEK_ID_TO_STRING_MAP = new Map<Integer, String> { 
        1 => 'Monday', 
        2 => 'Tuesday', 
        3 => 'Wednesday', 
        4 => 'Thursday', 
        5 => 'Friday', 
        6 => 'Saturday', 
        7 => 'Sunday'
    };
    
    public static final Map<String, Integer> WEEK_STRING_TO_ID_MAP = new Map<String, Integer> { 
        'Monday'     => 1,
        'Tuesday'    => 2, 
        'Wednesday'  => 3, 
        'Thursday'   => 4, 
        'Friday'     => 5, 
        'Saturday'   => 6, 
        'Sunday'     => 7
    };
    
    public static final Map<Integer, String> TIMEAT_ID_TO_STRING_MAP = new Map<Integer, String> {
        1 => '12:00 AM', 2 => '1:00 AM', 3 => '2:00 AM', 4 => '3:00 AM', 5  => '4:00 AM', 
        6 => '5:00 AM',  7 => '6:00 AM', 8 => '7:00 AM', 9 => '8:00 AM', 10 => '9:00 AM', 
        11 => '10:00 AM', 12 => '11:00 AM', 13 => '12:00 PM', 14 => '1:00 PM', 15 => '2:00 PM',
        16 => '3:00 PM', 17 => '4:00 PM', 18 => '5:00 PM', 19 => '6:00 PM', 20 => '7:00 PM', 21 => '8:00 PM', 
        22 => '9:00 PM', 23 => '10:00 PM', 24 => '11:00 PM'
    };
    
    public static final Map<String, Integer> TIMEAT_STRING_TO_ID_MAP = new Map<String, Integer> { 
        '12:00 AM' => 1, '1:00 AM' => 2, '2:00 AM' => 3, '3:00 AM' => 4, '4:00 AM' => 5, 
        '5:00 AM'  => 6, '6:00 AM' => 7, '7:00 AM' => 8, '8:00 AM' => 9, '9:00 AM' => 10, 
        '10:00 AM' => 11, '11:00 AM' => 12, '12:00 PM' => 13, '1:00 PM' => 14, '2:00 PM' => 15,
        '3:00 PM' => 16, '4:00 PM' => 17, '5:00 PM' => 18, '6:00 PM' => 19, '7:00 PM' => 20, '8:00 PM' => 21, 
        '9:00 PM' => 22, '10:00 PM' => 23, '11:00 PM' => 24
    };
}