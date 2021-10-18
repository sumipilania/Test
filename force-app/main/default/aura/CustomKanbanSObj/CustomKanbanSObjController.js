({
	handleClick : function(component, event, helper) {
		component.set("v.flag", true);
		//component.set("v.childAttr", true);
        component.set("v.parentopenModel", true);
	},
	onChildAttrChange : function(component, event, helper) {
		console.log('childdd');
		component.set("v.flag", false);
	}
})