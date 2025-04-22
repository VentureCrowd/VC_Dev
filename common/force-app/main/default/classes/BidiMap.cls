public class BidiMap {
    private Map<String, String> keyToValueMap = new Map<String, String>();
    private Map<String, String> valueToKeyMap = new Map<String, String>();

    // Constructor that accepts an initializer map
    public BidiMap(Map<String, String> initializer) {
        for (String key : initializer.keySet()) {
            String value = initializer.get(key);
            keyToValueMap.put(key, value);
            valueToKeyMap.put(value, key);
        }
    }

    // Default constructor
    public BidiMap() {}

    public void put(String key, String value) {
        if (keyToValueMap.containsKey(key)) {
            valueToKeyMap.remove(keyToValueMap.get(key));
        }
        if (valueToKeyMap.containsKey(value)) {
            keyToValueMap.remove(valueToKeyMap.get(value));
        }
        keyToValueMap.put(key, value);
        valueToKeyMap.put(value, key);
    }

    public String getValue(String key) {
        return keyToValueMap.get(key);
    }

    public String getKey(String value) {
        return valueToKeyMap.get(value);
    }

    public void removeByKey(String key) {
        String value = keyToValueMap.remove(key);
        if (value != null) {
            valueToKeyMap.remove(value);
        }
    }

    public void removeByValue(String value) {
        String key = valueToKeyMap.remove(value);
        if (key != null) {
            keyToValueMap.remove(key);
        }
    }

    public Boolean containsKey(String key) {
        return keyToValueMap.containsKey(key);
    }

    public Boolean containsValue(String value) {
        return valueToKeyMap.containsKey(value);
    }

    public Set<String> keySet() {
        return keyToValueMap.keySet();
    }

    public Set<String> valueSet() {
        return valueToKeyMap.keySet();
    }
}