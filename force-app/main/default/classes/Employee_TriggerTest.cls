@isTest
public class Employee_TriggerTest 
{
	@isTest
    Public static void TestEmployee_Trigger()
    {
        Employee__c emp = new Employee__c();
        emp.Name = 'Test Employee';
        emp.CompanyId__c = 'Dev';
        insert emp;
    }
}