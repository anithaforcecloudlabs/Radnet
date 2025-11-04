/*
* *****************************************************************************************************************************
* Apex Helper Class Name : DH_GeneralPayloadQueueable
* Created Date : 23-July-2024
* @description : Generic queueable class for payload bulk creation.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* CC-482-507               23-July-2024         Calling createLogRecord method
* CC-520                   09-August-2024       Added apiResponseList variable and updated execute method
* CC-491                   09-September-2024    Added new constructor and updated execute method
* *****************************************************************************************************************************
*/
public class DH_GeneralPayloadQueueable implements Queueable, Database.AllowsCallouts{
   DH_DexOutGeneralServiceRequest apiRequest;
   DH_DexOutGeneralServiceResponse apiResponse;
   Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> payloadMap = new Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>();
   public DH_GeneralPayloadQueueable(DH_DexOutGeneralServiceRequest apiRequest,DH_DexOutGeneralServiceResponse apiResponse) {
      this.apiRequest = apiRequest;
      this.apiResponse = apiResponse;
   }
   public DH_GeneralPayloadQueueable(Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> newPayloadMap) {
      payloadMap.putAll(newPayloadMap);
   }
   public void execute(QueueableContext context) {
      if(this.apiRequest!=null && this.apiResponse!=null){
         DH_DexLoggingUtility.createLogRecord(this.apiRequest,this.apiResponse);
      }else if(payloadMap !=null && !payloadMap.isEmpty()){
         DH_DexLoggingUtility.createLogRecord(payloadMap);
      }
   }
}