trigger EmailCapture on EmailMessage (after insert) {
    if(String.isNotBlank(Trigger.new[0].TextBody) &&  String.isNotBlank(Trigger.new[0].ParentId)){
        insert new CaseComment(CommentBody=Trigger.new[0].TextBody, ParentId=Trigger.new[0].ParentId);
    }    
}