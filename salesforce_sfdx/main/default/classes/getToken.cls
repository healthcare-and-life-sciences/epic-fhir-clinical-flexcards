/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 *
 *
 * Class to generate a JWT Token for use with APIs
 *
 * Version 2.0
 *
 * November 15, 2022
 * February 20, 2023 - Changed to implement Callable for use with Standard runtime
 *
 * author: Derek Cassese - Accelerate HLS - dcassese@salesforce.com
 * code was adapted by Starter Class written by Charles McGuinness
 *
 */

 global with sharing class getToken implements Callable {
    // This is used for debugging purposes: a method can put information in this, and
    // if an exception is thrown, it will be included in the report back to the caller.

    private String lastTidbit = '';
    public static String DEFAULT_ISS = 'fe0e3375-fffa-469b-8338-d5fe08f7d3b1';
    public static String DEFAULT_SUB = 'fe0e3375-fffa-469b-8338-d5fe08f7d3b1';
    public static String DEFAULT_JTI = 'fhirdemo';
    public static String DEFAULT_CERT = 'epicfhirnewcert';
    public static String DEFAULT_AUD = 'https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token';

    private List<Map<String, String>> debugLog;

    // Initialize the log, add it to the output.  Since the variable is put into the output by
    // reference, we can keep adding things to the list and the lastest version will be automatically
    // returned, no need to keep putting it into output after this initial call.

    private void initLog(Map<String, Object> output) {
        debugLog = new List<Map<String, String>>();
        output.put('debugLog', debugLog);
    }

    private void addLog(String message) {
        Map<String, String> thisMessage = new Map<String, String>();

        thisMessage.put('Timestamp', String.valueOf(Datetime.now()));
        thisMessage.put('Text', message);

        debugLog.add(thisMessage);
    }

    public Object call(String action, Map<String, Object> args) {

        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');

        return InvokeMethod(action, input, output, options);
    }

    /*
     * Standard entrypoint for VlocityOpenInterface.
     */
    global Boolean InvokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {

        try {
            initLog(output);

            if (methodName.equals('getToken')) {
                authWithEpic(methodName, input, output, options);
                return true;
            }
        } catch (Exception e) {
            output.put('Error', e.getMessage());
            output.put('ErrorLine', e.getLineNumber());
            output.put('TidBit', lastTidbit);
            output.put('Method', methodName);
        }
        return false;
    }

    /* This is the main function where we call the various objects we need for the document generation that are not yet available to Data Raptures due to the n-1 restriction */

    private void authWithEpic(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        String errorMessage = '';
        String token = 'testtoken';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();



        String access_token = null;

        String iss = (String) options.get('ISS');

        iss = String.isBlank(iss) ? DEFAULT_ISS : iss;

        String sub = (String) options.get('SUB');

        sub = String.isBlank(sub) ? DEFAULT_SUB : sub;

        String aud = (String) options.get('AUD');

        aud = String.isBlank(aud) ? DEFAULT_AUD : aud;

        //String jti = 'derekjwt';
        String jti = (String) options.get('JTI');

        jti = String.isBlank(jti) ? DEFAULT_JTI : jti;


        // Expiration time of the JWT itself

        Long exp = DateTime.now().addMinutes(5).getTime();
        String fixedExp = String.valueOf(exp);
        fixedExp = fixedExp.subString(0, fixedExp.length() - 3);
        output.put('Expiration', fixedExp);

        // Start constructing the header and claims
        // The "alg" will pretty much always be "RS256" with Salesforce
        String jwtHeader = '{"alg":"RS256","typ":"JWT"}';
        String jwtClaims = '{"iss":"' + iss + '","sub":"' + sub + '","aud":"' + aud + '","jti":"' + jti + '","exp":' + fixedExp + '}';

        // Now we have to start Base64 encoding things.
        // For JWT, Base64 is not good enough, there are 2 characters that are not URL-safe
        //   which we need to deal with.
        // '+' needs to be replaced with '-', and '/' needs to be replaced with '_'
        // This variant of Base64 is called Base64Url
        String encodedHeader = base64URLencode(Blob.valueOf(jwtHeader));
        String jwtRequest = encodedHeader + '.' + base64URLencode(Blob.valueOf(jwtClaims));


        Blob signature = null;
        String certname = (String) options.get('Cert');

        certname = String.isBlank(certname) ? DEFAULT_CERT : certname;

        signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwtRequest), certname);

        jwtRequest = jwtRequest + '.' + base64URLencode(signature);

        String signedJwtRequest = jwtRequest;

        // The JWT is fully constructed, now it's time to make the call to get the access token.

        String payload =
            'grant_type=client_credentials&client_assertion_type=' +
            System.EncodingUtil.urlEncode('urn:ietf:params:oauth:client-assertion-type:jwt-bearer', 'UTF-8');

        payload += '&client_assertion=' + signedJwtRequest;
        //payload += '&client_assertion=' + token;


        Http httpObj = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;

        req.setEndpoint(aud);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(payload);

        res = httpObj.send(req);

        try {
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                access_token = (String) responseMap.get('access_token');
                output.put('Token', access_token);
            } else {
                System.debug('JWTBearerFlow Error Occurred ');
            }
        } catch (Exception ex) {
            if (String.valueOf(ex).startsWith('Unauthorized endpoint')) {
                System.debug('JWTBearerFlow Please check Setup->Security->Remote site settings and add aud');
            } else {
                System.debug('JWTBearerFlow  ');
            }
        }


    }

    public static String base64URLencode(Blob input) {
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.subString(0, output.length() - 1);
        }
        return output;
    }
}
