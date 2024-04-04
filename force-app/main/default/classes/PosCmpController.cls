public with sharing class PosCmpController {
    public ToDo__c todorecord { get; set; }
    public string uuid { get; set; }
    public Boolean isLoggedIn { get; set; }
    public  void fetchUserType() {
       isLoggedIn = false;
      String userType = UserInfo.getUserType();
      if (userType != 'Guest') {
      isLoggedIn = true;
      system.debug('isLoggedIn++++' + isLoggedIn);
      }
 }
}