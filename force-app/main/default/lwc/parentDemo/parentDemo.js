import { LightningElement } from 'lwc';

export default class ParentDemo extends LightningElement {
    //First Test
    // connectedCallback(){
    //     console.log("login");
    //   //  window.location.href = 'https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=3MVG9G9pzCUSkzZuOH7WKrfYuJ03Z6pxGPHCY0YTMhLIJbzvCvdhmmY0I4IYEk9Wbs4KhslctuUwu5wf6Y0Lz&redirect_uri=https://sumit-pilaniya-light9domain-dev-ed.lightning.force.com/';
    //     console.log("end");


    //     var code='';
    //             var parsedUrl = new URL(window.location.href);
    //             console.log("parsedUrl=",parsedUrl);
    //             code = parsedUrl.searchParams.get("code");
    //             console.log("code=",code);


    //             if(code=='' || code==null){
    //               // var url =  'https://login.salesforce.com/services/oauth2/authorize?client_id=3MVG9G9pzCUSkzZuOH7WKrfYuJ03Z6pxGPHCY0YTMhLIJbzvCvdhmmY0I4IYEk9Wbs4KhslctuUwu5wf6Y0Lz&redirect_uri=https://sumit-pilaniya-light9domain-dev-ed.lightning.force.com/c/TestApp.app&response_type=code';

    //                  // window.location.href = url;                        
    //                 }
    //                 else{
    //                     console.log("Next Time Last");

    //                     //helper.fetchAllFilesFolder(component); 
    //                 }
                
    // }

    //Second Test
    video = "https://www.youtube.com/embed/GjcNH8lszKM?controls=1";

    handlePlay() {
        console.log('Parent Play');
        let result = this.template.querySelector('c-child-demo').play();
        console.log('Parent result=',result);
    }

    handlePause() {
      console.log('Parent Pause');
        this.template.querySelector('c-child-demo').pause('myTest');
    }
}