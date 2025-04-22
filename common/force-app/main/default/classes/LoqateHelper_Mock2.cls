@isTest
global class LoqateHelper_Mock2 implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"status":"SUCCESS","messages":[],"payload":[{"_type":"ValidatedAddressAu","fullAddress":"4 CADIGAL PL, DOVER HEIGHTS NSW 2030","country":"Australia","postcode":"2030","street2":null,"street":"CADIGAL PL","streetNumber":"4","postal":"","postalType":"","postalNumber":"","buildingName":"","subdwelling":"","eid":null,"lotNumber":"","flatUnitNumber":"","flatUnitType":"","floorLevelNumber":"","floorLevelType":"","streetSuffix":"","streetType":"PL","streetName":"CADIGAL","attributes":{"CountryIso2":"AU","Barcode":"1301013000101012220220303021323022213","CountryIso3":"AUS","DPID":"90335826","Bsp":"010","PAFPosition":"ROOFTOP"},"id":"AU&#124;AUPAF&#124;90335826","exception":null,"state":"NSW","locality":"DOVER HEIGHTS"}]}');
        res.setStatusCode(200);
        return res;
    }
}