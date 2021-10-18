({
    doInit : function(cmp, event, helper) {
        
        window.open('https://maps.googleapis.com/maps/api/js?key=AIzaSyAtNyKqhQ0fGQafCEE0g8Iy45OjsxhxhtY&callback=initMap')
        /*
		var recordId = component.get("v.recordId"); //Parent id dynamic
        var action = component.get('c.fetchAccountLocation');	
        action.setParams({
            parentRecId : recordId
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                console.log(response.getReturnValue());
            }
            else if(state === 'ERROR'){
                alert(response.getError());
            }
        });
        $A.enqueueAction(action); 
        
        /*
        cmp.set('v.mapMarkers', [
            {
                location: {
                    Street: '1 Market St',
                    City: 'San Francisco',
                    PostalCode: '94105',
                    State: 'CA',
                    Country: 'USA',
                  
                    
                },
                  Latitude: '80.790197',
                Longitude: '-122.396879',
                icon: 'utility:salesforce1',
                title: 'Worldwide Corporate Headquarters',
                description: 'Sales: 1800-NO-SOFTWARE'
            },
            {
                location: {
                    Street: '950 East Paces Ferry Road NE',
                    City: 'Atlanta',
                    PostalCode: '94105',
                    State: 'GA',
                    Country: 'USA',
                    
                },
                Latitude: '80.790197',
                Longitude: '-122.396879',
                icon: 'utility:salesforce1',
                title: 'salesforce.com inc Atlanta'
            }
            
        ]);
        
        cmp.set('v.center', {
            location: {
                City: 'Denver',
                Latitude: '100.790197',
                Longitude: '-122.396879'
            }
        });
        
        cmp.set('v.zoomLevel', 4);
        cmp.set('v.markersTitle', 'Salesforce locations in United States');
        cmp.set('v.showFooter', true);
        */
    }
})