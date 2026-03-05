({
    showToast : function(title, message, type) {
        var toast = $A.get("e.force:showToast");
        toast.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toast.fire();
    }
})