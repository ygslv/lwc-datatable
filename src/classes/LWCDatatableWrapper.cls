public with sharing class LWCDatatableWrapper {

    public static List<SObject> getData(String objectApiName) {

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

    @AuraEnabled
    public static DataWrapper initialDataRequest(String objectApiName) {
        try {
            DataWrapper dataWrapper = new DataWrapper()
                    .setColumns(getColumns(objectApiName))
                    .setData(getData(objectApiName));

            return dataWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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

    private class CustomException extends Exception {
    }
}