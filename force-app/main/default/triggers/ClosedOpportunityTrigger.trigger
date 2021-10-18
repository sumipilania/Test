trigger ClosedOpportunityTrigger on Opportunity (before insert) {
    
     List<Task> taskList = new List<Task>(); 
    List<Opportunity> Opps = Trigger.new; 
    
    
        for(Opportunity Opp : Opps) {
            if(Opp.StageName == 'Closed Won'){
                Task newTask = new Task(whatID = Opp.ID, Subject='Follow Up Test Task'); 
                taskList.add(newTask);
            }
        }
        insert taskList;
    

}