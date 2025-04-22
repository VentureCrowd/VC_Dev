/**

**/
public class VenturecrowdVerificationController {

      public string sName{get;set;}    
    public VenturecrowdVerificationController() {

    }

    public Pagereference upsertRecord() {
        system.debug('Inside Upsert');
        this.sName = 'updated';
        return null;
    }
    
}