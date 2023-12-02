import {LightningElement, track, api, wire} from 'lwc';

import requestRecords from "@salesforce/apex/LWCDatatableWrapper.requestRecords";
import requestColumns from "@salesforce/apex/LWCDatatableWrapper.requestColumns";

const columns = [
    { label: 'Id', fieldName: 'id' },
    { label: 'Name', fieldName: 'name'},
];

export default class LwcDatatableWrapper extends LightningElement {

    columns;
    @track data;
    @api objectApiName;
    dataSource;
    _params;
    @api
    set params(params) {
        this._params = params
    }
    get params() {
        return this._params;
    }

    connectedCallback() {
        this.columns = columns
        this.data = [...Array(50)].map((_, index) => {
            return {
                name: `Name (${index})`,
                website: 'www.salesforce.com',
                amount: Math.floor(Math.random() * 100),
                phone: `${Math.floor(Math.random() * 9000000000) + 1000000000}`,
                closeAt: new Date(
                    Date.now() + 86400000 * Math.ceil(Math.random() * 20)
                ),
            };
        });

        this.dataSource = this.objectApiName ? this.objectApiName : 'front'

        if (this.dataSource !== 'front') {
            this.requestColumns(this.objectApiName);
            this.requestRecords(this.objectApiName);
        }

    }

    requestRecords(objectApiName) {
        requestRecords({objectApiName})
            .then((data) => {
            this.data = data;
        })
            .catch((error) => console.error(error))
    }

    requestColumns(objectApiName) {
        requestColumns({objectApiName})
            .then((data) => {
                this.columns = data;
            })
            .catch((error) => console.error(error))
    }

    // ====== Getters ====== //

    get dataToDisplay() { return this.data}

    get columnsToDisplay() { return this.columns}

    // ====== Handlers ====== //

    handleFilterApply(event) {}

    handleSearchKeyChange(event) {}

    handleExportButtonClick(event) {}
}