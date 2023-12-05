public class QueryBuilder {
    public String query;
    public Set<String> selectedFields;
    public String entity;
    private QueryCondition conditionExpression;
    private String orderBy;
    private Integer limitAmount;
    private String sortingOption;

    // Sorting options
    public final String ASCENDING = 'ASC';
    public final String DESCENDING = 'DSC';

    public QueryBuilder(String objectApiName) {
        query = '';
        entity = objectApiName;
        selectedFields = new Set<String>();
    }

    public QueryBuilder selectField(String field) {
        selectedFields.add(field);
        return this;
    }

    public QueryBuilder selectFields(List<String> fields) {
        for (String field : fields) {
            selectField(field);
        }
        return this;
    }

    public override String toString() {
        // 'SELECT' clause
        query += 'SELECT ';
        query += String.join(new List<String>(selectedFields), ', ');

        // 'FROM' clause
        query += ' FROM ' + entity;

        // 'WHERE' clause
        if(conditionExpression != null) {
            query += ' WHERE ' + conditionExpression.toString();
        }

        // 'ORDER BY' clause
        if(orderBy != null) {
            query += ' ORDER BY ' + orderBy;

            // ASC / DSC
            if(sortingOption != null) {
                query += ' ' + sortingOption;
            }
        }

        // 'LIMIT' clause
        if(limitAmount != null) {
            query += ' LIMIT ' + this.limitAmount;
        }

        return query;
    }

    public QueryBuilder whereClause(QueryCondition conditionExpression) {
        if (!conditionExpression.isEmpty())     this.conditionExpression = conditionExpression;
           return this;
    }

    public QueryBuilder take(Integer limitAmount) {
        this.limitAmount = limitAmount;
        return this;
    }

    public QueryBuilder orderBy(String field) {
        this.orderBy = field;
        return this;
    }

    public QueryBuilder orderBy(String field, String sortingOption) {
        this.orderBy(field);
        this.sortingOption = sortingOption;
        return this;
    }

    public class QueryCondition implements QueryConditionI {
        private Set<String> statements;

        public QueryCondition() {
            statements = new Set<String>();
        }

        public Boolean isEmpty() {
            return statements.size() == 0;
        }

        private void addStatement(String field, String comparisonOperator, Object value) {
            if(value instanceof String) {
                value = '\'' + value + '\'';
            } else if(value instanceof Date) {
                value = String.valueOf((Date) value);
            }

            this.statements.add(String.format('{0} {1} {2}', new List<Object>{ field, comparisonOperator, value }));
        }

        public QueryCondition equals(String field, String value) {
            addStatement(field, '=', value);
            return this;
        }

        public QueryCondition equals(String field, Date aDate) {
            addStatement(field, '=', aDate);
            return this;
        }

        public QueryCondition greaterThan(String field, String value) {
            addStatement(field, '>', value);
            return this;
        }

        public QueryCondition greaterThan(String field, Date aDate) {
            addStatement(field, '>', aDate);
            return this;
        }


        public QueryCondition isLike(String field, String value) {
            addStatement(field, 'LIKE', value);
            return this;
        }

        public QueryCondition andCondition(QueryCondition condition) {
            this.statements.add(' AND ' + condition.toString());
            return this;
        }


        public QueryCondition orCondition(QueryCondition condition) {
            this.statements.add(' OR ' + condition.toString());
            return this;
        }

        public QueryCondition andGroup(QueryCondition condition) {
            this.statements.add(' AND (' + condition.toString() + ')');
            return this;
        }




        public override String toString() {
            List<String> statements = new List<String>(statements);

            for(Integer i = 0; i < statements.size(); i++) {
                // Allow comparison operator chaining without explicit 'AND' condition groupings
                if(i != 0) {
                    // If this QueryCondition doesn't already contain a logical operator prefix automatically assume 'AND'
                    if(!statements[i].startsWith(' AND') && !statements[i].startsWith(' OR')) {
                        statements[i] = ' AND ' + statements[i];
                    }
                }
            }

            return String.join(statements, '');
        }


    }
    interface QueryConditionI {
        // Comparison Operators
        Object equals(String field, String value);						// = 'value'
        Object greaterThan(String field, String value);						// > 2020-07-03
        Object isLike(String field, String value);						// LIKE '%value%'

        // Logical Operators
        Object andCondition(QueryCondition condition);							// AND ...
        Object orCondition(QueryCondition condition);							// OR ...
        Object andGroup(QueryCondition condition);							// AND (...)
    }

}

