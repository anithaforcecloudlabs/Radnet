@isTest
public with sharing class VF_ExportListViewAPX_TEST {
    
    @isTest
    private static void testmethod1(){
        List<Competition__c> listCompetition = new List<Competition__c>();
        ApexPages.StandardSetController testStdSetCon = new ApexPages.StandardSetController( listCompetition );
        VF_ExportListViewAPX testVF = new VF_ExportListViewAPX(testStdSetCon);
        testVF.redirectToExportListView();

    }
}