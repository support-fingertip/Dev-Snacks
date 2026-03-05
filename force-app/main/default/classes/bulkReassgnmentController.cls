public with sharing class bulkReassgnmentController {
    @AuraEnabled
    public static List<Contact> getFilteredContacts(String userId, String projectValues,String sourceValues, String statusValues, Integer offset, Integer limitSize,String dateValue,date startDate,date endDate) {
        try {
            // Debug input values
            System.debug('userId Values: ' + userId);
            System.debug('projectValues Values: ' + projectValues);
            System.debug('sourceValues Values: ' + sourceValues);
            System.debug('statusValues Values: ' + statusValues);
            System.debug('offset Values: ' + offset);
            System.debug('limitSize Values: ' + limitSize);
            System.debug('startDate Values: ' + startDate);
            System.debug('endDate Values: ' + endDate);
            System.debug('dateValue Values: ' + dateValue);
    
            // Initialize filters and bind variables
            List<String> filters = new List<String>();
            List<String> projectList = new List<String>();
            List<String> statusList = new List<String>();
            List<String> sourceList = new List<String>();
    
            // Add user filter
            if (!String.isEmpty(userId)) {
                filters.add('OwnerId = :userId');
            }
    
            // Add project filter
            if (!String.isEmpty(projectValues)) {
                projectList = projectValues.split(';');
                if (!projectList.isEmpty()) {
                    filters.add('Allocated_Project__c IN :projectList');
                }
            }
    
            // Add status filter
            if (!String.isEmpty(statusValues)) {
                statusList = statusValues.split(';');
                if (!statusList.isEmpty()) {
                    filters.add('Lead_Status__c IN :statusList');
                }
            }
    
            if (!String.isEmpty(sourceValues)) {
                sourceList = sourceValues.split(';');
                if (!sourceList.isEmpty()) {
                    filters.add('LeadSource IN :sourceList');
                }
            }

            if (!String.isEmpty(dateValue)) {
                if (startDate != null) {
                    filters.add( dateValue+' >= :startDate'); 
                }
                if (endDate != null) {
                    filters.add(dateValue+' <= :endDate');
                }
            }
            // Construct dynamic SOQL query
            String baseQuery = 'SELECT Id, Name, Phone__c, OwnerId, Lead_Status__c, Booking_Date__c, Created_Date__c, ' +
                               'Allocated_Project__c, LeadSource, Lead_Owner_Full_Name__c ' +
                               'FROM Contact';
    
            if (!filters.isEmpty()) {
                baseQuery += ' WHERE ' + String.join(filters, ' AND ');
            }
    
            baseQuery += ' ORDER BY CreatedDate DESC LIMIT :limitSize OFFSET :offset';
    
            // Debug final query
            System.debug('Final Query: ' + baseQuery);
    
            // Execute query
            List<Contact> contacts = Database.query(baseQuery);
    
            // Debug results
            System.debug('Contacts Retrieved: ' + contacts.size());
    
            return contacts;
        } catch (Exception ex) {
            System.debug('Error in getFilteredContacts: ' + ex.getMessage());
            throw new AuraHandledException('Unable to fetch contacts. Please try again later.');
        }
    }
    
    @AuraEnabled
    public static void saveUpdatedContacts(List<Contact> contacts) {
        try {
            if (contacts != null && !contacts.isEmpty()) {
                update contacts;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating contacts: ' + e.getMessage());
        }
    }
    public class UserWrapper {
        @AuraEnabled
        public String userId { get; set; }
        @AuraEnabled
        public String userName { get; set; }
 
        public UserWrapper(String id, String name) {
            this.userId = id;
            this.userName = name;
        }
    }
 
    @AuraEnabled(cacheable=true)
    public static List<UserWrapper> getUserPicklistValues() {
        List<UserWrapper> userPicklist = new List<UserWrapper>();
 
        // Query active users
        List<User> activeUsers = [SELECT Id, Name FROM User WHERE IsActive = true ORDER BY Name ASC];
 
        // Add Users to the wrapper list
        for (User u : activeUsers) {
            userPicklist.add(new UserWrapper(u.Id, u.Name));
        }
 
        return userPicklist;
    }
}