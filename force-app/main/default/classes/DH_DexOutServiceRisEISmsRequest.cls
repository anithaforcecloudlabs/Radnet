/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisEISmsRequest
* Created Date - 28-Aug-2024
* @description : RIS Patient Engagement Service SMS Request Wrapper
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-491                   06-Sept-2024          Original Version                  
* *****************************************************************************************************************************
*/
public class DH_DexOutServiceRisEISmsRequest {
        public String SfId { get; set; }
		public String SentDate { get; set; }
		public String Content { get; set; }
		public Integer JobId { get; set; }	
		public Integer OrderKey { get; set; }
		public Integer BatchId { get; set; }
		public Integer SubscriberID { get; set; }
		public boolean Sent { get; set; }
		public boolean NotSent { get; set; }
		public String PhoneNumber { get; set; }	
		public String JourneyName { get; set; }	
		public String JourneyTouchPoint { get; set; }
}