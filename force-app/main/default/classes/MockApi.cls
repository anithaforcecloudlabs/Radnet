@isTest
public with sharing class MockApi implements HttpCalloutMock {
    public class MockResponse {
        public String method;
        public String urlpattern;
        public HttpResponse response;
    }

    Map<String, MockResponse> mockEndpoints;

    public MockApi() {
        this.mockEndpoints = new Map<String, MockResponse>();
    }

    public void addResponse(String method, String urlpattern, Integer status, String body) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(status);
        response.setBody(body);

        MockResponse mr = new MockResponse();
        mr.method = method;
        mr.urlpattern = urlpattern;
        mr.response = response;
        this.mockEndpoints.put(method + '__' + urlpattern, mr);
    }

    public void addNotToRequest(String method, String urlpattern) {
        MockResponse mr = new MockResponse();
        mr.method = method;
        mr.urlpattern = urlpattern;
        this.mockEndpoints.put(urlpattern, mr);
    }

    public HTTPResponse respond(HTTPRequest request) {
        String method = request.getMethod();
        String endpoint = request.getEndpoint();

        for (String key : this.mockEndpoints.keySet()) {
            MockResponse mr = this.mockEndpoints.get(key);
            if (endpoint.contains(mr.urlpattern)) {
                if (mr.method == method) {
                    Assert.areNotEqual(null, mr.response, 'should not have called the api for ' + mr.method + ' ' + mr.urlpattern);
                    return mr.response;
                }
            }
        }
        return null;
    }
}