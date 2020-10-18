@RestResource(urlMapping='/svmx/rest/SFMExpressionBuilderIntf/*')
global class SFMExpressionBuilderIntf {

	@HttpPost
	global static void doPost() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		SFMExpressionBuilderImpl impl = new SFMExpressionBuilderImpl(req, res);
		impl.invokePost();
	}
}