({
    //fetch records list
    doInit: function(component, event, helper) {
        helper.kanbanCreate(component);
    },
    
    //Click on name than open new tab detail page
    doView: function(component, event, helper) {
        var firstId = event.target.id;
        var redUrl = "https://sumit-pilaniya-light9domain-dev-ed.my.salesforce.com/";
        window.open(redUrl+firstId);
    },
    
    //Allow prevent default function like submit form
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    
    //Fetch Id when drag
    drag: function (component, event, helper) {
        event.dataTransfer.setData("text", event.target.id);
    },
    
    //Append child records when we drop
    drop: function (component, event, helper) {
        event.preventDefault();
        var data = event.dataTransfer.getData("text");
        var tar = event.target;
        while(tar.tagName != 'ul' && tar.tagName != 'UL')
        tar = tar.parentElement;
        tar.appendChild(document.getElementById(data));
        document.getElementById(data).style.backgroundColor = "#ffb75d";
        helper.updatePickVal(component,data,component.get("v.kanbanPicklistField"),tar.getAttribute('data-Pick-Val'));
    }
})