public with sharing class EstimateController {
    public Order__C orderdata { get; set; }
    public Order__C cancelorder { get; set; }
    public string memberrecordid { get; set; }
    public string Accountrecordid { get; set; }  
    public ToDo__c todorecord { get; set; }
    public ToDo__c updatedTodorecord { get; set; }
    public string uuid { get; set; }
    public  void EstimateOrderdata() {
      String recordId = memberrecordid ;// ApexPages.currentPage().getParameters().get('recordid');
      system.debug('recordIdNDR'+ recordId);
      Orderdata = EstimateUtility.EstimateOrderData(recordId);
      system.debug(Orderdata);
    
 }
 public  void cancelOrderdata() {
    String OrderId = orderdata.Id ;// ApexPages.currentPage().getParameters().get('recordid');
    system.debug('cancleOrderRecordIdNDR'+ OrderId);
    cancelorder = EstimateUtility.CancelEstimate(OrderId);
    system.debug(cancelorder);

}
public  void paymentNavigation() {
    updatedTodorecord = EstimateUtility.paymentProceed(todorecord);
    system.debug(cancelorder);

}
}