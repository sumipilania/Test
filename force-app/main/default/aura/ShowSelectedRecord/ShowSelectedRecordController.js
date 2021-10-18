({
    onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var accs = myPageRef.state.c__listofAccounts;
        console.log('listofAccounts',JSON.stringify(accs));
        cmp.set("v.listofAccounts",accs);
        //split the account ids by comma and continue logic
    }
})