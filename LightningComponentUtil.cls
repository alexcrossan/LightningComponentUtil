public class with sharing LightningComponentUtil{
	/*
	 * A collection of generic functions regularly used across Lightning Components
	 */

	//@AuraEnabled
	public static Map<String,Boolean> checkFieldAccess(Id currentUser, String objectType, Set<String> fieldNameSet){
		/* Lightning Components do not check field level security before displaying record values.
		 * This function takes an object type and a set of fields for that object.
		 * Returns a map indicating the fields accessibility for the current user.
		 */
        Schema.DescribeSobjectResult describeObject = Schema.describeSObjects(new String[]{objectType})[0];
		Map<String,Schema.SObjectField> fieldDescribeTokens = describeObject.fields.getMap();
		
        Map<String,Boolean> fieldAccess = new Map<String,Boolean>();
		for(String fieldName : fieldNameSet){
			Boolean access = fieldDescribeTokens.get(fieldName).getDescribe().isAccessible();
			fieldAccess.put(fieldName,access);
		}
		System.debug('fieldAccess.size(): ' + fieldAccess.size());

		return fieldAccess;
	
	}
	
	//@AuraEnabled	
	public static String buildQuery(Id currentUser, String objectType, Set<String> fieldNameSet){
		/* Lightning Components do not check field level security before displaying record values.
		 * This function takes an object type and a set of fields for that object.
		 * Returns a SOQL query that only queries fields the user has access to.
		 */
        Schema.DescribeSobjectResult describeObject = Schema.describeSObjects(new String[]{objectType})[0];
		Map<String,Schema.SObjectField> fieldDescribeTokens = describeObject.fields.getMap();
        
		String queryString = 'SELECT Id';
		for(String fieldName : fieldNameSet){
			Boolean access = fieldDescribeTokens.get(fieldName).getDescribe().isAccessible();
			if(access){
				queryString += ', ' + fieldName;
			}
		}

		queryString += ' FROM ' + objectType;
		System.debug('queryString: ' + queryString);

		return queryString;

	}

}