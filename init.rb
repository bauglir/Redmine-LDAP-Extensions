require 'redmine'

# Patch controllers and models
# require 'ldap_extensions_members_controller_patch'
# require 'ldap_extensions_auth_source_ldap_model_patch'

Redmine::Plugin.register :redmine_ldap_extensions do
  name 'LDAP Extensions'
  author 'Joris Kraak'
  description 'A plugin which adds some additional LDAP functionality to Redmine/ChiliProject'
  version '0.0.1'
  url 'http://projects.majorfail.com/projects/ldap_extensions/'
  author_url 'http://majorfail.com/'

  requires_redmine :version_or_higher => '0.9.0'
  
  require 'dispatcher'
  Dispatcher.to_prepare :redmine_ldap_extensions do
    require_dependency 'auth_source_ldap'
    AuthSourceLdap.send(:include, RedmineLdapExtensions::Patches::AuthSourceLdapPatch)

    require_dependency 'members_controller'
    MembersController.send(:include, RedmineLdapExtensions::Patches::MembersControllerPatch)
  end
end
