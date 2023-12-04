// Rename to DatatableController
public with sharing class LWCDatatableWrapper {

    private static String objectApiName;

    private static Map<String, SObjectType> globalDescribeMap;
    private static DescribeSObjectResult describeSObjectResult;
    private static FieldSet fieldSet;

    public static void setDescribes() {
        globalDescribeMap = Schema.getGlobalDescribe();
        describeSObjectResult = globalDescribeMap.get(objectApiName)?.getDescribe();
        fieldSet = describeSObjectResult?.fieldSets.getMap().get(FIELDSET_NAME_PATTERN.replace('{0}',  objectApiName.replace('__c', '')));

        validateDescribes();
    }

    public static void validateDescribes(){
        String errorMessage;
        if (describeSObjectResult == null) errorMessage = 'No such object in database';
        else if (fieldSet == null) errorMessage = 'No correct fieldset for your object';

        if (errorMessage != null) throw new CustomException(errorMessage);
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
        try {
            LWCDatatableWrapper.objectApiName = objectApiName;
            DatatableWrapper datatableWrapper = new DatatableWrapper();
            setDescribes();
            Boolean isInitial = columns.isEmpty();
            if (isInitial) {
                columns = getColumns();
            }
            List<SObject> data = queryData(objectApiName, lastRecordId, limitRowsPerRequest, isInitial);
            datatableWrapper.setColumns(columns).setData(data);
            System.debug(datatableWrapper);
            return datatableWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    public static List<SObject> queryData(String objectApiName, String lastRecordId, Integer limitRowsPerRequest, Boolean isInitial) {
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

    public static List<ColumnWrapper> getColumns() {
        List<ColumnWrapper> columns = new List<ColumnWrapper>();
        for (FieldSetMember fsm : fieldSet.fields) {
            columns.add(new ColumnWrapper(fsm.label, fsm.fieldPath));
        }

        return columns;
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