global class BatchScheduleArchive implements Database.Batchable<sObject>
{
    public transient String CaseStatus{get;set;}
    public transient String CaseReason{get;set;}
    public transient String CaseOrigin{get;set;}
    public transient String CaseCreatedOlder{get;set;}
    public transient Integer RecordSize{get;set;}
    public transient String CaseClosedOlder{get; set;}
    String Query;
    String Case_Status;
    String Case_Reason;
    String Case_Origin;
    String Case_Created_Older;
    String Case_Closed_Older;
    Map<id,case> map_case_arc;
    map<id, EmailMessage> map_mail; 
    map<id, attachment> map_attm;
    string attach_ids='';
    String vid;
    list<EmailMessage> mail_del = new list<EmailMessage>();
    list<attachment> att_insert = new list<attachment>();
    list<attachment> mail_insert = new list<attachment>();
    public BatchScheduleArchive(String Q,String bid)
    {
        Query=q;
        vid=bid;
    }
    global Database.queryLocator start(Database.BatchableContext bc )
    {
        return Database.getQueryLocator(Query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Case> case_ar)
    {
        List<Case> case_arc=case_ar;
        map_case_arc =  new map<id,case>(case_arc);
        
        case_arc.clear();
        
        map_mail = new map<id, EmailMessage>([SELECT ActivityId,BccAddress,CcAddress,CreatedById,CreatedDate,EmailNumber__c,FromAddress,FromName,
                                              HasAttachment,Headers,HtmlBody,Id,Incoming,IsClientManaged,IsDeleted,IsExternallyVisible,
                                              LastModifiedById,LastModifiedDate,MessageDate,MessageIdentifier,ParentId,RelatedToId,
                                              ReplyToEmailMessageId,Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,
                                              ValidatedFromAddress FROM EmailMessage where ParentId in : map_case_arc.keySet() ]) ;
        
        map_attm = new  map<id, attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                             IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,
                                             SystemModstamp FROM Attachment where ParentId in : map_mail.keySet()]);
        
        
        for(attachment att : map_attm.values()){
            
            attachment atch = new attachment();
            
            EmailMessage ec =  map_mail.get(att.ParentId);
            
            atch.Body = att.Body;
            atch.ContentType = att.ContentType;
            atch.Description = att.Description;
            atch.IsPrivate =  att.IsPrivate;
            atch.Name  =  ec.EmailNumber__c+'_'+ec.Subject+'_Attachment_'+ att.Name;
            atch.OwnerId = att.OwnerId;
            atch.ParentId = ec.ParentId ;
            
            //system.debug('##############'+ atch);
            att_insert.add(atch);
            
        }
        map_attm.clear();
        if(att_insert.size()>0)
            insert att_insert;   
        
        
        for( EmailMessage caseMial : map_mail.values() ){
            
            attach_ids = '';  
            for(attachment a:att_insert ){
                string s = a.Name;
                if(s.startsWith(caseMial.EmailNumber__c+'_'+caseMial.Subject+'_Attachment_')){
                    attach_ids = attach_ids+a.Id+';' ;
                } 
            }
            
            attachment atch = new attachment();
            
            atch.ParentId =  caseMial.ParentId;
            atch.Name = caseMial.EmailNumber__c+'_'+caseMial.Subject+'_Email.pdf';
            //atch.Body = blob.toPDF(caseMial.FromName+'<br/>'+caseMial.FromAddress+'<br/>'+caseMial.CcAddress +'<br/>' +caseMial.CcAddress+'<br/>'+caseMial.Subject+'<br/>' +caseMial.TextBody +'<br/>'  );
            atch.Body =  blob.toPDF('<br/><b>Name : </b>'+(caseMial.FromName==Null? ' ' : caseMial.FromName)+
                                    '<br/><b>Address : </b>'+(caseMial.FromAddress==Null? ' ' : caseMial.FromAddress)+
                                    '<br/><b>BccAddress : </b>'+(caseMial.BccAddress==Null? ' ' : caseMial.BccAddress)+
                                    '<br/><b>CcAddress : </b>'+(caseMial.CcAddress==Null? ' ' : caseMial.CcAddress)+
                                    '<br/><br/><b>Subject : </b>'+caseMial.Subject+
                                    '<br/><br/>' +caseMial.TextBody.replaceAll('<','^').replaceAll('\n','<br/>') +
                                    '<br/>'  );
            mail_insert.add(atch);
            
            attachment atchtxt = new attachment();
            
            atchtxt.ParentId = caseMial.ParentId;
            atchtxt.Name = caseMial.EmailNumber__c+'_'+caseMial.Subject+'_Parser.txt';
            atchtxt.Body =  blob.valueOf('#%#BccAddress='+caseMial.BccAddress+'#%#CcAddress='+caseMial.CcAddress+
                                         '#%#FromAddress='+caseMial.FromAddress+'#%#FromName='+caseMial.FromName+
                                         '#%#Headers='+caseMial.Headers+'#%#Incoming='+caseMial.Incoming+'#%#MessageDate='+
                                         caseMial.MessageDate+'#%#ParentId='+caseMial.ParentId+'#%#TextBody='+caseMial.TextBody+'#%#Status='+caseMial.Status+'#%#ToAddress='+
                                         caseMial.ToAddress+'#%#Subject='+caseMial.Subject+'#%#Attachment=;'+attach_ids);
            mail_insert.add(atchtxt);
            
            
            mail_del.add(caseMial);
            
        }
        att_insert.clear();
        map_mail.clear();        
        insert mail_insert; 
        mail_insert.clear();
        delete mail_del;  
        if(mail_del.size()>0)
            database.emptyRecycleBin(mail_del);
        mail_del.clear();
        
        list<task> t = [SELECT Id,TaskSubtype,WhatId,WhoId FROM Task WHERE TaskSubtype = 'email' AND WhatId in: map_case_arc.keySet()];
        delete t;
        if(t.size()>0)
            database.emptyRecycleBin(t);
        List<Case> b=new List<Case>();
        For(Case v:map_case_arc.values())
        {
            v.IsArchived__c=true;
            b.add(v);
        }
        
        update b;    
        b.clear();        
        /*List<Account> lis=new List<Account>();
for(Account con:acc)
{

con.Ownership = 'None';
lis.add(con);

}
update lis; */
    }  
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,     JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      from AsyncApexJob where Id =:BC.getJobId()];
        
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          String[] toAddresses = new String[] {a.CreatedBy.Email};
          mail.setToAddresses(toAddresses);
          mail.setSubject('Records Restored ' + a.Status);
          mail.setPlainTextBody('Records Processed ' + a.TotalJobItems +
         ' with '+ a.NumberOfErrors + ' Failures.');
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   

//then use the active job id and abort it
system.abortJob(vid);
        
    }
}