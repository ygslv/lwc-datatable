import {LightningElement, track, api, wire} from 'lwc';
import {Toast} from "c/utilities"

import initialDataRequest from "@salesforce/apex/LWCDatatableWrapper.getData";
import requestData from "@salesforce/apex/LWCDatatableWrapper.getData";

const LIMIT = 10;

export default class LwcDatatableWrapper extends LightningElement {

    isLoading = false;

    @api c__objectApiName;
    @api
    get objectApiName() {
        return this.c__objectApiName || this._objectApiName;
    }
    set objectApiName(value){
        this._objectApiName = value;
    }

    @api illustration = 'fishingDeals';
    message = {header: "", paragraph: 'SOME PARAGRAPH'}

    requestParams = {}

    @track columns;
    @track data;

    connectedCallback() {
        this.setupDefaultRequestParams();
        this.handleInitialLoad();
    }

    setupDefaultRequestParams() {
        const getLastRecordId = () => {
            return this.data && this.data[this.data.length-1]?.Id
        }
        const getColumns = () => {
            return this.columns || [];
        }

        this.requestParams = {
            objectApiName: this.objectApiName,
            limitRowsPerRequest: LIMIT,
            get columns() { return getColumns() },
            get lastRecordId() { return getLastRecordId() }
        }
    }


    // ====== Getters ====== //

    get dataToDisplay() { return this.data}

    get columnsToDisplay() { return this.columns}

    get showDatatable() {return true}

    // ====== Handlers ====== //

    handleFilterApply(event) {}

    handleSearchKeyChange(event) {}

    handleExportButtonClick(event) {}

    handleInitialLoad() {
        if (!this.objectApiName) return

        const callbackFn = (response) => {
            const {data, columns}  = response;
            this.data = data;
            this.columns = columns;
            this.isLoading = false;
        }

        this.requestData(callbackFn);
    }

    handleLoadMore({target}) {
        if (target) target.isLoading = true;

        const callbackFn = (response) => {
            const {data} = response
            this.data = [...this.data, ...data]
            if (data.length < LIMIT) target.enableInfiniteLoading = false;
            target.isLoading = false;
        }

        this.requestData(callbackFn);
    }

    requestData(callbackFn) {
        requestData(this.requestParams)
            .then((response) => callbackFn(response))
            .catch((error) => {this.showErrorToast(error)})
    }

    showErrorToast(error) {

        new Toast(
            Toast.emptyString,
            error,
            Toast.variants.error
        ).dispatch()
    }

}