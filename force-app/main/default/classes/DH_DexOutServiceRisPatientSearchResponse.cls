/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisPatientSearchResponse
* Created Date - 30-May-2024
* @description : Response Wrapper class for DH_DexOutServiceRisPatientSearch service class.
* Modification Log :
* -------------------------------------------------------------------------------------------------------
* Jira#                          Date                 Description
* --------------------        --------------       ---------------------
* CC-476,CC-474,CC-478        12-June-2024         Original Version
* CC-482,CC-507,CC-520        31-July-2024         Added errorMessage variable
* CC-962                      28-August-2024       Changes related to inclusion of siteDescription node.
* *********************************************************************************************************************************************
*/
public class DH_DexOutServiceRisPatientSearchResponse{ 
    @AuraEnabled public String errorMessage{get;set;}
    @AuraEnabled public Integer patientKey{get;set;}
    @AuraEnabled public String firstName{get;set;}
    @AuraEnabled public String lastName{get;set;}
    @AuraEnabled public String middleInitial{get;set;}
    @AuraEnabled public String birthDate{get;set;}
    @AuraEnabled public String mrn{get;set;}
    @AuraEnabled public String address{get;set;}
    @AuraEnabled public String phoneNumber{get;set;}
    @AuraEnabled public List<String> phoneNoList{get;set;}
    @AuraEnabled public String emailAddress{get;set;}
    @AuraEnabled public String systemID{get;set;}
    @AuraEnabled public openEMROrder openEMROrder{get;set;}
    @AuraEnabled public openNonEMROrder openNonEMROrder{get;set;}
    @AuraEnabled public lastPerformedExam lastPerformedExam{get;set;}
    @AuraEnabled public nextScheduledExam nextScheduledExam{get;set;}
    @AuraEnabled public Integer groupingKey{get;set;}
    @AuraEnabled public String previousFirstName{get;set;}
    @AuraEnabled public String previousLastName{get;set;}
    @AuraEnabled public lastContact lastContact{get;set;}
    @AuraEnabled public boolean duplicateDropdown{get;set;}
    @AuraEnabled public boolean enableRadioButton{get;set;}
    @AuraEnabled public boolean collapseDropdown{get;set;}
    @AuraEnabled public boolean noChildDetails{get;set;}
    public class openEMROrder{
        @AuraEnabled public String requestedDate{get;set;}
        @AuraEnabled public String orderedProcedures{get;set;}
        @AuraEnabled public String requestedBy{get;set;}
        @AuraEnabled public String siteDescription{get;set;}
    }
    public class openNonEMROrder{
        @AuraEnabled public String requestedDate{get;set;}
        @AuraEnabled public String emrCode{get;set;}
        @AuraEnabled public String requestedBy{get;set;}
        @AuraEnabled public String orderedProcedures{get;set;}
        @AuraEnabled public String siteDescription{get;set;}
    }
    public class lastPerformedExam{
        @AuraEnabled public String scheduledDate{get;set;}
        @AuraEnabled public String examDescription{get;set;}
        @AuraEnabled public String requestedBy{get;set;}
        @AuraEnabled public String modalityType{get;set;}
        @AuraEnabled public String siteDescription{get;set;}
    }
    public class nextScheduledExam{
        @AuraEnabled public String scheduledDate{get;set;}
        @AuraEnabled public String examDescription{get;set;}
        @AuraEnabled public String requestedBy{get;set;}
        @AuraEnabled public String modalityType{get;set;}
        @AuraEnabled public String siteDescription{get;set;}
    }
    public class lastContact{
        @AuraEnabled public String lastContactDate{get;set;}
        @AuraEnabled public String lastFollowUpTypeCode{get;set;}
        @AuraEnabled public String lastContactNotes{get;set;}
        @AuraEnabled public String orderedProcedures{get;set;}
        @AuraEnabled public String requestedBy{get;set;}
        @AuraEnabled public String siteDescription{get;set;}
    }
}