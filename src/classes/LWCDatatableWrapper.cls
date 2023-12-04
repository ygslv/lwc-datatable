// Rename to DatatableController
public with sharing class LWCDatatableWrapper {

    public static String objectApiName;

    public static Map<String, SObjectType> globalDescribeMap;
    public static DescribeSObjectResult describeSObjectResult;
    public static Map<String, FieldSet> fieldSetMap;

    public static void setDescribes(String objectApiName) {
        globalDescribeMap = Schema.getGlobalDescribe();
        describeSObjectResult = globalDescribeMap.get(objectApiName).getDescribe();
        fieldSetMap = describeSObjectResult.fieldSets.getMap();
    }

    public final static String FIELDSET_NAME_PATTERN = 'LWCDatatable{0}List';

    @AuraEnabled
    public static DatatableWrapper getData(
            String objectApiName,
            List<ColumnWrapper> columns,
            String lastRecordId,
            Integer limitRowsPerRequest
            )
    {
        DatatableWrapper datatableWrapper = new DatatableWrapper();
        setDescribes(objectApiName);
        Boolean isInitial = columns.isEmpty();
         if (isInitial) {
             columns = getColumns(objectApiName);
        }
        List<SObject> data = queryData(objectApiName, lastRecordId, limitRowsPerRequest, isInitial);
        datatableWrapper.setColumns(columns).setData(data);
        return datatableWrapper;
    }

    public static List<SObject> queryData(String objectApiName, String lastRecordId, Integer limitRowsPerRequest, Boolean isInitial) {
        Schema.FieldSet fieldSet = fieldSetMap.get(FIELDSET_NAME_PATTERN.replace('{0}',  objectApiName.replace('__c', '')));

        List<String> fieldsToQuery = new List<String>();
        for (FieldSetMember fsm : fieldSet.fields) {
            fieldsToQuery.add(fsm.getFieldPath());
        }
        String joinedFieldsToQuery = String.join(fieldsToQuery, ', ');

        String query = '';

        if (isInitial) {
            String queryTemplate = 'SELECT {0} FROM ' + objectApiName + ' LIMIT ' + limitRowsPerRequest;
            query = String.format(
                    queryTemplate, new List<String>{joinedFieldsToQuery});

        } else {
            String queryTemplate = 'SELECT {0} FROM ' + objectApiName + ' WHERE {1} LIMIT ' + limitRowsPerRequest;
            query = String.format(
                    queryTemplate, new List<String>{joinedFieldsToQuery, 'Id > :lastRecordId'});
        }
        System.debug('query: ' + query);
        return Database.query(query);
    }


    public static List<SObject> getData(String objectApiName, String lastRecordId) {

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectApiName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(getFieldSetName(objectApiName));

        List<String> fieldsToQuery = new List<String>();
        for (FieldSetMember fsm : fieldSetObj.fields) {
            fieldsToQuery.add(fsm.getFieldPath());
        }


        String queryTemplate = 'SELECT {0} FROM {1} WHERE {2} LIMIT {3}';
        String query = String.format(
                queryTemplate, new List<String>{String.join(fieldsToQuery, ', '), objectApiName, 'Id > :lastRecordId', '10'});
        return Database.query(query);
    }

    public static String getFieldSetName (String objectApiName) {
        try {
            objectApiName = objectApiName.replace('__c', '');
            final String fieldSetName = 'LWCDatatable'+objectApiName+'List';

            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectApiName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(fieldSetName);

            if (fieldSetObj == null) {
                throw new CustomException('No fieldset for ' + objectApiName + ' created (format LWCDatatable{objectApiName}List');
            }
            return fieldSetName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<ColumnWrapper> getColumns(String objectApiName) {
        Schema.FieldSet fieldSet = fieldSetMap.get(FIELDSET_NAME_PATTERN.replace('{0}',  objectApiName.replace('__c', '')));

        List<ColumnWrapper> columns = new List<ColumnWrapper>();
        for (FieldSetMember fsm : fieldSet.fields) {
            columns.add(new ColumnWrapper(fsm.label, fsm.fieldPath));
        }

        return columns;
    }

    @AuraEnabled
    public static DataWrapper initialDataRequest(String objectApiName, Integer lim, String lastItemId) {
        try {
            DataWrapper dataWrapper = new DataWrapper()
                    .setColumns(getColumns(objectApiName))
                    .setData(getData(objectApiName, lastItemId));

            return dataWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DatatableWrapper {

        @AuraEnabled
        public List<SObject> data;
        @AuraEnabled
        public List<ColumnWrapper> columns;

        public DatatableWrapper() {
        }

        public DatatableWrapper(List<SObject> data, List<ColumnWrapper> columns) {
            this.setData(data);
            this.setColumns(columns);
        }

        public DatatableWrapper setData(List<SObject> data) {
            this.data = data;
            return this;
        }
        public DatatableWrapper setColumns(List<ColumnWrapper> columns) {
            this.columns = columns;
            return this;
        }
    }

    public class DataWrapper {

        @AuraEnabled
        public List<SObject> data;
        @AuraEnabled
        public List<ColumnWrapper> columns;

        public DataWrapper() {
        }

        public DataWrapper setData(List<SObject> data) {
            this.data = data;
            return this;
        }
        public DataWrapper setColumns(List<ColumnWrapper> columns) {
            this.columns = columns;
            return this;
        }
    }

    public class ColumnWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;

        public ColumnWrapper() {}

        public ColumnWrapper(String label, String fieldName) {
            this.setLabel(label);
            this.setFieldName(fieldName);
        }

        public ColumnWrapper setLabel(String label) {
            this.label = label;
            return this;
        }

        public ColumnWrapper setFieldName(String fieldName) {
            this.fieldName = fieldName;
            return this;
        }
    }

    private class CustomException extends Exception {}
}