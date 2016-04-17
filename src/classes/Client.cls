/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 bigass.force.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
abstract public class Client {

    static public String accessKeyId;
    static public String secretKey;

    protected String service;
    protected String region;
    
    protected String canonicalMethodFor(String method) {
        return method.toUpperCase();
    }
    
    protected String canonicalUriFor(String endpoint) {
        Url uri = new Url(endpoint);
        String segments = rfc3986for(uri.getPath());
        return segments.replace('%2F', '/');
    }
    
    protected String canonicalQueryStringFor(Map<String,String> parameters) {
        
        //sort keys by ascii code
        List<String> sortedKeys = new List<String>(parameters.keySet());
        sortedKeys.sort();
        
        //prepare values
        List<String> canonicalParameters = new List<String>();
        for (String sortedKey : sortedKeys) canonicalParameters.add(
            sortedKey + 
            '=' + 
            rfc3986for(parameters.get(sortedKey))
        );
        
        return String.join(canonicalParameters, '&');
    }
    
    protected String canonicalHeadersFor(Map<String,String> key2value) {
        
        //lowercase header keys
        Map<String,String> lower2value = new Map<String,String>();
        for (String key : key2value.keySet()) lower2value.put(key.toLowerCase(), key2value.get(key).trim().replaceAll('\\s+', ' '));
        
        //sort canonical keys by ascii code
        List<String> sortedKeys = new List<String>(lower2value.keySet());
        sortedKeys.sort();
        
        //prepare values
        List<String> canonicalHeaders = new List<String>();
        for (String sortedKey : sortedKeys) canonicalHeaders.add(sortedKey + ':' + lower2value.get(sortedKey) + '\n');
        
        return String.join(canonicalHeaders, '');
    }
    
    protected String signedHeadersFor(Map<String,String> headers) {
        
        //lowercase header keys
        List<String> keys = new List<String>(headers.keySet());
        for (Integer i = 0; i < keys.size(); i++) keys.set(i, keys[i].toLowerCase());
        
        //sort ascii
        keys.sort();
        
        //prepare values
        List<String> signedHeaders = new List<String>();
        for (String key : keys) signedHeaders.add(key);
        
        return String.join(signedHeaders, ';');
    }
    
    protected String hexEncodedHash(String data) {
        Blob bin = Blob.valueOf(data);
        Blob hash = Crypto.generateDigest('SHA256', bin);
        return EncodingUtil.convertToHex(hash);
    }
    
    protected String rfc3986for(String value) {
        return EncodingUtil.urlEncode(value, 'UTF-8').replace('+', '%20').replace('%7E', '~');
    }

    public HttpRequest requestFor(Map<String,String> parameters) {

        PageReference pr = new PageReference('https://' + this.service + '.' + this.region + '.amazonaws.com/');
        pr.getParameters().putAll(parameters);

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(pr.getUrl());

        Datetime now = Datetime.now();
        String iso8601time = now.formatGmt('YYYYMMdd\'T\'HHmmss\'Z\'');
        String iso8601date = now.formatGmt('YYYYMMdd');

        Map<String,String> headers = new Map<String,String>{
            'X-Amz-Date' => iso8601time,
            'Host' => this.service + '.amazonaws.com'
        };

        String payload = '';

        //Task 1: Create a Canonical Request for Signature Version 4
        String canonicalRequest = canonicalMethodFor('GET')
            + '\n' + canonicalUriFor(request.getEndpoint())
            + '\n' + canonicalQueryStringFor(parameters)
            + '\n' + canonicalHeadersFor(headers)
            + '\n' + signedHeadersFor(headers)
            + '\n' + hexEncodedHash(payload)
        ;

        String canonicalRequestHash = hexEncodedHash(canonicalRequest);

        //Task 2: Create a String to Sign for Signature Version 4
        String algorithm = 'AWS4-HMAC-SHA256';
        String termination = 'aws4_request';
        String credentialScope = iso8601date + '/' + region + '/' + service + '/' + termination;
        String stringToSign = algorithm + '\n' + iso8601time + '\n' + credentialScope + '\n' + canonicalRequestHash;

        //Task 3: Calculate the AWS Signature Version 4
        Blob keySecret = Blob.valueOf('AWS4' + secretKey);
        Blob keyDate = Crypto.generateMac('hmacSHA256', Blob.valueOf(iso8601date), keySecret);
        Blob keyRegion = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.region), keyDate);
        Blob keyService = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.service), keyRegion);
        Blob keySigning = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), keyService);

        Blob blobToSign = Blob.valueOf(stringToSign);
        Blob hmac = Crypto.generateMac('hmacSHA256', blobToSign, keySigning);
        String signature = EncodingUtil.convertToHex(hmac);

        //Task 4: Add the Signing Information to the Request
        String signedHeaders = signedHeadersFor(headers);
        String authorization = 'AWS4-HMAC-SHA256'
            + ' ' + 'Credential=' + accessKeyId + '/' + credentialScope
            + ', ' + 'SignedHeaders=' + signedHeaders
            + ', ' + 'Signature=' + signature
        ;

        //prepare headers
        request.setHeader('Authorization', authorization);
        for (String header : headers.keySet()) request.setHeader(header, headers.get(header));
        return request;
    }
    
}