/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class AddressTriggerHandler {
    public static void getGeocoding(List<Account> accounts) {
        System.debug('accounts: '+accounts);
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            if (acc.BillingStreet != null && 
                acc.BillingCity != null && 
                acc.BillingState != null && 
                acc.BillingPostalCode != null && 
                acc.BillingCountry != null) {
                    accountIds.add(acc.Id);
            }
        }
        /*if (!accountIds.isEmpty()) {
            System.debug('Calling batchGeocode: ');
            GeoCodingService.batchGeocode(accountIds);
        }*/
        if (!accountIds.isEmpty()) {
            System.enqueueJob(new GeoCodingService.BatchGeocodeJob(accountIds));
        }
    }
}