public withOut sharing class EstimateUtility {

    public static Order__C EstimateOrderData(string RecordId) {
      List < Order__C > Orderdatalist = new list < Order__C > ();
      try {
        string Estimate = 'Estimate';
        String Orderstring = 'SELECT ' + SYS_Helper.getAllFieldsFor('Order__c') +
          ', ' + SYS_Helper.getAllParentFields('Member__r.', 'Contact') +
          ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Order_Item__c') + ' FROM  Order_Items__r)' +
          ' FROM Order__c WHERE (Member__c =: RecordId) AND (Status__c =: Estimate)';
        system.debug('members serch' + Orderstring);
        Orderdatalist = Database.query(Orderstring);
        system.debug('fetchRecordNDR' + Orderdatalist);
      } catch (Exception e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
      }
      return (Orderdatalist.size() > 0) ? (Orderdatalist[0]) : (new Order__c());
    }
    public static Order__C CancelEstimate(string OrderId) {
      Order__c Orderdata;
      try {
        String Orderstring = 'SELECT ' + SYS_Helper.getAllFieldsFor('Order__c') +
          +' FROM Order__c WHERE (Id =: OrderId)';
        system.debug('members serch' + Orderstring);
        Orderdata = Database.query(Orderstring);
        Orderdata.Status__c = 'Cancelled';
        update Orderdata;
        system.debug('fetchRecordNDR' + Orderdata);
  
      } catch (Exception e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
      }
      return (Orderdata != null) ? (Orderdata) : (new Order__c());
    }
    public static ToDo__c paymentProceed( ToDo__c todorecord) {
       
        try {
            todorecord.Status__c = 'Completed';
          update todorecord;
          system.debug('fetchRecordNDR' + todorecord);
    
        } catch (Exception e) {
          System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return (todorecord != null) ? (todorecord) : (new ToDo__c());
      }
     
  }