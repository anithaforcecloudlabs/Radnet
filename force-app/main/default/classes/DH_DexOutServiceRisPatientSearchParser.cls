/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisPatientSearchParser
* Created Date - 23-June-2024
* @description : Parser class to parse the json response of the DH_DexOutServiceRisPatientSearch service class.
* Modification Log :
* ---------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-476                   23-June-2024         Added constructPatientData,getGroupKeyVsPatientMap,getGroupKeyVsPatientList methods.
* CC-474                   24-June-2024         Added parsingPatientRec method.
* CC-962                   30-July-2024         Changed the date format for lastContact,nextScheduledExam,openEMROrder,openNonEMROrder,lastPerformedExam
* CC-962                   28-August-2024       Changes related to inclusion of siteDescription node.
* CC-1276-CC-1277-CC-1296  06-September-2024    Added Changes related to the UI,Button and header bug.
* CC-1200                  20-September-2024    Changes related to data sorting
* CC-1200                  27-September-2024    Changes related to date formating
* **********************************************************************************************************************************
*/
public without sharing class DH_DexOutServiceRisPatientSearchParser{
    /**
	* @Jira CC-476
    * @description - This method will return the map whose key is the groupingKey of the patient and value is
    *                the list of patient records which are grouped based on the grouping key and stored in an ordered format.
    * @param       - String
    * @return      - Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>
	**/
    @AuraEnabled
    public static Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> constructPatientData(String response){
        Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> groupKeyVsPatientListMap = new Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>();
        Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> groupKeyVsPatientMap = new Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>();   
        Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> groupKeyVsPatientMapSorted = new Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>();
        if(response !=null){
            List<DH_DexOutServiceRisPatientSearchResponse> jsonResponseList = (List<DH_DexOutServiceRisPatientSearchResponse>) JSON.deserialize(response, List<DH_DexOutServiceRisPatientSearchResponse>.class);
            groupKeyVsPatientMap = getGroupKeyVsPatientMap(jsonResponseList);
            List<Integer> previousIds = new List<Integer>();
            for(Integer i= 0 ; i<jsonResponseList.size(); i++){
                if(!previousIds.contains(jsonResponseList[i].groupingKey)){
                    previousIds.add(jsonResponseList[i].groupingKey);
                    groupKeyVsPatientMapSorted.put(i,groupKeyVsPatientMap.get(jsonResponseList[i].groupingKey));
                }
            }
            groupKeyVsPatientListMap = getGroupKeyVsPatientList(groupKeyVsPatientMapSorted);
        }    
        return groupKeyVsPatientListMap;
    }

    /**
	* @Jira CC-476
    * @description - This method will group the patient records list based on the groupingKey value and will return a map
                    whose key is the groupingKey and value is the list of patient records.
    * @param       - List<DH_DexOutServiceRisPatientSearchResponse>
    * @return      - Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>
	**/
    public static Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> getGroupKeyVsPatientMap(List<DH_DexOutServiceRisPatientSearchResponse> jsonResponseList){
        Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> groupKeyVsPatientMap = new Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>();
        if(jsonResponseList !=null && !jsonResponseList.isEmpty()){
            for(DH_DexOutServiceRisPatientSearchResponse objectRecord: jsonResponseList){
                if(objectRecord.groupingKey!= null && !groupKeyVsPatientMap.containsKey(objectRecord.groupingKey)){
                    groupKeyVsPatientMap.put(objectRecord.groupingKey,new List<DH_DexOutServiceRisPatientSearchResponse>{objectRecord});
                }else if(objectRecord.groupingKey!= null && groupKeyVsPatientMap.containsKey(objectRecord.groupingKey)){
                    groupKeyVsPatientMap.get(objectRecord.groupingKey).add(objectRecord);
                }
            }
        }
        return groupKeyVsPatientMap;
    }
    /**
	* @Jira CC-476
    * @description - This method will return the map whose key is groupingKey of the patient record and value is
    *                the list of patient records which are parsed in the DH_DexOutServiceRisPatientSearchResponse wrapper format.
    * @param       - Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>
    * @return      - Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>
	**/
    public static Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> getGroupKeyVsPatientList(Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> groupKeyVsPatientMap){       
        Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> patientMap = new Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>();
        if(!(groupKeyVsPatientMap.isEmpty()) && groupKeyVsPatientMap != null){
            for(Integer key : groupKeyVsPatientMap.keySet()){
                List<DH_DexOutServiceRisPatientSearchResponse> patientList = new List<DH_DexOutServiceRisPatientSearchResponse>();
                patientList = parsingPatientRec(groupKeyVsPatientMap.get(key));
                if(patientList.size()>1){
                    patientList[0].enableRadioButton = false;
                    patientList[0].duplicateDropdown = true;
                    patientList[0].collapseDropdown = true;
                }
                else{
                    patientList[0].enableRadioButton = true;
                    patientList[0].duplicateDropdown = false;
                    patientList[0].collapseDropdown = false;
                }
                patientMap.put(key,patientList);
            }
        }
        return patientMap;
    }
    /**
	* @Jira CC-476
    * @description - This method parses the patient record data in the DH_DexOutServiceRisPatientSearchResponse wrapper class format and
                    sorts the list in ascending order of the sequence number and returns the list of patient records.
    * @param       - List<DH_DexOutServiceRisPatientSearchResponse>
    * @return      - List<DH_DexOutServiceRisPatientSearchResponse>
	**/
    public static List<DH_DexOutServiceRisPatientSearchResponse> parsingPatientRec(List<DH_DexOutServiceRisPatientSearchResponse> patientList){
        List<DH_DexOutServiceRisPatientSearchResponse> patientRecList = new List<DH_DexOutServiceRisPatientSearchResponse>();
        try{
            if(patientList != null){
                for(DH_DexOutServiceRisPatientSearchResponse patientRec : patientList){
                    DH_DexOutServiceRisPatientSearchResponse wrapperObj = new DH_DexOutServiceRisPatientSearchResponse();
                    DH_DexOutServiceRisPatientSearchResponse patient = new DH_DexOutServiceRisPatientSearchResponse();
                    patient.patientKey = patientRec.patientKey;
                    patient.firstName = patientRec.firstName;
                    patient.lastName = patientRec.lastName;
                    patient.middleInitial = patientRec.middleInitial;
                    if(patientRec.birthDate != null && patientRec.birthDate.length()>0){
                        List<String> dob = patientRec.birthDate.split('-');
                        patient.birthDate = dob[1]+'-'+dob[2]+'-'+dob[0];
                    }
                    patient.mrn = patientRec.mrn;
                    patient.address = patientRec.address;               
                    List<String> phNumList = new List<String>();
                    phNumList = getPhNumList(patientRec.phoneNumber);
                    patient.phoneNoList = phNumList;
                     if(phNumList.size()>0 && phNumList != null){
                        String phNumber = '('+ phNumList[0].substring(0,3)+') '+phNumList[0].substring(3,6)+'-'+phNumList[0].substring(6,10);
                        patient.phoneNumber = phNumber;
                    }                         
                    patient.emailAddress = patientRec.emailAddress;
                    patient.systemID = patientRec.systemID;
                    patient.groupingKey = patientRec.groupingKey;
                    patient.previousFirstName = patientRec.previousFirstName;
                    patient.previousLastName = patientRec.previousLastName;
                    DH_DexOutServiceRisPatientSearchResponse.lastContact patientLastContact = new DH_DexOutServiceRisPatientSearchResponse.lastContact();
                    if(patientRec.lastContact != null){
                        if(patientRec.lastContact.lastContactDate != null && patientRec.lastContact.lastContactDate.length()>0){
                            patientLastContact.lastContactDate = DH_GeneralUtility.getTimeStamp(UserInfo.getUserId(),patientRec.lastContact.lastContactDate,'MM-dd-yyyy, hh:mm a');
                        }
                        patientLastContact.lastFollowUpTypeCode = patientRec.lastContact.lastFollowUpTypeCode;
                        patientLastContact.lastContactNotes = patientRec.lastContact.lastContactNotes;
                        patientLastContact.orderedProcedures = patientRec.lastContact.orderedProcedures;
                        patientLastContact.requestedBy = patientRec.lastContact.requestedBy;
                        patientLastContact.siteDescription = patientRec.lastContact.siteDescription;
                        patient.lastContact = patientLastContact;
                    }           
                    if(patientRec.nextScheduledExam != null){
                        DH_DexOutServiceRisPatientSearchResponse.nextScheduledExam patientNextScheduledExam = new DH_DexOutServiceRisPatientSearchResponse.nextScheduledExam();   
                        if(patientRec.nextScheduledExam.scheduledDate != null && patientRec.nextScheduledExam.scheduledDate.length()>0){
                            patientNextScheduledExam.scheduledDate = DH_GeneralUtility.getTimeStamp(UserInfo.getUserId(),patientRec.nextScheduledExam.scheduledDate,'MM-dd-yyyy, hh:mm a');
                        }
                        patientNextScheduledExam.examDescription = patientRec.nextScheduledExam.examDescription;
                        patientNextScheduledExam.requestedBy = patientRec.nextScheduledExam.requestedBy;
                        patientNextScheduledExam.modalityType = patientRec.nextScheduledExam.modalityType;
                        patientNextScheduledExam.siteDescription = patientRec.nextScheduledExam.siteDescription;
                        patient.nextScheduledExam = patientNextScheduledExam;
                    }
                    if(patientRec.openEMROrder != null){
                        DH_DexOutServiceRisPatientSearchResponse.openEMROrder patientOpenEMROrder = new DH_DexOutServiceRisPatientSearchResponse.openEMROrder(); 
                        if(patientRec.openEMROrder.requestedDate != null && patientRec.openEMROrder.requestedDate.length()>0){
                            patientOpenEMROrder.requestedDate = DH_GeneralUtility.getTimeStamp(UserInfo.getUserId(),patientRec.openEMROrder.requestedDate,'MM-dd-yyyy');
                       }
                        patientOpenEMROrder.orderedProcedures = patientRec.openEMROrder.orderedProcedures;
                        patientOpenEMROrder.requestedBy = patientRec.openEMROrder.requestedBy;
                        patientOpenEMROrder.siteDescription = patientRec.openEMROrder.siteDescription;
                        patient.openEMROrder = patientOpenEMROrder;
                    }
                    if(patientRec.openNonEMROrder != null){
                        DH_DexOutServiceRisPatientSearchResponse.openNonEMROrder patientOpenNonEMROrder = new DH_DexOutServiceRisPatientSearchResponse.openNonEMROrder();
                        if(patientRec.openNonEMROrder.requestedDate != null && patientRec.openNonEMROrder.requestedDate.length()>0){
                            patientOpenNonEMROrder.requestedDate = DH_GeneralUtility.getTimeStamp(UserInfo.getUserId(),patientRec.openNonEMROrder.requestedDate,'MM-dd-yyyy');
                        }
                        patientOpenNonEMROrder.emrCode = patientRec.openNonEMROrder.emrCode;
                        patientOpenNonEMROrder.requestedBy = patientRec.openNonEMROrder.requestedBy;
                        patientOpenNonEMROrder.orderedProcedures = patientRec.openNonEMROrder.orderedProcedures;
                        patientOpenNonEMROrder.siteDescription = patientRec.openNonEMROrder.siteDescription;
                        patient.openNonEMROrder = patientOpenNonEMROrder;
                    }
                    if(patientRec.lastPerformedExam != null){
                        DH_DexOutServiceRisPatientSearchResponse.lastPerformedExam patientLastPerformedExam = new DH_DexOutServiceRisPatientSearchResponse.lastPerformedExam();
                        if(patientRec.lastPerformedExam.scheduledDate != null && patientRec.lastPerformedExam.scheduledDate.length()>0){
                            patientLastPerformedExam.scheduledDate = DH_GeneralUtility.getTimeStamp(UserInfo.getUserId(),patientRec.lastPerformedExam.scheduledDate,'MM-dd-yyyy');
                        }
                        patientLastPerformedExam.examDescription = patientRec.lastPerformedExam.examDescription;
                        patientLastPerformedExam.requestedBy = patientRec.lastPerformedExam.requestedBy;
                        patientLastPerformedExam.modalityType = patientRec.lastPerformedExam.modalityType;
                        patientLastPerformedExam.siteDescription = patientRec.lastPerformedExam.siteDescription;
                        patient.lastPerformedExam = patientLastPerformedExam;
                    }
                    if((patientRec.lastPerformedExam == null) && (patientRec.openNonEMROrder == null) && (patientRec.openEMROrder == null) && (patientRec.nextScheduledExam == null) && (patientRec.lastContact == null)){
                        patient.noChildDetails=true;
                    }
                    patientRecList.add(patient);
                }
            } 
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR+ex.getMessage());
        }
        return patientRecList;
    }
    /**
	* @Jira CC-476
    * @description - This method will take the string of phone numbers and will return the phone numbers list which are derived from the string.
    * @param       - String
    * @return      - List<String>
	**/
    public static List<String> getPhNumList(String phNo){       
		List<String> phoneNumbers = new List<String>();
        if(phNo != null){
            pattern myPattern = pattern.compile('\\(?(\\d{3})\\)?[- .]?\\d{3}[- .]?\\d{4}');
            matcher myMatcher = myPattern.matcher(phNo);
            while (myMatcher.find()) {
                String phoneNumber = myMatcher.group();
                String output = phoneNumber.replaceAll('\\(', '').replaceAll('\\)', '').replaceAll('\\-', '').replaceAll(' ', '');
                phoneNumbers.add(output);
            }
        }
        return phoneNumbers;
    }
}