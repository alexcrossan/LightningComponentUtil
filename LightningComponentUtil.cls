public with sharing class LightningComponentUtil{
	/*
	 * A collection of generic functions regularly used across Lightning Components
	 */
	

	 public static Boolean checkAccess(String objectName){
		/* This function checks that the current user has read access to the object.
		 * Returns a boolean indicating read access for the current user.
		*/		

	 	return checkAccess(objectName, 'Read');

	 }

	public static Boolean checkAccess(String objectName, String accessLevel){
		/* This function checks that the current user has the defined level of access to the object.
		 * Returns a boolean indicating accessibility for the current user.
		*/		

		SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

		if(accessLevel=='Read'){
			if(objectType.getDescribe().isAccessible()){
				return True;
			} else{
				return False
			}
		}else if(accessLevel=='Create'){
			if(objectType.getDescribe().isCreateable()){
				return True;
			} else{
				return False
			}
		}

		//TODO Extend for other types of access levels

	}


	public static Map<String,Boolean> checkObjectAccess(String objectName, Set<String> fieldNameSet){
		/* Lightning Components do not check Object access before displaying records. 
		 * This function checks that the current user has access to the record being displayed, and then checks the individual fields that are attempting to view.
		 * Returns a map indicating field accessibility for the current user, or throws an error if they don't have access to the object.
		*/
		
		Map<String,Boolean> fieldAccess = new Map<String,Boolean>();
		SObjectType ObjectType = Schema.getGlobalDescribe().get(objectName);
		
		if(!ObjectType.getDescribe().isAccessible()){
			throw new System.NoAccessException();
		} else{
			fieldAccess = checkFieldAccess(objectName, fieldNameSet);
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
	
	public static Boolean checkCreateAccess(String objectType){
        /* Lightning Components do not check for Create permission when inserting records.
         * This function checks that the user does have the 'Create' permission for the object being inserted.
         * When using this, devs should check for access before inserting any records.
        */
        Boolean hasCreateAccess = false;
        SObjectType sObjectType = Schema.getGlobalDescribe().get(objectType);

        if(sObjectType.getDescribe().isCreateable()){
            hasCreateAccess = true;
        }

        return hasCreateAccess;
    	
    }
}
