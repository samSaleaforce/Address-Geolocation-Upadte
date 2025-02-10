/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger AddressTrigger on Account (before insert, before update) {
    if (Trigger.isBefore) {
        System.debug('Entering Trigger:isBefore ');
        if (Trigger.isInsert || Trigger.isUpdate) {
            if (!TriggerUtility.isTriggerExecuted) {
                TriggerUtility.isTriggerExecuted = true;
                System.debug('Entering Trigger: ');
                System.debug('Trigger.new: '+Trigger.new);
                AddressTriggerHandler.getGeocoding(Trigger.new);
                System.debug('Exiting Trigger: ');
            }
        }
    }
}