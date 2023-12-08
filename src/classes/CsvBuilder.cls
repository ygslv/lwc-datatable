public with sharing class CsvBuilder {

    List<String> data;
    List<String> headers;
    String title;

    public CsvBuilder(List<String> data, List<String> headers, String title) {
        this.data = data;
        this.headers = headers;
        this.title = title;
    }

    public void createFile(String versionData, String title) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        insert cv;
    }

    public void createCSV(){
        String headerRow = String.join(this.headers,',') + '\n';
        String dataStr = headerRow;

        Integer i = 0;
        Integer rowListSize = this.data.size();

        for(String row :this.data){
            i++;
            dataStr += (String)row + ((i != rowListSize) ? '\n' : '');
        }
        this.title += ' - ' + Datetime.now().format() + '.csv';
        createFile(dataStr, this.title);
    }
}