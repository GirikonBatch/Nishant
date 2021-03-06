public class zemailsRestoreExt {
    public String CurrentPageID;
    public zemailsRestoreExt(ApexPages.StandardController controller)
	{  
		CurrentPageID=ApexPages.currentPage().getParameters().get('id'); 
	}
	List<EmailMessage> NewEmailList=new List<EmailMessage>();
	List<Attachment> Parserfiles1=new List<Attachment>();
    integer i=0;
     map<id,attachment> map_attall;
    public PageReference Restore()
    {	
          Map<integer,List<id>> EmailAttachementMap=new Map<integer,List<id>>();
             		map_attall=new map<id,attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                             IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,
                                             SystemModstamp FROM Attachment where ParentId = : CurrentPageID]);   
        Parserfiles1=[Select Id,ParentId,Name,body,ContentType From Attachment where name like '%Parser.txt' and ParentId=:CurrentPageID];
        System.debug('++++++++++++++++++++****************'+Parserfiles1);
         For(Attachment Parserfiles:Parserfiles1)
             {	String ParseStringBody;
             ParseStringBody='';
       		 ParseStringBody= Parserfiles.body.toString();
        	 String[] Parserfilelines = new String[]{};
            Parserfilelines = ParseStringBody.split('#%#'); 
             System.debug('++++++++++++++++++++'+Parserfilelines); 
              String[]AttachementFileNames=new String[]{};
         AttachementFileNames=Parserfilelines[13].split(';');
              System.debug('++++++++++++++++AttFileName'+AttachementFileNames);
      
        String[]ParentIdFileNames=new String[]{};
			ParentIdFileNames=Parserfilelines[8].split('=');
         EmailMessage NewEmail= new EmailMessage(ParentId=ParentIdFileNames[1]);
         
          String[]BccFileNames=new String[]{};
			BccFileNames=Parserfilelines[1].split('=');
               if(BccFileNames[1]=='null')
              {
        		 NewEmail.BccAddress='';
              }
              else if(BccFileNames[1]!='null')
              {
                 NewEmail.BccAddress=BccFileNames[1];
              }
       	

		String[]CcFileNames=new String[]{};
			CcFileNames=Parserfilelines[2].split('=');
              if(CcFileNames[1]=='null')
              {
        		NewEmail.CcAddress='';
              }
              else if(CcFileNames[1]!='null')
              {
                  NewEmail.CcAddress=CcFileNames[1];
              }

		String[]FromAddressFileNames=new String[]{};
		FromAddressFileNames=Parserfilelines[3].split('=');
        NewEmail.FromAddress=FromAddressFileNames[1];

		String[]FromNameFileNames=new String[]{};
		FromNameFileNames=Parserfilelines[4].split('=');
        NewEmail.FromName=FromNameFileNames[1];
		
		String[]HeadersFileNames=new String[]{};
		HeadersFileNames=Parserfilelines[5].split('=');
        NewEmail.Headers=HeadersFileNames[1];

		String[]IncomingFileNames=new String[]{};
		IncomingFileNames=Parserfilelines[6].split('=');
        NewEmail.Incoming=Boolean.valueOf(IncomingFileNames[1]);

		String[]MessageDateFileNames=new String[]{};
		MessageDateFileNames=Parserfilelines[7].split('=');
        NewEmail.MessageDate=Datetime.valueOf(MessageDateFileNames[1]);
        //System.debug('Parserfilelines++++++++++++++ '+Parserfilelines[9]);
       
		String TextBodyFileNames=Parserfilelines[9];
         TextBodyFileNames=TextBodyFileNames.remove('TextBody&%$');  
              
              System.debug('TextBodyFileNames+++++++++++ '+TextBodyFileNames);
        NewEmail.TextBody=TextBodyFileNames;

		String[]StatusFileNames=new String[]{};
		StatusFileNames=Parserfilelines[10].split('=');
        NewEmail.Status=StatusFileNames[1];

		String[]ToAddressFileNames=new String[]{};
		ToAddressFileNames=Parserfilelines[11].split('=');
        NewEmail.ToAddress=ToAddressFileNames[1];

		String[]SubjectFileNames=new String[]{};
		SubjectFileNames=Parserfilelines[12].split('=');
        NewEmail.Subject=SubjectFileNames[1];
        NewEmailList.add(NewEmail);
              
               List<id> AttachmentsID=new List<id>();
              
              
              
        For(integer k=1;k<AttachementFileNames.size();k++)
        {	 
         	
          
            AttachmentsID.add(AttachementFileNames[k]);
           
            
        } 
              AttachmentsID.add(NULL);
               EmailAttachementMap.put(i++,AttachmentsID);
            ParseStringBody='';
         }// for loop close
        
        
        insert NewEmailList;
        
         Map<id,List<id>> EmailAttachementMap1=new Map<id,List<id>>();
		
        
        for(integer i=0;i<NewEmailList.size();i++){
        EmailAttachementMap1.put(NewEmailList[i].id, EmailAttachementMap.get(i)) ;  
        EmailAttachementMap.remove(i);
        }//for loop close
        
        System.debug('++++++++++++++++++++++++'+EmailAttachementMap1);
        List<Attachment> atmList=new List<Attachment>();
        List<Attachment> atmLis=new List<Attachment>();
        for(id p_id : EmailAttachementMap1.keySet() ){
               List<id>attid=new List<id>();
             if(EmailAttachementMap1.get(p_id) != NULL){
              
                 attid=EmailAttachementMap1.get(p_id);
                 
                System.debug('*****************attid'+attid);
                 if(attid.size()>0)
                 {
             for(id att :attid )
             {		
                 if(att!=NULL)
                 {
                    attachment attm=new attachment();
                	attm=map_attall.get(att);
                 System.debug('+++++++++++++++++++++++attm'+attm);
                    attachment atch = new attachment();
                 	
                    atch.Body = attm.Body;
                    atch.ContentType = attm.ContentType;
                    atch.Description = attm.Description;
                    atch.IsPrivate =  attm.IsPrivate;
                    atch.Name  = attm.Name.substringAfterLast('_') ;
                    atch.OwnerId = attm.OwnerId;
                    atch.ParentId =p_id;
                    atmList.add(atch);  
                    atmLis.add(attm);  
                 }
				}
             }//if
             } //if 
        }//For loop close     
      
        if(atmList.size()>0)
        {
       		insert atmList; 
        }
        if(atmLis.size()>0)
        {
        delete atmLis;
        Database.emptyRecycleBin(atmLis);
        }
        del();
        PageReference pg=new PageReference('/'+ CurrentPageID);
        return pg;
    }//restore fuction
    
    public PageReference NO()
    {
         PageReference pg=new PageReference('/'+ CurrentPageID);
			 return pg;
    }
     
    void del()
    {
        List<Attachment> ParserfilesDelete=new List<Attachment>();
        List<Attachment> EmailfilesDelete=new List<Attachment>();
         ParserfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like '%Parser.txt%' and ParentId=:CurrentPageID];
         EmailfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like '%Email.pdf%' and ParentId=:CurrentPageID];
        Delete ParserfilesDelete;
        Database.emptyRecycleBin(ParserfilesDelete);
        Delete EmailfilesDelete;
        Database.emptyRecycleBin(EmailfilesDelete);
        case c=New Case();
        c=[Select id,isArchived__c from case where id=:CurrentPageID];
        c.IsArchived__c=False;
        Update c;
    }//delete
        
}