/**
 * @author bigassforce
 * Amazon Elastic Compute Cloud SDK for Salesforce Apex
 */
@IsTest class Ec2Test {

    class MockRequest {
        String Foo;
        List<String> Herp;
        List<MockRequest> Nested;
    }

    static testmethod void testRequestFormatter() {
        //arrange
        MockRequest request = new MockRequest();
        request.Foo = 'Bar';
        request.Herp = new List<String>{'Derp', 'Doop'};
        request.Nested = new List<MockRequest>();
        request.Nested.add(new MockRequest());
        request.Nested[0].Foo = 'Baz';

        //act
        Map<String,String> parameters = new Ec2.RequestFormatter(request).getMap();

        //assert
        System.assertEquals('Bar', parameters.get('Foo'), 'wrong foo');
        System.assertEquals('Derp', parameters.get('Herp.1'), 'wrong derp one');
        System.assertEquals('Doop', parameters.get('Herp.2'), 'wrong derp two');
        System.assertEquals('Baz', parameters.get('Nested.1.Foo'), 'wrong nested');
    }

    class DescribeInstancesResponder implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {

            String body = ''
                + '<?xml version="1.0" encoding="UTF-8"?>'
                + '<DescribeInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2015-10-01/">'
                + '    <requestId>aaaabbbb-cccc-dddd-eeee-ffffgggghhhh</requestId>'
                + '    <reservationSet>'
                + '        <item>'
                + '            <reservationId>r-aaaabbbb</reservationId>'
                + '            <ownerId>123456789012</ownerId>'
                + '            <groupSet/>'
                + '            <instancesSet>'
                + '                <item>'
                + '                    <instanceId>i-aaaabbbb</instanceId>'
                + '                    <imageId>ami-ccccdddd</imageId>'
                + '                    <instanceState>'
                + '                        <code>16</code>'
                + '                        <name>running</name>'
                + '                    </instanceState>'
                + '                    <privateDnsName>ip-172-11-22-33.us-east-1.compute.internal</privateDnsName>'
                + '                    <dnsName>ec2-11-22-33-44.us-east-1.compute.amazonaws.com</dnsName>'
                + '                    <reason/>'
                + '                    <keyName>kingdom</keyName>'
                + '                    <amiLaunchIndex>0</amiLaunchIndex>'
                + '                    <productCodes/>'
                + '                    <instanceType>t2.micro</instanceType>'
                + '                    <launchTime>2010-12-25T09:45:00.000Z</launchTime>'
                + '                    <placement>'
                + '                        <availabilityZone>us-east-1a</availabilityZone>'
                + '                        <groupName/>'
                + '                        <tenancy>default</tenancy>'
                + '                    </placement>'
                + '                    <monitoring>'
                + '                        <state>disabled</state>'
                + '                    </monitoring>'
                + '                    <subnetId>subnet-aaaabbbb</subnetId>'
                + '                    <vpcId>vpc-aaaabbbb</vpcId>'
                + '                    <privateIpAddress>172.11.22.33</privateIpAddress>'
                + '                    <ipAddress>11.22.33.44</ipAddress>'
                + '                    <sourceDestCheck>true</sourceDestCheck>'
                + '                    <groupSet>'
                + '                        <item>'
                + '                            <groupId>sg-aaaabbbb</groupId>'
                + '                            <groupName>launch-wizard-1</groupName>'
                + '                        </item>'
                + '                    </groupSet>'
                + '                    <architecture>x86_64</architecture>'
                + '                    <rootDeviceType>ebs</rootDeviceType>'
                + '                    <rootDeviceName>/dev/xvda</rootDeviceName>'
                + '                    <blockDeviceMapping>'
                + '                        <item>'
                + '                            <deviceName>/dev/xvda</deviceName>'
                + '                            <ebs>'
                + '                                <volumeId>vol-aaaabbbb</volumeId>'
                + '                                <status>attached</status>'
                + '                                <attachTime>2010-12-25T09:45:00.000Z</attachTime>'
                + '                                <deleteOnTermination>true</deleteOnTermination>'
                + '                            </ebs>'
                + '                        </item>'
                + '                    </blockDeviceMapping>'
                + '                    <virtualizationType>hvm</virtualizationType>'
                + '                    <clientToken>ABCDEF123456789012</clientToken>'
                + '                    <hypervisor>xen</hypervisor>'
                + '                    <networkInterfaceSet>'
                + '                        <item>'
                + '                            <networkInterfaceId>eni-aaaabbbb</networkInterfaceId>'
                + '                            <subnetId>subnet-aaaabbbb</subnetId>'
                + '                            <vpcId>vpc-aaaabbbb</vpcId>'
                + '                            <description/>'
                + '                            <ownerId>111122223333</ownerId>'
                + '                            <status>in-use</status>'
                + '                            <macAddress>aa:bb:cc:dd:ee:ff</macAddress>'
                + '                            <privateIpAddress>172.11.22.33</privateIpAddress>'
                + '                            <privateDnsName>ip-172-11-22-33.us-east-1.compute.internal</privateDnsName>'
                + '                            <sourceDestCheck>true</sourceDestCheck>'
                + '                            <groupSet>'
                + '                                <item>'
                + '                                    <groupId>sg-aaaabbbb</groupId>'
                + '                                    <groupName>launch-wizard-1</groupName>'
                + '                                </item>'
                + '                            </groupSet>'
                + '                            <attachment>'
                + '                                <attachmentId>eni-attach-11112222</attachmentId>'
                + '                                <deviceIndex>0</deviceIndex>'
                + '                                <status>attached</status>'
                + '                                <attachTime>2010-12-25T09:45:00.000Z</attachTime>'
                + '                                <deleteOnTermination>true</deleteOnTermination>'
                + '                            </attachment>'
                + '                            <association>'
                + '                                <publicIp>11.22.33.44</publicIp>'
                + '                                <publicDnsName>ec2-11-22-33-44.us-east-1.compute.amazonaws.com</publicDnsName>'
                + '                                <ipOwnerId>amazon</ipOwnerId>'
                + '                            </association>'
                + '                            <privateIpAddressesSet>'
                + '                                <item>'
                + '                                    <privateIpAddress>172.11.22.33</privateIpAddress>'
                + '                                    <privateDnsName>ip-172-11-22-33.us-east-1.compute.internal</privateDnsName>'
                + '                                    <primary>true</primary>'
                + '                                    <association>'
                + '                                        <publicIp>11.22.33.44</publicIp>'
                + '                                        <publicDnsName>ec2-11-22-33-44.us-east-1.compute.amazonaws.com</publicDnsName>'
                + '                                        <ipOwnerId>amazon</ipOwnerId>'
                + '                                    </association>'
                + '                                </item>'
                + '                            </privateIpAddressesSet>'
                + '                        </item>'
                + '                    </networkInterfaceSet>'
                + '                    <ebsOptimized>false</ebsOptimized>'
                + '                </item>'
                + '            </instancesSet>'
                + '        </item>'
                + '    </reservationSet>'
                + '</DescribeInstancesResponse>'
            ;

            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(body);
            return response;
        }
    }

    static testmethod void testDescribeInstances() {
        //arrange
        Test.setMock(HttpCalloutMock.class, new DescribeInstancesResponder());

        //act
        Connector connector = new Connector('access', 'secret');
        Ec2.DescribeInstancesResponse response = new Ec2(connector, 'us-east-1').describeInstances(null);

        //assert
        System.assertEquals('aaaabbbb-cccc-dddd-eeee-ffffgggghhhh', response.requestId, 'wrong requestId');

        System.assertEquals(1, response.reservationSet.size(), 'wrong reservationSet');
        System.assertEquals('r-aaaabbbb', response.reservationSet[0].reservationId, 'wrong reservationId');
        System.assertEquals('123456789012', response.reservationSet[0].ownerId, 'wrong ownerId');

        System.assertEquals(1, response.reservationSet[0].instancesSet.size(), 'wrong instancesSet');
        System.assertEquals('i-aaaabbbb', response.reservationSet[0].instancesSet[0].instanceId, 'wrong instanceId');
        System.assertEquals('ami-ccccdddd', response.reservationSet[0].instancesSet[0].imageId, 'wrong imageId');
        System.assertEquals('16', response.reservationSet[0].instancesSet[0].instanceState.code, 'wrong instanceState code');
        System.assertEquals('running', response.reservationSet[0].instancesSet[0].instanceState.name, 'wrong instanceState name');
        System.assertEquals('ip-172-11-22-33.us-east-1.compute.internal', response.reservationSet[0].instancesSet[0].privateDnsName, 'wrong privateDnsName');
        System.assertEquals('ec2-11-22-33-44.us-east-1.compute.amazonaws.com', response.reservationSet[0].instancesSet[0].dnsName, 'wrong dnsName');
        System.assertEquals('kingdom', response.reservationSet[0].instancesSet[0].keyName, 'wrong keyName');
        System.assertEquals('0', response.reservationSet[0].instancesSet[0].amiLaunchIndex, 'wrong amiLaunchIndex');
        System.assertEquals('t2.micro', response.reservationSet[0].instancesSet[0].instanceType, 'wrong instanceType');
        System.assertEquals(Datetime.newInstanceGmt(2010, 12, 25, 09, 45, 00), response.reservationSet[0].instancesSet[0].launchTime, 'wrong launchTime');
        System.assertEquals('us-east-1a', response.reservationSet[0].instancesSet[0].placement.availabilityZone, 'wrong placement availabilityZone');
        System.assertEquals('default', response.reservationSet[0].instancesSet[0].placement.tenancy, 'wrong placement tenancy');
        System.assertEquals('disabled', response.reservationSet[0].instancesSet[0].monitoring.state, 'wrong monitoring state');
        System.assertEquals('subnet-aaaabbbb', response.reservationSet[0].instancesSet[0].subnetId, 'wrong subnetId');
        System.assertEquals('vpc-aaaabbbb', response.reservationSet[0].instancesSet[0].vpcId, 'wrong vpcId');
        System.assertEquals('172.11.22.33', response.reservationSet[0].instancesSet[0].privateIpAddress, 'wrong privateIpAddress');
        System.assertEquals('11.22.33.44', response.reservationSet[0].instancesSet[0].ipAddress, 'wrong ipAddress');
        System.assertEquals(true, response.reservationSet[0].instancesSet[0].sourceDestCheck, 'wrong sourceDestCheck');

        System.assertEquals(1, response.reservationSet[0].instancesSet[0].groupSet.size(), 'wrong groupSet');
        System.assertEquals('sg-aaaabbbb', response.reservationSet[0].instancesSet[0].groupSet[0].groupId, 'wrong groupId');
        System.assertEquals('launch-wizard-1', response.reservationSet[0].instancesSet[0].groupSet[0].groupName, 'wrong groupId');

        System.assertEquals('x86_64', response.reservationSet[0].instancesSet[0].architecture, 'wrong architecture');
        System.assertEquals('ebs', response.reservationSet[0].instancesSet[0].rootDeviceType, 'wrong rootDeviceType');
        System.assertEquals('/dev/xvda', response.reservationSet[0].instancesSet[0].rootDeviceName, 'wrong rootDeviceName');

        System.assertEquals(1, response.reservationSet[0].instancesSet[0].blockDeviceMapping.size(), 'wrong blockDeviceMapping');
        System.assertEquals('/dev/xvda', response.reservationSet[0].instancesSet[0].blockDeviceMapping[0].deviceName, 'wrong blockDeviceMapping deviceName');
        System.assertEquals('vol-aaaabbbb', response.reservationSet[0].instancesSet[0].blockDeviceMapping[0].ebs.volumeId, 'wrong ebs volumeId');
        System.assertEquals('attached', response.reservationSet[0].instancesSet[0].blockDeviceMapping[0].ebs.status, 'wrong ebs status');
        System.assertEquals(Datetime.newInstanceGmt(2010, 12, 25, 09, 45, 00), response.reservationSet[0].instancesSet[0].blockDeviceMapping[0].ebs.attachTime, 'wrong ebs attachTime');
        System.assertEquals(true, response.reservationSet[0].instancesSet[0].blockDeviceMapping[0].ebs.deleteOnTermination, 'wrong ebs deleteOnTermination');

        System.assertEquals('hvm', response.reservationSet[0].instancesSet[0].virtualizationType, 'wrong virtualizationType');
        System.assertEquals('ABCDEF123456789012', response.reservationSet[0].instancesSet[0].clientToken, 'wrong virtualizationType');
        System.assertEquals('xen', response.reservationSet[0].instancesSet[0].hypervisor, 'wrong hypervisor');

        System.assertEquals(1, response.reservationSet[0].instancesSet[0].networkInterfaceSet.size(), 'wrong networkInterfaceSet');
        System.assertEquals('eni-aaaabbbb', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].networkInterfaceId, 'wrong networkInterfaceId');
        System.assertEquals('subnet-aaaabbbb', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].subnetId, 'wrong subnetId');
        System.assertEquals('vpc-aaaabbbb', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].vpcId, 'wrong vpcId');
        System.assertEquals('111122223333', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].ownerId, 'wrong ownerId');
        System.assertEquals('in-use', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].status, 'wrong status');
        System.assertEquals('aa:bb:cc:dd:ee:ff', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].macAddress, 'wrong macAddress');
        System.assertEquals('172.11.22.33', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddress, 'wrong privateIpAddress');
        System.assertEquals('ip-172-11-22-33.us-east-1.compute.internal', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateDnsName, 'wrong privateDnsName');
        System.assertEquals(true, response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].sourceDestCheck, 'wrong sourceDestCheck');

        System.assertEquals(1, response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].groupSet.size(), 'wrong groupSet');
        System.assertEquals('sg-aaaabbbb', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].groupSet[0].groupId, 'wrong groupId');
        System.assertEquals('launch-wizard-1', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].groupSet[0].groupName, 'wrong groupName');

        System.assertEquals('eni-attach-11112222', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].attachment.attachmentId, 'wrong attachmentId');
        System.assertEquals('0', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].attachment.deviceIndex, 'wrong deviceIndex');
        System.assertEquals('attached', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].attachment.status, 'wrong status');
        System.assertEquals(Datetime.newInstanceGmt(2010, 12, 25, 09, 45, 00), response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].attachment.attachTime, 'wrong attachTime');
        System.assertEquals(true, response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].attachment.deleteOnTermination, 'wrong deleteOnTermination');

        System.assertEquals('11.22.33.44', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].association.publicIp, 'wrong publicIp');
        System.assertEquals('ec2-11-22-33-44.us-east-1.compute.amazonaws.com', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].association.publicDnsName, 'wrong publicDnsName');
        System.assertEquals('amazon', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].association.ipOwnerId, 'wrong ipOwnerId');

        System.assertEquals(1, response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet.size(), 'wrong privateIpAddressesSet');
        System.assertEquals('172.11.22.33', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].privateIpAddress, 'wrong privateIpAddress');
        System.assertEquals('ip-172-11-22-33.us-east-1.compute.internal', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].privateDnsName, 'wrong privateDnsName');
        System.assertEquals(true, response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].primary, 'wrong primary');
        System.assertEquals('11.22.33.44', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].association.publicIp, 'wrong publicIp');
        System.assertEquals('ec2-11-22-33-44.us-east-1.compute.amazonaws.com', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].association.publicDnsName, 'wrong publicDnsName');
        System.assertEquals('amazon', response.reservationSet[0].instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].association.ipOwnerId, 'wrong ipOwnerId');

        System.assertEquals(false, response.reservationSet[0].instancesSet[0].ebsOptimized, 'wrong ebsOptimized');
    }

    class DescribeRegionsResponder implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {

            String body = ''
                + '<?xml version="1.0" encoding="UTF-8"?>'
                + '<DescribeRegionsResponse xmlns="http://ec2.amazonaws.com/doc/2015-10-01/">'
                + '    <requestId>aaaabbbb-cccc-dddd-eeee-ffffgggghhhh</requestId>'
                + '    <regionInfo>'
                + '        <item>'
                + '            <regionEndpoint>ec2.eu-west-1.amazonaws.com</regionEndpoint>'
                + '            <regionName>eu-west-1</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.ap-southeast-1.amazonaws.com</regionEndpoint>'
                + '            <regionName>ap-southeast-1</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.ap-southeast-2.amazonaws.com</regionEndpoint>'
                + '            <regionName>ap-southeast-2</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.eu-central-1.amazonaws.com</regionEndpoint>'
                + '            <regionName>eu-central-1</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.ap-northeast-2.amazonaws.com</regionEndpoint>'
                + '            <regionName>ap-northeast-2</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.ap-northeast-1.amazonaws.com</regionEndpoint>'
                + '            <regionName>ap-northeast-1</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.us-east-1.amazonaws.com</regionEndpoint>'
                + '            <regionName>us-east-1</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.sa-east-1.amazonaws.com</regionEndpoint>'
                + '            <regionName>sa-east-1</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.us-west-1.amazonaws.com</regionEndpoint>'
                + '            <regionName>us-west-1</regionName>'
                + '        </item>'
                + '        <item>'
                + '            <regionEndpoint>ec2.us-west-2.amazonaws.com</regionEndpoint>'
                + '            <regionName>us-west-2</regionName>'
                + '        </item>'
                + '    </regionInfo>'
                + '</DescribeRegionsResponse>'
            ;

            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(body);
            return response;
        }
    }

    static testmethod void testDescribeRegions() {
        //arrange
        Test.setMock(HttpCalloutMock.class, new DescribeRegionsResponder());

        //act
        Connector connector = new Connector('access', 'secret');
        Ec2.DescribeRegionsResponse response = new Ec2(connector, 'us-east-1').describeRegions(null);

        //assert
        System.assertEquals('aaaabbbb-cccc-dddd-eeee-ffffgggghhhh', response.requestId, 'wrong requestId');

        System.assertEquals(10, response.regionInfo.size(), 'wrong regionInfo');
        System.assertEquals('ec2.eu-west-1.amazonaws.com', response.regionInfo[0].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('eu-west-1', response.regionInfo[0].regionName, 'wrong regionName');
        System.assertEquals('ec2.ap-southeast-1.amazonaws.com', response.regionInfo[1].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('ap-southeast-1', response.regionInfo[1].regionName, 'wrong regionName');
        System.assertEquals('ec2.ap-southeast-2.amazonaws.com', response.regionInfo[2].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('ap-southeast-2', response.regionInfo[2].regionName, 'wrong regionName');
        System.assertEquals('ec2.eu-central-1.amazonaws.com', response.regionInfo[3].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('eu-central-1', response.regionInfo[3].regionName, 'wrong regionName');
        System.assertEquals('ec2.ap-northeast-2.amazonaws.com', response.regionInfo[4].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('ap-northeast-2', response.regionInfo[4].regionName, 'wrong regionName');
        System.assertEquals('ec2.ap-northeast-1.amazonaws.com', response.regionInfo[5].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('ap-northeast-1', response.regionInfo[5].regionName, 'wrong regionName');
        System.assertEquals('ec2.us-east-1.amazonaws.com', response.regionInfo[6].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('us-east-1', response.regionInfo[6].regionName, 'wrong regionName');
        System.assertEquals('ec2.sa-east-1.amazonaws.com', response.regionInfo[7].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('sa-east-1', response.regionInfo[7].regionName, 'wrong regionName');
        System.assertEquals('ec2.us-west-1.amazonaws.com', response.regionInfo[8].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('us-west-1', response.regionInfo[8].regionName, 'wrong regionName');
        System.assertEquals('ec2.us-west-2.amazonaws.com', response.regionInfo[9].regionEndpoint, 'wrong regionEndpoint');
        System.assertEquals('us-west-2', response.regionInfo[9].regionName, 'wrong regionName');
    }

    class RunInstancesResponder implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {

            String body = ''
                + '<?xml version="1.0" encoding="UTF-8"?>'
                + '<RunInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2015-10-01/">'
                + '    <requestId>aaaabbbb-cccc-dddd-eeee-ffffgggghhhh</requestId>'
                + '    <reservationId>r-aaaabbbb</reservationId>'
                + '    <ownerId>123456789012</ownerId>'
                + '    <groupSet/>'
                + '    <instancesSet>'
                + '        <item>'
                + '            <instanceId>i-aaaabbbb</instanceId>'
                + '            <imageId>ami-ccccdddd</imageId>'
                + '            <instanceState>'
                + '                <code>0</code>'
                + '                <name>pending</name>'
                + '            </instanceState>'
                + '            <privateDnsName>ip-172-11-22-33.us-east-1.compute.internal</privateDnsName>'
                + '            <dnsName/>'
                + '            <reason/>'
                + '            <amiLaunchIndex>0</amiLaunchIndex>'
                + '            <productCodes/>'
                + '            <instanceType>t2.micro</instanceType>'
                + '            <launchTime>2010-12-25T09:45:00.000Z</launchTime>'
                + '            <placement>'
                + '                <availabilityZone>us-east-1a</availabilityZone>'
                + '                <groupName/>'
                + '                <tenancy>default</tenancy>'
                + '            </placement>'
                + '            <monitoring>'
                + '                <state>disabled</state>'
                + '            </monitoring>'
                + '            <subnetId>subnet-aaaabbbb</subnetId>'
                + '            <vpcId>vpc-aaaabbbb</vpcId>'
                + '            <privateIpAddress>172.11.22.33</privateIpAddress>'
                + '            <sourceDestCheck>true</sourceDestCheck>'
                + '            <groupSet>'
                + '                <item>'
                + '                    <groupId>sg-aaaabbbb</groupId>'
                + '                    <groupName>default</groupName>'
                + '                </item>'
                + '            </groupSet>'
                + '            <stateReason>'
                + '                <code>pending</code>'
                + '                <message>pending</message>'
                + '            </stateReason>'
                + '            <architecture>x86_64</architecture>'
                + '            <rootDeviceType>ebs</rootDeviceType>'
                + '            <rootDeviceName>/dev/xvda</rootDeviceName>'
                + '            <blockDeviceMapping/>'
                + '            <virtualizationType>hvm</virtualizationType>'
                + '            <clientToken/>'
                + '            <hypervisor>xen</hypervisor>'
                + '            <networkInterfaceSet>'
                + '                <item>'
                + '                    <networkInterfaceId>eni-aaaabbbb</networkInterfaceId>'
                + '                    <subnetId>subnet-aaaabbbb</subnetId>'
                + '                    <vpcId>vpc-aaaabbbb</vpcId>'
                + '                    <description/>'
                + '                    <ownerId>111122223333</ownerId>'
                + '                    <status>in-use</status>'
                + '                    <macAddress>aa:bb:cc:dd:ee:ff</macAddress>'
                + '                    <privateIpAddress>172.11.22.33</privateIpAddress>'
                + '                    <privateDnsName>ip-172-11-22-33.us-east-1.compute.internal</privateDnsName>'
                + '                    <sourceDestCheck>true</sourceDestCheck>'
                + '                    <groupSet>'
                + '                        <item>'
                + '                            <groupId>sg-aaaabbbb</groupId>'
                + '                            <groupName>default</groupName>'
                + '                        </item>'
                + '                    </groupSet>'
                + '                    <attachment>'
                + '                        <attachmentId>eni-attach-11112222</attachmentId>'
                + '                        <deviceIndex>0</deviceIndex>'
                + '                        <status>attaching</status>'
                + '                        <attachTime>2010-12-25T09:45:00.000Z</attachTime>'
                + '                        <deleteOnTermination>true</deleteOnTermination>'
                + '                    </attachment>'
                + '                    <privateIpAddressesSet>'
                + '                        <item>'
                + '                            <privateIpAddress>172.11.22.33</privateIpAddress>'
                + '                            <privateDnsName>ip-172-11-22-33.us-east-1.compute.internal</privateDnsName>'
                + '                            <primary>true</primary>'
                + '                        </item>'
                + '                    </privateIpAddressesSet>'
                + '                </item>'
                + '            </networkInterfaceSet>'
                + '            <ebsOptimized>false</ebsOptimized>'
                + '        </item>'
                + '    </instancesSet>'
                + '</RunInstancesResponse>'
            ;

            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(body);
            return response;
        }
    }

    static testmethod void testRunInstances() {
        //arrange
        Test.setMock(HttpCalloutMock.class, new RunInstancesResponder());

        //act
        Connector connector = new Connector('access', 'secret');
        Ec2.RunInstancesResponse response = new Ec2(connector, 'us-east-1').runInstances(null);

        //assert
        System.assertEquals('aaaabbbb-cccc-dddd-eeee-ffffgggghhhh', response.requestId, 'wrong requestId');

        System.assertEquals(1, response.instancesSet.size(), 'wrong instancesSet');
        System.assertEquals('i-aaaabbbb', response.instancesSet[0].instanceId, 'wrong instanceId');
        System.assertEquals('ami-ccccdddd', response.instancesSet[0].imageId, 'wrong imageId');
        System.assertEquals('0', response.instancesSet[0].instanceState.code, 'wrong instanceState code');
        System.assertEquals('pending', response.instancesSet[0].instanceState.name, 'wrong instanceState name');
        System.assertEquals('ip-172-11-22-33.us-east-1.compute.internal', response.instancesSet[0].privateDnsName, 'wrong privateDnsName');
        System.assertEquals('0', response.instancesSet[0].amiLaunchIndex, 'wrong amiLaunchIndex');
        System.assertEquals('t2.micro', response.instancesSet[0].instanceType, 'wrong instanceType');
        System.assertEquals(Datetime.newInstanceGmt(2010, 12, 25, 09, 45, 00), response.instancesSet[0].launchTime, 'wrong launchTime');
        System.assertEquals('us-east-1a', response.instancesSet[0].placement.availabilityZone, 'wrong placement availabilityZone');
        System.assertEquals('default', response.instancesSet[0].placement.tenancy, 'wrong placement tenancy');
        System.assertEquals('disabled', response.instancesSet[0].monitoring.state, 'wrong monitoring state');
        System.assertEquals('subnet-aaaabbbb', response.instancesSet[0].subnetId, 'wrong subnetId');
        System.assertEquals('vpc-aaaabbbb', response.instancesSet[0].vpcId, 'wrong vpcId');
        System.assertEquals('172.11.22.33', response.instancesSet[0].privateIpAddress, 'wrong privateIpAddress');
        System.assertEquals(true, response.instancesSet[0].sourceDestCheck, 'wrong sourceDestCheck');

        System.assertEquals(1, response.instancesSet[0].groupSet.size(), 'wrong groupSet');
        System.assertEquals('sg-aaaabbbb', response.instancesSet[0].groupSet[0].groupId, 'wrong groupId');
        System.assertEquals('default', response.instancesSet[0].groupSet[0].groupName, 'wrong groupId');

        System.assertEquals('x86_64', response.instancesSet[0].architecture, 'wrong architecture');
        System.assertEquals('ebs', response.instancesSet[0].rootDeviceType, 'wrong rootDeviceType');
        System.assertEquals('/dev/xvda', response.instancesSet[0].rootDeviceName, 'wrong rootDeviceName');

        System.assertEquals('hvm', response.instancesSet[0].virtualizationType, 'wrong virtualizationType');
        System.assertEquals('xen', response.instancesSet[0].hypervisor, 'wrong hypervisor');

        System.assertEquals(1, response.instancesSet[0].networkInterfaceSet.size(), 'wrong networkInterfaceSet');
        System.assertEquals('eni-aaaabbbb', response.instancesSet[0].networkInterfaceSet[0].networkInterfaceId, 'wrong networkInterfaceId');
        System.assertEquals('subnet-aaaabbbb', response.instancesSet[0].networkInterfaceSet[0].subnetId, 'wrong subnetId');
        System.assertEquals('vpc-aaaabbbb', response.instancesSet[0].networkInterfaceSet[0].vpcId, 'wrong vpcId');
        System.assertEquals('111122223333', response.instancesSet[0].networkInterfaceSet[0].ownerId, 'wrong ownerId');
        System.assertEquals('in-use', response.instancesSet[0].networkInterfaceSet[0].status, 'wrong status');
        System.assertEquals('aa:bb:cc:dd:ee:ff', response.instancesSet[0].networkInterfaceSet[0].macAddress, 'wrong macAddress');
        System.assertEquals('172.11.22.33', response.instancesSet[0].networkInterfaceSet[0].privateIpAddress, 'wrong privateIpAddress');
        System.assertEquals('ip-172-11-22-33.us-east-1.compute.internal', response.instancesSet[0].networkInterfaceSet[0].privateDnsName, 'wrong privateDnsName');
        System.assertEquals(true, response.instancesSet[0].networkInterfaceSet[0].sourceDestCheck, 'wrong sourceDestCheck');

        System.assertEquals(1, response.instancesSet[0].networkInterfaceSet[0].groupSet.size(), 'wrong groupSet');
        System.assertEquals('sg-aaaabbbb', response.instancesSet[0].networkInterfaceSet[0].groupSet[0].groupId, 'wrong groupId');
        System.assertEquals('default', response.instancesSet[0].networkInterfaceSet[0].groupSet[0].groupName, 'wrong groupName');

        System.assertEquals('eni-attach-11112222', response.instancesSet[0].networkInterfaceSet[0].attachment.attachmentId, 'wrong attachmentId');
        System.assertEquals('0', response.instancesSet[0].networkInterfaceSet[0].attachment.deviceIndex, 'wrong deviceIndex');
        System.assertEquals('attaching', response.instancesSet[0].networkInterfaceSet[0].attachment.status, 'wrong status');
        System.assertEquals(Datetime.newInstanceGmt(2010, 12, 25, 09, 45, 00), response.instancesSet[0].networkInterfaceSet[0].attachment.attachTime, 'wrong attachTime');
        System.assertEquals(true, response.instancesSet[0].networkInterfaceSet[0].attachment.deleteOnTermination, 'wrong deleteOnTermination');

        System.assertEquals(1, response.instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet.size(), 'wrong privateIpAddressesSet');
        System.assertEquals('172.11.22.33', response.instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].privateIpAddress, 'wrong privateIpAddress');
        System.assertEquals('ip-172-11-22-33.us-east-1.compute.internal', response.instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].privateDnsName, 'wrong privateDnsName');
        System.assertEquals(true, response.instancesSet[0].networkInterfaceSet[0].privateIpAddressesSet[0].primary, 'wrong primary');

        System.assertEquals(false, response.instancesSet[0].ebsOptimized, 'wrong ebsOptimized');
    }


    class TerminateInstancesResponder implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {

            String body = ''
                + '<?xml version="1.0" encoding="UTF-8"?>'
                + '<TerminateInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2015-10-01/">'
                + '    <requestId>aaaabbbb-cccc-dddd-eeee-ffffgggghhhh</requestId>'
                + '    <instancesSet>'
                + '        <item>'
                + '            <instanceId>i-aaaabbbb</instanceId>'
                + '            <currentState>'
                + '                <code>32</code>'
                + '                <name>shutting-down</name>'
                + '            </currentState>'
                + '            <previousState>'
                + '                <code>16</code>'
                + '                <name>running</name>'
                + '            </previousState>'
                + '        </item>'
                + '    </instancesSet>'
                + '</TerminateInstancesResponse>'
            ;

            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(body);
            return response;
        }
    }

    static testmethod void testTerminateInstances() {
        //arrange
        Test.setMock(HttpCalloutMock.class, new TerminateInstancesResponder());

        //act
        Connector connector = new Connector('access', 'secret');
        Ec2.TerminateInstancesResponse response = new Ec2(connector, 'us-east-1').terminateInstances(null);

        //assert
        System.assertEquals('aaaabbbb-cccc-dddd-eeee-ffffgggghhhh', response.requestId, 'wrong requestId');

        System.assertEquals(1, response.instancesSet.size(), 'wrong instancesSet');
        System.assertEquals('i-aaaabbbb', response.instancesSet[0].instanceId, 'wrong instanceId');
        System.assertEquals('32', response.instancesSet[0].currentState.code, 'wrong currentState code');
        System.assertEquals('shutting-down', response.instancesSet[0].currentState.name, 'wrong currentState name');
        System.assertEquals('16', response.instancesSet[0].previousState.code, 'wrong previousState code');
        System.assertEquals('running', response.instancesSet[0].previousState.name, 'wrong previousState name');
    }

}