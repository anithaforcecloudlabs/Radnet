@RestResource(urlMapping='/risPatientSearch/*')
global with sharing class RisPatientSearchAPI {
    
    @HttpPost
    global static void searchPatients() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String body = req.requestBody.toString();
            
            // Deserialize input
            DH_DexOutServiceRisPatientSearchRequest inputWrapper = 
                (DH_DexOutServiceRisPatientSearchRequest) 
                JSON.deserialize(body, DH_DexOutServiceRisPatientSearchRequest.class);
            
            // Call your existing method
            Map<Integer, List<DH_DexOutServiceRisPatientSearchResponse>> result =
                DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(inputWrapper);
            
            // Serialize the Map into JSON
            String jsonOutput = JSON.serialize(result);
            
            // Set the response
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(jsonOutput);
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "'+e.getMessage()+'"}');
        }
    }


global class RisPatientSearchResponseWrapper {
    public Map<Integer, List<DH_DexOutServiceRisPatientSearchResponse>> responseData;
    
    global RisPatientSearchResponseWrapper(
        Map<Integer, List<DH_DexOutServiceRisPatientSearchResponse>> data
    ){
        this.responseData = data;
    }
}
}