global class IOTRestMethodInfo {
    
    /**
     * @description Name of the method
     */
    public String MethodName;
    
    /**
     * @description Type of the method
     */
    public String MethodType;

    public String VersionNumber;
    
    /**
     * @description The default constructor
     */
    global IOTRestMethodInfo(){}
    
    /**
     * @description The parametarised constructor for the sake of convinience
     * @param mname Name of the method
     * @param mtype Type of the method
     */
    global IOTRestMethodInfo(String mname, String mtype, String vnumber){
      MethodName = mname;
      MethodType = mtype;
      VersionNumber = vnumber;
    }


}