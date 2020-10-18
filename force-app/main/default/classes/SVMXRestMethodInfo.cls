/**
 * @description This class is used to capture the method information which needs be 
                executed on the matching 'Impl' class's instance.
 * @author      Indresh M S
 * @date        09.05.2012 
 */
global class SVMXRestMethodInfo {
    
    /**
     * @description Name of the method
     */
    public String MethodName;
    
    /**
     * @description Type of the method
     */
    public String MethodType;
    
    /**
     * @description The default constructor
     */
    global SVMXRestMethodInfo(){}
    
    /**
     * @description The parametarised constructor for the sake of convinience
     * @param mname Name of the method
     * @param mtype Type of the method
     */
    global SVMXRestMethodInfo(String mname, String mtype){
    	MethodName = mname;
    	MethodType = mtype;
    }
}