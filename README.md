# Amazon Web Services SDK for Salesforce Apex

The AWS SDK for Salesforce makes it easy for developers to access Amazon Web Services in their Apex code, and build robust applications and software using services like Amazon S3, Amazon EC2, etc. You can get started in minutes by [installing the package](installing the package).

#### Amazon Simple Storage Service (S3) SDK

S3 is storage for the Internet. The [Apex client](https://github.com/bigassforce/aws-sdk/blob/master/src/classes/S3.cls) gives you a kind of [proxy](https://en.wikipedia.org/wiki/Proxy_pattern) for manipulating both buckets and contents. You can create and destroy objects, and presign a download URL, given the bucket name and the object key.

<img src="https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/gsg/images/flowSignUpForS3.png" />

###### Sign up then go to your AWS Console > Security Credentials > Access Keys:

    String access = 'XXXXXXXXXXXXXXXXXXXX';
    String secret = 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY';
    AwsSdk.Connector connector = new AwsSdk.Connector(access, secret);

###### Creating a bucket:

    AwsSdk.S3 s3 = connector.s3(region);
    String name = 'thebucket';
    s3.createBucket(name);

###### Adding an object to a bucket:

    AwsSdk.S3.Bucket bucket = connector.s3(region).bucket('thebucket');
    Map<String,String> headers = new Map<String,String>{'Content-Type' => 'text/plain'};
    bucket.createContent('foo.txt', headers, Blob.valueOf('bar'));

###### Viewing an object:

    AwsSdk.S3.Content content = connector.s3(region).bucket('thebucket').content('foo.txt');
    HttpRequest request = content.presign();
    String url = request.getEndpoint();

You might want to store these in a Custom Setting instead of hard coded Apex.

#### Amazon Elastic Cloud Compute (EC2) SDK

EC2 provides scalable computing capacity in the cloud. The [Apex client](https://github.com/bigassforce/aws-sdk/blob/master/src/classes/Ec2.cls) calls services to launch instances, terminate instances, etc. The API responds synchronously, but bear in mind that the the instance state transitions take time.

<img src="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/images/instance_lifecycle.png" />

###### Describe running instances:

    AwsSdk.Ec2 ec2 = new AwsSdk.Connector(access, secret).ec2(region);
    AwsSdk.Ec2.DescribeInstancesRequest request = new AwsSdk.Ec2.DescribeInstancesRequest();
    ec2.describeInstances(request);

###### Launch new instance:

    AwsSdk.Ec2.RunInstancesRequest request = new AwsSdk.Ec2.RunInstancesRequest();
    request.imageId = 'ami-08111162'; //amazon linux machine image
    ec2.runInstances(request);

###### Terminate running instance:

    AwsSdk.Ec2.TerminateInstancesRequest request = new AwsSdk.Ec2.TerminateInstancesRequest();
    request.InstanceId = new List<String>{'i-aaaabbbb'};
    ec2.terminateInstances(request);
