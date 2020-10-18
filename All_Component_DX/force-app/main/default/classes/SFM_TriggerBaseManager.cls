public with sharing class SFM_TriggerBaseManager {

    private static SFM_TriggerBaseManager instance = new SFM_TriggerBaseManager();
     
    public static SFM_TriggerBaseManager getInstance() {
        return instance;
    }

    private SFM_TriggerBaseManager() {
    }

    public SFM_TriggerBaseInterface createSFMTrigger(string className) {
        Type t = Type.forName(className);
        if(t == null && className != null) {
            // Attempt to get the type again with the namespace explicitly set to blank
            t = Type.forName('', className);
        }
        if(t == null) {
            System.debug(LoggingLevel.Error, 'Failed to find type for ['+className+']');
            return null;
        }

        // Create an instance to confirm the type
        object testInstance = t.newInstance();
        if(!(testInstance instanceOf SFM_TriggerBaseInterface)) {
            return null;
        }

        SFM_TriggerBaseInterface interfaceInstance = (SFM_TriggerBaseInterface)testInstance;
        return interfaceInstance;
    }
}