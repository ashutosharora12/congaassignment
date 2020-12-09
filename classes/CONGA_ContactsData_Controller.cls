/**
* @author Ashutosh Arora
* @09-12-2020
*
* @description CONGA_ContactsData_Controller apex controller contains method relating to Contacts
*/
public class CONGA_ContactsData_Controller {
    /*******************************************************************************************************
    * @description return list of contacts with specified account id and having title in lstTitles 
    * @parameters sAccountId - parent account id AND lstTitles - list of titles
    * returns List of contacts matching above criteria
    */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsForAccount(String sAccountId, List<String> lstTitles){
        return  [SELECT LastName, Title
                    FROM Contact
                    WHERE Title IN: lstTitles];
    }
}