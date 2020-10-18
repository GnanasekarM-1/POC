/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @author Madhusudhan HK
 * @version 19.2000
 * @since 2019
 */

@RestResource(urlMapping='/svmx/DCX_ServiceIntf/*')
global class DCX_ServiceIntf
{   
    @HttpPost
    global static void doPost()
    {
        // try{
            
            RestRequest request = RestContext.request;
            System.debug('DO POST from JS '+request);
            RestResponse response = RestContext.response;
            DCX_ServiceImpl impl= new DCX_ServiceImpl(request, response);
            impl.invokePost();
        // }catch(Exception ex){
        //     throw ex;
        // }
    }


    @HttpGet
    global static void doGet() 
    {
    //    try{
long s2 = DateTime.Now().getTime();                       
            RestRequest request = RestContext.request;
            System.debug('DO GET from JS '+request);
            RestResponse response = RestContext.response;
            DCX_ServiceImpl impl = new DCX_ServiceImpl(request, response);
            impl.invokeGet();
long s1 = DateTime.Now().getTime(); 
system.debug('Main rest class time taken: '+(s1-s2));
        // }catch(Exception ex){
        //     throw ex;
        // }
    }

    @HttpPut
    global static void doPut()
    {
       
    }

}