package xyz.order;

import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.net.jms;
import ballerina.lang.system;
import ballerina.lang.jsons;

@http:config { basePath: "/orderprocess"}
service<http> orderProcessService {

    @http:POST {}
    @http:Path { value: "/order"}
    resource product (message m) {
    map properties = {"initialContextFactory":"org.apache.activemq.jndi.ActiveMQInitialContextFactory","providerUrl":"tcp://localhost:61616","connectionFactoryName":"QueueConnectionFactory","connectionFactoryType":"queue"};
    json jsonReq = messages:getJsonPayload(m);
    system:println("order information :"+jsons:toString(jsonReq));
    jms:ClientConnector jmsEP = create jms:ClientConnector(properties);
    system:println("orderID :"+jsons:toString(jsonReq));
    
     fork {
            worker orderWorkerA {
               OrderA orderA ={};
               transform {
                     orderA.ordersequence, _ = (string) jsonReq.Order.ID;
                     orderA.item, _= (string) jsonReq.Order.Name;
                     orderA.descript, _=(string) jsonReq.Order.Description;
               }
                json jOrderA =  <json> orderA;
                message queueMessage = {};
                messages:setJsonPayload(queueMessage,jOrderA);
                string stringPayload = messages:getStringPayload(m);
                system:println("tranformed message #######: " + stringPayload);
                jms:ClientConnector.send(jmsEP, "orderqueueA", queueMessage);
    
            }
            worker orderWorkerB {
              //TODO tranforming message as per queueB 
              OrderB orderB ={};
               transform {
                     orderB.orderID, _ = (string) jsonReq.Order.ID;
                     orderB.itemName, _= (string) jsonReq.Order.Name;
                     orderB.text, _=(string) jsonReq.Order.Description;
               }
                json jOrderB =  <json> orderB;
                message queueMessage = {};
                messages:setJsonPayload(queueMessage,jOrderB);
                jms:ClientConnector.send(jmsEP, "orderqueueB", queueMessage);
    
            }
        } join (all) (map m2) {
        }
        

    json payload = {"Status":"success"};
    message response = {};
    messages:setJsonPayload(response,payload);
    
    reply response;
       
}
}

struct OrderA {
    string ordersequence = "";
    string item = "";
    string descript = "";
}

struct OrderB {
    string orderID = "";
    string itemName = "";
    string text = "";
}


