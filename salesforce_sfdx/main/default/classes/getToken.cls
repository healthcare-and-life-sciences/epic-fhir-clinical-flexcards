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
 * OmniStudio related code was adapted by Starter Class written by Charles McGuinness
 *
 */

 global with sharing class getToken implements Callable {
    
    private String lastTidbit = '';
    public static String DEFAULT_ISS = '';
    public static String DEFAULT_SUB = '';
    public static String DEFAULT_JTI = '';
    public static String DEFAULT_CERT = '';
    public static String DEFAULT_AUD = '';
    private List<Map<String, String>> debugLog;

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
        String jti = (String) options.get('JTI');
        jti = String.isBlank(jti) ? DEFAULT_JTI : jti;

        Long exp = DateTime.now().addMinutes(5).getTime();
        String fixedExp = String.valueOf(exp);
        fixedExp = fixedExp.subString(0, fixedExp.length() - 3);
        output.put('Expiration', fixedExp);

        // Start constructing the header and claims
        String jwtHeader = '{"alg":"RS256","typ":"JWT"}';
        String jwtClaims = '{"iss":"' + iss + '","sub":"' + sub + '","aud":"' + aud + '","jti":"' + jti + '","exp":' + fixedExp + '}';

        String encodedHeader = base64URLencode(Blob.valueOf(jwtHeader));
        String jwtRequest = encodedHeader + '.' + base64URLencode(Blob.valueOf(jwtClaims));
        Blob signature = null;
        String certname = (String) options.get('Cert');
        certname = String.isBlank(certname) ? DEFAULT_CERT : certname;
        signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwtRequest), certname);
        jwtRequest = jwtRequest + '.' + base64URLencode(signature);
        String signedJwtRequest = jwtRequest;

        String payload =
            'grant_type=client_credentials&client_assertion_type=' +
            System.EncodingUtil.urlEncode('urn:ietf:params:oauth:client-assertion-type:jwt-bearer', 'UTF-8');

        payload += '&client_assertion=' + signedJwtRequest;
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
