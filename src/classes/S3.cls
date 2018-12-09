/**
 * @author bigassforce
 * Amazon Simple Storage Service SDK for Salesforce Apex
 *
 * Example usage:
 * 
 * String accessKey = 'XXXXXXXXXXXXXXXXXXXX';
 * String secretkey = 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY';
 * AwsSdk.Connector connector = new AwsSdk.Connector(accessKey, secretKey);
 *
 * String region = 'us-east-1';
 * AwsApi.S3 s3 = connector.s3(region);
 * List<AwsApi.S3.Content> contents = s3.bucket('bucketname').listContents(null);
 */
global class S3 {

    global class ClientException extends Exception {}

    Connector connector;
    global S3(Connector connector, String region) {
        this.connector = connector;
        this.connector.region = region;
        this.connector.service = 's3';
    }

    /**
     * Example usage:
     * new AwsSdk.Connector('access', 'secret').s3('us-east-1').bucket('bucketname');
     */
    global Bucket bucket(String name) {
        return new Bucket(this.connector, name);
    }

    /**
     * This section describes operations you can perform on Amazon S3 objects.
     * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectOps.html
     */
    global class Bucket {

        /**
         * Bucket's name.
         */
        global String Name;

        /**
         * Date the bucket was created.
         */
        global Datetime CreationDate;

        Connector connector;
        Bucket(Connector connector, String bucket) {
            this.connector = connector;
            this.Name = bucket;
        }

        /**
         * Example usage:
         * new AwsSdk.Connector('access', 'secret').s3('us-east-1').bucket('bucketname').content('key');
         */
        global Content content(String key) {
            return new Content(this, key);
        }

        /**
         * This implementation of the GET operation returns some or all (up to 1000) of the objects in a bucket.
         * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html
         */
        global List<Content> listContents(ListContentsRequest listContentsRequest) {
            PageReference pr = new PageReference('https://s3.amazonaws.com/' + this.Name);
            Map<String,String> parameters = new RequestFormatter(listContentsRequest).getMap();
            pr.getParameters().putAll(parameters);

            Url endpoint = new Url(pr.getUrl());
            HttpRequest request = this.connector.signedRequest('GET', endpoint, null, null, null);
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 200) throw new ClientException(response.getBody());

            ListBucketResult result = new ListBucketResult();
            result.Contents = new List<Content>();

            for (Dom.XmlNode node : response.getBodyDocument().getRootElement().getChildElements()) {
                if (node.getName() != 'Contents') continue;
                String data = new ResponseFormatter(node).getJson();
                Content dto = (Content)Json.deserialize(data, Content.class);
                dto.bucket = this;
                result.Contents.add(dto);
            }

            return result.Contents;
        }

        /**
         * The DELETE operation removes the null version (if there is one) of an object
         * and inserts a delete marker, which becomes the current version of the object.
         * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectDELETE.html
         */
        global HttpResponse deleteContent(String key) {
            if (key.startsWith('/')) throw new ClientException('Keys should not lead with slash');
            Url endpoint = new Url('https://s3.amazonaws.com/' + this.Name + '/' + key);
            HttpRequest request = this.connector.signedRequest('DELETE', endpoint, null, null, null);
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 204) throw new ClientException(response.getBody());
            return response;
        }

        /**
         * This implementation of the PUT operation adds an object to a bucket.
         * You must have WRITE permissions on a bucket to add an object to it.
         * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html
         */
        global HttpResponse createContent(String key, Map<String,String> headers, Blob payload) {
            if (key.startsWith('/')) throw new ClientException('Keys should not lead with slash');
            Url endpoint = new Url('https://s3.amazonaws.com/' + this.Name + '/' + key);
            HttpRequest request = this.connector.signedRequest('PUT', endpoint, headers, payload, null);
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 200) throw new ClientException(response.getBody());
            return response;
        }

    }

    /**
     * Metadata about each object returned.
     */
    global class Content {

        /**
         * The object's key.
         */
        global String Key;

        /**
         * Date and time the object was last modified.
         */
        global Datetime LastModified;

        /**
         * The entity tag is an MD5 hash of the object. The ETag only reflects changes to the contents of an
         * object, not its metadata.
         */
        global String ETag;

        /**
         * Size in bytes of the object.
         */
        global String Size;

        /**
         * STANDARD | STANDARD_IA | REDUCED_REDUNDANCY | GLACIER
         */
        global String StorageClass;

        /**
         * Bucket owner.
         */
        global Owner Owner;

        Bucket bucket;
        Content(Bucket bucket, String key) {
            this.bucket = bucket;
            this.Key = key;
        }

        /**
         * Provides the time period, in seconds, for which the generated presigned URL is valid.
         */
        global HttpRequest presign() {
            String method = 'GET';
            Url endpoint = new Url('https://s3.amazonaws.com/' + this.bucket.Name + '/' + this.Key);
            Map<String,String> headers = new Map<String,String>();
            Blob payload = null;
            Boolean presign = true;
            return this.bucket.connector.signedRequest(method, endpoint, headers, payload, presign);
        }

    }

    /**
     * This implementation of the GET operation returns a list of all
     * buckets owned by the authenticated sender of the request.
     * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTServiceGET.html
     */
    global class ListContentsRequest {

        /**
         * A delimiter is a character you use to group keys.
         *
         * All keys that contain the same string between the prefix, if specified, and the first occurrence of
         * the delimiter after the prefix are grouped under a single result element, CommonPrefixes. If you
         * don't specify the prefix parameter, then the substring starts at the beginning of the key. The keys
         * that are grouped under CommonPrefixes result element are not returned elsewhere in the response.
         *
         */
        global String delimiter;

        /**
         * Requests Amazon S3 to encode the response and specifies the encoding method to use.
         *
         * An object key can contain any Unicode character; however, XML 1.0 parser cannot parse some
         * characters, such as characters with an ASCII value from 0 to 10. For characters that are not
         * supported in XML 1.0, you can add this parameter to request that Amazon S3 encode the keys in the
         * response.
         */
        global String encodingType;

        /**
         * Specifies the key to start with when listing objects in a bucket. Amazon S3 returns object keys in
         * UTF-8 binary order, starting with key after the marker in order.
         */
        global String marker;

        /**
         * Sets the maximum number of keys returned in the response body. You can add this to your request if
         * you want to retrieve fewer than the default 1000 keys.
         *
         * The response might contain fewer keys but will never contain more. If there are additional keys
         * that satisfy the search criteria but were not returned because max-keys was exceeded, the response
         * contains <IsTruncated>true</IsTruncated>. To return the additional keys, see marker.
         */
        global String maxKeys;

        /**
         * Limits the response to keys that begin with the specified prefix. You can use prefixes to separate
         * a bucket into different groupings of keys. (You can think of using prefix to make groups in the
         * same way you'd use a folder in a file system.)
         */
        global String prefix;

    }

    /**
     * This implementation of the GET operation returns a list of all
     * buckets owned by the authenticated sender of the request.
     * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTServiceGET.html
     *
     * AwsApi.S3 s3 = new AwsApi.S3('us-west-2');
     * List<Bucket> results = s3.get();
     *
     */
    global List<Bucket> listBuckets() {
        HttpRequest request = this.connector.signedRequest('GET', new Url('https://s3.amazonaws.com/'), null, null, null);
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() != 200) throw new ClientException(response.getBody());

        String data = new ResponseFormatter(response.getBodyDocument().getRootElement()).getJson();
        Object dto = Json.deserialize(data, ListAllMyBucketsResult.class);
        return ((ListAllMyBucketsResult)dto).Buckets;
    }

    /**
     * This implementation of the PUT operation creates a new bucket.
     * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketPUT.html
     */
    global HttpResponse createBucket(String bucketName) {
        HttpRequest request = this.connector.signedRequest('PUT', new Url('https://s3.amazonaws.com/' + bucketName), null, null, null);
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() != 200) throw new ClientException(response.getBody());
        return response;
    }

    /**
     * This implementation of the DELETE operation deletes the bucket named in the URI.
     * All objects (including all object versions and delete markers) in the bucket must
     * be deleted before the bucket itself can be deleted.
     * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketDELETE.html
     */
    global HttpResponse deleteBucket(String bucketName) {
        HttpRequest request = this.connector.signedRequest('DELETE', new Url('https://s3.amazonaws.com/' + bucketName), null, null, null);
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() != 204) throw new ClientException(response.getBody());
        return response;
    }

    /**
     * Takes any request object and formats it as HTTP headers, for example:
     *
     * GetRequest: [
     *     delimiter=test,
     *     encodingType=text/plain
     * ]
     *
     * delimiter: test,
     * encoding-type: text/plain
     */
    @TestVisible class RequestFormatter {

        Map<String,String> p = new Map<String,String>();

        public RequestFormatter(Object dto) {
            if (dto == null) return;
            Map<String,Object> key2value = (Map<String,Object>)Json.deserializeUntyped(Json.serialize(dto));
            for (String key : key2value.keySet()) {
                Object value = key2value.get(key);
                if (value == null) continue;
                key = key.replaceAll('([A-Z])', '-$0').toLowerCase();
                p.put(key, String.valueOf(value));
            }
        }

        public Map<String,String> getMap() {
            return p;
        }

    }

    /**
     * Takes any response XML and formats into DTO-ready JSON, for example:
     *
     * <DescribeRegionsResponse>
     *     <requestId>eb34bc90-389f-46c1-81bd-d8492f88983a</requestId>
     *     <regionInfo>
     *         <item>
     *             <regionEndpoint>ec2.us-west-1.amazonaws.com</regionEndpoint>
     *             <regionName>us-west-1</regionName>
     *         </item>
     *     </regionInfo>
     * </DescribeRegionsResponse>
     *
     * {
     *     "requestId": "fff48ea8-2445-492e-a2cf-6bf2582896fb",
     *     "regionInfo": [
     *         {
     *             "regionEndpoint": "ec2.us-west-1.amazonaws.com",
     *             "regionName": "us-west-1"
     *         }
     *     ]
     * }
     */
    @TestVisible class ResponseFormatter {

        JsonGenerator g = Json.createGenerator(true);

        public ResponseFormatter(Dom.XmlNode node) {
            try {
                traverseNode(node);
            } catch (Exception e) {
                e.setMessage(g.getAsString());
                throw e;
            }
        }

        public String getJson() {
            return g.getAsString();
        }

        public void traverseNode(Dom.XmlNode node) {

            if (!String.isEmpty(node.getName()) && node.getChildren().isEmpty()) {
                //found self closing tag (not text and no children) eg <reason/>
                g.writeNull();
                return;
            }

            g.writeStartObject();

            for (Dom.XmlNode child : node.getChildren()) {

                String name = child.getName();
                String text = child.getText();

                if (String.isBlank(name) && String.isBlank(text)) {
                    //found whitespace
                    continue;
                }

                if (!String.isBlank(text)) {
                    //found text
                    g.writeFieldName(child.getName());
                    Object value = text;

                    //datetime, boolean, string
                    if (child.getName() == 'CreationDate' || child.getName() == 'LastModified') value = Json.deserialize('"' + value + '"', Datetime.class);
                    else if (value == 'true') value = true;
                    else if (value == 'false') value = false;
                    g.writeObject(value);

                } else if (name == 'Buckets') {
                    //found collection
                    g.writeFieldName(child.getName());
                    g.writeStartArray();
                    for (Dom.XmlNode item : child.getChildElements()) traverseNode(item);
                    g.writeEndArray();

                } else {
                    //found object
                    g.writeFieldName(child.getName());
                    traverseNode(child);
                }

            }

            g.writeEndObject();
        }

    }

    /**
     * This implementation of the GET operation returns a list of all buckets owned by the authenticated
     * sender of the request.
     * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTServiceGET.html
     */
    global class ListAllMyBucketsResult {
        global Owner Owner;
        global List<Bucket> Buckets;
    }

    /**
     * Container for bucket owner information.
     */
    global class Owner {

        /**
         * Bucket owner's user ID.
         */
        global String ID;

        /**
         * Bucket owner's display name.
         */
        global String DisplayName;

    }

    /**
     * This implementation of the GET operation returns some or all (up to 1000) of the objects in a bucket.
     * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html
     */
    global class ListBucketResult {

        /**
         * Name of the bucket.
         */
        global String Name;

        /**
         * Keys that begin with the indicated prefix.
         */
        global String Prefix;

        /**
         * Indicates where in the bucket listing begins.
         */
        global String Marker;

        /**
         * The maximum number of keys returned in the response body.
         */
        global Integer MaxKeys;

        /**
         * Specifies whether (true) or not (false) all of the results were returned.
         */
        global Boolean IsTruncated;

        /**
         * Metadata about each object returned.
         */
        global List<Content> Contents;
    }

}