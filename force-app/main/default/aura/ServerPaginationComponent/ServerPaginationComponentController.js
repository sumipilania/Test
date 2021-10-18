({
    fetchList : function(component, event, helper) {
        helper.sobjList(component);
        helper.sobjAllList(component);
       },
       onSelectChange: function(component, event, helper) {
        var selectCmp = component.find("pageSize").get("v.value");
        console.log('Option=='+selectCmp);
        component.set('v.selectedPageSize',selectCmp);
       }
})