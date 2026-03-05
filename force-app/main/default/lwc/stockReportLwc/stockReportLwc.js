import { LightningElement, track } from "lwc";
import FORM_FACTOR from "@salesforce/client/formFactor";
import getStockRows from "@salesforce/apex/StockReportController.getStockRowsNew";
import getStockRowsDefault from "@salesforce/apex/StockReportController.getStockRowsDefault";
import generatePdf from '@salesforce/apex/StockReportPdfService.generatePdf';
import { NavigationMixin } from 'lightning/navigation';

export default class StockReportCustom extends NavigationMixin(LightningElement) {
    @track routeOptions = [];
    @track routeId;
    @track fromDate;
    @track toDate;
    @track rows = [];
    @track loading = false;
    @track error;
    @track showFilter = false;
    @track sortBy = 'productName';
    @track sortDir = 'asc';
    @track selectedFilter;
    @track showModal = false;
    @track selectedRow = {};

    closeFilter() {
        if (this.showFilter) {
            this.showFilter = false;
        } else {
            this.showFilter = true;
        }
    }


    rows = []; // your existing rows data

    handleProductClick(event) {
        const productCode = event.currentTarget.dataset.id;

        this.selectedRow = this.rows.find(
            row => row.productCode === productCode
        );

        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.selectedRow = {};
    }
    colOptions =
        [{ label: 'Opening Quantity', value: 'openingQty' },
        { label: 'Total stock Received', value: 'totalStockReceived' },
        { label: 'Invoice cancellation', value: 'invoiceCancellation' },
        { label: 'Salable Returns', value: 'saleableReturns' },
        { label: 'Total Saleable Quantity', value: 'totalSaleableQty' },
        { label: 'Sold Quantity', value: 'soldQty' },
        { label: 'Saleable Closing Quantity', value: 'saleableClosingQty' },
        { label: 'Damaged Quantity', value: 'damagedQty' },
        { label: 'Total Quantity', value: 'totalQty' },
        ];


    columns = [
        { label: "Product Code", fieldName: "productCode" },
        { label: "Product", fieldName: "productName" },
        { label: "Opening Quantity", fieldName: "openingQty", type: "number" },
        { label: "Total stock Received", fieldName: "totalStockReceived", type: "number" },
        { label: "Invoice cancellation", fieldName: "invoiceCancellation", type: "number" },
        { label: "Salable Returns", fieldName: "saleableReturns", type: "number" },
        { label: "Total Saleable Quantity", fieldName: "totalSaleableQty", type: "number" },
        { label: "Sold Quantity", fieldName: "soldQty", type: "number" },
        { label: "Saleable Closing Quantity", fieldName: "saleableClosingQty", type: "number" },
        { label: "Damaged Quantity", fieldName: "damagedQty", type: "number" },
        { label: "Total Quantity", fieldName: "totalQty", type: "number" }
    ];
    sortOptions = [
        { label: 'Product', value: 'productName' },
        { label: 'Product Code', value: 'productCode' },
        { label: 'Opening Qty', value: 'openingQty' },
        { label: 'Received Qty', value: 'totalStockReceived' },
        { label: 'Invoice Cancellation', value: 'invoiceCancellation' },
        { label: 'Saleable Returns', value: 'saleableReturns' },
        { label: 'Total Saleable', value: 'totalSaleableQty' },
        { label: 'Sold Qty', value: 'soldQty' },
        { label: 'Closing Qty', value: 'saleableClosingQty' },
        { label: 'Damaged Qty', value: 'damagedQty' },
        { label: 'Total Qty', value: 'totalQty' }
    ];

    dirOptions = [
        { label: 'Ascending', value: 'asc' },
        { label: 'Descending', value: 'desc' }
    ];

    connectedCallback() {
        const { start, end } = this.getCurrentWeekRangeISO();
        this.fromDate = start;
        this.toDate = end;
        this.loadDefaultReport();
    }
    get rowCount() {
        return this.rows?.length || 0;
    }
    get routeName() {
        return this.routeOptions?.find(r => r.value === this.routeId)?.label;
    }
    handleFilterSelection(event) {
        this.selectedFilter = event.detail;
    }

    get isMobile() {
        return FORM_FACTOR === "Small";
    }
    get showTable() {
        return !this.isMobile && this.rows?.length;
    }
    get showCards() {
        return this.isMobile && this.rows?.length;
    }



    onRouteChange(e) { this.routeId = e.detail.value; }
    onFromChange(e) { this.fromDate = e.target.value; }
    onToChange(e) { this.toDate = e.target.value; }
    onSortByChange(e) { this.sortBy = e.detail.value; this.loadReport(); }
    onSortDirChange(e) { this.sortDir = e.detail.value; this.loadReport(); }

    getCurrentWeekRangeISO() {
        const now = new Date();
        const day = now.getDay(); // Sun=0..Sat=6
        const daysSinceMonday = (day + 6) % 7;

        const monday = new Date(now);
        monday.setDate(now.getDate() - daysSinceMonday);

        const sunday = new Date(monday);
        sunday.setDate(monday.getDate() + 6);

        const toISO = (d) => d.toISOString().slice(0, 10);
        return { start: toISO(monday), end: toISO(sunday) };
    }
    loadDefaultReport() {
        this.loading = true;
        this.error = null;
        this.rows = [];
        getStockRowsDefault({
            fromDate: this.fromDate,
            toDate: this.addOneDay(this.toDate),
            sortBy: this.sortBy,
            sortDir: this.sortDir
        }).then(result => {

            this.routeOptions = result.routes.options;
            this.routeId = result.routes.defaultRouteId;
            this.rows = result.reportRows;

            this.loading = false;
        })
            .catch(error => {
                console.error(JSON.stringify(error.message));
                this.loading = false;
            });
    }

    loadReport() {
        this.loading = true;
        this.error = null;
        this.rows = [];
        this.showFilter =false;
        if (!this.routeId) throw new Error("Select a Route.");
        if (!this.fromDate || !this.toDate) throw new Error("Select From and To dates.");
        if (this.fromDate > this.toDate) throw new Error("From Date cannot be after To Date.");
        getStockRows({
            fromDate: this.fromDate,
            toDate: this.addOneDay(this.toDate),
            routeId: this.routeId,
            selectedCol: this.selectedFilter,
            sortBy: this.sortBy,
            sortDir: this.sortDir
        }).then(result => {
            console.log(JSON.stringify(result));
            this.rows = result;
            this.loading = false;
        })
            .catch(error => {
                console.log(JSON.stringify(error.body.message));
                this.loading = false;
            });
    }

    addOneDay(dateStr) {
        // dateStr: "YYYY-MM-DD"
        const [y, m, d] = dateStr.split('-').map(Number);
        const dt = new Date(Date.UTC(y, m - 1, d)); // use UTC to avoid timezone shift
        dt.setUTCDate(dt.getUTCDate() + 1);
        return dt.toISOString().slice(0, 10);
    }

    async downloadPdf() {
        this.loading = true;
        this.error = null;
        try {
            const relative = await generatePdf({
                routeId: this.routeId,
                fromDate: this.fromDate,
                toDate: this.addOneDay(this.toDate),
                selectedCol: this.selectedFilter,
                sortBy: this.sortBy,
                sortDir: this.sortDir
            });
            window.open(relative, '_blank'); // no login prompt

            /* const absoluteUrl = new URL(relative, window.location.origin).toString();
 
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: { url: absoluteUrl }
            }); */
        } catch (e) {
            this.error = e?.body?.message || e.message || 'Download failed.';
        } finally {
            this.loading = false;
        }
    }
}