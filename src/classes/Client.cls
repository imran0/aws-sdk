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

    String service;
    String region;

    /**
     * AwsApi.Client.accessKeyId = 'XXXXXXXXXXXXXXXXXXXX';
     * AwsApi.Client.secretkey = 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY';
     *
     * AwsApi.Client.Ec2Filter filter = new AwsApi.Client.Ec2Filter();
     * filter.Name = 'instance-state-name';
     * filter.Value = new List<String>{'running'};
     *
     * AwsApi.Client.Ec2 ec2 = new AwsApi.Client.Ec2('us-west-2');
     * ec2.describeInstances(new List<AwsApi.Client.Ec2Filter>{filter});
     */
    public class Ec2 extends Client {

        public Ec2(String region) {
            this.service = 'ec2';
            this.region = region;
        }

        public Ec2DescribeInstancesResponse describeInstances() {
            return describeInstances(null);
        }

        /**
         * Describes one or more of your instances.
         * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html
         */
        public Ec2DescribeInstancesResponse describeInstances(Ec2DescribeInstancesRequest describeInstancesRequest) {
            Map<String,String> parameters = new Flattener(describeInstancesRequest).getMap();
            parameters.put('Version', '2015-10-01');
            parameters.put('Action', 'DescribeInstances');

            HttpRequest request = this.requestFor(parameters);
            HttpResponse response = new Http().send(request);
            
            String data = xml2json(response.getBody());
            Object dto = Json.deserialize(data, Ec2DescribeInstancesResponse.class);
            return (Ec2DescribeInstancesResponse)dto;
        }

        /**
         * Describes one or more regions that are currently available to you.
         * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Region.html
         */
        public Ec2DescribeRegionsResponse describeRegions(Ec2DescribeRegionsRequest describeRegionsRequest) {
            Map<String,String> parameters = new Flattener(describeRegionsRequest).getMap();
            parameters.put('Version', '2015-10-01');
            parameters.put('Action', 'DescribeRegions');

            HttpRequest request = this.requestFor(parameters);
            HttpResponse response = new Http().send(request);

            String data = xml2json(response.getBody());
            Object dto = Json.deserialize(data, Ec2DescribeRegionsResponse.class);
            return (Ec2DescribeRegionsResponse)dto;
        }

        /**
         * Launches the specified number of instances using an AMI for which you have permissions.
         * http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html
         */
        public Ec2RunInstancesResponse runInstances(Ec2RunInstancesRequest runInstancesRequest) {
            Map<String,String> parameters = new Flattener(runInstancesRequest).getMap();
            parameters.put('Version', '2015-10-01');
            parameters.put('Action', 'RunInstances');

            HttpRequest request = this.requestFor(parameters);
            HttpResponse response = new Http().send(request);

            String data = xml2json(response.getBody());
            Object dto = Json.deserialize(data, Ec2RunInstancesResponse.class);
            return (Ec2RunInstancesResponse)dto;
        }

    }

    /**
     * Describes one or more of your instances.
     */
    public class Ec2DescribeInstancesRequest {

        /**
         * Checks whether you have the required permissions for the action, without actually making the
         * request, and provides an error response. If you have the required permissions, the error response
         * is DryRunOperation. Otherwise, it is UnauthorizedOperation.
         */
        public Boolean DryRun;

        /**
         * One or more filters.
         */
        public List<Ec2Filter> Filter;

        /**
         * One or more instance IDs.
         */
        public List<String> InstanceId;

        /**
         * The maximum number of results to return in a single call. To retrieve the remaining results, make
         * another call with the returned NextToken value. This value can be between 5 and 1000. You cannot
         * specify this parameter and the instance IDs parameter in the same call.
         */
        public Integer MaxResults;

        /**
         * The token to request the next page of results.
         */
        public String NextToken;

    }

    /**
     * A filter name and value pair that is used to return a more specific list of results.
     * Filters can be used to match a set of resources by various criteria, such as tags, attributes, or IDs.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Filter.html
     */
    public class Ec2Filter {

        /**
         * The name of the filter. Filter names are case-sensitive.
         */
        public String Name;

        /**
         * One or more filter values. Filter values are case-sensitive.
         */
        public List<String> Value;

    }

    /**
     * Describes one or more regions that are currently available to you.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeRegions.html
     */
    public class Ec2DescribeRegionsRequest {

        /**
         * Checks whether you have the required permissions for the action, without actually making the
         * request, and provides an error response. If you have the required permissions, the error response
         * is DryRunOperation. Otherwise, it is UnauthorizedOperation.
         */
        public Boolean DryRun;

        /**
         * One or more filters.
         */
        public List<Ec2Filter> Filter;

        /**
         * The names of one or more regions.
         */
        public List<String> RegionName;

    }

    /**
     * Launches the specified number of instances using an AMI for which you have permissions.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html?&!
     */
    public class Ec2RunInstancesRequest {

        /**
         * Reserved.
         */
        public String AdditionalInfo;

        /**
         * The block device mapping.
         */
        public List<Ec2BlockDeviceMapping> BlockDeviceMapping;

        /**
         * Unique, case-sensitive identifier you provide to ensure the idempotency of the request.
         */
        public String ClientToken;

        /**
         * If you set this parameter to true, you can't terminate the instance using the Amazon EC2 console,
         * CLI, or API; otherwise, you can. If you set this parameter to true and then later want to be able
         * to terminate the instance, you must first change the value of the disableApiTermination attribute
         * to false using ModifyInstanceAttribute.
         *
         * Alternatively, if you set InstanceInitiatedShutdownBehavior to terminate, you can terminate the
         * instance by running the shutdown command from the instance.
         */
        public Boolean DisableApiTermination;

        /**
         * Checks whether you have the required permissions for the action, without actually making the
         * request, and provides an error response. If you have the required permissions, the error response
         * is DryRunOperation. Otherwise, it is UnauthorizedOperation.
         */
        public Boolean DryRun;

        /**
         * Indicates whether the instance is optimized for EBS I/O. This optimization provides dedicated
         * throughput to Amazon EBS and an optimized configuration stack to provide optimal EBS I/O
         * performance. This optimization isn't available with all instance types. Additional usage charges
         * apply when using an EBS-optimized instance.
         */
        public Boolean EbsOptimized;

        /**
         * The IAM instance profile.
         */
        public Ec2IamInstanceProfileSpecification IamInstanceProfile;

        /**
         * The ID of the AMI, which you can get by calling DescribeImages.
         */
        public String ImageId = 'ami-08111162';

        /**
         * Indicates whether an instance stops or terminates when you initiate shutdown from the instance
         * (using the operating system command for system shutdown).
         */
        public String InstanceInitiatedShutdownBehavior;

        /**
         * The instance type. For more information, see Instance Types in the Amazon Elastic Compute Cloud
         * User Guide.
         */
        public String InstanceType = 't2.micro';

        /**
         * The ID of the kernel.
         */
        public String KernelId;

        /**
         * The name of the key pair. You can create a key pair using CreateKeyPair or ImportKeyPair.
         */
        public String KeyName;

        /**
         * The maximum number of instances to launch. If you specify more instances than Amazon EC2 can
         * launch in the target Availability Zone, Amazon EC2 launches the largest possible number of
         * instances above MinCount.
         */
        public Integer MaxCount = 1;

        /**
         * The minimum number of instances to launch. If you specify a minimum that is more instances than
         * Amazon EC2 can launch in the target Availability Zone, Amazon EC2 launches no instances.
         */
        public Integer MinCount = 1;

        /**
         * The monitoring for the instance.
         */
        public Ec2RunInstancesMonitoringEnabled Monitoring;

        /**
         * One or more network interfaces.
         */
        public List<Ec2InstanceNetworkInterfaceSpecification> NetworkInterface;

        /**
         * The placement for the instance.
         */
        public Ec2Placement Placement;

        /**
         * The primary IP address. You must specify a value from the IP address range of the subnet.
         */
        public String PrivateIpAddress;

        /**
         * The ID of the RAM disk.
         */
        public String RamdiskId;

        /**
         * One or more security group IDs. You can create a security group using CreateSecurityGroup.
         */
        public List<String> SecurityGroupId;

        /**
         * One or more security group names. For a nondefault VPC, you must use security group IDs instead.
         */
        public List<String> SecurityGroup;

        /**
         * The ID of the subnet to launch the instance into.
         */
        public String SubnetId;

        /**
         * Data to configure the instance, or a script to run during instance launch. For more information,
         * see Running Commands on Your Linux Instance at Launch (Linux) and Adding User Data (Windows). For
         * API calls, the text must be base64-encoded. For command line tools, the encoding is performed for
         * you, and you can load the text from a file.
         */
        public String UserData;

    }

    /**
     * Describes an IAM instance profile.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_IamInstanceProfileSpecification.html
     */
    public class Ec2IamInstanceProfileSpecification {

        /**
         * The Amazon Resource Name (ARN) of the instance profile.
         */
        public String Arn;

        /**
         * The name of the instance profile.
         */
        public String Name;

    }

    /**
     * Describes the monitoring for the instance.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstancesMonitoringEnabled.html
     */
    public class Ec2RunInstancesMonitoringEnabled {

        /**
         * Indicates whether monitoring is enabled for the instance.
         */
        public Boolean Enabled;

    }

    /**
     * Describes a network interface.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstanceNetworkInterfaceSpecification.html
     */
    public class Ec2InstanceNetworkInterfaceSpecification {

        /**
         * Indicates whether to assign a public IP address to an instance you launch in a VPC. The public IP
         * address can only be assigned to a network interface for eth0, and can only be assigned to a new
         * network interface, not an existing one. You cannot specify more than one network interface in the
         * request. If launching into a default subnet, the default value is true.
         */
        public Boolean AssociatePublicIpAddress;

        /**
         * If set to true, the interface is deleted when the instance is terminated. You can specify true
         * only if creating a new network interface when launching an instance.
         */
        public Boolean DeleteOnTermination;

        /**
         * The description of the network interface. Applies only if creating a network interface when
         * launching an instance.
         */
        public String Description;

        /**
         * The index of the device on the instance for the network interface attachment. If you are specifying
         * a network interface in a RunInstances request, you must provide the device index.
         */
        public Integer DeviceIndex;

        /**
         * The IDs of the security groups for the network interface. Applies only if creating a network
         * interface when launching an instance.
         */
        public List<String> SecurityGroupId;

        /**
         * The ID of the network interface.
         */
        public String NetworkInterfaceId;

        /**
         * The private IP address of the network interface. Applies only if creating a network interface when
         * launching an instance.
         */
        public String PrivateIpAddress;

        /**
         * One or more private IP addresses to assign to the network interface. Only one private IP address
         * can be designated as primary.
         */
        public List<Ec2PrivateIpAddressSpecification> PrivateIpAddressesSet;

        /**
         * The number of secondary private IP addresses. You can't specify this option and specify more than
         * one private IP address using the private IP addresses option.
         */
        public Integer SecondaryPrivateIpAddressCount;

        /**
         * The ID of the subnet associated with the network string. Applies only if creating a network
         * interface when launching an instance.
         */
        public String SubnetId;
    }

    /**
     * Describes a secondary private IP address for a network interface.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_PrivateIpAddressSpecification.html
     */
    public class Ec2PrivateIpAddressSpecification {

        /**
         * Indicates whether the private IP address is the primary private IP address. Only one IP address
         * can be designated as primary.
         */
        public Boolean Primary;

        /**
         * The private IP addresses.
         */
        public String PrivateIpAddress;

    }

    @TestVisible static String canonicalMethodFor(String method) {
        return method.toUpperCase();
    }
    
    @TestVisible static String canonicalUriFor(String endpoint) {
        Url uri = new Url(endpoint);
        String segments = rfc3986for(uri.getPath());
        return segments.replace('%2F', '/');
    }
    
    @TestVisible static String canonicalQueryStringFor(Map<String,String> parameters) {
        
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
    
    @TestVisible static String canonicalHeadersFor(Map<String,String> key2value) {
        
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
    
    @TestVisible static String signedHeadersFor(Map<String,String> headers) {
        
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
    
    @TestVisible static String hexEncodedHash(String data) {
        Blob bin = Blob.valueOf(data);
        Blob hash = Crypto.generateDigest('SHA256', bin);
        return EncodingUtil.convertToHex(hash);
    }
    
    @TestVisible static String rfc3986for(String value) {
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

    @TestVisible class Flattener {

        Map<String,String> p = new Map<String,String>();
        List<Object> stack = new List<Object>();

        /**
         * Usage:
         * new Flattener(dto).getMap();
         */
        public Flattener(Object dto) {
            dto = Json.deserializeUntyped(Json.serialize(dto));
            if (dto == null) {
                //nothing to do
            } else if (dto instanceof Map<String,Object>) {
                traverseMap((Map<String,Object>)dto);
            } else if (dto instanceof List<Object>) {
                traverseList((List<Object>)dto);
            } else {
                //nothing to do
            }
        }

        public Map<String,String> getMap() {
            return p;
        }

        void traverseMap(Map<String,Object> dto) {
            List<String> keys = new List<String>(dto.keySet());
            for (String key : keys) {
                stack.add(key);

                Object value = dto.get(key);
                if (value == null) {
                    //nothing to do
                } else if (value instanceof Map<String,Object>) {
                    traverseMap((Map<String,Object>)value);
                } else if (value instanceof List<Object>) {
                    traverseList((List<Object>)value);
                } else {
                    p.put(String.join(stack, '.'), String.valueOf(value));
                }

                stack.remove(stack.size() - 1);
            }
        }

        void traverseList(List<Object> objs) {

            for (Integer i = 0; i < objs.size(); i++) {
                stack.add(i + 1);

                if (objs[i] == null) {
                    //nothing to do
                } else if (objs[i] instanceof Map<String,Object>) {
                    traverseMap((Map<String,Object>)objs[i]);
                } else if (objs[i] instanceof List<Object>) {
                    traverseList((List<Object>)objs[i]);
                } else {
                    p.put(String.join(stack, '.'), String.valueOf(objs[i]));
                }

                stack.remove(stack.size() - 1);
            }

        }

    }



    @TestVisible static String xml2json(String xml) {
        XmlStreamReader reader = new XmlStreamReader(xml);
        reader.setCoalescing(true);

        //skip START_DOCUMENT
        reader.nextTag();

        JsonGenerator g = Json.createGenerator(true);
        g.writeStartObject();

        while (reader.hasNext()) {

            if (reader.isWhitespace()) {
                //nothing to do

            } else if (reader.isStartElement()) {

                //found open tag
                String name = reader.getLocalName();
                reader.next();

                if (reader.isWhitespace()) {
                    //skip whitespace
                    reader.next();
                }

                if (reader.isEndElement()) {
                    //found immediately closing tag
                    g.writeNullField(name);

                } else if (!reader.isCharacters()) {
                    //found object
                    if (name.endsWith('Response')) {
                        //nothing to do

                    } else if (name.endsWith('Set') || name.endsWith('Mapping') || name.endsWith('Info')) {
                        g.writeFieldName(name);
                        g.writeStartArray();

                    } else if (name == 'item') {
                        g.writeStartObject();

                    } else {
                        g.writeFieldName(name);
                        g.writeStartObject();
                    }

                    continue;

                } else {
                    //found text

                    String text = reader.getText();

                    if (text == 'true' || text == 'false') {
                        //found boolean field
                        g.writeBooleanField(name, text == 'true');

                    } else {
                        //all others strings
                        g.writeStringField(name, reader.getText());
                    }

                    reader.nextTag(); //skip close
                }

            } else if (reader.isCharacters()) {

                //found text
                g.writeObject(reader.getText());
                reader.nextTag(); //skip close

            }  else if (reader.isEndElement()) {

                //found end tag
                String name = reader.getLocalName();
                if (name.endsWith('Response')) {
                    //nothing to do
                } else if (name.endsWith('Set') || name.endsWith('Mapping') || name.endsWith('Info')) {
                    g.writeEndArray();
                } else if (name == 'item') {
                    g.writeEndObject();
                } else {
                    g.writeEndObject();
                }
                reader.next();
            }

            reader.next();
        }

        return g.getAsString();
    }

    /**
     * Describes one or more of your instances.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html
     */
    public class Ec2DescribeInstancesResponse {
        public String requestId;
        public List<Ec2Reservation> reservationSet;
    }

    /**
     * Describes a reservation.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Reservation.html
     */
    public class Ec2Reservation {

        /**
         * One or more security groups.
         */
        public List<Ec2SecurityGroup> groupSet;

        /**
         * One or more instances.
         */
        public List<Ec2Instance> instancesSet;

        /**
         * The ID of the AWS account that owns the reservation.
         */
        public String ownerId;

        /**
         * The ID of the reservation.
         */
        public String reservationId;
    }

    /**
     * Describes a security group.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_GroupIdentifier.html
     */
    public class Ec2SecurityGroup {

        /**
         * The ID of the security group.
         */
        public String groupId;

        /**
         * The name of the security group.
         */
        public String groupName;
    }

    /**
     * Describes an instance.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Instance.html
     */
    public class Ec2Instance {

        /**
         * The AMI launch index, which can be used to find this instance in the launch group.
         */
        public String amiLaunchIndex;

        /**
         * The architecture of the image.
         */
        public String architecture;

        /**
         * Any block device mapping entries for the instance.
         */
        public List<Ec2BlockDeviceMapping> blockDeviceMapping;

        /**
         * The idempotency token you provided when you launched the instance, if applicable.
         */
        public String clientToken;

        /**
         * Indicates whether the instance is optimized for EBS I/O. This optimization provides dedicated
         * throughput to Amazon EBS and an optimized configuration stack to provide optimal I/O performance.
         * This optimization isn't available with all instance types. Additional usage charges apply when
         * using an EBS Optimized instance.
         */
        public Boolean ebsOptimized;

        /**
         * The hypervisor type of the instance.
         */
        public String hypervisor;

        /**
         * The ID of the AMI used to launch the instance.
         */
        public String imageId;

        /**
         * The ID of the instance.
         */
        public String instanceId;

        /**
         * The instance type.
         */
        public String instanceType;

        /**
         * The name of the key pair, if this instance was launched with an associated key pair.
         */
        public String keyName;

        /**
         * The time the instance was launched.
         */
        public String launchTime;

        /**
         * The monitoring information for the instance.
         */
        public Ec2Monitoring monitoring;

        /**
         * One or more network interfaces for the instance.
         */
        public List<Ec2NetworkInterface> networkInterfaceSet;

        /**
         * The location where the instance launched, if applicable.
         */
        public Ec2Placement placement;

        /**
         * The private DNS name assigned to the instance. This DNS name can only be used inside the Amazon EC2
         * network. This name is not available until the instance enters the running state. For EC2-VPC, this
         * name is only available if you've enabled DNS hostnames for your VPC.
         */
        public String privateDnsName;

        /**
         * The private IP address assigned to the instance.
         */
        public String privateIpAddress;

        /**
         * The product codes attached to this instance, if applicable.
         */
        //public List<ProductCode> productCodes; //collection does not end in Set

        /**
         * The public DNS name assigned to the instance. This name is not available until the instance enters
         * the running state. For EC2-VPC, this name is only available if you've enabled DNS hostnames for
         * your VPC.
         */
        public String dnsName;

        /**
         * The public IP address assigned to the instance, if applicable.
         */
        public String ipAddress;

        /**
         * The root device name (for example, /dev/sda1 or /dev/xvda).
         */
        public String rootDeviceName;

        /**
         * The root device type used by the AMI. The AMI can use an EBS volume or an instance store volume.
         */
        public String rootDeviceType;

        /**
         * One or more security groups for the instance.
         */
        public List<Ec2SecurityGroup> groupSet;

        /**
         * Specifies whether to enable an instance launched in a VPC to perform NAT. This controls whether
         * source/destination checking is enabled on the instance. A value of true means checking is enabled,
         * and false means checking is disabled. The value must be false for the instance to perform NAT. For
         * more information, see NAT Instances in the Amazon Virtual Private Cloud User Guide.
         */
        public Boolean sourceDestCheck;

        /**
         * The private IP address assigned to the instance.
         */
        public Ec2InstanceState instanceState;

        /**
         * The reason for the most recent state transition. This might be an empty string.
         */
        public Ec2Reason reason;

        /**
         * The ID of the subnet in which the instance is running.
         */
        public String subnetId;

        /**
         * Any tags assigned to the instance.
         */
        public List<Ec2Tag> tagSet;

        /**
         * The virtualization type of the instance.
         */
        public String virtualizationType;

        /**
         * The ID of the VPC in which the instance is running.
         */
        public String vpcId;

    }

    /**
     * Describes a block device mapping.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstanceBlockDeviceMapping.html
     */
    public class Ec2BlockDeviceMapping {

        /**
         * The device name exposed to the instance (for example, /dev/sdh or xvdh).
         */
        public String deviceName;

        /**
         * Parameters used to automatically set up EBS volumes when the instance is launched.
         */
        public Ec2BlockDevice ebs;
    }

    /**
     * Describes a parameter used to set up an EBS volume in a block device mapping.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_EbsInstanceBlockDevice.html
     */
    public class Ec2BlockDevice {
        /**
         * The time stamp when the attachment initiated.
         */
        public String attachTime;

        /**
         * Indicates whether the volume is deleted on instance termination.
         */
        public Boolean deleteOnTermination;

        /**
         * The attachment state.
         */
        public String status;

        /**
         * The ID of the EBS volume.
         */
        public String volumeId;

    }

    /**
     * Describes the monitoring for the instance.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Monitoring.html
     */
    public class Ec2Monitoring {
        public String state; //disabled
    }

    /**
     * Describes a network interface.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstanceNetworkInterface.html
     */
    public class Ec2NetworkInterface {

        /**
         * The association information for an Elastic IP associated with the network interface.
         */
        public Ec2NetworkAssociation association;

        /**
         * The network interface attachment.
         */
        public Ec2NetworkAttachment attachment;

        /**
         * The description.
         */
        public String description;

        /**
         * One or more security groups.
         */
        public List<Ec2SecurityGroup> groupSet;

        /**
         * The MAC address.
         */
        public String macAddress;

        /**
         * The ID of the network interface.
         */
        public String networkInterfaceId;

        /**
         * The ID of the AWS account that created the network interface.
         */
        public String ownerId;

        /**
         * The private DNS name.
         */
        public String privateDnsName;

        /**
         * The IP address of the network interface within the subnet.
         */
        public String privateIpAddress;

        /**
         * The private IP addresses associated with the network interface.
         */
        public List<Ec2PrivateIpAddress> privateIpAddressesSet;

        /**
         * Indicates whether to validate network traffic to or from this network interface.
         */
        public Boolean sourceDestCheck;

        /**
         * The status of the network interface.
         */
        public String status;

        /**
         * The ID of the subnet.
         */
        public String subnetId;

        /**
         * The ID of the VPC.
         */
        public String vpcId;

    }


    /**
     * Describes association information for an Elastic IP address.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstanceNetworkInterfaceAssociation.html
     */
    public class Ec2NetworkAssociation {

        /**
         * The ID of the owner of the Elastic IP address.
         */
        public String ipOwnerId;

        /**
         * The public DNS name.
         */
        public String publicDnsName;

        /**
         * The public IP address or Elastic IP address bound to the network interface.
         */
        public String publicIp;

    }

    /**
     * Describes a network interface attachment.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstanceNetworkInterfaceAttachment.html
     */
    public class Ec2NetworkAttachment {

        /**
         * The ID of the network interface attachment.
         */
        public String attachmentId;

        /**
         * The time stamp when the attachment initiated.
         */
        public String attachTime;

        /**
         * Indicates whether the network interface is deleted when the instance is terminated.
         */
        public Boolean deleteOnTermination;

        /**
         * The index of the device on the instance for the network interface attachment.
         */
        public String deviceIndex;

        /**
         * The attachment state.
         */
        public String status;
    }

    /**
     * Describes a private IP address.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstancePrivateIpAddress.html
     */
    public class Ec2PrivateIpAddress {

        /**
         * The association information for an Elastic IP address for the network interface.
         */
        public Ec2NetworkAssociation association;

        /**
         * Indicates whether this IP address is the primary private IP address of the network interface.
         */
        public Boolean primary;

        /**
         * Indicates whether this IP address is the primary private IP address of the network interface.
         */
        public String privateDnsName;

        /**
         * privateIpAddress
         */
        public String privateIpAddress;
    }

    /**
     * Describes the placement for the instance.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Placement.html
     */
    public class Ec2Placement {

        /**
         * The affinity setting for the instance on the Dedicated host. This parameter is not supported for
         * the ImportInstance command.
         */
        public String Affinity;

        /**
         * The Availability Zone of the instance.
         */
        public String AvailabilityZone;

        /**
         * The name of the placement group the instance is in (for cluster compute instances).
         */
        public String GroupName;

        /**
         * The ID of the Dedicted host on which the instance resides. This parameter is not support for the
         * ImportInstance command.
         */
        public String HostId;

        /**
         * The tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of
         * dedicated runs on single-tenant hardware. The host tenancy is not supported for the ImportInstance
         * command.
         */
        public String Tenancy;

    }

    /**
     * Describes a product code.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ProductCode.html
     */
    public class Ec2ProductCode {

        /**
         * The product code.
         */
        public String productCode;

        /**
         * The type of product code.
         */
        public String type;

    }

    /**
     * Describes the current state of the instance.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstanceState.html
     */
    public class Ec2InstanceState {
        /**
         * The low byte represents the state. The high byte is an opaque internal value and should be ignored.
         */
        public String code;

        /**
         * The current state of the instance.
         */
        public String name;

    }

    /**
     * Describes a state change.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_StateReason.html
     */
    public class Ec2Reason {

        /**
         * The reason code for the state change.
         */
        public String code;

        /**
         * The message for the state change.
         */
        public String message;

    }

    /**
     * Describes a tag.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Tag.html
     */
    public class Ec2Tag {

        /**
         * The key of the tag.
         */
        public String key;

        /**
         * The value of the tag.
         */
        public String value;
    }

    /**
     * Describes one or more regions that are currently available to you.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeRegions.html
     */
    public class Ec2DescribeRegionsResponse {

        /**
         * Information about one or more regions.
         */
        public List<Ec2Region> regionInfo;

        /**
         * The ID of the request.
         */
        public String requestId;

    }

    /**
     * Describes a region.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Region.html
     */
    public class Ec2Region {

        /**
         * The region service endpoint.
         */
        public String regionEndpoint;

        /**
         * The name of the region.
         */
        public String regionName;

    }

    /**
     * Launches the specified number of instances using an AMI for which you have permissions.
     * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html
     */
    public class Ec2RunInstancesResponse {

        /**
         * The ID of the request.
         */
        public String requestId;

        /**
         * Zero or more reservations.
         */
        public Ec2Reservation reservation;

    }

}