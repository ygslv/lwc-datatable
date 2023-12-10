public with sharing class CsvBuilder implements IBuilder{

    List<List<String>> data;
    List<String> columns;
    String objectApiName;

    public void build() {
        String headerRow = String.join(this.columns,',') + '\n';
        String dataStr = headerRow;

        Integer rowIdx = 0;
        Integer rowListSize = this.data.size();

        for(List<String> row : this.data){
            rowIdx++;

            String concatRow = String.join(row, ',');
            dataStr += concatRow + ((rowIdx != rowListSize) ? '\n' : '');
        }
        String titleTemplate = '{2} Export {0} ({1}).{2}';
        String title = String.format(titleTemplate, new List<String>{this.objectApiName, Datetime.now().format(), 'csv'});
        createFile(dataStr, title);
    }

    public CsvBuilder setColumns(List<String> columns) {
        this.columns = columns;
        return this;
    }

    public CsvBuilder setData(List<List<String>> data) {
        this.data = data;
        return this;
    }

    public CsvBuilder setObjectName(String objectApiName) {
        this.objectApiName = objectApiName;
        return this;
    }

    public CsvBuilder() {
    }

    public void createFile(String versionData, String title) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        insert cv;
    }
}