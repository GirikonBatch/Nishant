public class zemailsArchiveExtensions {
    
    public String CurrentPageID;
    List<EmailMessage> eMessage=new List<EmailMessage>();
      public zemailsArchiveExtensions(ApexPages.StandardController controller)
    {  CurrentPageID=ApexPages.currentPage().getParameters().get('id'); 
    }
    public PageReference NO()
    {
         PageReference pg=new PageReference('/'+ CurrentPageID);
        return pg;
    }
    public void Yes()
    {
    System.debug('Nishant gupta$$$$dfgdfgdfdgxcgdffghdhdghgh');  
    List<EmailMessage> DeletedMessage=new List<EmailMessage>();
        List<Attachment> EmailAttachment=new List<Attachment>();
        eMessage=[SELECT ActivityId,EmailNumber__c,BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,
            FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,IsClientManaged,
            IsDeleted,IsExternallyVisible,LastModifiedById,LastModifiedDate,
            MessageDate,MessageIdentifier,ParentId,RelatedToId,ReplyToEmailMessageId,
            Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,
            ValidatedFromAddress FROM EmailMessage WHERE ParentId =:CurrentPageID];
         For(EmailMessage e:eMessage)
        {   Attachment attachmentPdfEmail = new Attachment();
                    attachmentPdfEmail.parentId =CurrentPageID;
         
         			
                    attachmentPdfEmail.name =e.EmailNumber__c+'_'+e.Subject+'_Email'+ '.pdf';
                   // attachmentPdfEmail.body = blob.toPDF('<b>Name: </b>'+e.FromName+'<br />'+'FromAddress: '+e.FromAddress+'<br />'+'To Address:'+e.ToAddress+'<br />'+
                                                       //  'CcAddress: '+e.CcAddress+'<br />'+'Bcc Address: '+e.BccAddress+'<br />'+
                                                       // 'Subject :'+e.Subject+'<br />'+'Text Body:'+e.TextBody.replaceAll('<','^^')+'<br />');
         			
         			  attachmentPdfEmail.Body =  blob.toPDF('<br/><b>Name : </b>'+(e.FromName==Null? ' ' : e.FromName)+
                                    '<br/><b>Address : </b>'+(e.FromAddress==Null? ' ' : e.FromAddress)+
                                    '<br/><b>BccAddress : </b>'+(e.BccAddress==Null? ' ' : e.BccAddress)+
                                    '<br/><b>CcAddress : </b>'+(e.CcAddress==Null? ' ' : e.CcAddress)+
                                    '<br/><br/><b>Subject : </b>'+e.Subject+
                                    '<br/><br/>' +e.TextBody.replaceAll('<','^').replaceAll('\n','<br/>') +
                                    '<br/>'  );
                    EmailAttachment.add(attachmentPdfEmail);  
                    DeletedMessage.add(e);
                    System.debug('TEST');
        }
        insert EmailAttachment;
         Delete DeletedMessage;
        Case c=new Case();
        c=[select id,IsArchived__c from case where id=:CurrentPageID];
        c.IsArchived__c=True;
        update c;
        if(DeletedMessage.size()>0)
       Database.emptyRecycleBin(DeletedMessage);
       List<task> t=new List<task>();
t=[SELECT AccountId,ActivityDate,CallDisposition,CallDurationInSeconds,CallObject,CallType,CreatedById,CreatedDate,Description,Id,IsArchived,IsClosed,IsDeleted,IsHighPriority,IsRecurrence,IsReminderSet,LastModifiedById,LastModifiedDate,OwnerId,Priority,RecurrenceActivityId,RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,RecurrenceEndDateOnly,RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,RecurrenceRegeneratedType,RecurrenceStartDateOnly,RecurrenceTimeZoneSidKey,RecurrenceType,ReminderDateTime,Status,Subject,SystemModstamp,TaskSubtype,WhatId,WhoId FROM Task WHERE TaskSubtype = 'Email' AND WhatId =:CurrentPageID];
		if(t.size()>0)
        {
        Delete t;
          Database.emptyRecycleBin(t);
        }
    }
    public PageReference parserfile()
    {
      
        eMessage=[SELECT ActivityId,EmailNumber__c,BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,
            FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,IsClientManaged,
            IsDeleted,IsExternallyVisible,LastModifiedById,LastModifiedDate,
            MessageDate,MessageIdentifier,ParentId,RelatedToId,ReplyToEmailMessageId,
            Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,
            ValidatedFromAddress FROM EmailMessage WHERE ParentId =:CurrentPageID];
        
          Map<id,EmailMessage> EmMap=new Map<id,EmailMessage>(eMessage);
        
        String Atid='';
     Map<id,Attachment> AtMap=new Map<id,Attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                      IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment WHERE ParentId in :EmMap.keyset()]);
        List<Attachment> Attachments=new List<Attachment>();
        
        for(Attachment a:AtMap.values())
        {
            attachment x = new attachment();
                    
                    EmailMessage e =  EmMap.get(a.ParentId);
                    
                    x.Body = a.Body;
                    x.ContentType = a.ContentType;
                    x.Description = a.Description;
                    x.IsPrivate =  a.IsPrivate;
                    x.Name  =  e.EmailNumber__c+'_'+e.Subject+'_Attachment_'+ a.Name;
                    x.OwnerId = a.OwnerId;
                    x.ParentId = e.ParentId ;
                    
                    //system.debug('##############'+ atch);
                     Attachments.add(x);
        }
      
        
        insert Attachments;
        List<Attachment> ParserAtt=new List<Attachment>();
        
       For(EmailMessage e:eMessage)
    {  String s=string.valueOf(e.EmailNumber__c);// add this.........................
     System.debug('++++++++++++++++++++++++++s'+s);
        For(Attachment a:[SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                      IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment WHERE Name like :('%'+s+ '%')])
             {// add this.........................
                 
                 Atid+=a.id+';';
                 System.debug('===============FGHGHG=========='+Atid);
                 
             }//second attachement loop
                  Attachment parserfile= new Attachment();
                    
                  parserfile.name =e.EmailNumber__c+'_'+e.Subject+'_Parser'+ '.txt';
                    parserfile.ContentType='text/plain';
                 parserfile.parentId =CurrentPageID;
                 parserfile.body = blob.valueOf('#%#BccAddress='+e.BccAddress+'#%#CcAddress='+e.CcAddress+
                                                           '#%#FromAddress='+e.FromAddress+'#%#FromName='+e.FromName+
                                                            '#%#Headers='+e.Headers+'#%#Incoming='+e.Incoming+'#%#MessageDate='+
                                                            e.MessageDate+'#%#ParentId='+CurrentPageID+'#%#TextBody&%$'+e.TextBody+'#%#Status='+e.Status+'#%#ToAddress='+
                                                            e.ToAddress+'#%#Subject='+e.Subject+'#%#Attachment=;'+Atid);
             ParserAtt.add(parserfile);// add this..................................
             Atid=''; // add this.........................
         }//second loop for email message
        
      insert ParserAtt;
        Yes();
        PageReference pg=new PageReference('/'+ CurrentPageID);
        return pg;
        
        
    } //parser file
    
    
} //class closing