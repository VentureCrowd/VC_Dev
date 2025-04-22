public class LoqateHelper {
    @AuraEnabled
    public static List<options> loqateFinder(string country, string adress){
        HttpRequest req = new HttpRequest();
        string endPont = 'callout:Loqate_finder?country='+EncodingUtil.urlEncode(country, 'UTF-8')+'&fullAddress='+EncodingUtil.urlEncode(adress, 'UTF-8');
        if(country.equalsIgnoreCase('NZ')){
            endPont += '&sourceOfTruth='+EncodingUtil.urlEncode('NZAD', 'UTF-8');
        }
        req.setEndpoint(endPont);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse response = http.send(req);
        loqateFinderWrapper retwrap = (loqateFinderWrapper) JSON.deserialize(response.getBody().replaceAll('_type','type'),loqateFinderWrapper.class);
        List<options> retOptns = new List<options>();
        for(payload p : retwrap.payload){
            retOptns.add(new options(p.fullAddress,p.id));
        }
        return retOptns;
    }
    public class loqateFinderWrapper{
        @AuraEnabled public string status;
        @AuraEnabled public List<string> messages;
        @AuraEnabled public List<payload> payload;
    }
    public class payload{
        @AuraEnabled public string type;
        @AuraEnabled public string fullAddress;
        @AuraEnabled public Map<string,string> attributes;
        @AuraEnabled public string id;
    }
    public class options{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
        public options(string s1, string s2){
            label = s1;
            value = s2;
        }
    }
    @AuraEnabled
    public static payloadWrapper loqateRetriever(string id){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Loqate_retrieve?id='+EncodingUtil.urlEncode(id, 'UTF-8'));
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse response = http.send(req);
        system.debug(response.getBody());
        loqateRetrieverWrapper retwrap = (loqateRetrieverWrapper) JSON.deserialize(response.getBody().replaceAll('_type','type'),loqateRetrieverWrapper.class);
        return retwrap.payload[0];
    }
    public class loqateRetrieverWrapper{
        @AuraEnabled public string status;
        @AuraEnabled public List<string> messages;
        @AuraEnabled public List<payloadWrapper> payload;
    }
    public class payloadWrapper{
        @AuraEnabled public string type;
        @AuraEnabled public string fullAddress;
        @AuraEnabled public Map<string,string> attributes;
        @AuraEnabled public string id;
        @AuraEnabled public string state;
        @AuraEnabled public string locality;
        @AuraEnabled public string streetName;
        @AuraEnabled public string streetType;
        @AuraEnabled public string streetSuffix;
        @AuraEnabled public string floorLevelType;
        @AuraEnabled public string floorLevelNumber;
        @AuraEnabled public string flatUnitType;
        @AuraEnabled public string flatUnitNumber;
        @AuraEnabled public string lotNumber;
        @AuraEnabled public string eid;
        @AuraEnabled public string subdwelling;
        @AuraEnabled public string buildingName;
        @AuraEnabled public string postalNumber;
        @AuraEnabled public string postalType;
        @AuraEnabled public string postal;
        @AuraEnabled public string streetNumber;
        @AuraEnabled public string street;
        @AuraEnabled public string street2;
        @AuraEnabled public string postcode;
        @AuraEnabled public string country;
        @AuraEnabled public string townCity;
    }
}