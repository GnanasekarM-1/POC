@isTest
private with sharing class SFM_Migrator_UT {

  static testmethod void test1()
  {
    ApexPages.currentPage().getParameters().put('SVMX_retURL','SVMX_retURL'); 
    SFM_Migrator migrator = new SFM_Migrator();
    system.assert(migrator!=null);
    migrator.getMySessionId();
    migrator.getreturnURL();
  }

}