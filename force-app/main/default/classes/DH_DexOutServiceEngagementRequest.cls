/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServiceEngagementRequest
* Created Date : 30-Jun-2024
* @description : Service class to get patient engagement details for a patient.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-Jun-2024          Added Response fields.
* *****************************************************************************************************************************
*/
public class DH_DexOutServiceEngagementRequest {
    public String patientKey { get; set; }
    public String systemId { get; set; }
    public String recordId { get; set; }
    public String communicationChannel {get; set;}
}