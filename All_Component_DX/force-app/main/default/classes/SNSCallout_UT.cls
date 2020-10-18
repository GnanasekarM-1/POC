@isTest
public class SNSCallout_UT 
{
     @isTest static void testCallout() 
     {
        // Set mock callout class 
        SVMXC__SM_SNS_Detail__c newDetail = new SVMXC__SM_SNS_Detail__c();
        newDetail.SVMXC__SM_User__c=Userinfo.getUserId();
        newDetail.SVMXC__SM_TargetArn__c='test';
        insert newDetail;        // 
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new SNSCallout_UT.MockHttpResponseGenerator());
        SNSCallout.callingOut('test');
    }
    
    @isTest static void testCallOutWithOutResponse()
    {
        SVMXC__SM_SNS_Detail__c newDetail = new SVMXC__SM_SNS_Detail__c();
        newDetail.SVMXC__SM_User__c=Userinfo.getUserId();
        newDetail.SVMXC__SM_TargetArn__c='test';
        insert newDetail;
        SNSCallout.callingOut('test');    
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock 
    {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) 
        {
            // Optionally, only send a mock response for a specific endpoint and method.
            // Create a fake response
            List<SNSCallout.ARN> arnListTest = new List<SNSCallout.ARN> ();
            SNSCallout.ARN newARN = new SNSCallout.ARN();
            newARN.arn='test';
            newARN.StatusCode='400';
            arnListTest.add(newARN);
        
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body  = JSON.serialize(arnListTest);
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}