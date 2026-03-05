({
    doInit: function(component, event, helper) {
        const todayStr = new Date().toISOString().slice(0, 10);
        component.set("v.startDate", todayStr);
        component.set("v.endDate", todayStr);

        // Fetch branches
        const branchAction = component.get("c.getBranches");
        branchAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.branchOptions", response.getReturnValue());
            } else {
                helper.showToast("error", "Failed to load branches.");
            }
        });
        $A.enqueueAction(branchAction);

        // Fetch routes
        const routeAction = component.get("c.getRoutes");
        routeAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.routeOptions", response.getReturnValue());
            } else {
                helper.showToast("error", "Failed to load routes.");
            }
        });
        $A.enqueueAction(routeAction);

        // Set columns (add Branch column if desired)
        component.set("v.columns", [
            { label: "Log Name", fieldName: "logName", type: "text" },
            { label: "Branch", fieldName: "branch", type: "text" },
            { label: "Route", fieldName: "route", type: "text" },
            { label: "Clock In", fieldName: "clockIn", type: "date", typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
            { label: "Clock Out", fieldName: "clockOut", type: "date", typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
            { label: "First Invoice ID", fieldName: "firstInvoiceId", type: "text" },
            { label: "First Invoice Created", fieldName: "firstInvoiceCreated", type: "date", typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
            { label: "Last Invoice ID", fieldName: "lastInvoiceId", type: "text" },
            { label: "Last Invoice Created", fieldName: "lastInvoiceCreated", type: "date", typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } }
        ]);
    },

    loadReport: function(component, event, helper) {
        const start = component.get("v.startDate");
        const end = component.get("v.endDate");
        const branchId = component.get("v.selectedBranchId");
        const routeId = component.get("v.selectedRouteId");

        if (!start || !end) {
            helper.showToast("error", "Please select both start and end dates.");
            return;
        }

        const action = component.get("c.getLogReport");
        action.setParams({ 
            startDate: start, 
            endDate: end,
            branchId: branchId,
            routeId: routeId
        });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const data = response.getReturnValue() || [];
                component.set("v.reportData", data);
                component.set("v.showTable", data.length > 0);
                if (data.length === 0) helper.showToast("info", "No records found for selected criteria.");
            } else {
                const errors = response.getError();
                helper.showToast("error", (errors && errors[0] && errors[0].message) ? errors[0].message : "Failed to load report.");
                component.set("v.showTable", false);
            }
        });

        $A.enqueueAction(action);
    },

    exportToExcel: function(component, event, helper) {
        const rows = component.get("v.reportData") || [];
        const cols = component.get("v.columns") || [];

        if (!rows.length) {
            helper.showToast("info", "No data to export.");
            return;
        }
        helper.downloadCSVFromRows(cols, rows, "DailyLogReport.csv");
    }
})