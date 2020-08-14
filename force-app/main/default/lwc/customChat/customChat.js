import { track,LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getCurrentLoggedInUserInfo from '@salesforce/apex/CustomChatController.getCurrentLoggedInUserInfo';
import saveToMessageLog from '@salesforce/apex/CustomChatController.saveToMessageLog';

export default class customChat extends LightningElement {
    channelName = '/event/MessageLogEvent__e';
    @track messageList=[];
    inboundMessage='';
    //@track outboundMessage='';
    @track currentUserName='';
    // @track enableOutBoundMessage=false;
    // @track enableInBoundMessage=false;
    @track time='';
    @track initialTime='';
    @track sfdcuserId='';
    newMessageToSave='';
    @track emptyMessage='Type your Message Here';

    subscription = {};

    // Initializes the component
    connectedCallback() {       
        // Register error listener   
        this.handleSubscribe();
        this.registerErrorListener();  
        this.getCurrentLoggedInUserInfo();    
    }

    getCurrentLoggedInUserInfo(){
        getCurrentLoggedInUserInfo().then(result =>{
            this.currentUserName=result.name;
            this.initialTime=result.currentLoggedinTime;
        })
        .catch(error => {
            this.handleToast('Error', 'Something went wrong.', 'error');
        });
    }
    // Handles subscribe button click
    handleSubscribe() {

        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => { 
            // console.log('size of messagelis'+this.messageList.size());
            if(response.data.payload.MessageType__c === 'Outbound'){
            this.enableOutBoundMessage=true
            var newDate = new Date()
            this.time = newDate.getHours()+':'+newDate.getSeconds();
            var message={ messagetext: response.data.payload.Message__c,
                time:this.time,
                enableOutBoundMessage : true,
                enableInBoundMessage : false,
              }
            }else{
                var newDate = new Date()
                this.time = newDate.getHours()+':'+newDate.getSeconds();
                var message={ messagetext: response.data.payload.Message__c,
                    time:this.time,
                    enableOutBoundMessage : false,
                    enableInBoundMessage : true,
                  }
            }
        //     this.outboundMessage=response.data.payload.Message__c;
        //     this.time=response.data.payload.CreatedDate;
        //     this.time=this.time.substring(this.time.indexOf("T")+1);
        //    console.log('new message in js'+this.outboundMessage);
          
            // }
 
            // Response contains the payload of the new message received
            this.messageList.push({key:response.data.schema,value: message });
            console.log('messagelist : '+JSON.stringify(this.messageList));
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
            //this.toggleSubscribeButton(true);
        });
    }

    handleMessage(event) {
        this.inboundMessage = event.target.value;
    //    if (this.inboundMessage !=''){
    //     this.enableInBoundMessage=true;
    //     var newDate = new Date()
    //     this.time = newDate.getHours()+':'+newDate.getSeconds();
    //     }  
    }

    handleEnter(event){
        if(event.key === 'Enter'){ 
            this.saveToMessageLog();
        }
    }

    saveToMessageLog() {         
        saveToMessageLog({ message:  this.inboundMessage})
        .then(result => {
           if(result.isSuccess){
            this.emptyMessage='';
               console.log('Successfully saved to messageLog');
           }
        })
        .catch(error => {
            this.handleErrorConditions(error);
        });    
    }


    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    handleToast(title, message, variant) {
        const showInfo = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(showInfo);
    }
}