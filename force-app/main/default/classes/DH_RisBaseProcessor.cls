public abstract class DH_RisBaseProcessor {
	
	protected String getUniqueKey(String systemID, String itemKey, String risKey, String recordTypeName) {
		return systemID + '_' + itemKey + '_' + risKey + '_' + recordTypeName;
	}

	protected String getUniqueKey(String systemID, String risKey, String recordTypeName) {
		return systemID + '_' + risKey + '_' + recordTypeName;
	}

	protected String getUniqueKey(String systemID, String risKey) {
		return systemID + '_' + risKey;
	}
}