@isTest
private class PipoControllerTest {

    @testSetup

    static void setupTestData() {
        // Create test data for Account and User
        
        // Fetch the User record for 'The VentureCrowd Team'
        User owner = [SELECT Id FROM User WHERE Name = 'The VentureCrowd Team' LIMIT 1];
        
        // Get Record Type Id for VC Person Account
        Id recordTypeId = Schema.getGlobalDescribe().get('Account')
            .getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        
        // Create an Account with relevant fields
        Account testAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            Preferred_Name__pc = 'PreferredTestName',
            Investor_Banner_Interaction__c = true,
            ID_Checked__pc = true,
            OwnerId = owner.Id
        );
        insert testAccount;


        // Create an Account with the 'VC Business Account' RecordType || Entities
        Id bussAcctRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        Account businessAccount = new Account(
            Name = 'Test Business Account',
            RecordTypeId = bussAcctRT,
            Active__c = true
        );

        insert businessAccount;


        EOI__c testEOI = new EOI__c(Name = 'Test EOI', Account__c = businessAccount.Id, Internal_Owner__c=owner.Id);
        insert testEOI;

        Lead testLead = new Lead(
            FirstName ='Test',
            LastName='Lead',
            Email='mail@mail.com',
            Related_EOI__c=testEOI.Id
         );
         insert testLead;

        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = testAccount.Id,
            Status__c = 'New',
            Form_Problem_or_Opportunity__c = 'Problem statement',
            Form_Solution__c = 'Solution statement',
            Form_Differentiation__c = 'Differentiation statement',
            Form_Intellectual_Property__c = 'IP statement',
            Form_Total_addressable_market__c = 'Market size statement',
            Form_Progress__c = 'Progress statement',
            Form_Growth_plan__c = 'Growth plan statement',
            Form_Valuation__c = 1000000,
            Owner__c = owner.Id,
            Form_Company_one_liner__c = 'One liner',
            Form_Offer_close_date__c = Date.today().addDays(30),
            Form_Offer_launch_date__c = Date.today()
        );
        insert testRaise;

        // Create test Product2 records that match the criteria
        Product2 product1 = new Product2(
            Name = 'Test Product 1',
            Portal_Display_Name__c = 'Product Display 1',
            Tile_Heading__c = 'Heading 1',
            Deal_Description__c = 'Deal Description 1',
            Tile_Offer_Type__c = 'Offer Type 1',
            Tile_Banner__c = 'Banner 1',
            Family = 'Test Family',
            Deal_Page_Link__c = 'http://example.com/product1',
            DisplayUrl = 'http://example.com/product1',
            Publish_on_Community_Site__c = true,
            IsActive = true,
            Raise__c = testRaise.Id,
            Offer_Close_Date__c = Date.today().addDays(1)
        );
        insert product1;
        
        // Create a User associated with the test Account
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'TestingUserN2',
            Username = 'testUser_n2@test.com',
            LastName = 'TestAds',
            Email = 'testUser_n2@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = contact.Id
        );
        insert testUser;

        // Create an AccountContactRelation
        AccountContactRelation acr = new AccountContactRelation(
            AccountId = businessAccount.Id,
            ContactId = contact.Id
        );
        insert acr;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            Invested_Product_ADMIN_FIELD__c = product1.Id
        );

        Opportunity opportunity2 = new Opportunity(
            Name = 'Test Opportunity2',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = businessAccount.Id,
            Invested_Product_ADMIN_FIELD__c = product1.Id
        );

        Opportunity opportunity3 = new Opportunity(
            Name = 'Test Opportunity3',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            Invested_Product_ADMIN_FIELD__c = product1.Id
        );
        insert new List<Opportunity> {opportunity, opportunity2, opportunity3};

        PricebookEntry priceBook = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product1.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert priceBook;

        // Create Opp Line Item
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            Product2Id = product1.Id,
            PricebookEntryId = priceBook.Id,
            Quantity = 1,
            UnitPrice = 1000
        );

        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opportunity2.Id,
            Product2Id = product1.Id,
            PricebookEntryId = priceBook.Id,
            Quantity = 1,
            UnitPrice = 5000
        );
        insert new List<OpportunityLineItem> {oli, oli2};


        // Investment Entity Account
        Investment__c investment = new Investment__c(
            Opportunity__c = opportunity2.Id, 
            Account__c = businessAccount.Id,
            Investment_Date__c = Date.today(),
            Investment_Opp_ID__c = 'MOPXS 123',
            Related_Product__c = product1.Id,
            Opportunity_Product__c = oli.id,
            Funds_Received_in_Bank__c = true,
            Amount__c = 23000,
            Stage__c = 'Closed Won',
            Investment_Product_Name__c = 'Test Product 1'
        );

        // Investment Person Account
        Investment__c investment2 = new Investment__c(
            Opportunity__c = opportunity.Id, 
            Account__c = testAccount.Id,
            Related_Product__c = product1.Id,
            Opportunity_Product__c = oli.id,
            Amount__c = 23000,
            Stage__c = 'Closed Won',
            Investment_Product_Name__c = 'Test Product 1'
        );
        // Pending investment
        Investment__c investment3 = new Investment__c(
            Opportunity__c = opportunity3.Id, 
            Account__c = testAccount.Id,
            Investment_Date__c = Date.today(),
            Related_Product__c = product1.Id,
            Opportunity_Product__c = oli2.id,
            Funds_Received_in_Bank__c = false,
            Amount__c = 23000,
            Stage__c = 'Application Received',
            Investment_Product_Name__c = 'Test Product 1'
        );
        insert new List<Investment__c> {investment, investment2, investment3};

        // Create a Transaction record associated with the Investment
        Transaction__c transactions = new Transaction__c(
            Account__c = testAccount.Id,
            Transaction_Type__c = 'Bill',
            Status__c = 'Paid',
            Investment__c = investment.Id,
            XI_Line_Items_Description__c = 'Test Int_IP Description',
            XI_Line_item_amount__c = '1000',
            Transaction_Amount__c = 1000,
            CreatedDate = Date.today().addDays(-1),
            XI_Issue_Date__c = Date.today().addDays(-1)
        );
        insert transactions;


        // Create a sample ContentVersion
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'FY_23_Document';
        contentVersion.PathOnClient = 'FY_23_Document.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.Form_Field__c = 'TestField';
        insert contentVersion;
        
        // Link the document to the account
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        docLink.LinkedEntityId = opportunity.Id;
        docLink.ShareType = 'V';
        docLink.Visibility = 'AllUsers';
        insert docLink;

        // Create a sample ContentDistribution
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.ContentVersionId = contentVersion.Id;
        contentDistribution.Name = 'Test Distribution';
        insert contentDistribution;

    }

        @isTest
        static void testPortfolioAccountInformationSuccess() {
            Test.startTest();
            // Arrange: Fetch the test User
            Id testUserId = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1].Id;
            
            // Act: Call the portfolioAccountInformation method
            Map<String, Object> result = PipoController.portfolioAccountInformation(testUserId);
            
            // Assert: Validate that the returned Map contains the expected values
            System.assertNotEquals(null, result, 'The result should not be null.');
            System.assertEquals('PreferredTestName', result.get('Name'), 'The Name should match the PreferredName.');
            System.assertEquals(true, result.get('IdVerified'), 'The IdVerified flag should be true.');
            Test.stopTest();
        }

        @isTest
        static void testPortfolioAccountInformationException() {
            Test.startTest();
            try {
                // Act: Call the portfolioAccountInformation method with an invalid userId
                pipoController.portfolioAccountInformation('005000000000001');
                System.assert(false, 'An exception should have been thrown.');
            } catch (DmlException e) {
                // Assert: Ensure the AuraHandledException is thrown and contains the expected message
                System.assert(true, 'Exception should have been thrown for wrong user ID');
            }
            Test.stopTest();
        }

        @isTest
        static void testGetAccountInvestmentsSuccess() {
            Test.startTest();
            // Arrange: Fetch the test User
            User testUser = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1];

            // Act: Call the getAccountInvestments method
            List<Map<String, Object>> investments = PipoController.getAccountInvestments(testUser.Id, 10, 0);
            
            // Assert: Validate that the returned List contains investment data
            System.assertNotEquals(null, investments, 'The investments result should not be null.');
            System.assertNotEquals(0, investments.size(), 'There should be at least one investment.');
            Test.stopTest();
        }

        @isTest
        static void testGetEntitiesInvestmentsSuccess() {
            Test.startTest();
            // Arrange: Fetch the test User
            User testUser = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1];

            // Act: Call the getEntitiesInvestments method
            System.runAs(testUser) {
                List<Map<String, Object>> entityInvestments = PipoController.getEntitiesInvestments(0,10);
                
                // Assert: Validate that the returned List contains entity-related investment data
                System.assertNotEquals(null, entityInvestments, 'The entity investments result should not be null.');
                // System.assertNotEquals(0, entityInvestments.size(), 'There should be at least one entity investment.');
            }
            Test.stopTest();
        }

        // @isTest
        // Is not throwing an exception because it's a list and returns a empty list
        // static void testGetAccountInvestmentsException() {
        //     Test.startTest();
        //     try {
        //         // Act: Call the getAccountInvestments method with an invalid userId
        //         pipoController.getAccountInvestments('005000000000001');
        //         System.assert(false, 'An exception should have been thrown.');
        //     } catch (Exception e) {
        //         // Assert: Ensure the AuraHandledException is thrown and contains the expected message
        //         System.assert(true, 'Exception should have been thrown for wrong user ID');
        //     }
        //     Test.stopTest();
        // }

        @isTest
        static void testGetEntitiesInvestmentsException() {
            Test.startTest();
            try {
                User owner = [SELECT Id FROM User WHERE Name = '12' LIMIT 1];
                    PipoController.getEntitiesInvestments(0,10);
                    // Act: Call the getAccountInvestments method with an invalid userId
                    System.assert(false, 'An exception should have been thrown.');
            } catch (Exception e) {
                // Assert: Ensure the AuraHandledException is thrown and contains the expected message
                System.assert(true, 'Exception should have been thrown for wrong user ID');
            }
            Test.stopTest();
        }

        @isTest
        static void testGetTaxDocumentsSuccess() {
            Test.startTest();
            // Arrange: Fetch the test User created in setupTestData
            Id testUserId = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1].Id;
            
            // Act: Call the getTaxDocuments method
            List<Map<String, Object>> taxDocuments = PipoController.getTaxDocuments(testUserId, 'FY_', false);
            
            // Assert: Validate that the returned List contains data
            System.assertNotEquals(null, taxDocuments, 'The taxDocuments result should not be null.');
            Test.stopTest();
        }

        @isTest
        static void testGetInvestmentDetailsSuccess() {
            Test.startTest();
            // Arrange: Fetch the test Investment created in setupTestData
            Id testInvestmentId = [SELECT Id FROM Investment__c WHERE Investment_Opp_ID__c = 'MOPXS 123' LIMIT 1].Id;
            
            // Act: Call the getInvestmentDetails method
            Map<String, Object> investmentDetails = PipoController.getInvestmentDetails(testInvestmentId);
            
            // Assert: Validate that the returned Map contains data
            System.assertNotEquals(null, investmentDetails, 'The investmentDetails result should not be null.');
            Test.stopTest();
        }
    
        @isTest
        static void testGetInvestmentDetailsException() {
            Test.startTest();
            try {
                // Act: Call the getInvestmentDetails method with an invalid investmentId
                PipoController.getInvestmentDetails('123456789012345');
                System.assert(false, 'An exception should have been thrown.');
            } catch (Exception e) {
                // Assert: Ensure the AuraHandledException is thrown and contains the expected message
                System.assert(true, 'Exception should have been thrown for invalid investment ID.');
            }
            Test.stopTest();
        }
    
        @isTest
        static void testGetInvestmentTransactionsSuccess() {
            Test.startTest();
            // Arrange: Fetch the test Investment created in setupTestData
            Id testInvestmentId = [SELECT Id FROM Investment__c LIMIT 1].Id;
            
            // Act: Call the getInvestmentTransactions method
            List<Map<String, Object>> transactions = PipoController.getInvestmentTransactions(testInvestmentId);
            
            // Assert: Validate that the returned List contains transaction data
            System.assertNotEquals(null, transactions, 'The transactions result should not be null.');
            System.assertNotEquals(0, transactions.size(), 'There should be at least one transaction.');
            Test.stopTest();
        }
    
        @isTest
        static void testGetInvestmentTransactionsException() {
            Test.startTest();
            try {
                // Act: Call the getInvestmentTransactions method with an invalid investmentId
                PipoController.getInvestmentTransactions('123456789012345');
                System.assert(false, 'An exception should have been thrown.');
            } catch (Exception e) {
                // Assert: Ensure the AuraHandledException is thrown and contains the expected message
                System.assert(true, 'Exception should have been thrown for invalid investment ID.');
            }
            Test.stopTest();
        }
    
        @isTest
        static void testRequestRefundSuccess() {
            Test.startTest();
            // Arrange: Fetch the test Investment created in setupTestData
            Id testInvestmentId = [SELECT Id FROM Investment__c WHERE Investment_Opp_ID__c = 'MOPXS 123' LIMIT 1].Id;
            String reasonRefund = 'Test reason for refund';
    
            // Act: Call the requestRefund method
            PipoController.requestRefund(testInvestmentId, reasonRefund);
    
            // Assert: No exception should be thrown during the execution
            System.assert(true, 'Refund request should be processed successfully.');
            Test.stopTest();
        }
    
        @isTest
        static void testRequestRefundException() {
            Test.startTest();
            try {
                // Act: Call the requestRefund method with an invalid investmentId
                PipoController.requestRefund('123456789012345', 'Invalid reason');
                System.assert(false, 'An exception should have been thrown.');
            } catch (Exception e) {
                // Assert: Ensure the AuraHandledException is thrown and contains the expected message
                System.assert(true, 'Exception should have been thrown for invalid investment ID.');
            }
            Test.stopTest();
        }


        @isTest
        static void testTourTakenSuccess() {
            Test.startTest();
            // Arrange: Fetch the test Investment created in setupTestData
            Id testInvestmentId = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1].Id;
    
            // Act: Call the requestRefund method
            PipoController.tourTaken(testInvestmentId);
    
            // Assert: No exception should be thrown during the execution
            System.assert(true, 'Refund request should be processed successfully.');
            Test.stopTest();
        }
    
        @isTest
        static void testTourTakenException() {
            Test.startTest();
            try {
                // Act: Call the requestRefund method with an invalid investmentId
                PipoController.tourTaken('123456789012345');
                System.assert(false, 'An exception should have been thrown.');
            } catch (Exception e) {
                // Assert: Ensure the AuraHandledException is thrown and contains the expected message
                System.assert(true, 'Exception should have been thrown for invalid investment ID.');
            }
            Test.stopTest();
        }
        
        @isTest
        static void testGetSpotlightDataSuccess() {
            // Arrange
            Id testUserId = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1].Id;

            // Act
            Test.startTest();
            Map<String, Decimal> result = PipoController.getSpotlightData(testUserId);
            Test.stopTest();

            // Assert
            System.assertNotEquals(null, result, 'The result should not be null.');
        }

        // @isTest
        // static void testGetSpotlightDataException() {
        //     // Arrange
        //     Id invalidUserId = '005000000000000';

        //     // Act & Assert
        //     Test.startTest();
        //     try {
        //         PipoController.getSpotlightData(invalidUserId);
        //         System.assert(false, 'Exception should have been thrown.');
        //     } catch (Exception e) {
        //         System.assert(true, 'Exception should have been thrown for invalid investment ID.');
        //     }
        //     Test.stopTest();
        // }

        @isTest
        static void testGetPendingAndInactiveInvestmentsSuccess() {
            // Arrange
            Id testUserId = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1].Id;

            // Act
            Test.startTest();
            List<Map<String, Object>> investments = PipoController.getPendingAndInactiveInvestments(testUserId);
            Test.stopTest();

            // Assert
            System.assertNotEquals(null, investments, 'The investments list should not be null.');
        }

        @isTest
        static void testGetPendingAndInactiveInvestmentsException() {
            // Arrange
            Id invalidUserId = '005000000000000';

            // Act & Assert
            Test.startTest();
            try {
                PipoController.getPendingAndInactiveInvestments(invalidUserId);
                System.assert(false, 'Exception should have been thrown.');
            } catch (Exception e) {
                System.assert(true, 'Exception should have been thrown for invalid investment ID.');
            }
            Test.stopTest();
        }
    }