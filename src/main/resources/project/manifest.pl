@files = (
    ######################################################################################
    #                                   GENERIC PROPS                                    #
    ######################################################################################
    ['//property[propertyName="ec_setup"]/value',       'ec_setup.pl'],
    ['//property[propertyName="Heroku"]/value',         'lib/Heroku.pl'],
    ['//property[propertyName="postp_matchers"]/value', 'postp_matchers.pl'],
    ######################################################################################
    #                                    STEP PROPS                                      #
    ######################################################################################
    ['//step[stepName="AddOnsManagement"]/command',        'add_ons_management.pl'],
    ['//step[stepName="ApplicationManagement"]/command',   'application_management.pl'],
    ['//step[stepName="CollaboratorManagement"]/command',  'collaborator_management.pl'],
    ['//step[stepName="ConfigurationManagement"]/command', 'configuration_management.pl'],
    ['//step[stepName="DeployApplication"]/command',       'deploy_application.pl'],
    ['//step[stepName="ProcessManagement"]/command',       'process_management.pl'],
    ['//step[stepName="ReleasesManagement"]/command',      'releases_management.pl'],
    ['//step[stepName="SSHKeysManagement"]/command',       'ssh_keys_management.pl'],

    ######################################################################################
    #                                      SECURITY                                      #
    ######################################################################################
    ['//property[propertyName="ui_forms"]/propertySheet/property[propertyName="@PLUGIN_KEY@ - HerokuCreateConfigForm"]/value', 'forms/configuration/HerokuCreateConfigForm.xml'],
    ['//property[propertyName="ui_forms"]/propertySheet/property[propertyName="@PLUGIN_KEY@ - HerokuEditConfigForm"]/value',   'forms/configuration/HerokuEditConfigForm.xml'],
    ['//procedure[procedureName="CreateConfiguration"]/step[stepName="CreateConfiguration"]/command',                          'conf/createcfg.pl'],
    #['//procedure[procedureName="CreateConfiguration"]/step[stepName="CreateAndAttachCredential"]/command',                    'conf/createAndAttachCredential.pl'],
    ['//procedure[procedureName="DeleteConfiguration"]/step[stepName="DeleteConfiguration"]/command',                          'conf/deletecfg.pl'],
);
