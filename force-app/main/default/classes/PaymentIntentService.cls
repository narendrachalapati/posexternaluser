public without sharing class PaymentIntentService {

    public static List<Payment_Intent__c> getPaymentRequestByUUID(String uuid) {
        return [SELECT Id,Name,
                Account__c,
                Account__r.Name,
                Contact__c,
                Contact__r.Name,
                Contact__r.LastName,
                Contact__r.FirstName,
                Contact__r.Phone_Number__c,
                Contact__r.Email,
                Contact__r.StripeCustomerId__c,
                Contact__r.Default_Payment_Method__c,
                Order__c,
                Order__r.Name,
                Order__r.Order_Type__c,
                Amount__c,
                Frequency__c,
                Currency_Code__c,Email__c,First_Charge_Date__c,Payment_Link__c,
                Payment_Reference_Id__c,Payment_Type__c,Status__c,UUID__c FROM Payment_Intent__c WHERE UUID__c = :uuid];
    }

    public static Payment_Intent__c getPaymentIntent(Id id) {
        return [SELECT Id,Name,
                Account__c,
                Account__r.Name,
                Contact__c,
                Contact__r.Name,
                Contact__r.LastName,
                Contact__r.FirstName,
                Contact__r.Phone_Number__c,
                Contact__r.Email,
                Contact__r.StripeCustomerId__c,
                Contact__r.Default_Payment_Method__c,
                Order__c,
                Order__r.Name,
                Order__r.Order_Type__c,
                Amount__c,
                Frequency__c,
                Currency_Code__c,Email__c,First_Charge_Date__c,Payment_Link__c,
                Payment_Reference_Id__c,Payment_Type__c,Status__c,UUID__c FROM Payment_Intent__c WHERE Id = :id];
    }

    public static Payment_Intent__c createNewPaymentIntent(
            String paymentName,
            Id contactId,
            Id accountId,
            Id orderId,
            String paymentType,
            Double amount,
            String email,
            String frequency,
            Date firstChargeDate) {
                //Name Field MAX Size Truncate
                Integer fieldmaxSize = 80;
                if(paymentName.length() > fieldmaxSize ){
                    paymentName = paymentName.substring(0, fieldmaxSize);
                }

                Payment_Intent__c paymentIntent = new Payment_Intent__c(
                Name = paymentName,
                Contact__c = contactId,
                Account__c = accountId,
                Order__c = orderId,
                Email__c = email,
                Payment_Type__c = paymentType,
                Frequency__c = frequency,
                First_Charge_Date__c = firstChargeDate,
                Amount__c = amount,
                Currency_Code__c = UserInfo.getDefaultCurrency(),
                UUID__c = SYS_Helper.getUUID()
        );
        system.debug('paymentIntentNDR'+paymentIntent);
        insert paymentIntent;

        return getPaymentIntent(paymentIntent.Id);
    }
}