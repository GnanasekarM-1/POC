/**
 * Interface to be implemented by all BatchApex classes that can be chained.
*/

public interface WSCH_BatchApex_Interface {

    boolean hasPendingObjects();
    
    void startBatch();    
}