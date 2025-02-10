/**
 * @description       : Service class to handle geocoding operations using Google Maps Geocoding API
**/

/*To stop the Queueable jobs run the below code
    for ( AsyncApexJob queue: [ Select id from AsyncApexJob where Status not in 

                                           ('Aborted','Completed') and JobType =  'Queueable'] ){

      System.AbortJob(queue.Id);

}
*/

public class GeoCodingService {
    // URL for the Geocoding API
    private static final String GEOCODING_API_URL = 'https://geocode.maps.co/search';
    private static final String API_KEY = '679589c1f0c06233877976bhk7d2140'; // Replace with your actual API key

    // Queueable Apex class for batch geocoding
    public class BatchGeocodeJob implements Queueable {
        private Set<Id> accountIds;

        public BatchGeocodeJob(Set<Id> accountIds) {
            this.accountIds = accountIds;
        }

        public void execute(QueueableContext context) {
            List<Account> accounts = [
                SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Lat__c, Long__c
                FROM Account
                WHERE Id IN :accountIds limit 1
            ];

            Map<Id, Map<String, Double>> accountCoordinates = new Map<Id, Map<String, Double>>();

            for (Account acc : accounts) {
                if (acc.BillingStreet != null && acc.BillingCity != null && acc.BillingState != null &&
                    acc.BillingPostalCode != null && acc.BillingCountry != null) {
                    String address = acc.BillingStreet + ', ' + acc.BillingCity + ', ' + acc.BillingState +
                        ', ' + acc.BillingPostalCode + ', ' + acc.BillingCountry;

                    Map<String, Double> coordinates = getCoordinates(address);
                    if (coordinates != null) {
                        accountCoordinates.put(acc.Id, coordinates);
                    }
                }
            }

            if (!accountCoordinates.isEmpty()) {
                List<Account> accountsToUpdate = new List<Account>();
                for (Id accId : accountCoordinates.keySet()) {
                    Account acc = new Account(Id = accId);
                    acc.Lat__Latitude__s = accountCoordinates.get(accId).get('latitude');
                    acc.Lat__Longitude__s = accountCoordinates.get(accId).get('longitude');
                    accountsToUpdate.add(acc);
                }
                update accountsToUpdate;
            }
        }
    }

    // Helper method to get coordinates for a given address
    private static Map<String, Double> getCoordinates(String address) {
        Map<String, Double> coordinates = new Map<String, Double>();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(GEOCODING_API_URL + '?q=' + EncodingUtil.urlEncode(address, 'UTF-8') + '&api_key=' + API_KEY);
            request.setMethod('GET');

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (results.containsKey('results') && ((List<Object>) results.get('results')).size() > 0) {
                    Map<String, Object> firstResult = (Map<String, Object>) ((List<Object>) results.get('results')).get(0);
                    Map<String, Object> geometry = (Map<String, Object>) firstResult.get('geometry');
                    Map<String, Object> location = (Map<String, Object>) geometry.get('location');

                    coordinates.put('latitude', (Double) location.get('lat'));
                    coordinates.put('longitude', (Double) location.get('lng'));
                }
            }
        } catch (Exception e) {
            System.debug('Error in GeoCodingService: ' + e.getMessage());
        }
        return coordinates;
    }
}

/*public class GeoCodingService {
    // URL for the Google Maps Geocoding API
   // private static final String GEOCODING_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json';
    private static final String GEOCODING_API_URL = 'https://geocode.maps.co/search';
   // API key for accessing the Google Maps Geocoding API
    private static final String API_KEY = '679589c1f0c06233877976bhk7d2140'; // Replace with your actual API key

    /**
     * @description       : Future method to perform geocoding for a batch of accounts asynchronously
     * @param accountIds  : Set of Account IDs to be geocoded
     **/
   /* @future(callout=true)
    public static void batchGeocode(Set<Id> accountIds) {
        // Query the accounts based on the provided IDs
        List<Account> accounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Lat__c,Long__c FROM Account WHERE Id IN :accountIds];
       // Map to store the coordinates for each account
        Map<Id, Map<String, Double>> accountCoordinates = new Map<Id, Map<String, Double>>();

        // Iterate through each account and get the coordinates for the address
        for (Account acc : accounts) {
            if (acc.BillingStreet != null && acc.BillingCity != null && acc.BillingState != null && acc.BillingPostalCode != null && acc.BillingCountry != null) {
                 // Construct the address string
                String address = acc.BillingStreet + ', ' + acc.BillingCity + ', ' + acc.BillingState + ', ' + acc.BillingPostalCode + ', ' + acc.BillingCountry;
                // Get the coordinates for the address
                Map<String, Double> coordinates = getCoordinates(address);
                if (coordinates != null) {
                    accountCoordinates.put(acc.Id, coordinates);
                }
            }
        }

        // Update the accounts with the retrieved coordinates
        if (!accountCoordinates.isEmpty()) {
            List<Account> accountsToUpdate = new List<Account>();
            for (Id accId : accountCoordinates.keySet()) {
                Account acc = new Account(Id = accId);
                //acc.BillingLatitude = accountCoordinates.get(accId).get('latitude');
                //acc.BillingLongitude = accountCoordinates.get(accId).get('longitude');
                acc.Lat__Latitude__s = accountCoordinates.get(accId).get('latitude');
                acc.Lat__Longitude__s = accountCoordinates.get(accId).get('longitude');
                accountsToUpdate.add(acc);
            }
            update accountsToUpdate;
        }
    }

    /**
     * @description       : Helper method to get coordinates for a given address using Google Maps Geocoding API
     * @param address     : The address to be geocoded
     * @return            : A map containing latitude and longitude
     **/

   /* private static Map<String, Double> getCoordinates(String address) {
        Map<String, Double> coordinates = new Map<String, Double>();
        try {
            // Create an HTTP request to the Geocoding API
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(GEOCODING_API_URL + '?q=' + EncodingUtil.urlEncode(address, 'UTF-8') + '&api_key=' + API_KEY);
            request.setMethod('GET');
            
            // Send the request and get the response
            HttpResponse response = http.send(request);
            System.debug('response: ' + response);
            System.debug('response: ' + response.getBody());
            if (response.getStatusCode() == 200) {
                // Parse the JSON response
                System.debug('Inside If');
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('results: ' + results);
                if (results.containsKey('results') && ((List<Object>) results.get('results')).size() > 0) {
                    Map<String, Object> firstResult = (Map<String, Object>) ((List<Object>) results.get('results')).get(0);
                    Map<String, Object> geometry = (Map<String, Object>) firstResult.get('geometry');
                    Map<String, Object> location = (Map<String, Object>) geometry.get('location');
                    
                    // Extract latitude and longitude from the response
                    coordinates.put('latitude', (Double) location.get('lat'));
                    coordinates.put('longitude', (Double) location.get('lng'));
                }
            }
        } catch (Exception e) {
            // Log any errors that occur during the callout
            System.debug('Error in GeoCodingService: ' + e.getMessage());
        }
        return coordinates;
    }*/
//}