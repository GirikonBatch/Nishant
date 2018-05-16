public class zemailsRestoreExtensions 
{
	public String CurrentPageID;
	public zemailsRestoreExtensions(ApexPages.StandardController controller)
	{  
		CurrentPageID=ApexPages.currentPage().getParameters().get('id'); 
	}
	List<EmailMessage> NewEmailList=new List<EmailMessage>();
	List<Attachment> Parserfiles1=new List<Attachment>();
	public void Restore()
    {
        Map<integer,List<id>> EmailAttachementMap=new Map<integer,List<id>>();
        Parserfiles1=[Select Id,ParentId,Name,body,ContentType From Attachment where name like :('%' +'Parser'+ '%') and ParentId=:CurrentPageID];
         For(Attachment Parserfiles:Parserfiles1)
         {	
       		String ParseStringBody=Parserfiles.body.toString();
        	String[] Parserfilelines = new String[]{};
            Parserfilelines = ParseStringBody.split('#%#'); 
      
        String[]AttachementFileNames=new String[]{};
            AttachementFileNames=Parserfilelines[13].split(';');
      
        String[]ParentIdFileNames=new String[]{};
			ParentIdFileNames=Parserfilelines[8].split('=');
         EmailMessage NewEmail= new EmailMessage(ParentId=ParentIdFileNames[1]);
         
          String[]BccFileNames=new String[]{};
			BccFileNames=Parserfilelines[1].split('=');
       	NewEmail.BccAddress=BccFileNames[1];

		String[]CcFileNames=new String[]{};
			CcFileNames=Parserfilelines[2].split('=');
        NewEmail.CcAddress=CcFileNames[1];

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
        
        String[]TextBodyFileNames=new String[]{};
		TextBodyFileNames=Parserfilelines[9].split('=');
        NewEmail.TextBody=TextBodyFileNames[1];

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
        {	 Attachment b=new Attachment();
            b=[SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment WHERE id=:AttachementFileNames[k]];
            AttachmentsID.add(b.id);
        }     
            
            
            integer i=0;
       		 EmailAttachementMap.put(++i,AttachmentsID);
       
         }// for loop close
      
        insert NewEmailList;

       	
      //  Map<id,List<id>> EmailAttachementMap1=new Map<integer,List<id>>();
        
        for(EmailMessage Em:NewEmailList)
        {
            For(integer j=1;j<EmailAttachementMap.size();j++)
            {
              //  EmailAttachementMap1.put(Em.id,EmailAttachementMap.get(j));
            }
        }
       
        
       // del();
    }//restore fuction
    
    void del()
    {
        Attachment ParserfilesDelete=new Attachment();
        Attachment EmailfilesDelete=new Attachment();
         ParserfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like :('%' +'Parser'+ '%') and ParentId=:CurrentPageID limit 1];
         EmailfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like :('%' +'Email'+ '%') and ParentId=:CurrentPageID limit 1];
        Delete ParserfilesDelete;
        Delete EmailfilesDelete;
    }//delete
}