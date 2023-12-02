public with sharing class LWCDatatableWrapper {

    @AuraEnabled
    public static List<SObject> requestRecords(String objectApiName) {

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectApiName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(getFieldSetName(objectApiName));

        List<String> fieldsToQuery = new List<String>();
        for (FieldSetMember fsm : fieldSetObj.fields) {
            fieldsToQuery.add(fsm.getFieldPath());
        }


        String queryTemplate = 'SELECT {0} FROM {1}';
        String query = String.format(queryTemplate, new List<String>{String.join(fieldsToQuery, ', '), objectApiName});
        return Database.query(query);
    }

    public static String getFieldSetName (String objectApiName) {
        objectApiName = objectApiName.replace('__c', '');
        return 'LWCDatatable'+objectApiName+'List';
    }

    @AuraEnabled
    public static List<ColumnWrapper> requestColumns(String objectApiName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectApiName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(getFieldSetName(objectApiName));

        List<ColumnWrapper> columns = new List<ColumnWrapper>();
        for (FieldSetMember fsm : fieldSetObj.fields) {
            columns.add(new ColumnWrapper(fsm.label, fsm.fieldPath));
        }

        return columns;
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
}