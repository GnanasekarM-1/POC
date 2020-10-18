/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The APFT_Schema defines class structure to parse json string.
 * 
 *
 * @author Ramachandra Mohan
 * @version 16.39000
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      13 May 2016     Created. 
 *****************************************************************************************************/
public with sharing class APFT_Schema {
    
    public class Filters {
        
        public Set<String> wizards = new Set<String>();        
        public Set<String> sfms = new Set<String>();        
        public Set<String> sfactions = new Set<String>();
    }
}