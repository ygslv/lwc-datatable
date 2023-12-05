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
        if (describeSObjectResult == null) errorMessage = System.Label.ObjectNotFound.replace('{0}', objectApiName);
        else if (fieldSet == null) errorMessage = System.Label.FieldsetNotFound.replace('{0}', objectApiName);

        if (errorMessage != null) throw new CustomException(errorMessage);
    }

    public final static String FIELDSET_NAME_PATTERN = 'LWCDatatable{0}List';

    @AuraEnabled
    public static DatatableWrapper getData(
            String objectApiName,
            List<String> columns,
            String lastRecordId,
            Integer limitRowsPerRequest,
            Boolean isInitialRequest,
            String searchValue
    )
    {
        try {
            LWCDatatableWrapper.objectApiName = objectApiName;
            DatatableWrapper datatableWrapper = new DatatableWrapper();
            setDescribes();
            if (isInitialRequest) {

                List<ColumnWrapper> wrappedColumns = getColumns();
                datatableWrapper.setColumns(wrappedColumns);
                columns.clear();
                for (ColumnWrapper column : wrappedColumns) {
                    columns.add(column.fieldName);
                }
            }

            List<SObject> data = queryData(objectApiName, lastRecordId, limitRowsPerRequest, isInitialRequest, columns, searchValue);
            datatableWrapper.setData(data);
            System.debug(datatableWrapper);
            return datatableWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<SObject> queryData(String objectApiName, String lastRecordId, Integer lim, Boolean isInitial, List<String> fieldsToQuery, String searchValue) {
        QueryBuilder queryBuilder = new QueryBuilder(objectApiName);
        QueryBuilder.QueryCondition queryCondition = new QueryBuilder.QueryCondition();
        QueryBuilder.QueryCondition searchCondition;

        if (searchValue != '' && searchValue != null) {
            searchCondition = new QueryBuilder.QueryCondition();
            Boolean firstIn = true;
            for (FieldSetMember fsm : fieldSet.getFields()) {
                QueryBuilder.QueryCondition condition = new QueryBuilder.QueryCondition();
                // PICKLIST
                switch on String.valueOf(fsm.type) {
                    when 'REFERENCE', 'ID' {
                        if (searchValue.length() == 18) condition.equals(fsm.fieldPath, searchValue);
                    }
                    when 'STRING' {
                        condition.isLike(fsm.fieldPath, '%'+searchValue+'%');
                    }
                }
                if (condition.isEmpty()) continue;
                if (firstIn) {
                    searchCondition = condition;
                    firstIn = false;
                    continue;
                }
                searchCondition.orCondition(condition);
            }
        }
        if (!isInitial) queryCondition.greaterThan('Id', lastRecordId);
        if (!isInitial && searchCondition != null) {
            queryCondition.andGroup(searchCondition);
        }
        if (isInitial && searchCondition != null) {
            queryCondition = searchCondition;
        }

        String query = queryBuilder
                .selectFields(fieldsToQuery)
                .whereClause(queryCondition)
                .take(lim)
                .toString();
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