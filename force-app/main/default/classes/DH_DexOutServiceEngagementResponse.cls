/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServiceEngagementResponse
* Created Date : 30-Jun-2024
* @description : Service class to get patient engagement details for a patient.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-Jun-2024          Added Response fields and compareTo methods.
* *****************************************************************************************************************************
*/

public class DH_DexOutServiceEngagementResponse  implements Comparable{
    public String uniqueID { get; set; }
    public String subject { get; set; }
    public Datetime timeStamp { get; set; }
    public String displayTime { get; set; }
    public String displayDate { get; set; }    
    public String description { get; set; }
    public String iconVariant { get; set; }
    public String responseError {get;set;}
    public Boolean displayResponseList {get;set;}
    public Boolean inboundFlag {get;set;}
    public List<DH_DexEngagementInteraction> responseList {get;set;}
    
    
    public Integer compareTo(Object compareTo) {
        DH_DexOutServiceEngagementResponse compareToEmp = (DH_DexOutServiceEngagementResponse)compareTo;
        if(this.timeStamp < compareToEmp.timeStamp){
            return 1;
        }
        if(this.timeStamp > compareToEmp.timeStamp){
            return -1;
        }
        return 0;        
    }
}