@IsTest class SnsTest {
    
    @IsTest static void testSuccess() {
        
        //arrange
        Sns sns = new Connector('AccessKey', 'SecretKey').sns('Region');
        
        //act
        Test.setMock(HttpCalloutMock.class, new PublishSuccess());
        Sns.PublishResponse response = sns.publish('TopicArn', 'Payload');
        
        //assert
        System.assertEquals('f24d0373-7dde-58fd-9559-57295091b79f', response.ResponseMetadata.RequestId);
    }
    
    @IsTest static void testFailure() {
        
        //arrange
        Sns sns = new Connector('AccessKey', 'SecretKey').sns('Region');
        
        try {
            //act
            Test.setMock(HttpCalloutMock.class, new PublishFailure());
            sns.publish('TopicArn', 'Payload');
            System.assert(false, 'wrong exception');
        } catch (Sns.ErrorResponseException e) {
            System.assertEquals('Sender', e.Error.Type);
            System.assertEquals('NotFound', e.Error.Code);
            System.assertEquals('Topic does not exist', e.Error.Message);
            System.assertEquals('113bc8ab-5044-5c3f-946a-9cf17a58541c', e.RequestId);
        }
    }
    
    class PublishFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody(''
                + '<ErrorResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">'
                + '    <Error>'
                + '        <Type>Sender</Type>'
                + '        <Code>NotFound</Code>'
                + '        <Message>Topic does not exist</Message>'
                + '    </Error>'
                + '    <RequestId>113bc8ab-5044-5c3f-946a-9cf17a58541c</RequestId>'
                + '</ErrorResponse>'
            );
            return response;
        }
    }
    
    class PublishSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(''
                + '<PublishResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">'
                + '    <PublishResult>'
                + '        <MessageId>0ab2de57-b693-5789-b30a-8a0d9bdc78eb</MessageId>'
                + '    </PublishResult>'
                + '    <ResponseMetadata>'
                + '        <RequestId>f24d0373-7dde-58fd-9559-57295091b79f</RequestId>'
                + '    </ResponseMetadata>'
                + '</ErrorResponse>'
            );
            return response;
        }
    }
    
}