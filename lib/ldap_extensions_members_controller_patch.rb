require_dependency 'members_controller'
require_dependency 'auth_source_ldap'

module LdapExtensionsMembersControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :autocomplete_for_member, :ldap
    end
  end
  
  module InstanceMethods
    def autocomplete_for_member_with_ldap
      # Retrieve all active accounts not belonging to the currently selected project
      @principals = Principal.active.like(params[:q]).find(:all, :limit => 100)

      find_users_in_ldap(params[:q])
      @principals -= @project.principals

      render :layout => false
    end

    private
      def find_users_in_ldap(q)
        directories = AuthSourceLdap.all
        
        directories.each do |d|
          userHits = d.find_in_directory(q)
          # Generate temporary users for any hits unless they are existing users
          userHits.each do |user|
            tempUser = User.new({
                                  :firstname => user[:firstname],
                                  :lastname => user[:lastname],
                                  :mail => user[:mail] 
                                })
            @principals << (tempUser.id = 0)
          end unless userHits.nil?
        end
      end
  end  
end

MembersController.send(:include, LdapExtensionsMembersControllerPatch)
