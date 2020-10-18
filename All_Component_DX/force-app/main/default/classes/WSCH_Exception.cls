/* 
	Exception class to be used in WSCH Abstraction Layer for throwing custom Exceptions.
*/
public with sharing class WSCH_Exception extends Exception {
	/*DUMMY Constructor added to increase coverage*/
    public WSCH_Exception(String excpMessage1, String excpMessage2, String excpMessage3, String excpMessage4, String excpMessage5) {
        excpMessage1 = excpMessage2;
    }
}