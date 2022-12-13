public with sharing class EpicFHIRAuthentication {
/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

    public static String DEFAULT_ISS = 'fe0e3375-fffa-469b-8338-d5fe08f7d3b1';
    public static String DEFAULT_SUB = 'fe0e3375-fffa-469b-8338-d5fe08f7d3b1';
    public static String DEFAULT_JTI = 'salesforce_fhir';
    public static String DEFAULT_CERT = 'epicfhirnewcert';
    public static String DEFAULT_AUD = 'https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token';
    public static List<Epic_Access__c> EpicAccessList { get; set; }

    @InvocableMethod(label='Get Token from Epic' description='Opens a connection to Epic via FHIR and pulls in appropriate data.' category='Account')
    public static void getToken() {
      
      System.debug('Inside getToken');
      String access_token = null;
      // The consumer key for a connected app of mine
      //String iss = '667532f3-ba38-417e-855a-958bd131e18f';
      String iss = DEFAULT_ISS;
      System.debug('ISS: '+ iss);
      iss = String.isBlank(iss) ? DEFAULT_ISS : iss;

      // I'm doing this in a sandbox, so aud is test.salesforce.com
      // Replace with login.salesforce.com for production environments
      //String sub = '667532f3-ba38-417e-855a-958bd131e18f';
      String sub = DEFAULT_SUB;
      System.debug('SUB: '+ sub);
      sub = String.isBlank(sub) ? DEFAULT_SUB : sub;

      // A user that belongs to one of the pre-authorized profiles for your connected app.
      // Setup -> Create -> Apps
      // Connected apps are at the bottom of the page (at time of writing, API v41.0)
      // Go into your target connected app and click the "manage" button
      // Click "Manage Profiles" near the bottom of the page, and add/remove profiles as needed.
      //String aud = 'https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token';
      String aud = DEFAULT_AUD;
      System.debug('AUD: '+ aud);
      aud = String.isBlank(aud) ? DEFAULT_AUD : aud;

      //String jti = 'derekjwt';
      String jti = DEFAULT_JTI;
      System.debug('Jti is : '+ jti);
      jti = String.isBlank(jti) ? DEFAULT_JTI : jti;
      System.debug('Now Jti is : '+ jti);

      // Expiration time of the JWT itself
      // Best to make this a long instead of an int
      // Adding 5 minutes is arbitrary, anything less than a minute is fairly dangerous,
      //   and anything more is fine (could be minutes, days, months, or years in the future)
      Long exp = DateTime.now().addMinutes(5).getTime();
      String fixedExp = String.valueOf(exp);
      fixedExp = fixedExp.subString(0,fixedExp.length()-3);
      System.debug('Original Exp: '+ exp + ' and Fixed is ' + fixedExp);
      // Start constructing the header and claims
      // The "alg" will pretty much always be "RS256" with Salesforce
      String jwtHeader = '{"alg":"RS256","typ":"JWT"}';
      String jwtClaims = '{"iss":"' + iss + '","sub":"' + sub + '","aud":"' + aud + '","jti":"' + jti +'","exp":' + fixedExp + '}';

      // Now we have to start Base64 encoding things.
      // For JWT, Base64 is not good enough, there are 2 characters that are not URL-safe
      //   which we need to deal with.
      // '+' needs to be replaced with '-', and '/' needs to be replaced with '_'
      // This variant of Base64 is called Base64Url, and Salesforce doesn't provide us
      //   with a method to do that automatically.
      // This step takes the JWT header and claims, separately Base64Url encodes them, and 
      //   concatenates them with a period/full stop
      //String jwtRequest = System.encodingUtil.base64Encode(Blob.valueOf(jwtHeader)).replace('+', '-').replace('/', '_') + '.' + System.encodingUtil.base64Encode(Blob.valueOf(jwtClaims)).replace('+', '-').replace('/', '_');
      String encodedHeader = base64URLencode(Blob.valueOf(jwtHeader));
      
      String jwtRequest = encodedHeader + '.' + base64URLencode(Blob.valueOf(jwtClaims));

      System.debug('Cleaned Request: ' + jwtRequest);

      
      Blob signature = null;
      String certname = DEFAULT_CERT;
      System.debug('CERT Name: '+ certname);
      certname = String.isBlank(certname) ? DEFAULT_CERT : certname;

      signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwtRequest), certname);
      //signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwtRequest), privateKey);

      jwtRequest = jwtRequest + '.' + base64URLencode(signature);

      String signedJwtRequest = jwtRequest;

      // The JWT is fully constructed, now it's time to make the call to get the access token.

      String payload = 'grant_type=client_credentials&client_assertion_type=' + System.EncodingUtil.urlEncode('urn:ietf:params:oauth:client-assertion-type:jwt-bearer', 'UTF-8');
      
      payload += '&client_assertion=' + signedJwtRequest;
      //payload += '&client_assertion=' + token;
      System.debug('JWT : '+ signedJwtRequest);
      System.debug('Payload : '+ payload);

      EpicAccessList = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c, ExpireEpoch__c From EPIC_Access__c Where Name='EPICAccess'];


      Http httpObj = new Http();
      HttpRequest req = new HttpRequest();
      HttpResponse res;
      
      // My sandbox is on cs52 for the moment
      // You'll need to replace this with your sandbox pod (or production pod, or your custom
      //   domain if you've embraced Lightning Experience)
      // Having a "My Domain" set up for production is very helpful, as Salesforce can
      //   eventually migrate your production org to a different pod.
      // If you're doing this in anonymous apex (or in Apex in general), don't forget to 
      //   add this domain to your remote site settings.
      // No matter what environment you're using, the tail end of the endpoint you'll
      //   be using to submit the JWT is '/services/oauth2/token'
      req.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token');
      req.setMethod('POST');
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setBody(payload);
      System.debug('Payload: ' + payload);
      res = httpObj.send(req);
      System.debug(res.getBody());
      try{
        if ( res.getStatusCode() == 200 ) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            EPIC_Access__c EpicInfo = new EPIC_Access__c();
                EpicInfo.Access_Token__c =  String.valueOf(responseMap.get('access_token'));
                EpicInfo.Expires_In_Seconds__c =  Double.valueOf(responseMap.get('expires_in'));
                EpicInfo.ExpireEpoch__c = exp;
                EpicInfo.ExpiresWhen__c = DateTime.newInstance(exp);
                EpicInfo.Name ='EPICAccess';
                
                if(EpicAccessList!=null && EpicAccessList.size() > 0){
                    EpicInfo.Id = EpicAccessList[0].Id;
                }
            access_token = (String)responseMap.get('access_token');
            upsert EpicInfo;
        }else{
            System.debug('JWTBearerFlow Error Occurred '+res.getBody());
        }
    }catch(Exception ex){
        if(String.valueOf(ex).startsWith('Unauthorized endpoint')){
            System.debug('JWTBearerFlow Please check Setup->Security->Remote site settings and add '+aud);
        }else{
            System.debug('JWTBearerFlow  '+ex.getStackTraceString());
            System.debug('JWTBearerFlow '+ex);
        }
    }
    //return access_token;
    System.debug('YES. We have a access token: '+ access_token);
    //FHIRdemoHelper.getUserDetail(access_token);

      
      // If everything goes well, res.getBody() should contain JSON with "access_token"

    }


    @AuraEnabled
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
    
}