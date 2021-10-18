({
    handleRecordUpdate: function(component, event, helper) {
        var accountFields = component.get("v.accFields");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: accountFields.Type + ' - ' + accountFields.Name
            });
        })
    }
})