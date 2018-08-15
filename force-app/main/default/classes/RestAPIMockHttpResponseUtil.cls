/*****************************************************************
Name:  RestAPIMockHttpResponseUtil
 
=================================================================
Purpose: 
Apex REST API Mock utility methods                                                                                                                       
=================================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE           DETAIL          Description
1.0   	 aashiru        06/2018        Created         AMS: 
*****************************************************************/

global class RestAPIMockHttpResponseUtil implements HttpCalloutMock {
	 global HTTPResponse respond(HTTPRequest req) {        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();        
        mock.setHeader('Content-Type', 'application/json');
		mock.setStatusCode(200);

        String endPoint = req.getEndpoint();      
        System.debug(endPoint);
        
        //Get Layout Response
        if(endPoint.contains('sobjects/Account/describe/layouts')){
            mock.setStaticResource('TestAccountLayoutResponse');
        }
        
        //Get Describe Response
        else if(endPoint.contains('sobjects/Account/describe')){
            mock.setStaticResource('TestAccountDescribeResponse');
        }

        //Get Contacts Response
        else if(endPoint.contains('/Contacts')){
            mock.setStaticResource('TestAccountContactsResponse');            
        }
                
        else if(endPoint.contains('sobjects/Account')){
            mock.setStaticResource('TestAccountDetailsResponse');
        }
        
        else if (endPoint.contains('/tooling/query')){
            mock.setStaticResource('TestAccountDetailsResponse');
        }
        
        return mock.respond(req);
    }
}