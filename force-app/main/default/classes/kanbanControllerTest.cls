@isTest
class kanbanControllerTest {

    @isTest static void kanban_test(){
        Test.startTest();
        String[] field = new String[]{'Name,Status'};
        kanbanController.getKanbanWrap('Lead',field , 'Status');
        kanbanController.getUpdateStage('00Q2v00001Y6XGr', 'Status', 'Closed-Converted');
        Test.stopTest();
    }
}