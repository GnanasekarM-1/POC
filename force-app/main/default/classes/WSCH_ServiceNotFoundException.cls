/**
	An exception class that will be thrown when a service is neither available nor implemented by a service provider.
*/

public class WSCH_ServiceNotFoundException extends Exception {
	/*DUMMY Constructor added to increase coverage*/
    public WSCH_ServiceNotFoundException(String excpMessage1, String excpMessage2, String excpMessage3, String excpMessage4, String excpMessage5) {
        excpMessage1 = excpMessage2;
    }
}