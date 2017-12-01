public with sharing class LightningComponentUtil{
	/*
	 * A collection of generic functions regularly used across Lightning Components
	 */
	
	public static Map<String,Boolan> checkObjectAccess(String objectName, Set<String> fieldNameSet){
		/* Lightning Components do not check Object access before displaying records. 
		 * This function checks that the current user has access to the record being displayed, and then checks the individual fields that are attempting to view.
		 * Returns a map indicating field accessibility for the current user, or throws an error if they don't have access to the object.
		*/
		
		Map<String,Boolean> fieldAccess = new Map<String,Boolean>();
		SObjectType sObjectType = Schema.getGlobalDescribe().get(sobjectName);
		
		if(!sObjectType.getDescribe().isAccessible()){
			throw new System.NoAccessException();
		} else{
			fieldAccess = checkFieldAccess(objectType, fieldNameSet);
		}
		
		return fieldAccess;
				
	}
	
	public static Map<String,Boolean> checkFieldAccess(String objectType, Set<String> fieldNameSet){
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
	
	public static String buildQuery(String objectType, Set<String> fieldNameSet){
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
