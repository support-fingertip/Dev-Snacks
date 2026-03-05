import { LightningElement, track } from "lwc";
import FORM_FACTOR from "@salesforce/client/formFactor";
import getRoutes from "@salesforce/apex/StockReportController.getRoutes";
import getStockRows from "@salesforce/apex/StockReportController.getStockRowsNew";
import generatePdf from '@salesforce/apex/StockReportPdfService.generatePdf';
import initRoutes from "@salesforce/apex/StockReportController.initRoutes";
import { NavigationMixin } from 'lightning/navigation';

export default class StockReportCustom extends NavigationMixin(LightningElement) {
    @track routeOptions = [];
    @track routeId;

    @track fromDate;
    @track toDate;

    @track rows = [];
    @track loading = false;
    @track error;
    @track selectedFilter;
    @track sortBy = 'productName';
    @track sortDir = 'asc';

    colOptions =
        [{ label: 'Opening Quantity', value: 'openingQty' },
        { label: 'Total stock Received', value: 'totalStockReceived' },
        { label: 'Invoice cancellation', value: 'invoiceCancellation' },
        { label: 'Salable Returns', value: 'saleableReturns' },
        { label: 'Total Saleable Quantity', value: 'totalSaleableQty' },
        { label: 'Sold Quantity', value: 'soldQty' },
        { label: 'Saleable Closing Quantity', value: 'saleableClosingQty' },
        { label: 'Damaged Quantity', value: 'damagedQty' },
          { label: 'Unsealed Quantity', value: 'unsealedQty' },
        { label: 'Total Quantity', value: 'totalQty' },
        ];
    columns = [
        { label: "Product Code", fieldName: "productCode" },
        { label: "Product", fieldName: "productName" },
        { label: "Opening Quantity", fieldName: "openingQty", type: "number" },
        { label: "Total stock Received", fieldName: "totalStockReceived", type: "number" },
        { label: "Invoice cancellation", fieldName: "invoiceCancellation", type: "number" },
              { label: "Unsealed Quantity", fieldName: "unsealedQty", type: "number" },
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
         { label: 'Unsealed Quantity', value: 'unsealedQty' },
        { label: 'Sold Qty', value: 'soldQty' },
        { label: 'Closing Qty', value: 'saleableClosingQty' },
        { label: 'Damaged Qty', value: 'damagedQty' },
        { label: 'Total Qty', value: 'totalQty' }
    ];



    handleFilterSelection(event) {
        this.selectedFilter = event.detail;
    }

    dirOptions = [
        { label: 'Ascending', value: 'asc' },
        { label: 'Descending', value: 'desc' }
    ];

    async connectedCallback() {
        const { start, end } = this.getCurrentWeekRangeISO();
        this.fromDate = start;
        this.toDate = end;

        await this.loadRoutesAndDefault();
        if (this.routeId) {
            this.loadReport();
        }
    }

    async loadRoutesAndDefault() {
        try {
            const res = await initRoutes();
            this.routeOptions = res.options || [];
            this.routeId = res.defaultRouteId || null;
        } catch (e) {
            this.error = e?.body?.message || e.message || "Failed to load routes.";
        }
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

    async loadRoutes() {
        try {
            this.routeOptions = await getRoutes();
        } catch (e) {
            this.error = e?.body?.message || e.message || "Failed to load routes.";
        }
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

    async loadReport() {
        this.loading = true;
        this.error = null;
        this.rows = [];

        try {
            if (!this.routeId) throw new Error("Select a Route.");
            if (!this.fromDate || !this.toDate) throw new Error("Select From and To dates.");
            if (this.fromDate > this.toDate) throw new Error("From Date cannot be after To Date.");

            this.rows = await getStockRows({
                fromDate: this.fromDate,
                toDate: this.addOneDay(this.toDate),
                routeId: this.routeId,
                selectedCol: this.selectedFilter,
                sortBy: this.sortBy,
                sortDir: this.sortDir
            });
        } catch (e) {
            this.error = e?.body?.message || e.message || "Failed to load report.";
        } finally {
            this.loading = false;
        }
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
        /*  this.loading = true;
         this.error = null;
         try {
             const url = await generatePdf({
                 routeId: this.routeId,
                 fromDate: this.fromDate,
                 toDate: this.toDate
             });
 
             this[NavigationMixin.Navigate]({
                 type: 'standard__webPage',
                 attributes: { url }   // IMPORTANT: relative /sfc/... url
             });
         } catch (e) {
             this.error = e?.body?.message || e.message || 'PDF generation failed.';
         } finally {
             this.loading = false;
         } */
    }
}