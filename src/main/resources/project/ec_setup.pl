
# Data that drives the create step picker registration for this plugin.
my %AddOnsManagement = (
                        label       => "Heroku - AddOnsManagement",
                        procedure   => "AddOnsManagement",
                        description => "Allows the user to List all, List installed, Install, Upgrade and Uninstall an Add-On",
                        category    => "Deployment"
                       );

my %ApplicationManagement = (
                             label       => "Heroku - ApplicationManagement",
                             procedure   => "ApplicationManagement",
                             description => "Allows the user to create, transfer, rename or destroy an App",
                             category    => "Deployment"
                            );

my %CollaboratorManagement = (
                              label       => "Heroku - CollaboratorManagement",
                              procedure   => "CollaboratorManagement",
                              description => "Used to invite other developers to collaborate on an app, to revoke the access to a developer or  view all the current collaborators",
                              category    => "Deployment"
                             );

my %ConfigurationManagement = (
                               label       => "Heroku - ConfigurationManagement",
                               procedure   => "ConfigurationManagement",
                               description => "Allows the developer to manage the config vars",
                               category    => "Deployment"
                              );

my %DeployApplication = (
                         label       => "Heroku - DeployApplication",
                         procedure   => "DeployApplication",
                         description => "Allow the user to deploy code just by pushing it to the branch",
                         category    => "Deployment"
                        );

my %ProcessManagement = (
                         label       => "Heroku - ProcessManagement",
                         procedure   => "ProcessManagement",
                         description => "Allows the user to List, Restart, Stop and Scale processes",
                         category    => "Deployment"
                        );

my %ReleasesManagement = (
                          label       => "Heroku - ReleasesManagement",
                          procedure   => "ReleasesManagement",
                          description => "Allows the user to List, Get info and Rollback a Release",
                          category    => "Deployment"
                         );

my %SSHKeysManagement = (
                         label       => "Heroku - SSHKeysManagement",
                         procedure   => "SSHKeysManagement",
                         description => "Allows to generate a public key, get all the existing keys, add and remove keys as well",
                         category    => "Deployment"
                        );
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - AddOnsManagement");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - ApplicationManagement");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - CollaboratorManagement");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - ConfigurationManagement");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - DeployApplication");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - ProcessManagement");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - ReleasesManagement");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Heroku - SSHKeysManagement");

@::createStepPickerSteps = (\%AddOnsManagement, \%ApplicationManagement, \%CollaboratorManagement, \%ConfigurationManagement, \%DeployApplication, \%ProcessManagement, \%ReleasesManagement, \%SSHKeysManagement);


my $pluginName = "@PLUGIN_NAME@";
if ($upgradeAction eq 'upgrade') {
    my $query   = $commander->newBatch();
    my $newcfg  = $query->getProperty("/plugins/$pluginName/project/Heroku_cfgs");
    my $oldcfgs = $query->getProperty("/plugins/$otherPluginName/project/Heroku_cfgs");

    local $self->{abortOnError} = 0;
    $query->submit();

    # if new plugin does not already have cfgs
    if ($query->findvalue($newcfg, "code") eq "NoSuchProperty") {

        # if old cfg has some cfgs to copy
        if ($query->findvalue($oldcfgs, "code") ne "NoSuchProperty") {
            $batch->clone(
                          {
                            path      => "/plugins/$otherPluginName/project/Heroku_cfgs",
                            cloneName => "/plugins/$pluginName/project/Heroku_cfgs"
                          }
                         );
        }
    }
}
