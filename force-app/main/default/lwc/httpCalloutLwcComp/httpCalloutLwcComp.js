import { LightningElement } from 'lwc';

export default class HttpCalloutLwcComp extends LightningElement {
    connectedCallback() {
       
    }
    handleAuth1(){
        var parsedUrl = new URL(window.location.href);
        console.log('parsedUrl=',parsedUrl);
        let code = parsedUrl.searchParams.get("code");
        console.log('code=',code);
        let redirect_uri = 'https://sumit-pilaniya-light9domain-dev-ed.lightning.force.com/lightning/page/home';
        if(code || code===null || code==''){
            console.log('if true=');
            //window.location.href = 'https://www.dropbox.com/1/oauth2/authorize?response_type=code&client_id=19kyeab0dlhk1nu&redirect_uri='+redirect_uri;
          /*
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod(method);
            req.setTimeout(60*1000);
            req.setBodyAsBlob(body);
            Http h = new Http();
            HttpResponse res = h.send(req);
            System.debug('Generic Res=='+res.getBody());*/
           
        }
        else{
            console.log('if false=');
        }
    }
    handleAuth() {
        console.log('In=');
        //console.log("hhhhhhhh==","BASIC "+window.btoa("19kyeab0dlhk1nu : mi8bhslrarv6v8w"));
        //let redirect_uri = 'https://sumit-pilaniya-light9domain-dev-ed--c.visualforce.com/apex/DemoPage';
        let str= '{"path": "","recursive": false,"include_media_info": false,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
        let bl = new Blob(str);
        console.log('str=',str);
       // console.log('Blob=',bl);

       var JSONResponse = '';
       var JsonBody = '';
       JsonBody = str;
       console.log('--JsonBody ------->'+JsonBody );
       
       var xhr = new XMLHttpRequest();
       xhr.open("POST", "https://api.dropboxapi.com/2/files/list_folder", true);
       xhr.setRequestHeader("Authorization","Bearer pe5tL91waPAAAAAAAAAG_STIs75gxAnLoMA66ShzSmd9VVRDru0iQoS9sCPzo70W" ); 
       xhr.setRequestHeader("Content-type", "application/json;charset=UTF-8");
      // xhr.setRequestHeader("Accept", "application/json");
       xhr.onload = function () 
       {
           JSONResponse = xhr.responseText;
           console.log('--JSONResponse ------->'+xhr.responseText);
       };
       xhr.send(JsonBody);
       setTimeout( function()
           {
               if(xhr.status == 404){                     
               }
               else if(xhr.status == 401){
               }
               else if(xhr.status == 500){
               }
               else if(xhr.status == 200)
               {
                   obj1 = JSON.parse(JSONResponse );
                   for(var x=0;x< obj1.length;x++)
                   {
                       var singleEle = obj1[x];
                       console.log('--singleEle ------->'+singleEle );
                   }
               }
           },
       2000);



        /*
        fetch('https://api.dropboxapi.com/2/files/list_folder', // End point URL
        {
            // Request type
            method:"POST",
            
            headers:{
                "Content-Type":"application/json",
                "Authorization": "Bearer pe5tL91waPAAAAAAAAAG_FlXaNTLrf8NSf1HB2WNiIer7xU_Oo_4qvjk0GnqM_Oj"
            },
            body :{
               bl
            }
        })
        .then((response) => {
            console.log('response ===> ',response);

            return response.json(); // returning the response in the form of JSON
        })
        .then((jsonResponse) => {
            console.log('jsonResponse ===> ',jsonResponse);

            console.log('jsonResponse Strinfy===> ',JSON.stringify(jsonResponse));
            // retriving the response data
        })
        .catch(error => {
            console.log('callout error ===> '+JSON.stringify(error));
        }) */
    }
}