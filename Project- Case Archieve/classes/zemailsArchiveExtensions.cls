public class zemailsArchiveExtensions {
    
    public String CurrentPageID;
    List<EmailMessage> eMessage=new List<EmailMessage>();
      public zemailsArchiveExtensions(ApexPages.StandardController controller)
    {  CurrentPageID=ApexPages.currentPage().getParameters().get('id'); 
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
                    attachmentPdfEmail.name =e.EmailNumber__c+'_Email'+ '.pdf';
                    attachmentPdfEmail.body = blob.toPDF('Name: '+e.FromName+'<br />'+'FromAddress: '+e.FromAddress+'<br />'+'To Address:'+e.ToAddress+'<br />'+
                                                         'CcAddress: '+e.CcAddress+'<br />'+'Bcc Address: '+e.BccAddress+'<br />'+
                                                        'Subject :'+e.Subject+'<br />'+'Text Body:'+e.TextBody+'<br />');
                    EmailAttachment.add(attachmentPdfEmail);  
                    DeletedMessage.add(e);
                    System.debug('TEST');
        }
        insert EmailAttachment;
         Delete DeletedMessage;
       //Database.emptyRecycleBin(DeletedMessage);
    }
    public PageReference parserfile()
    {
        
        eMessage=[SELECT ActivityId,EmailNumber__c,BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,
            FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,IsClientManaged,
            IsDeleted,IsExternallyVisible,LastModifiedById,LastModifiedDate,
            MessageDate,MessageIdentifier,ParentId,RelatedToId,ReplyToEmailMessageId,
            Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,
            ValidatedFromAddress FROM EmailMessage WHERE ParentId =:CurrentPageID];
        String Atid='';
     List<Attachment> Attachments=new List<Attachment>();
        For(EmailMessage e:eMessage)
        {   For(Attachment a:[SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                      IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment WHERE ParentId =:e.Id])
            {               Attachment x=new Attachment();
                            x.ParentId=CurrentPageID;
                            x.body=a.Body;
                               
                            x.Name=e.EmailNumber__c+'_Attachement_'+a.Name;
                            
                            x.Description=a.Description;
                            x.IsPrivate=a.IsPrivate;
                            x.OwnerId=a.OwnerId;
                            Attachments.add(x); 
            }   //for attachment ....
         
                
                       
        } //for email message
        
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
                    
                  parserfile.name =e.EmailNumber__c+'_Parser'+ '.txt';
                    parserfile.ContentType='text/plain';
                 parserfile.parentId =CurrentPageID;
                 parserfile.body = blob.valueOf('#%#BccAddress='+e.BccAddress+'#%#CcAddress='+e.CcAddress+
                                                           '#%#FromAddress='+e.FromAddress+'#%#FromName='+e.FromName+
                                                            '#%#Headers='+e.Headers+'#%#Incoming='+e.Incoming+'#%#MessageDate='+
                                                            e.MessageDate+'#%#ParentId='+CurrentPageID+'#%#TextBody='+e.TextBody+'#%#Status='+e.Status+'#%#ToAddress='+
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