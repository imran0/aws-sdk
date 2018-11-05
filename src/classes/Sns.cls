global class Sns {
    
    global class ErrorResponseException extends Exception {
        global String RequestId;
        global Error Error = new Error();
        public ErrorResponseException(Dom.Document dom) {
            Dom.XmlNode root = dom.getRootElement();
            String ns = root.getNamespace();
            this.RequestId = root.getChildElement('RequestId', ns).getText();
            this.Error.Type = root.getChildElement('Error', ns).getChildElement('Type', ns).getText();
            this.Error.Code = root.getChildElement('Error', ns).getChildElement('Code', ns).getText();
            this.Error.Message = root.getChildElement('Error', ns).getChildElement('Message', ns).getText();
            this.setMessage(this.Error.Type + ' ' + this.Error.Code + ' ' + this.Error.Message + ' ' + this.RequestId);
        }
    }

    global class Error {
        global String Type;
        global String Code;
        global String Message;
    }

    global class PublishResponse {
        global PublishResult PublishResult = new PublishResult();
        global ResponseMetadata ResponseMetadata = new ResponseMetadata();
        public PublishResponse(Dom.Document dom) {
            Dom.XmlNode root = dom.getRootElement();
            String ns = root.getNamespace();
            Dom.XmlNode publishResult = root.getChildElement('PublishResult', ns);
            Dom.XmlNode responseMetadata = root.getChildElement('ResponseMetadata', ns);
            this.PublishResult.MessageId = publishResult.getChildElement('MessageId', ns).getText();
            this.ResponseMetadata.RequestId = responseMetadata.getChildElement('RequestId', ns).getText();
        }
    }

    global class ResponseMetadata {
        global String RequestId;
    }

    global class PublishResult {
        global String MessageId;
        
    }
    
    Connector connector;
    global Sns(Connector connector, String region) {
        this.connector = connector;
        this.connector.region = region;
        this.connector.service = 'sns'; //Credential should be scoped to correct service
    }

    global PublishResponse publish(String topicArn, Object payload) {
        
        PageReference endpoint = new PageReference('https://sns.' + this.connector.region + '.amazonaws.com/');
        endpoint.getParameters().put('Action', 'Publish');
        endpoint.getParameters().put('TopicArn', topicArn);
        endpoint.getParameters().put('MessageStructure', 'json');

        /**
         * The following example publishes a different messages to each protocol. Message:
         * {
         *     "default": "some message",
         *     "email": "some email message",
         *     "email-json": "some email-json message",
         *     "http": "some http message",
         *     "https": "some https message",
         *     "sqs": "some sqs message"
         * }
         */
        endpoint.getParameters().put('Message', Json.serialize(new Map<String,Object>{
            'default' => Json.serialize(payload)
        }));
        
        HttpRequest request = this.connector.signedRequest('POST', new Url(endpoint.getUrl()), null, null, null);
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() != 200)
        {
            throw new ErrorResponseException(response.getBodyDocument());
        }
        
        /**
         * Unique identifier assigned to the published message.
         * When a messageId is returned, the message has been saved
         * and Amazon SNS will attempt to deliver it shortly.
         */
        return new PublishResponse(response.getBodyDocument());
    }
    
}