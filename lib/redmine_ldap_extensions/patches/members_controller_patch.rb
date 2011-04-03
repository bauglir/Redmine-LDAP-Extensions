module RedmineLdapExtensions
  module Patches
    module MembersControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
    
        base.class_eval do
          alias_method_chain :autocomplete_for_member, :ldap
        end
      end

      module InstanceMethods
        def autocomplete_for_member_with_ldap
          # Retrieve all active internal accounts
          @principals = Principal.active.like(params[:q]).find(:all, :limit => 100)

          # Retrieve all accounts from the directory service
          find_users_in_ldap(params[:q])

          # Remove users already added to the project
          @principals -= @project.principals

          render :layout => false
        end
    
        private
          def find_users_in_ldap(q)
            existingUsers = @principals.collect { |user| user.login }
            
            directories = AuthSourceLdap.all
            directories.each do |d|
              userHits = d.find_in_directory(q)
              # Generate temporary users for any hits to the query unless the user
              # has already been found
              userHits.each do |user|
                tempUser = User.new({
                                      :firstname => user[:firstname],
                                      :lastname => user[:lastname],
                                      :mail => user[:mail],
                                      :auth_source_id => user[:auth_source_id] 
                                    })
                tempUser.login = user[:uid]
                tempUser.id = 0
                @principals << tempUser unless existingUsers.include?(tempUser.login)
              end unless userHits.nil?
              puts @principals
            end
          end
      end
    end
  end
end
