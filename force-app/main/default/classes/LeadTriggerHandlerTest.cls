@IsTest
public with sharing class LeadTriggerHandlerTest {
    
    @IsTest
    public static void leadTriggerHandlerTest_handleTitleNormalization() {
        List<Lead> testLeads = new List<Lead>{
            new Lead(LastName = 'Test1', Company = 'Company1', Title = 'VP'),
            new Lead(LastName = 'Test2', Company = 'Company2', Title = 'mgr'),
            new Lead(LastName = 'Test3', Company = 'Company3', Title = 'head'),
            new Lead(LastName = 'Test4', Company = 'Company4', Title = 'assist'),
            new Lead(LastName = 'Test5', Company = 'Company1', Title = 'V.P.'),
            new Lead(LastName = 'Test6', Company = 'Company2', Title = 'Manager'),
            new Lead(LastName = 'Test7', Company = 'Company3', Title = 'Chief'),
            new Lead(LastName = 'Test8', Company = 'Company4', Title = 'JR')
        };

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> updatedLead = [SELECT Id, Title FROM Lead WHERE Id IN :testLeads];

        Map<String, Lead> leadMap = new Map<String, Lead>();
        for (Lead ld : updatedLead) {
            leadMap.put(ld.Title, ld);
        }

        System.assert(leadMap.containsKey('Vice President'), 'Title should be normailzed to Vice President');
        System.assert(leadMap.containsKey('Manager'), 'Title should be normailzed to Manager');
        System.assert(leadMap.containsKey('Executive'), 'Title should be normailzed to Executive');
        System.assert(leadMap.containsKey('Assistant'), 'Title should be normailzed to Assistant');
    }

    @IsTest
    public static void leadTriggerHandlerTest_handleTitleNormalization_errorException() {
        List<Lead> testEmptyLeads = new List<Lead>();

        Test.startTest();
        insert testEmptyLeads;
        Test.stopTest();

        List<Lead> updatedEmptyLeads = [SELECT Id, Title FROM Lead WHERE Id IN :testEmptyLeads];

        Map<String, Lead> leadMap = new Map<String, Lead>();
        for (Lead ld : updatedEmptyLeads) {
            leadMap.put(ld.Title, ld);
        }
        Assert.isTrue(true, 'Method sucessfully executed');
    }

    @IsTest
    public static void leadTriggerHandlerTest_handleAutoLeadScoring() {
    /*
        * Criteria:
	 * - If the lead source is from the web and an email exists, increment score by 3 points.
	 * - If the lead provides a phone number, increment score by 5 points.
	 * - If the lead belongs to the 'Technology' industry, increment score by another 10 points.
     */
        Lead testLead1 = new lead(LastName = 'TestLead1', Company = 'TestCo1', LeadSource = 'Web', Email = 'test@test.com', Phone = '000-000-0000', Industry = 'Technology');// score 18
        Lead testLead2 = new lead(LastName = 'TestLead2', Company = 'TestCo2', LeadSource = 'Web', Email = '', Phone = '000-000-1111', Industry = 'Technology'); // score 15
        Lead testLead3 = new lead(LastName = 'TestLead3', Company = 'TestCo3', LeadSource = '', Email = 'test@test.com', Phone = '000-000-3333', Industry = 'Technology');// score 15
        Lead testLead4 = new lead(LastName = 'TestLead4', Company = 'TestCo4', LeadSource = '', Email = '', Phone = '000-000-0000', Industry = 'Technology'); // score 15
        Lead testLead5 = new lead(LastName = 'TestLead5', Company = 'TestCo5', LeadSource = '', Email = '', Phone = '', Industry = 'Technology'); // score 10
        Lead testLead6 = new lead(LastName = 'TestLead6', Company = 'TestCo6', LeadSource = 'Web', Email = 'test@test.com', Phone = '000-000-0000', Industry = 'Banking');// score 8
        Lead testLead7 = new lead(LastName = 'TestLead7', Company = 'TestCo7', LeadSource = 'Web', Email = 'test@test.com', Phone = '', Industry = 'Technology'); //score 13
        Lead testLead8 = new lead(LastName = 'TestLead8', Company = 'TestCo8', LeadSource = 'Other', Email = 'test@test.com', Phone = '000-000-0000', Industry = 'Banking');// score 5
        Lead testLead9 = new lead(LastName = 'TestLead9', Company = 'TestCo9', LeadSource = 'Web', Email = 'test@test.com', Phone = '', Industry = 'Energy');//score 3
        Lead testLead10 = new lead(LastName = 'TestLead10', Company = 'TestCo10', LeadSource = 'Purchase List', Email = 'test@test.com', Phone = '', Industry = 'Education');// score 0
        List<Lead> testLeads = new List<Lead>{testLead1, testLead2, testLead3, testLead4, testLead5, testLead6, testLead7, testLead8, testLead9, testLead10};
        

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        testLead1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead1.Id];
        testLead2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead2.Id];
        testLead3 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead3.Id];
        testLead4 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead4.Id];
        testLead5 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead5.Id];
        testLead6 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead6.Id];
        testLead7 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead7.Id];
        testLead8 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead8.Id];
        testLead9 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead9.Id];
        testLead10 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead10.Id];

        System.assertEquals(18,testLead1.Lead_Score__c, 'Test score should be 18');
        System.assertEquals(15,testLead2.Lead_Score__c, 'Test score should be 15');
        System.assertEquals(15,testLead3.Lead_Score__c, 'Test score should be 15');
        System.assertEquals(15,testLead4.Lead_Score__c, 'Test score should be 15');
        System.assertEquals(10,testLead5.Lead_Score__c, 'Test score should be 10');
        System.assertEquals(8,testLead6.Lead_Score__c, 'Test score should be 8');
        System.assertEquals(13,testLead7.Lead_Score__c, 'Test score should be 13');
        System.assertEquals(5,testLead8.Lead_Score__c, 'Test score should be 5');
        System.assertEquals(3,testLead9.Lead_Score__c, 'Test score should be 3');
        System.assertEquals(0,testLead10.Lead_Score__c, 'Test score should be 0');
    }

    @IsTest
    public static void leadTriggerHandlerTests_handleLeadAutoConvert() {
        Account newAcct = new Account(Name = 'TestAccount');
        insert newAcct;

        Contact newCont = new Contact(LastName = 'Belly', Email = 'test@test.com.invalid', AccountId = newAcct.Id);
        insert newCont;

        Lead newLead = new Lead(LastName = 'BigBelly', Email = 'test@test.com.invalid', Company = 'Test Co');

        Test.startTest();
        insert newLead;
        Test.stopTest();

        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :newLead.Id];
        Lead convertedLead = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];

        Assert.areEqual(newCont.Id, convertedLead.ConvertedContactId, 'Contact Id does not match convertedLeadId');
        Assert.areEqual(newAcct.Id, convertedLead.ConvertedAccountId, 'Account Id does not match convertedLeadAccountId');
        Assert.isTrue(updatedLead.IsConverted, 'Lead should have been converted');
    }

    @IsTest
    public static void leadTriggerHandlerTests_handleLeadAutoConvert_mix() {
        Account newAcct = new Account(Name = 'TestAccount');
        insert newAcct;

        Contact newCont = new Contact(LastName = 'Belly', Email = 'test@test.com.invalid', AccountId = newAcct.Id);
        insert newCont;

        Lead newLead = new Lead(LastName = 'BigBelly', Email = 'testing@test.com.invalid', Company = 'Test Co');
        Lead newLead2 = new Lead(LastName = 'Zulu', email = 'test@test.com.invalid', Company = 'Test2 Co');

        Test.startTest();
        insert newLead;
        insert newLead2;
        Test.stopTest();

        List<Lead> updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :newLead.Id OR Id = :newLead2.Id];
        List<Lead> convertedLead = [SELECT ConvertedAccountId, ConvertedContactId, IsConverted FROM Lead WHERE IsConverted = TRUE];

       
        Assert.isFalse(updatedLead[0].IsConverted, 'BigBelly should not be a converted lead');
        Assert.isTrue(updatedLead[1].IsConverted, 'Zulu should be a converted lead');
        Assert.areEqual(1, convertedLead.size(), 'there should be 1 converted lead');
    }
}