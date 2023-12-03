import {LightningElement, track, api, wire} from 'lwc';

import initialDataRequest from "@salesforce/apex/LWCDatatableWrapper.initialDataRequest";

export default class LwcDatatableWrapper extends LightningElement {

    @api c__objectApiName;
    @api
    get objectApiName() {
        return this.c__objectApiName || this._objectApiName;
    }
    set objectApiName(value){
        this._objectApiName = value;
    }

    isLoaded = false;


    columns;
    @track data;

    connectedCallback() {
        this.initialDataRequest();
    }

    initialDataRequest() {
        if (!this.objectApiName) return
        const params = {objectApiName: this.objectApiName}
        initialDataRequest(params)
            .then((response) => {
                const {data, columns} = response;
                this.data = data;
                this.columns = columns;
                this.isLoaded = true;
            })
            .catch((error) => {
                console.error(error);
            })
    }

    // ====== Getters ====== //

    get dataToDisplay() { return this.data}

    get columnsToDisplay() { return this.columns}

    get showDatatable() {return true}

    // ====== Handlers ====== //

    handleFilterApply(event) {}

    handleSearchKeyChange(event) {}

    handleExportButtonClick(event) {}

    handleLoadMore(event) {}
}