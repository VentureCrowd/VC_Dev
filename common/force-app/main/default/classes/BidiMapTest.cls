@isTest
private class BidiMapTest {
    @isTest
    static void testDefaultConstructor() {
        BidiMap bidibidimap = new BidiMap();
        
        // Test put and get methods
        bidibidimap.put('key1', 'value1');
        System.assertEquals('value1', bidibidimap.getValue('key1'));
        System.assertEquals('key1', bidibidimap.getKey('value1'));
        
        // Test containsKey and containsValue methods
        System.assert(bidibidimap.containsKey('key1'));
        System.assert(bidibidimap.containsValue('value1'));
        
        // Test removeByKey method
        bidibidimap.removeByKey('key1');
        System.assert(!bidibidimap.containsKey('key1'));
        System.assert(!bidibidimap.containsValue('value1'));
        
        // Test removeByValue method
        bidibidimap.put('key2', 'value2');
        bidibidimap.removeByValue('value2');
        System.assert(!bidibidimap.containsKey('key2'));
        System.assert(!bidibidimap.containsValue('value2'));
        
        // Test keySet and valueSet methods
        bidibidimap.put('key3', 'value3');
        Set<String> keys = bidibidimap.keySet();
        Set<String> values = bidibidimap.valueSet();
        System.assert(keys.contains('key3'));
        System.assert(values.contains('value3'));
    }

    @isTest
    static void testInitializerConstructor() {
        Map<String, String> initializer = new Map<String, String>{
            'key1' => 'value1',
            'key2' => 'value2'
        };
        
        BidiMap bidimap = new BidiMap(initializer);
        
        // Test getValue and getKey methods
        System.assertEquals('value1', bidimap.getValue('key1'));
        System.assertEquals('key1', bidimap.getKey('value1'));
        System.assertEquals('value2', bidimap.getValue('key2'));
        System.assertEquals('key2', bidimap.getKey('value2'));
        
        // Test containsKey and containsValue methods
        System.assert(bidimap.containsKey('key1'));
        System.assert(bidimap.containsValue('value1'));
        System.assert(bidimap.containsKey('key2'));
        System.assert(bidimap.containsValue('value2'));
        
        // Test removeByKey method
        bidimap.removeByKey('key1');
        System.assert(!bidimap.containsKey('key1'));
        System.assert(!bidimap.containsValue('value1'));
        
        // Test removeByValue method
        bidimap.removeByValue('value2');
        System.assert(!bidimap.containsKey('key2'));
        System.assert(!bidimap.containsValue('value2'));
        
        // Test keySet and valueSet methods
        bidimap.put('key3', 'value3');
        Set<String> keys = bidimap.keySet();
        Set<String> values = bidimap.valueSet();
        System.assert(keys.contains('key3'));
        System.assert(values.contains('value3'));
    }
    
    @isTest
    static void testOverwrite() {
        BidiMap bidimap = new BidiMap();
        bidimap.put('key1', 'value1');
        bidimap.put('key2', 'value2');
        
        // Overwrite value for key1
        bidimap.put('key1', 'value3');
        System.assertEquals('value3', bidimap.getValue('key1'));
        System.assertEquals('key1', bidimap.getKey('value3'));
        System.assert(!bidimap.containsValue('value1'));
        
        // Overwrite key for value2
        bidimap.put('key3', 'value2');
        System.assertEquals('value2', bidimap.getValue('key3'));
        System.assertEquals('key3', bidimap.getKey('value2'));
        System.assert(!bidimap.containsKey('key2'));
    }
}