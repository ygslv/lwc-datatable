public with sharing class ExportBatch implements Database.Batchable<SObject>, Database.Stateful {
    IBuilder builder;

    List<List<String>> data;
    List<String> columns;
    String query;

    public ExportBatch(IBuilder builder) {
        this.builder = builder;
    }

    public ExportBatch setQuery(String query) {
        this.query = query;
        return this;
    }

    public ExportBatch setColumns(List<String> columns) {
        this.columns = columns;
        return this;
    }

    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> state) {
        for (SObject sObj : state) {
            List<String> row = new List<String>{};
            for (String column : this.columns) {
                row.add(sObj.get(column) != null ? (String) sObj.get(column) : '');
            }
            data.add(row);
        }
    }

    public void finish(Database.BatchableContext bc) {
        builder.setData(this.data).build();
    }
}