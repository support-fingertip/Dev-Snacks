import { LightningElement, api, wire } from 'lwc';
import getLatestBranchPrice
    from '@salesforce/apex/ProductBranchLatestPriceController.getLatestBranchPrice';

const COLUMNS = [
    { label: 'Branch Name', fieldName: 'branchName' },
    { label: 'Latest MRP', fieldName: 'price', type: 'currency' },
    { label: 'Stock Date', fieldName: 'stockDate', type: 'date' }
];

export default class ProductBranchLatestPrice extends LightningElement {

    @api recordId; // Product Id
    data;
    error;
    columns = COLUMNS;

    get noData() {
        return this.data && this.data.length === 0;
    }

    @wire(getLatestBranchPrice, { productId: '$recordId' })
    wiredPrices({ error, data }) {
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
            console.error(error);
        }
    }
}