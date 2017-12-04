
@isTest
public class LightningComponentUtilTest{

    @testSetup
    public static void createTestData(){

        List<User> userList = new List<User>();

        User adminUser = TestDataCreator.createUser('System Administrator');
        adminUser.FirstName = 'Admin User';
        userList.add(adminUser);

        User chatterUser = TestDataCreator.createUser('Chatter External User');
        chatterUser.FirstName = 'Chatter User';
        userList.add(chatterUser);

        insert userList;
    }

    /*
     * Method to test that the sys admin user has the expected access to fields.
    */
    @isTest
    public static void lightningComponentUtilTest_checkAdminObjectAccess(){

        User adminUser = [SELECT Id FROM User WHERE FirstName = 'Admin User' LIMIT 1];

        Map<String,Boolean> objectAccess = new Map<String,Boolean>();

        System.runAs(adminUser){
            Set<String> fieldNameSet = new Set<String>{'Name', 'Id'};
            objectAccess = EducationLightningUtil.checkObjectAccess('Account', fieldNameSet);
        }

        Map<String,Boolean> expectedObjectAccess = new Map<String,Boolean>();           //The map we would expect.
        expectedObjectAccess.put('Name', true);
        expectedObjectAccess.put('Id', true);

        System.assertEquals(expectedObjectAccess, objectAccess);                        //Check that the expected and returned values are the same.
    }

    /*
     * Method to test that the chatter only user has the expected access to fields.
    */
    @isTest
    public static void lightningComponentUtilTest_checkChatterObjectAccess(){

        User chatterUser = [SELECT Id FROM User WHERE FirstName = 'Chatter User' LIMIT 1];
        Map<String,Boolean> objectAccess = new Map<String,Boolean>();
        Boolean hasException = false;

        System.runAs(chatterUser){

            Set<String> fieldNameSet = new Set<String>{'Name', 'Id'};
            try{
                objectAccess = EducationLightningUtil.checkObjectAccess('Account', fieldNameSet);
            } catch (Exception e){
                hasException = true;
            }
        }

        System.assertEquals(true, hasException);                                    //Check that the expected and returned values are the same.
    }

    /*
     * Method to test building a query to ensure that the expected query is returned.
    */
    @isTest
    public static void lightningComponentUtilTest_buildAdminQuery(){

        User adminUser = [SELECT Id FROM User WHERE FirstName = 'Admin User' LIMIT 1];
        String returnedQuery;

        System.runAs(adminUser){
            Set<String> fieldNameSet = new Set<String>{'Name'};
            returnedQuery = EducationLightningUtil.buildQuery('Account', fieldNameSet);
        }

        String expectedQuery = 'SELECT Id, Name FROM Account';
        System.assertEquals(expectedQuery, returnedQuery);                              //Check expected and returned queries are the same.

    }

    /*
     * Method to test checking that the admin user has create permission on the object.
    */
    @isTest
    public static void lightningComponentUtilTest_checkAdminCreateAccess(){

        User adminUser = [SELECT Id FROM User WHERE FirstName = 'Admin User' LIMIT 1];
        Boolean hasAccess;

        System.runAs(adminUser){
            hasAccess = EducationLightningUtil.checkCreateAccess('Account');
        }
        
        System.assert(hasAccess);                                                       //Sys admin should have access.
    }

    /*
     * Method to check that the chatter user does not have create permission on the object.
    */
    @isTest
    public static void lightningComponentUtilTest_checkChatterCreateAccess(){

        User chatterUser = [SELECT Id FROM User WHERE FirstName = 'Chatter User' LIMIT 1];
        Boolean hasAccess;

        System.runAs(chatterUser){
            hasAccess = EducationLightningUtil.checkCreateAccess('Account');
        }

        System.assert(!hasAccess);
    }

}