public with sharing class COMM_SVMXC_Utils3 
{
    boolean isUpdateSuccess = true;
    public COMM_SVMXC_Utils3()
    {
        
    }
    public COMM_SVMXC_Utils3(Boolean IsTags)
    {
        if(IsTags)
        {
            //Naveen:replaced all the tags with custom labels
            //tagTextMap  = comTagUtils.SVMX_getTagList('INVT001');
            tagTextMap.put('HLPURL',System.Label.INVT001_HLPURL);
            tagTextMap.put('TAG001',System.Label.INVT001_TAG001);
            tagTextMap.put('TAG002',System.Label.INVT001_TAG002);
            tagTextMap.put('TAG003',System.Label.INVT001_TAG003);
            tagTextMap.put('TAG004',System.Label.INVT001_TAG004);
            tagTextMap.put('TAG005',System.Label.INVT001_TAG005);
            tagTextMap.put('TAG006',System.Label.INVT001_TAG006);
            tagTextMap.put('TAG007',System.Label.INVT001_TAG007);
            tagTextMap.put('TAG008',System.Label.INVT001_TAG008);
            tagTextMap.put('TAG009',System.Label.INVT001_TAG009);
            tagTextMap.put('TAG010',System.Label.INVT001_TAG010);
            tagTextMap.put('TAG011',System.Label.INVT001_TAG011);
            tagTextMap.put('TAG012',System.Label.INVT001_TAG012);
            tagTextMap.put('TAG013',System.Label.INVT001_TAG013);
            tagTextMap.put('TAG014',System.Label.INVT001_TAG014);
            tagTextMap.put('TAG015',System.Label.INVT001_TAG015);
            tagTextMap.put('TAG016',System.Label.INVT001_TAG016);
            tagTextMap.put('TAG017',System.Label.INVT001_TAG017);
            tagTextMap.put('TAG018',System.Label.INVT001_TAG018);
            tagTextMap.put('TAG019',System.Label.INVT001_TAG019);
            tagTextMap.put('TAG020',System.Label.INVT001_TAG020);
            tagTextMap.put('TAG021',System.Label.INVT001_TAG021);
            tagTextMap.put('TAG022',System.Label.INVT001_TAG022);
            tagTextMap.put('TAG023',System.Label.INVT001_TAG023);
            tagTextMap.put('TAG024',System.Label.INVT001_TAG024);
            tagTextMap.put('TAG025',System.Label.INVT001_TAG025);
            tagTextMap.put('TAG026',System.Label.INVT001_TAG026);
            tagTextMap.put('TAG027',System.Label.INVT001_TAG027);
            tagTextMap.put('TAG028',System.Label.INVT001_TAG028);
            tagTextMap.put('TAG029',System.Label.INVT001_TAG029);
            tagTextMap.put('TAG030',System.Label.INVT001_TAG030);
            tagTextMap.put('TAG031',System.Label.INVT001_TAG031);
            tagTextMap.put('TAG032',System.Label.INVT001_TAG032);
            tagTextMap.put('TAG033',System.Label.INVT001_TAG033);
            tagTextMap.put('TAG034',System.Label.INVT001_TAG034);
            tagTextMap.put('TAG035',System.Label.INVT001_TAG035);
            tagTextMap.put('TAG036',System.Label.INVT001_TAG036);
            tagTextMap.put('TAG037',System.Label.INVT001_TAG037);
            tagTextMap.put('TAG038',System.Label.INVT001_TAG038);
            tagTextMap.put('TAG039',System.Label.INVT001_TAG039);
            tagTextMap.put('TAG040',System.Label.INVT001_TAG040);
            tagTextMap.put('TAG041',System.Label.INVT001_TAG041);
            tagTextMap.put('TAG042',System.Label.INVT001_TAG042);
            tagTextMap.put('TAG043',System.Label.INVT001_TAG043);
            tagTextMap.put('TAG044',System.Label.INVT001_TAG044);
            tagTextMap.put('TAG045',System.Label.INVT001_TAG045);
            tagTextMap.put('TAG046',System.Label.INVT001_TAG046);
            tagTextMap.put('TAG047',System.Label.INVT001_TAG047);
            tagTextMap.put('TAG048',System.Label.INVT001_TAG048);
            tagTextMap.put('TAG049',System.Label.INVT001_TAG049);
            tagTextMap.put('TAG050',System.Label.INVT001_TAG050);
            tagTextMap.put('TAG051',System.Label.INVT001_TAG051);
            tagTextMap.put('TAG052',System.Label.INVT001_TAG052);
            tagTextMap.put('TAG053',System.Label.INVT001_TAG053);
            tagTextMap.put('TAG054',System.Label.INVT001_TAG054);
            tagTextMap.put('TAG055',System.Label.INVT001_TAG055);
            tagTextMap.put('TAG056',System.Label.INVT001_TAG056);
            tagTextMap.put('TAG057',System.Label.INVT001_TAG057);
            tagTextMap.put('TAG058',System.Label.INVT001_TAG058);
            tagTextMap.put('TAG062',System.Label.INVT001_TAG062); 
            tagTextMap.put('TAG063',System.Label.INVT001_TAG063);   

            //Added by Nidhi - Custom Label for New Inventory And BAtch
            tagTextMap.put('TAG083',System.Label.INVT001_TAG083);
            tagTextMap.put('TAG084',System.Label.INVT001_TAG084);
            tagTextMap.put('TAG085',System.Label.INVT001_TAG085);
            tagTextMap.put('TAG086',System.Label.INVT001_TAG086); 
            tagTextMap.put('TAG087',System.Label.INVT001_TAG087);
            tagTextMap.put('TAG088',System.Label.INVT001_TAG088);
            tagTextMap.put('TAG089',System.Label.INVT001_TAG089);
            tagTextMap.put('TAG090',System.Label.INVT001_TAG090);
            tagTextMap.put('TAG091',System.Label.INVT001_TAG091); 
            tagTextMap.put('TAG092',System.Label.INVT001_TAG092);
            tagTextMap.put('TAG093',System.Label.INVT001_TAG093);
            tagTextMap.put('TAG094',System.Label.INVT001_TAG094);
            tagTextMap.put('TAG095',System.Label.INVT001_TAG095);
            tagTextMap.put('TAG096',System.Label.INVT001_TAG096); 
            tagTextMap.put('TAG097',System.Label.INVT001_TAG097);
            tagTextMap.put('TAG098',System.Label.INVT001_TAG098);
            tagTextMap.put('TAG099',System.Label.INVT001_TAG099);
            tagTextMap.put('TAG100',System.Label.INVT001_TAG100);
            tagTextMap.put('TAG101',System.Label.INVT001_TAG101);
            tagTextMap.put('TAG103',System.Label.INVT001_TAG103);
            tagTextMap.put('TAG104',System.Label.INVT001_TAG104);
            tagTextMap.put('TAG107',System.Label.INVT001_TAG107);//Placeholder tags
            tagTextMap.put('TAG108',System.Label.INVT001_TAG108);
            tagTextMap.put('TAG109',System.Label.INVT001_TAG109);
            tagTextMap.put('TAG110',System.Label.INVT001_TAG110);
            
            //Use at server side for new invetory and batch lot
            tagTextMap.put('TAG102',System.Label.INVT001_TAG102);
            tagTextMap.put('TAG105',System.Label.INVT001_TAG105);//Added for BAC-6127
            tagTextMap.put('TAG106',System.Label.INVT001_TAG106);//Added for BAC-6152
        }
    }
    public COMM_SVMXC_Utils3(string strSubModuleID)
    {
        if(strSubModuleID != null && strSubModuleID.length() > 0)
        {
            //Naveen:replaced all the tags with custom labels
            //tagTextMap  = comTagUtils.SVMX_getTagList(strSubModuleID);
            if (strSubModuleID == 'CONF009')
            {
                tagTextMap.put('HLPURL',System.Label.CONF009_HLPURL);
                tagTextMap.put('TAG001',System.Label.CONF009_TAG001);
                tagTextMap.put('TAG002',System.Label.CONF009_TAG002);
                tagTextMap.put('TAG003',System.Label.CONF009_TAG003);
                tagTextMap.put('TAG004',System.Label.CONF009_TAG004);
                tagTextMap.put('TAG005',System.Label.CONF009_TAG005);
                tagTextMap.put('TAG006',System.Label.CONF009_TAG006);
                tagTextMap.put('TAG007',System.Label.CONF009_TAG007);
                tagTextMap.put('TAG008',System.Label.CONF009_TAG008);
                tagTextMap.put('TAG009',System.Label.CONF009_TAG009);
                tagTextMap.put('TAG010',System.Label.CONF009_TAG010);
                tagTextMap.put('TAG011',System.Label.CONF009_TAG011);
                tagTextMap.put('TAG012',System.Label.CONF009_TAG012);
                tagTextMap.put('TAG013',System.Label.CONF009_TAG013);
                tagTextMap.put('TAG014',System.Label.CONF009_TAG014);
                tagTextMap.put('TAG015',System.Label.CONF009_TAG015);
                tagTextMap.put('TAG016',System.Label.CONF009_TAG016);
                tagTextMap.put('TAG017',System.Label.CONF009_TAG017);
                tagTextMap.put('TAG018',System.Label.CONF009_TAG018);
                tagTextMap.put('TAG019',System.Label.CONF009_TAG019);
                tagTextMap.put('TAG020',System.Label.CONF009_TAG020);
                tagTextMap.put('TAG021',System.Label.CONF009_TAG021);
                tagTextMap.put('TAG022',System.Label.CONF009_TAG022);
                tagTextMap.put('TAG023',System.Label.CONF009_TAG023);              
            }else if (strSubModuleID == 'CONF010')
            {
            tagTextMap.put('HLPURL',System.Label.CONF010_HLPURL);
            tagTextMap.put('TAG001',System.Label.CONF010_TAG001);
            tagTextMap.put('TAG002',System.Label.CONF010_TAG002);
            tagTextMap.put('TAG003',System.Label.CONF010_TAG003);
            tagTextMap.put('TAG004',System.Label.CONF010_TAG004);
            tagTextMap.put('TAG005',System.Label.CONF010_TAG005);
            tagTextMap.put('TAG006',System.Label.CONF010_TAG006);
            tagTextMap.put('TAG007',System.Label.CONF010_TAG007);
            tagTextMap.put('TAG008',System.Label.CONF010_TAG008);
            tagTextMap.put('TAG009',System.Label.CONF010_TAG009);
            tagTextMap.put('TAG010',System.Label.CONF010_TAG010);
            tagTextMap.put('TAG011',System.Label.CONF010_TAG011);
            tagTextMap.put('TAG012',System.Label.CONF010_TAG012);
            tagTextMap.put('TAG013',System.Label.CONF010_TAG013);
            tagTextMap.put('TAG014',System.Label.CONF010_TAG014);
            tagTextMap.put('TAG015',System.Label.CONF010_TAG015);
            tagTextMap.put('TAG016',System.Label.CONF010_TAG016);
            tagTextMap.put('TAG017',System.Label.CONF010_TAG017);
            tagTextMap.put('TAG018',System.Label.CONF010_TAG018);
            tagTextMap.put('TAG019',System.Label.CONF010_TAG019);
            tagTextMap.put('TAG020',System.Label.CONF010_TAG020);
            tagTextMap.put('TAG021',System.Label.CONF010_TAG021);
            tagTextMap.put('TAG022',System.Label.CONF010_TAG022);
            tagTextMap.put('TAG023',System.Label.CONF010_TAG023);
            tagTextMap.put('TAG024',System.Label.CONF010_TAG024);
            tagTextMap.put('TAG025',System.Label.CONF010_TAG025);
            tagTextMap.put('TAG026',System.Label.CONF010_TAG026);
            tagTextMap.put('TAG027',System.Label.CONF010_TAG027);
            tagTextMap.put('TAG028',System.Label.CONF010_TAG028);
            tagTextMap.put('TAG029',System.Label.CONF010_TAG029);
            tagTextMap.put('TAG030',System.Label.CONF010_TAG030);
            tagTextMap.put('TAG031',System.Label.CONF010_TAG031);
            tagTextMap.put('TAG032',System.Label.CONF010_TAG032);
            tagTextMap.put('TAG033',System.Label.CONF010_TAG033);
            tagTextMap.put('TAG034',System.Label.CONF010_TAG034);
            tagTextMap.put('TAG035',System.Label.CONF010_TAG035);
            tagTextMap.put('TAG036',System.Label.CONF010_TAG036);
            tagTextMap.put('TAG037',System.Label.CONF010_TAG037);
            tagTextMap.put('TAG038',System.Label.CONF010_TAG038);
            tagTextMap.put('TAG039',System.Label.CONF010_TAG039);
            tagTextMap.put('TAG040',System.Label.CONF010_TAG040);
            tagTextMap.put('TAG041',System.Label.CONF010_TAG041);
            tagTextMap.put('TAG042',System.Label.CONF010_TAG042);
            tagTextMap.put('TAG043',System.Label.CONF010_TAG043);
            tagTextMap.put('TAG044',System.Label.CONF010_TAG044);
            tagTextMap.put('TAG045',System.Label.CONF010_TAG045);
            tagTextMap.put('TAG046',System.Label.CONF010_TAG046);
            tagTextMap.put('TAG047',System.Label.CONF010_TAG047);
            tagTextMap.put('TAG048',System.Label.CONF010_TAG048);
            tagTextMap.put('TAG049',System.Label.CONF010_TAG049);
            tagTextMap.put('TAG050',System.Label.CONF010_TAG050);
            tagTextMap.put('TAG051',System.Label.CONF010_TAG051);
            tagTextMap.put('TAG052',System.Label.CONF010_TAG052);
            tagTextMap.put('TAG053',System.Label.CONF010_TAG053);
            tagTextMap.put('TAG054',System.Label.CONF010_TAG054);
            tagTextMap.put('TAG055',System.Label.CONF010_TAG055);
            tagTextMap.put('TAG056',System.Label.CONF010_TAG056);
            tagTextMap.put('TAG057',System.Label.CONF010_TAG057);
            tagTextMap.put('TAG058',System.Label.CONF010_TAG058);
            tagTextMap.put('TAG059',System.Label.CONF010_TAG059);
            tagTextMap.put('TAG060',System.Label.CONF010_TAG060);
            tagTextMap.put('TAG061',System.Label.CONF010_TAG061);
            tagTextMap.put('TAG062',System.Label.CONF010_TAG062);
            tagTextMap.put('TAG063',System.Label.CONF010_TAG063);
            tagTextMap.put('TAG064',System.Label.CONF010_TAG064);
            tagTextMap.put('TAG065',System.Label.CONF010_TAG065);
            tagTextMap.put('TAG066',System.Label.CONF010_TAG066);
            //tagTextMap.put('TAG067',System.Label.CONF010_TAG067);
            tagTextMap.put('TAG068',System.Label.CONF010_TAG068);
            //tagTextMap.put('TAG069',System.Label.CONF010_TAG069);
            tagTextMap.put('TAG070',System.Label.CONF010_TAG070);
            tagTextMap.put('TAG071',System.Label.CONF010_TAG071);
            tagTextMap.put('TAG072',System.Label.CONF010_TAG072);
            //tagTextMap.put('TAG073',System.Label.CONF010_TAG073);
            tagTextMap.put('TAG074',System.Label.CONF010_TAG074);
            tagTextMap.put('TAG075',System.Label.CONF010_TAG075);
            tagTextMap.put('TAG076',System.Label.CONF010_TAG076);
            //tagTextMap.put('TAG077',System.Label.CONF010_TAG077);
            tagTextMap.put('TAG078',System.Label.CONF010_TAG078);
            tagTextMap.put('TAG079',System.Label.CONF010_TAG079);
            tagTextMap.put('TAG080',System.Label.CONF010_TAG080);
            //tagTextMap.put('TAG081',System.Label.CONF010_TAG081);
            tagTextMap.put('TAG082',System.Label.CONF010_TAG082);
            tagTextMap.put('TAG083',System.Label.CONF010_TAG083);
            tagTextMap.put('TAG084',System.Label.CONF010_TAG084);
            /*
            tagTextMap.put('TAG085',System.Label.CONF010_TAG085);
            tagTextMap.put('TAG086',System.Label.CONF010_TAG086);
            tagTextMap.put('TAG087',System.Label.CONF010_TAG087);
            tagTextMap.put('TAG088',System.Label.CONF010_TAG088);
            tagTextMap.put('TAG089',System.Label.CONF010_TAG089);
            tagTextMap.put('TAG090',System.Label.CONF010_TAG090);
            tagTextMap.put('TAG091',System.Label.CONF010_TAG091);
            */
            tagTextMap.put('TAG092',System.Label.CONF010_TAG092);
            tagTextMap.put('TAG093',System.Label.CONF010_TAG093);
            //tagTextMap.put('TAG094',System.Label.CONF010_TAG094);
            tagTextMap.put('TAG095',System.Label.CONF010_TAG095);
            tagTextMap.put('TAG096',System.Label.CONF010_TAG096);
            tagTextMap.put('TAG097',System.Label.CONF010_TAG097);
            tagTextMap.put('TAG098',System.Label.CONF010_TAG098);
            tagTextMap.put('TAG099',System.Label.CONF010_TAG099);
            tagTextMap.put('TAG100',System.Label.CONF010_TAG100);
            tagTextMap.put('TAG101',System.Label.CONF010_TAG101);
            tagTextMap.put('TAG102',System.Label.CONF010_TAG102);
            tagTextMap.put('TAG103',System.Label.CONF010_TAG103);
            tagTextMap.put('TAG104',System.Label.CONF010_TAG104);
            tagTextMap.put('TAG105',System.Label.CONF010_TAG105);
            tagTextMap.put('TAG106',System.Label.CONF010_TAG106);
            tagTextMap.put('TAG107',System.Label.CONF010_TAG107);
            tagTextMap.put('TAG108',System.Label.CONF010_TAG108);
            tagTextMap.put('TAG109',System.Label.CONF010_TAG109);
            tagTextMap.put('TAG110',System.Label.CONF010_TAG110);
            tagTextMap.put('TAG111',System.Label.CONF010_TAG111);
            tagTextMap.put('TAG112',System.Label.CONF010_TAG112);
            tagTextMap.put('TAG113',System.Label.CONF010_TAG113);
            tagTextMap.put('TAG114',System.Label.CONF010_TAG114);
            tagTextMap.put('TAG115',System.Label.CONF010_TAG115);
            tagTextMap.put('TAG116',System.Label.CONF010_TAG116);
            tagTextMap.put('TAG117',System.Label.CONF010_TAG117);
            tagTextMap.put('TAG118',System.Label.CONF010_TAG118);
            tagTextMap.put('TAG119',System.Label.CONF010_TAG119);
            tagTextMap.put('TAG120',System.Label.CONF010_TAG120);
            tagTextMap.put('TAG121',System.Label.CONF010_TAG121);
            tagTextMap.put('TAG122',System.Label.CONF010_TAG122);
            tagTextMap.put('TAG123',System.Label.CONF010_TAG123);
            tagTextMap.put('TAG124',System.Label.CONF010_TAG124);
            tagTextMap.put('TAG125',System.Label.CONF010_TAG125);
            tagTextMap.put('TAG126',System.Label.CONF010_TAG126);
            tagTextMap.put('TAG127',System.Label.CONF010_TAG127);
            tagTextMap.put('TAG128',System.Label.CONF010_TAG128);
            tagTextMap.put('TAG129',System.Label.CONF010_TAG129);
            tagTextMap.put('TAG130',System.Label.CONF010_TAG130);
            tagTextMap.put('TAG131',System.Label.CONF010_TAG131);
            tagTextMap.put('TAG132',System.Label.CONF010_TAG132);
            tagTextMap.put('TAG133',System.Label.CONF010_TAG133);
            tagTextMap.put('TAG134',System.Label.CONF010_TAG134);
            tagTextMap.put('TAG135',System.Label.CONF010_TAG135);
            tagTextMap.put('TAG136',System.Label.CONF010_TAG136);
            tagTextMap.put('TAG137',System.Label.CONF010_TAG137);
            tagTextMap.put('TAG138',System.Label.CONF010_TAG138);
            tagTextMap.put('TAG139',System.Label.CONF010_TAG139);
            tagTextMap.put('TAG140',System.Label.CONF010_TAG140);
            tagTextMap.put('TAG141',System.Label.CONF010_TAG141);
            tagTextMap.put('TAG142',System.Label.CONF010_TAG142);
            tagTextMap.put('TAG143',System.Label.CONF010_TAG143);
            tagTextMap.put('TAG144',System.Label.CONF010_TAG144);
            tagTextMap.put('TAG145',System.Label.CONF010_TAG145);
            tagTextMap.put('TAG146',System.Label.CONF010_TAG146);
            tagTextMap.put('TAG147',System.Label.CONF010_TAG147);
            tagTextMap.put('TAG148',System.Label.CONF010_TAG148);
            tagTextMap.put('TAG149',System.Label.CONF010_TAG149);
            tagTextMap.put('TAG150',System.Label.CONF010_TAG150);
            tagTextMap.put('TAG151',System.Label.CONF010_TAG151);
            tagTextMap.put('TAG152',System.Label.CONF010_TAG152);
            tagTextMap.put('TAG153',System.Label.CONF010_TAG153);
            tagTextMap.put('TAG154',System.Label.CONF010_TAG154);
            tagTextMap.put('TAG155',System.Label.CONF010_TAG155);
            tagTextMap.put('TAG156',System.Label.CONF010_TAG156);
            tagTextMap.put('TAG157',System.Label.CONF010_TAG157);
            tagTextMap.put('TAG158',System.Label.CONF010_TAG158);
            tagTextMap.put('TAG159',System.Label.CONF010_TAG159);
            tagTextMap.put('TAG160',System.Label.CONF010_TAG160);
            tagTextMap.put('TAG161',System.Label.CONF010_TAG161);
            tagTextMap.put('TAG162',System.Label.CONF010_TAG162);
            tagTextMap.put('TAG163',System.Label.CONF010_TAG163);
            tagTextMap.put('TAG164',System.Label.CONF010_TAG164);
            tagTextMap.put('TAG165',System.Label.CONF010_TAG165);
            tagTextMap.put('TAG168',System.Label.CONF010_TAG168); //Added for BAC-5625
            tagTextMap.put('TAG169',System.Label.CONF010_TAG169); //Added for BAC-5625
            
            }
        }
        
    }
    //public SVMXC.COMM_Utils_ManageTags comTagUtils = new SVMXC.COMM_Utils_ManageTags();
    public Map<String, String> tagTextMap  = new Map<String, String>();
    public String getHLPURL() {return tagTextMap.containsKey('HLPURL')?tagTextMap.get('HLPURL') : '';}
    public String getTAG001() {return tagTextMap.containsKey('TAG001')?tagTextMap.get('TAG001') : '';}
    public String getTAG002() {return tagTextMap.containsKey('TAG002')?tagTextMap.get('TAG002') : '';}
    public String getTAG003() {return tagTextMap.containsKey('TAG003')?tagTextMap.get('TAG003') : '';}
    public String getTAG004() {return tagTextMap.containsKey('TAG004')?tagTextMap.get('TAG004') : '';}
    public String getTAG005() {return tagTextMap.containsKey('TAG005')?tagTextMap.get('TAG005') : '';}
    public String getTAG006() {return tagTextMap.containsKey('TAG006')?tagTextMap.get('TAG006') : '';}
    public String getTAG007() {return tagTextMap.containsKey('TAG007')?tagTextMap.get('TAG007') : '';}
    public String getTAG008() {return tagTextMap.containsKey('TAG008')?tagTextMap.get('TAG008') : '';}
    public String getTAG009() {return tagTextMap.containsKey('TAG009')?tagTextMap.get('TAG009') : '';}
    public String getTAG010() {return tagTextMap.containsKey('TAG010')?tagTextMap.get('TAG010') : '';}
    public String getTAG011() {return tagTextMap.containsKey('TAG011')?tagTextMap.get('TAG011') : '';}
    public String getTAG012() {return tagTextMap.containsKey('TAG012')?tagTextMap.get('TAG012') : '';}
    public String getTAG013() {return tagTextMap.containsKey('TAG013')?tagTextMap.get('TAG013') : '';}
    public String getTAG014() {return tagTextMap.containsKey('TAG014')?tagTextMap.get('TAG014') : '';}
    public String getTAG015() {return tagTextMap.containsKey('TAG015')?tagTextMap.get('TAG015') : '';}
    public String getTAG016() {return tagTextMap.containsKey('TAG016')?tagTextMap.get('TAG016') : '';}
    public String getTAG017() {return tagTextMap.containsKey('TAG017')?tagTextMap.get('TAG017') : '';}
    public String getTAG018() {return tagTextMap.containsKey('TAG018')?tagTextMap.get('TAG018') : '';}
    public String getTAG019() {return tagTextMap.containsKey('TAG019')?tagTextMap.get('TAG019') : '';}
    public String getTAG020() {return tagTextMap.containsKey('TAG020')?tagTextMap.get('TAG020') : '';}
    public String getTAG021() {return tagTextMap.containsKey('TAG021')?tagTextMap.get('TAG021') : '';}
    public String getTAG022() {return tagTextMap.containsKey('TAG022')?tagTextMap.get('TAG022') : '';}
    public String getTAG023() {return tagTextMap.containsKey('TAG023')?tagTextMap.get('TAG023') : '';}
    public String getTAG024() {return tagTextMap.containsKey('TAG024')?tagTextMap.get('TAG024') : '';}
    public String getTAG025() {return tagTextMap.containsKey('TAG025')?tagTextMap.get('TAG025') : '';}
    public String getTAG026() {return tagTextMap.containsKey('TAG026')?tagTextMap.get('TAG026') : '';}
    public String getTAG027() {return tagTextMap.containsKey('TAG027')?tagTextMap.get('TAG027') : '';}
    public String getTAG028() {return tagTextMap.containsKey('TAG028')?tagTextMap.get('TAG028') : '';}
    public String getTAG029() {return tagTextMap.containsKey('TAG029')?tagTextMap.get('TAG029') : '';}
    public String getTAG030() {return tagTextMap.containsKey('TAG030')?tagTextMap.get('TAG030') : '';}
    public String getTAG031() {return tagTextMap.containsKey('TAG031')?tagTextMap.get('TAG031') : '';}
    public String getTAG032() {return tagTextMap.containsKey('TAG032')?tagTextMap.get('TAG032') : '';}
    public String getTAG033() {return tagTextMap.containsKey('TAG033')?tagTextMap.get('TAG033') : '';}
    public String getTAG034() {return tagTextMap.containsKey('TAG034')?tagTextMap.get('TAG034') : '';}
    public String getTAG035() {return tagTextMap.containsKey('TAG035')?tagTextMap.get('TAG035') : '';}
    public String getTAG036() {return tagTextMap.containsKey('TAG036')?tagTextMap.get('TAG036') : '';}
    public String getTAG037() {return tagTextMap.containsKey('TAG037')?tagTextMap.get('TAG037') : '';}
    public String getTAG038() {return tagTextMap.containsKey('TAG038')?tagTextMap.get('TAG038') : '';}
    public String getTAG039() {return tagTextMap.containsKey('TAG039')?tagTextMap.get('TAG039') : '';}
    public String getTAG040() {return tagTextMap.containsKey('TAG040')?tagTextMap.get('TAG040') : '';}
    public String getTAG041() {return tagTextMap.containsKey('TAG041')?tagTextMap.get('TAG041') : '';}
    public String getTAG042() {return tagTextMap.containsKey('TAG042')?tagTextMap.get('TAG042') : '';}
    public String getTAG043() {return tagTextMap.containsKey('TAG043')?tagTextMap.get('TAG043') : '';}
    public String getTAG044() {return tagTextMap.containsKey('TAG044')?tagTextMap.get('TAG044') : '';}
    public String getTAG045() {return tagTextMap.containsKey('TAG045')?tagTextMap.get('TAG045') : '';}
    public String getTAG046() {return tagTextMap.containsKey('TAG046')?tagTextMap.get('TAG046') : '';}
    public String getTAG047() {return tagTextMap.containsKey('TAG047')?tagTextMap.get('TAG047') : '';}
    public String getTAG048() {return tagTextMap.containsKey('TAG048')?tagTextMap.get('TAG048') : '';}
    public String getTAG049() {return tagTextMap.containsKey('TAG049')?tagTextMap.get('TAG049') : '';}
    public String getTAG050() {return tagTextMap.containsKey('TAG050')?tagTextMap.get('TAG050') : '';}
    public String getTAG051() {return tagTextMap.containsKey('TAG051')?tagTextMap.get('TAG051') : '';}
    public String getTAG052() {return tagTextMap.containsKey('TAG052')?tagTextMap.get('TAG052') : '';}
    public String getTAG053() {return tagTextMap.containsKey('TAG053')?tagTextMap.get('TAG053') : '';}
    public String getTAG054() {return tagTextMap.containsKey('TAG054')?tagTextMap.get('TAG054') : '';}
    public String getTAG055() {return tagTextMap.containsKey('TAG055')?tagTextMap.get('TAG055') : '';}
    public String getTAG056() {return tagTextMap.containsKey('TAG056')?tagTextMap.get('TAG056') : '';}
    public String getTAG057() {return tagTextMap.containsKey('TAG057')?tagTextMap.get('TAG057') : '';}
    public String getTAG058() {return tagTextMap.containsKey('TAG058')?tagTextMap.get('TAG058') : '';}
    public String getTAG059() {return tagTextMap.containsKey('TAG059')?tagTextMap.get('TAG059') : '';} 
    public String getTAG060() {return tagTextMap.containsKey('TAG060')?tagTextMap.get('TAG060') : '';} 
    public String getTAG061() {return tagTextMap.containsKey('TAG061')?tagTextMap.get('TAG061') : '';} 
    public String getTAG062() {return tagTextMap.containsKey('TAG062')?tagTextMap.get('TAG062') : '';}
    public String getTAG063() {return tagTextMap.containsKey('TAG063')?tagTextMap.get('TAG063') : '';} 
    public String getTAG064() {return tagTextMap.containsKey('TAG064')?tagTextMap.get('TAG064') : '';}
    public String getTAG065() {return tagTextMap.containsKey('TAG065')?tagTextMap.get('TAG065') : '';}
    public String getTAG066() {return tagTextMap.containsKey('TAG066')?tagTextMap.get('TAG066') : '';} 
    //public String getTAG067() {return tagTextMap.containsKey('TAG067')?tagTextMap.get('TAG067') : '';} 
    public String getTAG068() {return tagTextMap.containsKey('TAG068')?tagTextMap.get('TAG068') : '';} 
    public String getTAG069() {return tagTextMap.containsKey('TAG069')?tagTextMap.get('TAG069') : '';}
    public String getTAG070() {return tagTextMap.containsKey('TAG070')?tagTextMap.get('TAG070') : '';}       
    public String getTAG071() {return tagTextMap.containsKey('TAG071')?tagTextMap.get('TAG071') : '';} 
    public String getTAG072() {return tagTextMap.containsKey('TAG072')?tagTextMap.get('TAG072') : '';} 
    public String getTAG073() {return tagTextMap.containsKey('TAG072')?tagTextMap.get('TAG072') : '';}
    public String getTAG074() {return tagTextMap.containsKey('TAG074')?tagTextMap.get('TAG074') : '';} 
    public String getTAG075() {return tagTextMap.containsKey('TAG075')?tagTextMap.get('TAG075') : '';}
    public String getTAG076() {return tagTextMap.containsKey('TAG076')?tagTextMap.get('TAG076') : '';} 
    //public String getTAG077() {return tagTextMap.containsKey('TAG077')?tagTextMap.get('TAG077') : '';} 
    public String getTAG078() {return tagTextMap.containsKey('TAG078')?tagTextMap.get('TAG078') : '';} 
    public String getTAG079() {return tagTextMap.containsKey('TAG079')?tagTextMap.get('TAG079') : '';} 
    public String getTAG080() {return tagTextMap.containsKey('TAG080')?tagTextMap.get('TAG080') : '';} 
    //public String getTAG081() {return tagTextMap.containsKey('TAG081')?tagTextMap.get('TAG081') : '';} 
    public String getTAG082() {return tagTextMap.containsKey('TAG082')?tagTextMap.get('TAG082') : '';} 
    public String getTAG083() {return tagTextMap.containsKey('TAG083')?tagTextMap.get('TAG083') : '';} 
    public String getTAG084() {return tagTextMap.containsKey('TAG084')?tagTextMap.get('TAG084') : '';} 
    /*
    public String getTAG085() {return tagTextMap.containsKey('TAG085')?tagTextMap.get('TAG085') : '';} 
    public String getTAG086() {return tagTextMap.containsKey('TAG086')?tagTextMap.get('TAG086') : '';} 
    public String getTAG087() {return tagTextMap.containsKey('TAG087')?tagTextMap.get('TAG087') : '';} 
    public String getTAG088() {return tagTextMap.containsKey('TAG088')?tagTextMap.get('TAG088') : '';} 
    public String getTAG089() {return tagTextMap.containsKey('TAG089')?tagTextMap.get('TAG089') : '';} 
    public String getTAG090() {return tagTextMap.containsKey('TAG090')?tagTextMap.get('TAG090') : '';} 
    public String getTAG091() {return tagTextMap.containsKey('TAG091')?tagTextMap.get('TAG091') : '';}
    */ 
    public String getTAG092() {return tagTextMap.containsKey('TAG092')?tagTextMap.get('TAG092') : '';} 
    public String getTAG093() {return tagTextMap.containsKey('TAG093')?tagTextMap.get('TAG093') : '';} 
    //public String getTAG094() {return tagTextMap.containsKey('TAG094')?tagTextMap.get('TAG094') : '';} 
    public String getTAG095() {return tagTextMap.containsKey('TAG095')?tagTextMap.get('TAG095') : '';} 
    public String getTAG096() {return tagTextMap.containsKey('TAG096')?tagTextMap.get('TAG096') : '';} 
    public String getTAG097() {return tagTextMap.containsKey('TAG097')?tagTextMap.get('TAG097') : '';} 
    public String getTAG098() {return tagTextMap.containsKey('TAG098')?tagTextMap.get('TAG098') : '';} 
    public String getTAG099() {return tagTextMap.containsKey('TAG099')?tagTextMap.get('TAG099') : '';}
    public String getTAG100() {return tagTextMap.containsKey('TAG100')?tagTextMap.get('TAG100') : '';}
    public String getTAG101() {return tagTextMap.containsKey('TAG101')?tagTextMap.get('TAG101') : '';} 
    public String getTAG102() {return tagTextMap.containsKey('TAG102')?tagTextMap.get('TAG102') : '';}
    public String getTAG103() {return tagTextMap.containsKey('TAG103')?tagTextMap.get('TAG103') : '';}
    public String getTAG104() {return tagTextMap.containsKey('TAG104')?tagTextMap.get('TAG104') : '';}
    public String getTAG105() {return tagTextMap.containsKey('TAG105')?tagTextMap.get('TAG105') : '';}
    public String getTAG106() {return tagTextMap.containsKey('TAG106')?tagTextMap.get('TAG106') : '';}
    public String getTAG107() {return tagTextMap.containsKey('TAG107')?tagTextMap.get('TAG107') : '';}
    public String getTAG108() {return tagTextMap.containsKey('TAG108')?tagTextMap.get('TAG108') : '';}
    public String getTAG109() {return tagTextMap.containsKey('TAG109')?tagTextMap.get('TAG109') : '';}
    public String getTAG110() {return tagTextMap.containsKey('TAG110')?tagTextMap.get('TAG110') : '';}
    public String getTAG111() {return tagTextMap.containsKey('TAG111')?tagTextMap.get('TAG111') : '';}
    public String getTAG112() {return tagTextMap.containsKey('TAG112')?tagTextMap.get('TAG112') : '';}
    public String getTAG113() {return tagTextMap.containsKey('TAG113')?tagTextMap.get('TAG113') : '';}
    public String getTAG114() {return tagTextMap.containsKey('TAG114')?tagTextMap.get('TAG114') : '';}
    public String getTAG115() {return tagTextMap.containsKey('TAG115')?tagTextMap.get('TAG115') : '';}
    public String getTAG116() {return tagTextMap.containsKey('TAG116')?tagTextMap.get('TAG116') : '';}
    public String getTAG117() {return tagTextMap.containsKey('TAG117')?tagTextMap.get('TAG117') : '';}
    public String getTAG118() {return tagTextMap.containsKey('TAG118')?tagTextMap.get('TAG118') : '';}
    public String getTAG119() {return tagTextMap.containsKey('TAG119')?tagTextMap.get('TAG119') : '';}
    public String getTAG120() {return tagTextMap.containsKey('TAG120')?tagTextMap.get('TAG120') : '';}
    public String getTAG121() {return tagTextMap.containsKey('TAG121')?tagTextMap.get('TAG121') : '';}
    public String getTAG122() {return tagTextMap.containsKey('TAG122')?tagTextMap.get('TAG122') : '';}
    public String getTAG123() {return tagTextMap.containsKey('TAG123')?tagTextMap.get('TAG123') : '';}
    public String getTAG124() {return tagTextMap.containsKey('TAG124')?tagTextMap.get('TAG124') : '';}
    public String getTAG125() {return tagTextMap.containsKey('TAG125')?tagTextMap.get('TAG125') : '';}
    public String getTAG126() {return tagTextMap.containsKey('TAG126')?tagTextMap.get('TAG126') : '';}
    public String getTAG127() {return tagTextMap.containsKey('TAG127')?tagTextMap.get('TAG127') : '';}
    public String getTAG128() {return tagTextMap.containsKey('TAG128')?tagTextMap.get('TAG128') : '';}
    public String getTAG129() {return tagTextMap.containsKey('TAG129')?tagTextMap.get('TAG129') : '';}
    public String getTAG130() {return tagTextMap.containsKey('TAG130')?tagTextMap.get('TAG130') : '';}
    public String getTAG131() {return tagTextMap.containsKey('TAG131')?tagTextMap.get('TAG131') : '';}
    public String getTAG132() {return tagTextMap.containsKey('TAG132')?tagTextMap.get('TAG132') : '';}
    public String getTAG133() {return tagTextMap.containsKey('TAG133')?tagTextMap.get('TAG133') : '';}
    public String getTAG134() {return tagTextMap.containsKey('TAG134')?tagTextMap.get('TAG134') : '';}
    public String getTAG135() {return tagTextMap.containsKey('TAG135')?tagTextMap.get('TAG135') : '';}
    public String getTAG136() {return tagTextMap.containsKey('TAG136')?tagTextMap.get('TAG136') : '';}
    public String getTAG137() {return tagTextMap.containsKey('TAG137')?tagTextMap.get('TAG137') : '';}
    public String getTAG138() {return tagTextMap.containsKey('TAG138')?tagTextMap.get('TAG138') : '';}
    public String getTAG139() {return tagTextMap.containsKey('TAG139')?tagTextMap.get('TAG139') : '';}
    public String getTAG140() {return tagTextMap.containsKey('TAG140')?tagTextMap.get('TAG140') : '';}
    public String getTAG141() {return tagTextMap.containsKey('TAG141')?tagTextMap.get('TAG141') : '';}
    public String getTAG142() {return tagTextMap.containsKey('TAG142')?tagTextMap.get('TAG142') : '';}
    public String getTAG143() {return tagTextMap.containsKey('TAG143')?tagTextMap.get('TAG143') : '';}
    public String getTAG144() {return tagTextMap.containsKey('TAG144')?tagTextMap.get('TAG144') : '';}
    public String getTAG145() {return tagTextMap.containsKey('TAG145')?tagTextMap.get('TAG145') : '';}
    public String getTAG146() {return tagTextMap.containsKey('TAG146')?tagTextMap.get('TAG146') : '';}
    public String getTAG147() {return tagTextMap.containsKey('TAG147')?tagTextMap.get('TAG147') : '';}
    public String getTAG148() {return tagTextMap.containsKey('TAG148')?tagTextMap.get('TAG148') : '';}
    public String getTAG149() {return tagTextMap.containsKey('TAG149')?tagTextMap.get('TAG149') : '';}
    public String getTAG150() {return tagTextMap.containsKey('TAG150')?tagTextMap.get('TAG150') : '';}
    public String getTAG151() {return tagTextMap.containsKey('TAG151')?tagTextMap.get('TAG151') : '';}
    public String getTAG152() {return tagTextMap.containsKey('TAG152')?tagTextMap.get('TAG152') : '';}
    public String getTAG153() {return tagTextMap.containsKey('TAG153')?tagTextMap.get('TAG153') : '';}
    public String getTAG154() {return tagTextMap.containsKey('TAG154')?tagTextMap.get('TAG154') : '';}
    public String getTAG155() {return tagTextMap.containsKey('TAG155')?tagTextMap.get('TAG155') : '';}
    public String getTAG156() {return tagTextMap.containsKey('TAG156')?tagTextMap.get('TAG156') : '';}
    public String getTAG157() {return tagTextMap.containsKey('TAG157')?tagTextMap.get('TAG157') : '';}
    public String getTAG158() {return tagTextMap.containsKey('TAG158')?tagTextMap.get('TAG158') : '';}
    public String getTAG159() {return tagTextMap.containsKey('TAG159')?tagTextMap.get('TAG159') : '';}
    public String getTAG160() {return tagTextMap.containsKey('TAG160')?tagTextMap.get('TAG160') : '';}
    public String getTAG161() {return tagTextMap.containsKey('TAG161')?tagTextMap.get('TAG161') : '';}
    public String getTAG162() {return tagTextMap.containsKey('TAG162')?tagTextMap.get('TAG162') : '';}
    public String getTAG163() {return tagTextMap.containsKey('TAG163')?tagTextMap.get('TAG163') : '';}
    public String getTAG164() {return tagTextMap.containsKey('TAG164')?tagTextMap.get('TAG164') : '';}
    public String getTAG165() {return tagTextMap.containsKey('TAG165')?tagTextMap.get('TAG165') : '';}
    public String getTAG168() {return tagTextMap.containsKey('TAG168')?tagTextMap.get('TAG168') : '';} //Added for BAC-5625
    public String getTAG169() {return tagTextMap.containsKey('TAG169')?tagTextMap.get('TAG169') : '';} //Added for BAC-5625
    
    public List<SelectOption> sortingSelectOption(List<SelectOption> so, boolean bSortByLabel)
    {
        map<string, selectOption> mapTemp = new map<string, SelectOption>();
        if(bSortByLabel)
        {
            for(selectOption o :so)
            {
                mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
            }
        }
        else
        {
            for(selectOption o :so)
            {
                mapTemp.put(o.getValue()+'-'+o.getLabel(), o);
            }
        }
        list<string> lstTemp = new list<string>();
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        so.clear();
        for(string str: lstTemp)
        {
            so.add(mapTemp.get(str));
        }
        return so;
    }
    public map<string, string>  mapObjectNameField = new map<String, String>();
    public map<string, Map<String,Schema.SObjectField>>  mapObjectFieldmap = new map<String, Map<String,Schema.SObjectField>>();
    private Set<String> fieldTobypassed = new Set<String>{'lastvieweddate', 'lastreferenceddate'};

    public string getFieldString(Schema.sObjectType St)
    {
        boolean isNameFieldAdded = false;
        string strFields = '';
        try
        {
            if(St != null)
            {
                Schema.DescribeSObjectResult r = St.getDescribe();
                if(St == Account.SObjectType)
                {
                    mapObjectNameField.put(r.getName(), 'Name');
                    isNameFieldAdded = true;
                }
                Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();  
                if(!mapObjectFieldmap.ContainsKey(r.getName()))
                {
                    objfieldMap = r.fields.getMap();
                    mapObjectFieldmap.put(r.getName() , objfieldMap);
                }
                else
                    objfieldMap = mapObjectFieldmap.get(r.getName());
                if(objfieldMap != null)
                {
                    for (String fieldKey : objfieldMap.keySet()) 
                    {
                        if(fieldTobypassed.contains(fieldKey)) // by passing lastvieweddate as is known issue below version 27
                        {
                            continue;
                        }
                        
                        Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                        Schema.DescribeFieldResult f = fsObj.getDescribe();
                        if(!isNameFieldAdded && f.isNameField())
                        {

                            mapObjectNameField.put(r.getName(), f.getName());
                            isNameFieldAdded = true;
                        }
                        if( strFields.length() > 0)
                            strFields += ', ';
                        strFields += f.getName();
                    }
                }
            }
        }
        catch(exception ex)
        {
            system.debug('asdf'+ ex);
        }
        return strFields;
    }
    
    public WraperSObject sObjectUpdate(sObject sObj, String fieldName, String fieldType, String value, string objectName)
    {
        isUpdateSuccess = true;
        try
        {
            if(sObj != null && fieldName != null && fieldType != null)
            {
                sObj = updateSObjectInner(sObj, fieldName, fieldType, value, objectName);
            }else
            {
                isUpdateSuccess = false; 
            } 
        }catch(Exception e)
        {
            isUpdateSuccess = false;
            throw e;
        }
        return (new WraperSObject(sObj, isUpdateSuccess));
    }
    private Sobject updateSObjectInner(sObject sObj, String fieldName, String fieldType, String value, string objectName)
    {
        if(fieldType.toUpperCase() == 'DOUBLE')
            sObj.put(fieldName, double.valueOf(Value));
        else if(fieldType.toUpperCase() == 'BOOLEAN')
        {
            if(Value.toUpperCase() == 'TRUE')
                sObj.put(fieldName, true);
            if(Value.toUpperCase() == 'FALSE')
                sObj.put(fieldName, false);
        }
        else if(fieldType.toUpperCase() == 'INTEGER')
            sObj.put(fieldName, Integer.valueOf(Value));
        else if(fieldType.toUpperCase() == 'ID')
            sObj.put(fieldName, value);
        else if(fieldType.toUpperCase() == 'STRING')
            sObj.put(fieldName, value);
        else if(fieldType.toUpperCase() == 'TEXTAREA')
            sObj.put(fieldName, value);
        else if(fieldType.toUpperCase() == 'URL')
            sObj.put(fieldName, value);
        else if(fieldType.toUpperCase() == 'PHONE')
            sObj.put(fieldName, value);
        else if(fieldType.toUpperCase() == 'CURRENCY')
            sObj.put(fieldName, Decimal.valueOf(value));
        else if(fieldType.toUpperCase() == 'DECIMAL')
            sObj.put(fieldName, Decimal.valueOf(value));
        else if(fieldType.toUpperCase() == 'DATE')
            sObj.put(fieldName, getDate(value));
        else if(fieldType.toUpperCase() == 'DATETIME')
            sObj.put(fieldName, getDateTime(value));
        else 
            sObj.put(fieldName, value);
        
        if(fieldType.toUpperCase() == 'REFERENCE' && ObjectName != null && ObjectName.ToUpperCase() == 'USER')
        {
            if(Value.toUpperCase() == 'SVMX.CURRENTUSER')
                sObj.put(fieldName,UserInfo.getUserId());
            
            if(Value.toUpperCase() == 'SVMX.OWNER')
            {
                try
                {
                    sObj.put(fieldName,sObj.get('OwnerId'));
                }
                catch(exception ex){}
            }
        }
        else if(fieldType.toUpperCase() == 'REFERENCE')
            sObj.put(fieldName,value);  
        return sObj;
    }
    public WraperSObject updateSObject(sObject sObj, String FieldName, string FieldType, String Value, string ObjectName)
    {
        isUpdateSuccess = true;
        try
        {
            if(sObj != null && FieldName != null && FieldType != null)
            {
              sObj = updateSObjectInner(sObj, fieldName, fieldType, value, objectName);
            }
            else
            {
                isUpdateSuccess = false;
            }
                
        }
        catch (Exception ex)
        {
            System.debug('exception : '+ ex.getMessage());
            isUpdateSuccess = false;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
  
        }
        return (new WraperSObject(sObj, isUpdateSuccess));
    }
    //Old code 
    /*public WraperSObject updateSObject(sObject sObj, String FieldName, string FieldType, String Value, string ObjectName)
    {
        isUpdateSuccess = true;
        try
        {
            if(sObj != null && FieldName != null && FieldType != null)
            {
                if(FieldType.toUpperCase() == 'DOUBLE')
                        sObj.put(FieldName, double.valueOf(Value));
                else if(FieldType.toUpperCase() == 'BOOLEAN')
                {
                    if(Value.toUpperCase() == 'TRUE')
                            sObj.put(FieldName, true);
                    if(Value.toUpperCase() == 'FALSE')
                            sObj.put(FieldName, false);
                }
                else if(FieldType.toUpperCase() == 'INTEGER')
                        sObj.put(FieldName, Integer.valueOf(Value));
                else if(FieldType.toUpperCase() == 'ID')
                        sObj.put(FieldName, Value);
                else if(FieldType.toUpperCase() == 'STRING')
                        sObj.put(FieldName, Value);
                else if(FieldType.toUpperCase() == 'TEXTAREA')
                        sObj.put(FieldName, Value);
                else if(FieldType.toUpperCase() == 'URL')
                        sObj.put(FieldName, Value);
                else if(FieldType.toUpperCase() == 'PHONE')
                        sObj.put(FieldName, Value);
                else if(FieldType.toUpperCase() == 'CURRENCY')
                        sObj.put(FieldName, Decimal.valueOf(Value));
                else if(FieldType.toUpperCase() == 'DECIMAL')
                        sObj.put(FieldName, Decimal.valueOf(Value));
                else if(FieldType.toUpperCase() == 'DATE')
                        sObj.put(FieldName, getDate(Value));
                else if(FieldType.toUpperCase() == 'DATETIME')
                        sObj.put(FieldName, getDateTime(Value));
                else 
                        sObj.put(FieldName, Value);
                        
                if(FieldType.toUpperCase() == 'REFERENCE' && ObjectName != null && ObjectName.ToUpperCase() == 'USER')
                {
                    if(Value.toUpperCase() == 'SVMX.CURRENTUSER')
                        sObj.put(FieldName,UserInfo.getUserId());
                        
                    if(Value.toUpperCase() == 'SVMX.OWNER')
                    {
                        try
                        {
                            sObj.put(FieldName,sObj.get('OwnerId'));
                        }
                        catch(exception ex){}
                    }
                }
                else if(FieldType.toUpperCase() == 'REFERENCE')
                    sObj.put(FieldName,Value);
            }
            else
                isUpdateSuccess = false;
        }
        catch (Exception ex)
        {
            
            
            System.debug('exception : '+ ex.getMessage());
            isUpdateSuccess = false;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            
            
        }
        System.debug(sObj);
        System.debug(isUpdateSuccess);
        return (new WraperSObject(sObj, isUpdateSuccess));
    }*/    
    public Date getDate(String str)
    {
        try
        {
            if(str != null && (str.toUpperCase() == 'TODAY' || str.toUpperCase() == 'SVMX.NOW'))
                return Date.today();
            else if(str != null && str.toUpperCase() == 'TOMORROW')
                return Date.today().addDays(1);
            else if(str != null && str.toUpperCase() == 'YESTERDAY')
                return Date.today().addDays(-1);
            else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                return Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1]) );
            else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                return Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1]) );
            else 
                return Date.valueOf(str);
        }
        catch(exception ex)
        {
            isUpdateSuccess = false;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    public DateTime getDateTime(String str)
    {
        try
        {
            if(str != null && str.toUpperCase() == 'SVMX.NOW')
                return DateTime.now();
            else
                return Datetime.newInstance(getDate(str), time.newInstance(0, 0, 0, 0)); 
        }
        catch(exception ex)
        {
            isUpdateSuccess = false;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    public class WraperSObject 
    {
        public sObject sObj;
        public Boolean IsSuccess = true;
        public WraperSObject(sObject oSObj, boolean bIsSuccess)
        {
            this.sObj = oSObj;
            this.IsSuccess = bIsSuccess;
        }
    }
    transient List<SelectOption> options = new List<SelectOption>();
    public List<SelectOption> getLstStockbleLocation()
    {
        options = new List<SelectOption>();
        options.add(new selectOption('SVMX.NONE', getTAG062()));
        options.add(new selectOption('1', getTAG114()));
        options.add(new selectOption('2', getTAG115()));
        options.add(new selectOption('3', getTAG116()));
        return options;
    }
    public String getSelStockbleLocation(SVMXC.COMM_Inventory_Classes.InventoryProcess objSVMXPro)
     {
        string SelStockbleLocation = '';
        if(!objSVMXPro.Is_Target_Location_Stockable && objSVMXPro.Is_Source_Location_Stockable)
            SelStockbleLocation = '2';
        if(objSVMXPro.Is_Target_Location_Stockable && !objSVMXPro.Is_Source_Location_Stockable)
            SelStockbleLocation = '1';
        if(objSVMXPro.Is_Target_Location_Stockable && objSVMXPro.Is_Source_Location_Stockable)
            SelStockbleLocation = '3';
        if(!objSVMXPro.Is_Target_Location_Stockable && !objSVMXPro.Is_Source_Location_Stockable)
            SelStockbleLocation = 'SVMX.NONE';
        return SelStockbleLocation ;    
     }
     public SVMXC.COMM_Inventory_Classes.InventoryProcess setSelStockbleLocation(String s, SVMXC.COMM_Inventory_Classes.InventoryProcess objSVMXPro)
     {
        string SelStockbleLocation = s;
        if(SelStockbleLocation == '1')
        {
            objSVMXPro.Is_Target_Location_Stockable = true; 
            objSVMXPro.Is_Source_Location_Stockable = false;
        } 
        if(SelStockbleLocation == '2')
        {
            objSVMXPro.Is_Target_Location_Stockable = false; 
            objSVMXPro.Is_Source_Location_Stockable = true;
        } 
        if(SelStockbleLocation == '3')
        {
            objSVMXPro.Is_Target_Location_Stockable = true; 
            objSVMXPro.Is_Source_Location_Stockable = true;
        }
        if(SelStockbleLocation == 'SVMX.NONE')
        {
            objSVMXPro.Is_Target_Location_Stockable = false;
            objSVMXPro.Is_Source_Location_Stockable = false;
        }
        return objSVMXPro;
     }
     public List<selectoption> getlstChildRecordType(List<selectoption> lstChildRecordType, map<String,map<string, SelectOption>> RTypeMap, SVMXC.COMM_Inventory_Classes.InventoryProcess objSVMXPro) 
    {
        try
        {
            lstChildRecordType.clear();
            if(RTypeMap.containsKey(objSVMXPro.Child_Object_Name) && RTypeMap.get(objSVMXPro.Child_Object_Name) != null)
            {
                for(Selectoption s :RTypeMap.get(objSVMXPro.Child_Object_Name).values())
                {
                    lstChildRecordType.add(new Selectoption( s.getLabel(), s.getLabel()));
                }
            }
            if (lstChildRecordType.size() == 0)
                lstChildRecordType.add(new SelectOption('SVMX.NONE',getTAG062()));
            else if(lstChildRecordType.size() != 1 )
                lstChildRecordType.add(0, new SelectOption('SVMX.NONE',getTAG062()));
            return lstChildRecordType;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
    public boolean getIsChildRecordTypeRequired(map<String,map<string, SelectOption>> RTypeMap, SVMXC.COMM_Inventory_Classes.InventoryProcess objSVMXPro)
     {
        try
        {
            if(RTypeMap.containsKey(objSVMXPro.Child_Object_Name) && RTypeMap.get(objSVMXPro.Child_Object_Name) != null)
            {
                if(RTypeMap.get(objSVMXPro.Child_Object_Name).values().size()> 1)
                    return true;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return false;
    }
    public string setselectedTab(string str) 
    {
        if(str == getTAG015())
            return getTAG015();
        if(str == getTAG108())
            return getTAG108();
        if(str == getTAG016())
            return getTAG016();
        if(str == getTAG014())
            return getTAG014();
        if(str == getTAG013())
            return getTAG013();
        if(str == getTAG012())
            return getTAG012();
        return '';
    }
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
    }
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    /*1
    if(!mapAllStock.ContainsKey((string)sPS.get('SVMXC__Product__c')))
        {
            map<string, WraperSObject> m = new map<string, WraperSObject>();
            map<string, map<string, WraperSObject>> m2 = new map<string, map<string, WraperSObject>>();
            m.put((String)sPS.get('SVMXC__Status__c'), new WraperSObject(sPS));
            m2.put((string)sPS.get('SVMXC__Location__c'), m);
            mapAllStock.put((string)sPS.get('SVMXC__Product__c'), m2);
        }
        else if(!mapAllStock.get((string)sPS.get('SVMXC__Product__c')).ContainsKey((string)sPS.get('SVMXC__Location__c')))
        {
            map<string, WraperSObject> m = new map<string, WraperSObject>();
            m.put((String)sPS.get('SVMXC__Status__c'), new WraperSObject(sPS));
            mapAllStock.get((string)sPS.get('SVMXC__Product__c')).put((string)sPS.get('SVMXC__Location__c'), m);
        }
        else //if(!mapAllStock.get((string)sPS.get('SVMXC__Product__c')).get((string)sPS.get('SVMXC__Location__c')).containsKey((String)sPS.get('SVMXC__Status__c')))
        {
            mapAllStock.get((string)sPS.get('SVMXC__Product__c')).get((string)sPS.get('SVMXC__Location__c')).put((String)sPS.get('SVMXC__Status__c'), new WraperSObject(sPS));
        }
    */
    /*2
    if(mapAllStock.ContainsKey(prodId))
    {
        if(mapAllStock.get(prodId).ContainsKey(FromLocation))
        {
            if(mapAllStock.get(prodId).get(FromLocation).containsKey(invProcess.Source_Status))
                sourceFound = true;
        }
    }
    */
    /*3
    if(mapAllStock.ContainsKey(prodId))
                        {
                            if(mapAllStock.get(prodId).ContainsKey(FromLocation))
                            {
                                if(mapAllStock.get(prodId).get(FromLocation).containsKey(invProcess.Source_Status))
                                    sourceFound = true;
                            }
                        }*/
    /*4
    if(mapAllStock.ContainsKey(prodId))
                        {
                            if(mapAllStock.get(prodId).ContainsKey(ToLocation))
                            {
                                if(mapAllStock.get(prodId).get(ToLocation).containsKey(invProcess.Target_Status))
                                    TargetFound = true;
                                if(ToLocation == null || ToLocation.length() == 0)
                                {
                                    if(mapAllStock.get(prodId).get(FromLocation).containsKey('DECREASED'))
                                        TargetFound = true;
                                }
                            }
                        }
    */
}