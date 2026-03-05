({
    showToast: function(type, message) {
        const toast = $A.get("e.force:showToast");
        if (toast) {
            toast.setParams({ type, message });
            toast.fire();
        } else {
            alert(message);
        }
    },

    downloadCSVFromRows: function(columns, rows, fileName) {
        const headers = columns.map(c => c.label);
        const fields  = columns.map(c => c.fieldName);

        const escapeCSV = (val) => {
            if (val === null || val === undefined) return "";
            let s = String(val);

            // If value is an object (rare), stringify it
            if (typeof val === "object") {
                try { s = JSON.stringify(val); } catch (e) {}
            }

            // wrap + escape
            if (s.includes(",") || s.includes('"') || s.includes("\n") || s.includes("\r")) {
                s = `"${s.replace(/"/g, '""')}"`;
            }
            return s;
        };

        const lines = [];
        lines.push(headers.map(escapeCSV).join(","));

        rows.forEach(r => {
            lines.push(fields.map(f => escapeCSV(r[f])).join(","));
        });

        const csv = lines.join("\r\n");

        // Primary download method: Blob
        try {
            const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
            const url = URL.createObjectURL(blob);

            const link = document.createElement("a");
            link.href = url;
            link.setAttribute("download", fileName);
            link.style.display = "none";

            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            URL.revokeObjectURL(url);
        } catch (e) {
            // Fallback: data URI (some browsers)
            const encoded = encodeURIComponent(csv);
            const dataUri = "data:text/csv;charset=utf-8," + encoded;

            const link = document.createElement("a");
            link.href = dataUri;
            link.setAttribute("download", fileName);
            link.style.display = "none";

            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    }
});