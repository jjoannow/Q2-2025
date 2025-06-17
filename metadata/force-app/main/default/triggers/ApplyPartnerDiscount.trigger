trigger ApplyPartnerDiscount on SBQQ__QuoteLine__c (before insert, before update) {
    Set<Id> quoteIds = new Set<Id>();

    // Collect Quote IDs from Quote Lines
    for (SBQQ__QuoteLine__c qli : Trigger.new) {
        if (qli.SBQQ__Quote__c != null) {
            quoteIds.add(qli.SBQQ__Quote__c);
        }
    }

    // Query Quotes to get related Account IDs
    Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(
        [SELECT Id, SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]
    );

    // Collect Account IDs
    Set<Id> accountIds = new Set<Id>();
    for (SBQQ__Quote__c quote : quoteMap.values()) {
        if (quote.SBQQ__Account__c != null) {
            accountIds.add(quote.SBQQ__Account__c);
        }
    }

    // Query Accounts for Partner Type and Tier
    Map<Id, Account> accountMap = new Map<Id, Account>(
        [SELECT Id, Type, Tier__c FROM Account WHERE Id IN :accountIds]
    );

    // Apply 30% Partner Discount for Platinum Partners
    for (SBQQ__QuoteLine__c qli : Trigger.new) {
        SBQQ__Quote__c quote = quoteMap.get(qli.SBQQ__Quote__c);
        if (quote != null) {
            Account acc = accountMap.get(quote.SBQQ__Account__c);
            if (acc != null && acc.Type == 'Partner' && acc.Tier__c == 'Platinum') {
                qli.SBQQ__PartnerDiscount__c = 30.0;
            }
        }
    }
}