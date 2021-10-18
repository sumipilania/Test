({
    init : function (component) {
        console.log('In');
       	var myPageRef = component.get("v.pageReference");
        var accs = myPageRef.state.c__listofAccounts;
        console.log('listofAccounts',JSON.stringify(accs));
        //cmp.set("v.listofAccounts",accs);
    },
})