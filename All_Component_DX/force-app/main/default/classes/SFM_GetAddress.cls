/* Security Scanned */
public with sharing class SFM_GetAddress 
{
    
    public SFM_getAddress(){}
    public Sobject getAddress(Sobject sobj,list<SVMXC.SFM_WrapperDef.SFM_StringMap> strmaplst)
    {
       
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMapList = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        StringMapList = strmaplst;
        String AddressType = '';
        String IBId = '';
        system.debug('StringMapList'+StringMapList);
        if(StringMapList.size() > 0)
        {
            for(Integer i = 0;i<StringMapList.size();i++)
            {
                if(StringMapList[i].key.touppercase() == 'ADDRESSTYPE')
                    AddressType = StringMapList[i].value.touppercase();
                if(StringMapList[i].key.touppercase() == 'IBID')
                    IBId = StringMapList[i].value;
            }
        }
        //TOADDRESS
        if(AddressType != null && AddressType.length() > 0 && AddressType == 'TOADDRESS')
        {
            sobj.put('SVMXC__Destination_Street__c',null);
            sobj.put('SVMXC__Destination_City__c',null);
            sobj.put('SVMXC__Destination_State__c',null);
            sobj.put('SVMXC__Destination_Zip__c',null);
            sobj.put('SVMXC__Destination_Country__c',null);
            String Address = ''; 
            Address = String.valueof(sobj.get('SVMXC__Address_Type__c'));
            //Account Billing Addres
            if(Address != null && Address.length() > 0 && Address == 'Account Billing Address' && sobj.get('SVMXC__Company__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Company__c'));
                list<Account> acc = new list<Account>();
                acc = [Select Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity From Account where Id =: RecId];
                if(acc != null && !acc.isempty())
                {
                    sobj.put('SVMXC__Destination_Street__c',acc[0].BillingStreet);
                    sobj.put('SVMXC__Destination_City__c',acc[0].BillingCity);
                    sobj.put('SVMXC__Destination_State__c',acc[0].BillingState);
                    sobj.put('SVMXC__Destination_Zip__c',acc[0].BillingPostalCode);
                    sobj.put('SVMXC__Destination_Country__c',acc[0].BillingCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;    
            }
            //Account Shipping Address
            if(Address != null && Address.length() > 0 && Address == 'Account Shipping Address' && sobj.get('SVMXC__Company__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Company__c'));
                list<Account> acc = new list<Account>();
                acc = [Select Id,ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity From Account where Id =: RecId];
                if(acc != null && !acc.isempty())
                {
                    sobj.put('SVMXC__Destination_Street__c',acc[0].ShippingStreet);
                    sobj.put('SVMXC__Destination_City__c',acc[0].ShippingCity);
                    sobj.put('SVMXC__Destination_State__c',acc[0].ShippingState);
                    sobj.put('SVMXC__Destination_Zip__c',acc[0].ShippingPostalCode);
                    sobj.put('SVMXC__Destination_Country__c',acc[0].ShippingCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
            //Contact Mailing Address
            if(Address != null && Address.length() > 0 && Address == 'Contact Mailing Address' && sobj.get('SVMXC__Contact__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Contact__c'));
                list<Contact> con = new list<Contact>();
                con = [select Id,MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity From Contact where Id =: RecId];
                if(con != null && !con.isempty())
                {
                    sobj.put('SVMXC__Destination_Street__c',con[0].MailingStreet);
                    sobj.put('SVMXC__Destination_City__c',con[0].MailingCity);
                    sobj.put('SVMXC__Destination_State__c',con[0].MailingState);
                    sobj.put('SVMXC__Destination_Zip__c',con[0].MailingPostalCode);
                    sobj.put('SVMXC__Destination_Country__c',con[0].MailingCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
            //Contact Other Address
            if(Address != null && Address.length() > 0 && Address == 'Contact Other Address' && sobj.get('SVMXC__Contact__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Contact__c'));
                list<Contact> con = new list<Contact>();
                con = [select Id,OtherStreet,OtherState,OtherCity,OtherPostalCode,OtherCountry From Contact where Id =: RecId];
              if(con != null && !con.isempty())
                {
                    system.debug('asdfghjk');
                    sobj.put('SVMXC__Destination_Street__c',con[0].OtherStreet);
                    sobj.put('SVMXC__Destination_City__c',con[0].OtherCity);
                    sobj.put('SVMXC__Destination_State__c',con[0].OtherState);
                    sobj.put('SVMXC__Destination_Zip__c',con[0].OtherPostalCode);
                    sobj.put('SVMXC__Destination_Country__c',con[0].OtherCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
            //Installed Product Address
            if(Address != null && Address.length() > 0 && Address == 'Installed Product Address' && IBId != null && IBId.length() > 0)
            {
                list<SVMXC__Installed_Product__c> Ib = new list<SVMXC__Installed_Product__c>();
                Ib = [Select Id,SVMXC__Street__c, SVMXC__City__c,SVMXC__State__c,SVMXC__Country__c,SVMXC__Zip__c,SVMXC__Site__c,SVMXC__Site__r.Name From SVMXC__Installed_Product__c where Id =: IBId];
                if(Ib != null && !Ib.isempty())
                {
                    sobj.put('SVMXC__Destination_Street__c',Ib[0].SVMXC__Street__c);
                    sobj.put('SVMXC__Destination_City__c',Ib[0].SVMXC__City__c);
                    sobj.put('SVMXC__Destination_State__c',Ib[0].SVMXC__State__c);
                    sobj.put('SVMXC__Destination_Zip__c',Ib[0].SVMXC__Zip__c);
                    sobj.put('SVMXC__Destination_Country__c',Ib[0].SVMXC__Country__c);
                    sobj.put('SVMXC__Destination_Location__c',Ib[0].SVMXC__Site__c);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
        }
        //FROMADDRESS
        if(AddressType != null && AddressType.length() > 0 && AddressType == 'FROMADDRESS')
        {
            //sobj.put('SVMXC__Source_Location__c',null);//Null the Form Location Field
            sobj.put('SVMXC__Source_Street__c',null);
            sobj.put('SVMXC__Source_City__c',null);
            sobj.put('SVMXC__Source_State__c',null);
            sobj.put('SVMXC__Source_Zip__c',null);
            sobj.put('SVMXC__Source_Country__c',null);
            String Address = ''; 
            Address = String.valueof(sobj.get('SVMXC__Address_Type__c'));
            //Account Billing Addres
            if(Address != null && Address.length() > 0 && Address == 'Account Billing Address' && sobj.get('SVMXC__Company__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Company__c'));
                list<Account> acc = new list<Account>();
                acc = [Select Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity From Account where Id =: RecId];
                if(acc != null && !acc.isempty())
                {
                    sobj.put('SVMXC__Source_Street__c',acc[0].BillingStreet);
                    sobj.put('SVMXC__Source_City__c',acc[0].BillingCity);
                    sobj.put('SVMXC__Source_State__c',acc[0].BillingState);
                    sobj.put('SVMXC__Source_Zip__c',acc[0].BillingPostalCode);
                    sobj.put('SVMXC__Source_Country__c',acc[0].BillingCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;    
            }
            //Account Shipping Address
            if(Address != null && Address.length() > 0 && Address == 'Account Shipping Address' && sobj.get('SVMXC__Company__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Company__c'));
                system.debug('RecId'+RecId);
                list<Account> acc = new list<Account>();
                acc = [Select Id,ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity From Account where Id =: RecId];
                 if(acc != null && !acc.isempty())
                {
                    sobj.put('SVMXC__Source_Street__c',acc[0].ShippingStreet);
                    sobj.put('SVMXC__Source_City__c',acc[0].ShippingCity);
                    sobj.put('SVMXC__Source_State__c',acc[0].ShippingState);
                    sobj.put('SVMXC__Source_Zip__c',acc[0].ShippingPostalCode);
                    sobj.put('SVMXC__Source_Country__c',acc[0].ShippingCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
            //Contact Mailing Address
            if(Address != null && Address.length() > 0 && Address == 'Contact Mailing Address' && sobj.get('SVMXC__Contact__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Contact__c'));
                list<Contact> con = new list<Contact>();
                con = [select Id,MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity From Contact where Id =: RecId];
                if(con != null && !con.isempty())
                {
                    sobj.put('SVMXC__Source_Street__c',con[0].MailingStreet);
                    sobj.put('SVMXC__Source_City__c',con[0].MailingCity);
                    sobj.put('SVMXC__Source_State__c',con[0].MailingState);
                    sobj.put('SVMXC__Source_Zip__c',con[0].MailingPostalCode);
                    sobj.put('SVMXC__Source_Country__c',con[0].MailingCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
            //Contact Other Address
            if(Address != null && Address.length() > 0 && Address == 'Contact Other Address' && sobj.get('SVMXC__Contact__c') != null)
            {
                String RecId = String.valueof(sobj.get('SVMXC__Contact__c'));
                list<Contact> con = new list<Contact>();
                con = [select Id,OtherStreet,OtherState,OtherCity,OtherPostalCode,OtherCountry From Contact where Id =: RecId];
                 if(con != null && !con.isempty())
                {
                    sobj.put('SVMXC__Source_Street__c',con[0].OtherStreet);
                    sobj.put('SVMXC__Source_City__c',con[0].OtherCity);
                    sobj.put('SVMXC__Source_State__c',con[0].OtherState);
                    sobj.put('SVMXC__Source_Zip__c',con[0].OtherPostalCode);
                    sobj.put('SVMXC__Source_Country__c',con[0].OtherCountry);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
            //Installed Product Address
            if(Address != null && Address.length() > 0 && Address == 'Installed Product Address' && IBId != null && IBId.length() > 0)
            {
                list<SVMXC__Installed_Product__c> Ib = new list<SVMXC__Installed_Product__c>();
                Ib = [Select Id,SVMXC__Street__c, SVMXC__City__c,SVMXC__State__c,SVMXC__Country__c,SVMXC__Zip__c,SVMXC__Site__c,SVMXC__Site__r.Name From SVMXC__Installed_Product__c where Id =: IBId];
                if(Ib != null && !Ib.Isempty())
                {
                    sobj.put('SVMXC__Source_Street__c',Ib[0].SVMXC__Street__c);
                    sobj.put('SVMXC__Source_City__c',Ib[0].SVMXC__City__c);
                    sobj.put('SVMXC__Source_State__c',Ib[0].SVMXC__State__c);
                    sobj.put('SVMXC__Source_Zip__c',Ib[0].SVMXC__Zip__c);
                    sobj.put('SVMXC__Source_Country__c',Ib[0].SVMXC__Country__c);
                    sobj.put('SVMXC__Source_Location__c',Ib[0].SVMXC__Site__c);
                }
                system.debug('sobj'+sobj);
                return sobj;
            }
        }
        //TO LOCATION
        if(AddressType != null && AddressType.length() > 0 && AddressType == 'TOLOCATION' && sobj.get('SVMXC__Destination_Location__c') != null)
        {
            sobj.put('SVMXC__Destination_Street__c',null);
            sobj.put('SVMXC__Destination_City__c',null);
            sobj.put('SVMXC__Destination_State__c',null);
            sobj.put('SVMXC__Destination_Zip__c',null);
            sobj.put('SVMXC__Destination_Country__c',null);
            String RecId = String.valueof(sobj.get('SVMXC__Destination_Location__c'));
            list<SVMXC__Site__c> Loc = new list<SVMXC__Site__c>();
            Loc = [Select Id,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c, SVMXC__Country__c From SVMXC__Site__c where Id =: RecId];
            if(Loc != null && !Loc.isempty())
            {
                sobj.put('SVMXC__Destination_Street__c',Loc[0].SVMXC__Street__c);
                sobj.put('SVMXC__Destination_City__c',Loc[0].SVMXC__City__c);
                sobj.put('SVMXC__Destination_State__c',Loc[0].SVMXC__State__c);
                sobj.put('SVMXC__Destination_Zip__c',Loc[0].SVMXC__Zip__c);
                sobj.put('SVMXC__Destination_Country__c',Loc[0].SVMXC__Country__c);
            }
            system.debug('sobj'+sobj);
            return sobj;
        }
        //FROM LOCATION
        if(AddressType != null && AddressType.length() > 0 && AddressType == 'FROMLOCATION' && sobj.get('SVMXC__Source_Location__c') !=  null)
        {
            sobj.put('SVMXC__Source_Street__c',null);
            sobj.put('SVMXC__Source_City__c',null);
            sobj.put('SVMXC__Source_State__c',null);
            sobj.put('SVMXC__Source_Zip__c',null);
            sobj.put('SVMXC__Source_Country__c',null);
            String RecId = String.valueof(sobj.get('SVMXC__Source_Location__c'));
            list<SVMXC__Site__c> Loc = new list<SVMXC__Site__c>();
            Loc = [Select Id,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c, SVMXC__Country__c From SVMXC__Site__c where Id =: RecId];
           if(Loc != null && !Loc.isempty())
            {
                sobj.put('SVMXC__Source_Street__c',Loc[0].SVMXC__Street__c);
                sobj.put('SVMXC__Source_City__c',Loc[0].SVMXC__City__c);
                sobj.put('SVMXC__Source_State__c',Loc[0].SVMXC__State__c);
                sobj.put('SVMXC__Source_Zip__c',Loc[0].SVMXC__Zip__c);
                sobj.put('SVMXC__Source_Country__c',Loc[0].SVMXC__Country__c);
            }
            system.debug('sobj'+sobj);
            return sobj;
        }
        return sobj;
    }
}