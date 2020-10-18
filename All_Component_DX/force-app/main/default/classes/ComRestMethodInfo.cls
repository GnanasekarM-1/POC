/**
 * @description This class is used to capture the method information which needs be executed on the matching 'Impl' class's instance.
 */
global class ComRestMethodInfo 
{    
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
    global ComRestMethodInfo(){}
    /**
     * @description The parametarised constructor for the sake of convinience
     * @param mname Name of the method
     * @param mtype Type of the method
     */
    global ComRestMethodInfo(String mname, String mtype)
    {
        MethodName = mname;
        MethodType = mtype;
    }
}