/**
 * Example usage:
 *
 * String key = 'XXXXXXXXXXXXXXXXXXXX';
 * String secret = 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY';
 *
 * AwsApi.S3 s3 = new AwsSdk.Connector(key, secret).s3('us-east-1');
 * AwsApi.Ec2 ec2 = new AwsSdk.Connector(key, secret).ec2('us-west-2');
 */
public class Connector {

    String accessKeyId;
    String secretKey;
    public String service;
    public String region;
    
    public Connector(String accessKeyId, String secretKey) {
        this.accessKeyId = accessKeyId;
        this.secretKey = secretKey;
    }

    public S3 s3(String region) {
        return new s3(this, region);
    }

    public Ec2 ec2(String region) {
        return new ec2(this, region);
    }

    String canonicalMethodFor(String method) {
        return method.toUpperCase();
    }
    
    String canonicalUriFor(String endpoint) {
        Url uri = new Url(endpoint);
        return rfc3986for(uri.getPath(), false);
    }
    
    String canonicalQueryStringFor(Map<String,String> parameters) {
        
        //sort keys by ascii code
        List<String> sortedKeys = new List<String>(parameters.keySet());
        sortedKeys.sort();
        
        //prepare values
        List<String> canonicalParameters = new List<String>();
        for (String sortedKey : sortedKeys) canonicalParameters.add(
            sortedKey + 
            '=' + 
            rfc3986for(parameters.get(sortedKey), true)
        );
        
        return String.join(canonicalParameters, '&');
    }
    
    String canonicalHeadersFor(Map<String,String> key2value) {
        
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
    
    String signedHeadersFor(Map<String,String> headers) {
        
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
    
    String hexEncodedHash(Blob data) {
        Blob hash = Crypto.generateDigest('SHA256', data);
        return EncodingUtil.convertToHex(hash);
    }
    
    String rfc3986for(String characters, Boolean encodeSlash) {
        String result = '';
        for (Integer i = 0; i < characters.length(); i++) {
            String character = characters.substring(i, i + 1);
            
            if (
                (character >= 'A' && character <= 'Z') || 
                (character >= 'a' && character <= 'z') || 
                (character >= '0' && character <= '9') || 
                character == '_' || 
                character == '-' || 
                character == '~' || 
                character == '.'
            ) {
                result += character;
            } else if (character == '/') {
                result += encodeSlash ? '%2F' : character;
            } else {
                result += '%' + EncodingUtil.convertToHex(Blob.valueOf(character)).toUpperCase();
            }
        }
        
        return result;
    }
    
    public HttpRequest signedRequest(String method, Url endpoint, Map<String,String> headers, Blob payload, Boolean presign) {
        
        //defaults
        if (headers == null) headers = new Map<String,String>();
        if (payload == null) payload = Blob.valueOf('');
        if (presign == null) presign = false;

        //assemble
        Datetime now = Datetime.now();
        String termination = 'aws4_request';
        String iso8601date = now.formatGmt('YYYYMMdd');
        String iso8601time = now.formatGmt('YYYYMMdd\'T\'HHmmss\'Z\'');
        String credentialScope = iso8601date + '/' + region + '/' + service + '/' + termination;

        //prepare headers
        headers.put('Host', endpoint.getHost());
        String signedHeaders = signedHeadersFor(headers);

        //prepare parameters
        PageReference pr = new PageReference(endpoint.toExternalForm());
        Map<String,String> parameters = pr.getParameters();
        parameters.put('X-Amz-Algorithm', 'AWS4-HMAC-SHA256');
        parameters.put('X-Amz-Credential', this.accessKeyId + '/' + credentialScope);
        parameters.put('X-Amz-Date', iso8601time);
        parameters.put('X-Amz-Expires', '86400');
        parameters.put('X-Amz-SignedHeaders', signedHeaders);
        
        //Task 1: Create a Canonical Request for Signature Version 4
        String canonicalRequest = canonicalMethodFor(method)
            + '\n' + canonicalUriFor(endpoint.toExternalForm())
            + '\n' + canonicalQueryStringFor(parameters)
            + '\n' + canonicalHeadersFor(headers)
            + '\n' + signedHeadersFor(headers)
            + '\n' + (presign ? 'UNSIGNED-PAYLOAD' : hexEncodedHash(payload))
        ;

        //Task 2: Create a String to Sign for Signature Version 4
        String algorithm = 'AWS4-HMAC-SHA256';
        String canonicalRequestHash = hexEncodedHash(Blob.valueOf(canonicalRequest));
        String stringToSign = algorithm + '\n' + iso8601time + '\n' + credentialScope + '\n' + canonicalRequestHash;
        
        //Task 3: Calculate the AWS Signature Version 4
        Blob keySecret = Blob.valueOf('AWS4' + this.secretKey);
        Blob keyDate = Crypto.generateMac('hmacSHA256', Blob.valueOf(iso8601date), keySecret);
        Blob keyRegion = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.region), keyDate);
        Blob keyService = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.service), keyRegion);
        Blob keySigning = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), keyService);
        Blob blobToSign = Blob.valueOf(stringToSign);
        Blob hmac = Crypto.generateMac('hmacSHA256', blobToSign, keySigning);

        //Task 4: Add the Signing Information to the Request
        if (!presign) headers.put('X-Amz-Content-Sha256', hexEncodedHash(payload));
        String signature = EncodingUtil.convertToHex(hmac);
        parameters.put('X-Amz-Signature', signature);

        //prepare request
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(pr.getUrl());
        if (payload != Blob.valueOf('')) request.setBodyAsBlob(payload); //affects http method
        for (String header : headers.keySet()) request.setHeader(header, headers.get(header));

        return request;
    }
    
}