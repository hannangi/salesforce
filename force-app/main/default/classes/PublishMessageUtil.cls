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
public without sharing class PublishMessageUtil {

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 08-13-2020 
    * @param messageLogList 
    **/
    public static void publishMessages(List<MessageLog__c> messageLogList){

        List<MessageLogEvent__e> messageLogEventList = new List<MessageLogEvent__e>();

        for (MessageLog__c messageLog : messageLogList) {
            MessageLogEvent__e messageLogEvent = new MessageLogEvent__e();
            messageLogEvent.Message__C=messageLog.Message__C;
            messageLogEvent.MessageType__c=messageLog.MessageType__c;
            messageLogEvent.SfdcUser__C=messageLog.User__C;
            messageLogEventList.add(messageLogEvent);
        }                
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(messageLogEventList);        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        

    }
    
}