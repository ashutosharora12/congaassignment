/**
* @author Ashutosh Arora
* @09-12-2020
*
* @description Conga_ObjectSummary_Controller contains methods to fetch summary data
*/
public class Conga_ObjectSummary_Controller {
    /*******************************************************************************************************
    * @description generic method that returns list of Summary data | label => value pairs for the specified fields fetched dynamically 
    * @parameters sRecordId - record Id for which summary data is to be fetched
    * @parameters sChildToQuery - child relationship name to query total child records
    * returns List SummaryData -> key value pairs of Field Label and it's value
    */
    @AuraEnabled(cacheable=true)
    public static List<SummaryData> getObjectSummaryData(Id sRecordId, String sChildToQuery) {
        List<SummaryData> lstObjectSummaryData = new List<SummaryData>();
        List<Object_Summary__mdt> lstSummaryMeta = new List<Object_Summary__mdt>();
        //get the object api from record Id
        String sObjectApi = sRecordId.getSObjectType().getDescribe().getName();
        //Get all field schema for the specific object
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectApi).getDescribe().fields.getMap();
        try{
            //get dynamic list of fields to display on ui
            lstSummaryMeta = [SELECT Fields__c 
                FROM Object_Summary__mdt
                WHERE DeveloperName =: sObjectApi];
            
            if(lstSummaryMeta.size() > 0){
                String sFieldsToQuery = lstSummaryMeta[0].Fields__c;
                //get List of Field Api Names already fetched from Custom Metadata
                List<String> lstFieldApis = sFieldsToQuery.split(',');

                //get dynamic query
                String sQuery = createDynamicQuery(sFieldsToQuery, sChildToQuery, sObjectApi);
                //execute query
                sObject objDynamicObject = Database.query(sQuery);
                
                //Iterate on list of field api fetched from custom metadata which are to be displayed on summary compoent and populate data to return
                for(String sFieldAPI : lstFieldApis){
                SummaryData objFieldSummary = new SummaryData();
                //Get field label
                objFieldSummary.sLabel = fieldMap.get(sFieldAPI).getDescribe().getLabel();
                //Get field value
                objFieldSummary.sValue = objDynamicObject.get(sFieldAPI) != null ? String.valueOf(objDynamicObject.get(sFieldAPI)) : '-';
                lstObjectSummaryData.add(objFieldSummary);
                }
                //check if Total of child records are to be fetched - child relationship name would be passed from component
                if(String.isNotBlank(sChildToQuery)){
                    SummaryData objFieldSummary = new SummaryData();
                    //Set label as Total + Related Object name
                    objFieldSummary.sLabel = 'Total ' + sChildToQuery;
                    //fetch size of related contacts fetched..
                    objFieldSummary.sValue = String.valueOf(objDynamicObject.getSObjects(sChildToQuery).size());
                    lstObjectSummaryData.add(objFieldSummary);
                }
            }else{
                throw new AuraHandledException('Summary fields not found. Please contact your administrator.');
            }
        }catch(AuraHandledException objAuraException){
            throw objAuraException;
        }
        catch(Exception objException){
            throw new AuraHandledException('Error Occurred while fetching data. Please report this to your Admin.');
        }
        return lstObjectSummaryData;
    }

    /*******************************************************************************************************
    * @description method to create dynamic soql based on fields to query string, child relationship name and object api 
    * @parameters sFieldsToQuery - String with comma separated fields api to query
    * @parameters sChildToQuery - child relationship name to query total child records
    * @parameters sObjectApi - Object Api Name to query
    * returns sQuery -> Dynamic query String
    */
    public static String createDynamicQuery(String sFieldsToQuery, String sChildToQuery, String sObjectApi){
        //Create dynamic query
        String sQuery = 'SELECT ' + sFieldsToQuery;
        // check if child record count is to be fetched.. 
        if(sChildToQuery != null){
        sQuery += ', (SELECT Id FROM ' + sChildToQuery + ')';
        }
        sQuery += ' FROM ' + sObjectApi;
        sQuery += ' WHERE Id=: sRecordId';

        return sQuery;
    }

    /**
    * @author Ashutosh Arora
    * @09-12-2020
    *
    * @description SummaryData Wrapper class with 2 fields - sLabel & sValue
    */
    public class SummaryData{
        @AuraEnabled public string sLabel;
        @AuraEnabled public string sValue;
    }
}