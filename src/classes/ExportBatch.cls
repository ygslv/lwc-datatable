/**
 * Created by whydi on 12/9/2023.
 */

public with sharing class ExportBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator('');
    }

    public void execute(Database.BatchableContext bc, List<SObject> state) {

    }

    public void finish(Database.BatchableContext bc) {

    }
}