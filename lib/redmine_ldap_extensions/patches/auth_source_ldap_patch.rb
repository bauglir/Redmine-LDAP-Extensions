module RedmineLdapExtensions
  module Patches
    module AuthSourceLdapPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end
      
      module InstanceMethods
        def find_in_directory(q)
          # We won't bother querying the directory for any query shorter than 2 
          # characters
          return unless q.length > 2
    
          ldap_con = initialize_ldap_con(self.account, self.account_password)
    
          # Filter for an occurence of the query string anywhere in any of the 
          # attributes
          q = "*#{q}*"
          object_filter = Net::LDAP::Filter.eq( 'objectClass', 'person' )
          login_filter = Net::LDAP::Filter.eq( self.attr_login, q )
          firstname_filter = Net::LDAP::Filter.eq( self.attr_firstname, q )
          lastname_filter = Net::LDAP::Filter.eq( self.attr_lastname, q )
          mail_filter = Net::LDAP::Filter.eq( self.attr_mail, q )
    
          userHits = []
          ldap_con.search( :base => self.base_dn, 
                           :filter => object_filter & ( login_filter |
                                                        firstname_filter |
                                                        lastname_filter |
                                                        mail_filter ), 
                           :attributes=> ['uid'].concat(search_attributes)) do |entry|
            userHits << get_user_attributes_from_ldap_entry(entry).merge({:uid => entry.uid[0]})
          end
          
          return userHits
        end
      end
    end
  end  
end
