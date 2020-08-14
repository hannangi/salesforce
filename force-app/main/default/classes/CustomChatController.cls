/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-13-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   08-13-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class CustomChatController {


    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 08-13-2020 
    * @return CurrentLoggedInUser 
    **/
    @AuraEnabled
    public static CurrentLoggedInUser  getCurrentLoggedInUserInfo() {     
        DateTime now = DateTime.now();
        Integer hours = now.hour(), minutes = now.minute(), seconds = now.second();
        // System.debug(now);
        // System.debug(hours+':'+minutes+':'+seconds);              
        CurrentLoggedInUser currentLoggedInUser=new CurrentLoggedInUser();
        User user = [Select id,name from user where id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        currentLoggedInUser.Name=user.name;
        currentLoggedInUser.sfdcId=user.id;
        currentLoggedInUser.currentLoggedinTime=hours+':'+minutes+':'+seconds;
        return currentLoggedInUser;
    }


    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 08-13-2020 
    * @param message 
    * @return string 
    **/
    @AuraEnabled
    public static Boolean saveToMessageLog(String message){
        Boolean isSuccess=false;
        List<MessageLog__C> messageLogList = new List<MessageLog__C>();
        MessageLog__C messageLog= new MessageLog__C();
        messageLog.Message__C=message;
        messageLog.MessageType__C='Inbound';
        messageLog.User__C=UserInfo.getUserId();
        messageLogList.add(messageLog);
        Database.SaveResult[] results = Database.insert(messageLogList,false);

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                isSuccess=true;
                System.debug('Successfully Saved to MessageLog.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        return isSuccess;
    }

    public class CurrentLoggedInUser {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public id sfdcId;
        @AuraEnabled
        public String currentLoggedinTime;
    }

}