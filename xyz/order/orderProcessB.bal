package xyz.order;

import ballerina.lang.messages;
import ballerina.lang.system;
import ballerina.net.jms;

@jms:config {
    connectionFactoryType:"queue",
    connectionFactoryName:"QueueConnectionFactory",
    destination:"orderqueueB",
    acknowledgmentMode:"AUTO_ACKNOWLEDGE"
,
    providerUrl:"tcp://localhost:61616",
    initialContextFactory:"org.apache.activemq.jndi.ActiveMQInitialContextFactory"}
service<jms> orderProcessB {
    resource onMessage (message m) {
        //Process the message

        string msgType = messages:getProperty(m,"JMS_MESSAGE_TYPE");
        string stringPayload = messages:getStringPayload(m);
        system:println("orderProcessB : " + msgType);
        system:println(stringPayload);
    }
}

