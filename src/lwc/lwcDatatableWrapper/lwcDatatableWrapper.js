import {LightningElement, track, api, wire} from 'lwc';
import {Toast} from "c/utilities"

import requestData from "@salesforce/apex/LWCDatatableWrapper.getData";

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
    @api illustrationMessage = {header: "", paragraph: 'SOME PARAGRAPH'}

    @track columns ;
    @track data ;

    isLoading = true;

    // ====== Getters ====== //

    get hasData() {
        this.data && this.data.length > 0
    }

    connectedCallback() {
        this.setupDefaultRequestParams();
        this.handleInitialLoad();
    }

    setupDefaultRequestParams() {
        const getLastRecordId = () => {
            return this.data && this.data[this.data.length-1]?.Id
        }
        const getColumns = () => {
            return this.columns;
        }

        this.requestParams = {
            objectApiName: this.objectApiName,
            limitRowsPerRequest: LIMIT,
            get columns() { return getColumns() },
            get lastRecordId() { return getLastRecordId() }
        }
    }

    // ====== Handlers ====== //

    handleFilterApply(event) {}

    handleSearchKeyChange(event) {}

    handleExportButtonClick(event) {}

    async handleInitialLoad() {
        const callbackFn = (response) => {
            const {data, columns}  = response;
            this.data = data;
            this.columns = columns;
        }

        await this.requestData(callbackFn);
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

    async requestData(callbackFn) {
        await requestData(this.requestParams)
            .then((response) => callbackFn(response))
            .catch((error) => {this.showErrorToast(error)})
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