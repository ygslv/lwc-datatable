import {LightningElement, track, api, wire} from 'lwc';
import {Toast} from "c/utilities"

import requestData from "@salesforce/apex/LWCDatatableWrapper.getData";

import objectNotFound from "@salesforce/label/c.ObjectNotFound";
import fieldsetNotFound from "@salesforce/label/c.FieldsetNotFound";

const LIMIT = 10;

export default class LwcDatatableWrapper extends LightningElement {

    @api c__objectApiName;
    @api
    get objectApiName() {
        return this.c__objectApiName || this._objectApiName;
    }
    set objectApiName(value){
        this._objectApiName = value;
    }

    @api illustration = 'fishingDeals';
    get illustrationMessage() {
        if (this.objectNotFound) return objectNotFound.replace('{0}', this.objectApiName);
        if (this.fieldsetNotFound) return fieldsetNotFound.replace('{0}', this.objectApiName);

        return 'Unknown Error';
    }

    @track columns = [];
    @track data = [];

    isLoading = true;

    // ====== Getters ====== //

    get hasData() {
        return this.data && this.data.length > 0
    }

    connectedCallback() {
        this.setupDefaultRequestParams();
        this.handleInitialLoad();
    }

    setupDefaultRequestParams() {
        const getLastRecordId = () => {
            return this.data[this.data.length-1]?.Id
        }
        const getColumns = () => {
            return this.columns.map(({fieldName}) => fieldName);
        }

        this.requestParams = {
            objectApiName: this.objectApiName,
            limitRowsPerRequest: LIMIT,
            isInitialRequest: true,
            get columns() { return getColumns() },
            get lastRecordId() { return getLastRecordId() }
        }
    }

    // ====== Handlers ====== //

    handleFilterApply(event) {}

    handleSearchKeyChange(event) {}

    handleExportButtonClick(event) {}

    async handleInitialLoad() {
        const responseFn = (response) => {
            const {data, columns}  = response;
            this.data = data;
            this.columns = columns;
            this.requestParams.isInitialRequest = false;
        }

        const errorFn = (error) => {
            this.objectNotFound = error.body?.message === objectNotFound.replace('{0}', this.objectApiName);
            this.fieldsetNotFound = error.body?.message === fieldsetNotFound.replace('{0}', this.objectApiName);
            this.showErrorToast(error)
        }

        await this.requestData(responseFn, errorFn);
        this.isLoading = false;
    }

    async handleLoadMore({target}) {
        if (target) target.isLoading = true;

        const callbackFn = (response) => {
            const {data} = response
            this.data = [...this.data, ...data]
            if (data.length < LIMIT) target.enableInfiniteLoading = false;
            target.isLoading = false;
        }

        await this.requestData(callbackFn);
    }

    async requestData(responseFn, errorFn = (error) => {this.showErrorToast(error)}) {
        await requestData(this.requestParams)
            .then((response) => responseFn(response))
            .catch((error) => errorFn(error))
    }

    // ====== Utility ====== //

    showErrorToast(error) {
        new Toast(
            Toast.emptyString,
            error,
            Toast.variants.error
        ).dispatch()
    }
}