public with sharing class SFM_ScheduledBatchUtils {
    private static SFM_ScheduledBatchUtils instance = new SFM_ScheduledBatchUtils();
     
    public static SFM_ScheduledBatchUtils getInstance() {
        return instance;
    }

    private SFM_ScheduledBatchUtils() {
    }

    public static SFM_ScheduledBatchInterface getInstance(string namespace, string className) {
        Type typeClass = Type.forName(className);
        if(typeClass == null && className != null) {
            // Attempt to get the type again with the namespace explicitly set to blank
            typeClass = Type.forName(namespace, className);
        }
        if(typeClass == null) {
            System.debug(LoggingLevel.Error, 'Failed to find type for ['+className+']');
            return null;
        }

        // Create an instance to confirm the type
        object testInstance = typeClass.newInstance();
        if(!(testInstance instanceOf SFM_ScheduledBatchInterface)) { 
            return null;
        }

        SFM_ScheduledBatchInterface interfaceInstance = (SFM_ScheduledBatchInterface)testInstance;
        return interfaceInstance;
    }
}