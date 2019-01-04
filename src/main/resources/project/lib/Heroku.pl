# -------------------------------------------------------------------------
# Package
#    Heroku.pl
#
# Dependencies
#    -none
#
# Purpose
#    Perl script to integrate Heroku functionality
#
# Date
#    06/08/2012
#
# Engineer
#    Bryan Barrantes
#
# Copyright (c) 2012 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use strict;
use warnings;
use ElectricCommander;
use ElectricCommander::PropDB;
use lib "$ENV{COMMANDER_PLUGINS}/@PLUGIN_NAME@/agent/lib";
use LWP 5.825;    #5.831;#6.02;
use LWP::Simple;
use JSON;

local $| = 1;

########################################################################

=head2 add_ons_management
 
  Title    : add_ons_management
  Usage    : add_ons_management("ConfigName","Action","AppName","AddOnName");
  Function : Method with parameters
  Returns  : none
  Args     : named arguments:
           : -ConfigName    => name of the configuration
           : -Action        => action to perform
           : -AppName       => name of the application
           : -AddOnName     => name of the add-on
           :
=cut

########################################################################
sub add_ons_management {
    my ($ConfigName, $Action, $AppName, $AddOnName) = @_;
    my $empty   = q{};
    my $Content = $empty;
    my $apiKey  = qq{};
    my $sshKey  = qq{};

    my %configuration = get_configuration($ConfigName);
    if (%configuration) {
        if ($configuration{'token'} && $configuration{'token'} ne "") {
            $apiKey = $configuration{'token'};
        }
        else {
            $ec->setProperty("outcome", "error");
            print "Error: API token cannot be empty\n";
            exit;
        }
        if ($configuration{'key'} && $configuration{'key'} ne "") {
            $sshKey = $configuration{'key'};
        }
    }

    if ($Action eq "listall") {
        $Content = "accept=application%2Fjson&action=GET+%2Faddons&params=&apikey=" . $apiKey;
    }
    elsif ($Action eq "list") {
        if ($AppName eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Application Name cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=GET+%2Fapps%2F" . $AppName . "%2Faddons&params=&apikey=" . $apiKey;
        }
    }
    else {
        if ($AppName eq "" or $AddOnName eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Application Name and Add-On Name cannot be empty\n";
            exit;
        }
        else {
            if ($Action eq "install") {
                $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Faddons%2F" . $AddOnName . "&params=&apikey=" . $apiKey;
            }
            elsif ($Action eq "upgrade") {
                $Content = "accept=application%2Fjson&action=PUT+%2Fapps%2F" . $AppName . "%2Faddons%2F" . $AddOnName . "&params=&apikey=" . $apiKey;
            }
            else {    # uninstall
                $Content = "accept=application%2Fjson&action=DELETE+%2Fapps%2F" . $AppName . "%2Faddons%2F" . $AddOnName . "&params=&apikey=" . $apiKey;
            }
        }
    }
    heroku_api_request($Content);
}

########################################################################

=head2 application_management
 
  Title    : application_management
  Usage    : application_management("ConfigName","Action","AppName","NewAppName","Stack","NewAppOwner");
  Function : Method with parameters
  Returns  : none
  Args     : named arguments:
           : -ConfigName    => name of the configuration
           : -Action        => action to perform
           : -AppName       => name of the application
           : -NewAppName    => new name for the application
           : -Stack         => stack for the application
           : -NewAppOwner   => new owner of the application
           :
=cut

########################################################################
sub application_management {
    my ($ConfigName, $Action, $AppName, $NewAppName, $Stack, $NewAppOwner) = @_;

    my $empty   = q{};
    my $Content = $empty;
    my $apiKey  = qq{};
    my $sshKey  = qq{};

    my %configuration = get_configuration($ConfigName);
    if (%configuration) {
        if ($configuration{'token'} && $configuration{'token'} ne "") {
            $apiKey = $configuration{'token'};
        }
        else {
            $ec->setProperty("outcome", "error");
            print "Error: API token cannot be empty\n";
            exit;
        }
        if ($configuration{'key'} && $configuration{'key'} ne "") {
            $sshKey = $configuration{'key'};
        }
    }
    if ($AppName eq "") {
        $ec->setProperty("outcome", "error");
        print "Error: Application Name cannot be empty\n";
        exit;
    }

    if ($Action eq "create") {
        if ($Stack and $Stack ne "") {
            $Content = "accept=application%2Fjson&action=POST+%2Fapps&params=app%5Bname%5D%3D" . $AppName . "&app%5Bstack%5D%3D" . $Stack . "&apikey=" . $apiKey;
        }
        else {
            $Content = "accept=application%2Fjson&action=POST+%2Fapps&params=app%5Bname%5D%3D" . $AppName . "&apikey=" . $apiKey;
        }
    }
    elsif ($Action eq "rename") {
        if ($NewAppName eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: New Application Name cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=PUT+%2Fapps%2F" . $AppName . "&params=app%5Bname%5D%3D" . $NewAppName . "&apikey=" . $apiKey;
        }
    }
    elsif ($Action eq "transfer") {
        if ($NewAppOwner eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: New Application Owner cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=PUT+%2Fapps%2F" . $AppName . "&params=app%5Btransfer_owner%5D%3D" . $NewAppOwner . "&apikey=" . $apiKey;
        }
    }
    else {    #destroy
        $Content = "accept=application%2Fjson&action=DELETE+%2Fapps%2F" . $AppName . "&params=&apikey=" . $apiKey;
    }

    heroku_api_request($Content);
}

########################################################################

=head2 collaborator_management
 
  Title    : collaborator_management
  Usage    : collaborator_management("ConfigName","Action","AppName","EmailAccount");
  Function : Method with parameters
  Returns  : none
  Args     : named arguments:
           : -ConfigName    => name of the configuration
           : -Action        => action to perform
           : -AppName       => name of the application
           : -EmailAccount  => Email account
           :
=cut

########################################################################
sub collaborator_management {
    my ($ConfigName, $Action, $AppName, $EmailAccount) = @_;
    my $empty   = q{};
    my $Content = $empty;
    my $apiKey  = qq{};
    my $sshKey  = qq{};

    my %configuration = get_configuration($ConfigName);
    if (%configuration) {
        if ($configuration{'token'} && $configuration{'token'} ne "") {
            $apiKey = $configuration{'token'};
        }
        else {
            $ec->setProperty("outcome", "error");
            print "Error: API token cannot be empty\n";
            exit;
        }
        if ($configuration{'key'} && $configuration{'key'} ne "") {
            $sshKey = $configuration{'key'};
        }
    }

    if ($AppName eq "") {
        $ec->setProperty("outcome", "error");
        print "Error: Application Name cannot be empty\n";
        exit;
    }

    if ($Action eq "view") {
        $Content = "accept=application%2Fjson&action=GET+%2Fapps%2F" . $AppName . "%2Fcollaborators&params=&apikey=" . $apiKey;
    }
    if ($EmailAccount eq "") {
        $ec->setProperty("outcome", "error");
        print "Error: Email Account cannot be empty\n";
        exit;
    }
    else {
        if ($Action eq "add") {
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fcollaborators&params=collaborator%5Bemail%5D%3D" . $EmailAccount . "&apikey=" . $apiKey;
        }
        else {    #remove
            $Content = "accept=application%2Fjson&action=DELETE+%2Fapps%2F" . $AppName . "%2Fcollaborators%2F" . $EmailAccount . "&params=&apikey=" . $apiKey;
        }
    }
    heroku_api_request($Content);
}

########################################################################

=head2 configuration_management
 
  Title    : configuration_management
  Usage    : configuration_management("ConfigName","Action","AppName","Body","Key");
  Function : Method with parameters
  Returns  : none
  Args     : named arguments:
           : -ConfigName    => name of the configuration
           : -Action        => action to perform
           : -AppName       => name of the application
           : -Body          => new config vars, as a JSON hash
           : -Key           => name of the config var to remove
           :
=cut

########################################################################
sub configuration_management {
    my ($ConfigName, $Action, $AppName, $Body, $Key) = @_;
    my $empty   = q{};
    my $Content = $empty;
    my $apiKey  = qq{};
    my $sshKey  = qq{};

    my %configuration = get_configuration($ConfigName);
    if (%configuration) {
        if ($configuration{'token'} && $configuration{'token'} ne "") {
            $apiKey = $configuration{'token'};
        }
        else {
            $ec->setProperty("outcome", "error");
            print "Error: API token cannot be empty\n";
            exit;
        }
        if ($configuration{'key'} && $configuration{'key'} ne "") {
            $sshKey = $configuration{'key'};
        }
    }

    if ($AppName eq "") {
        $ec->setProperty("outcome", "error");
        print "Error: Application Name cannot be empty\n";
        exit;
    }

    if ($Action eq "view") {
        $Content = "accept=application%2Fjson&action=GET+%2Fapps%2F" . $AppName . "%2Fconfig_vars&params=&apikey=" . $apiKey;
    }
    elsif ($Action eq "add") {
        if ($Body eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Body cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=PUT+%2Fapps%2F" . $AppName . "%2Fconfig_vars&params=" . $Body . "&apikey=" . $apiKey;
        }
    }
    else {    #remove
        if ($Key eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Key cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=DELETE+%2Fapps%2F" . $AppName . "%2Fconfig_vars%2F" . $Key . "&params=&apikey=" . $apiKey;
        }
    }
    heroku_api_request($Content);
}

########################################################################

=head2 deploy_application
 
  Title    : deploy_application
  Usage    : deploy_application("Application Path");
  Function : Deploy a Heroku application using Git
  Returns  : nothing
  Args     : named arguments:
           : -AppPath => Local path to Heroku application
           : -Branch  => Branch for deploy
           :    
=cut

########################################################################
sub deploy_application {
    my ($AppPath, $Branch) = @_;

    # Validate empty params
    if ($AppPath eq "") {
        $ec->setProperty("outcome", "error");
        print "Error: Application Path cannot be empty\n";
        exit;
    }
    my $command = qq{};

    #Go to app folder
    chdir($AppPath);
    if ($! and $! ne "") {
        $ec->setProperty("outcome", "error");
        print "Error: Invalid Application Path\n";
        exit;
    }

    if ($Branch eq "" or $Branch eq "master") {

        #git push heroku master
        $command .= qq{git push heroku master};
    }
    else {    #git push heroku $Branch:master
        $command .= qq{git push heroku $Branch:master};
    }
    print "Directory: " . $AppPath . "\n";
    print "Command: " . $command;
    $ec->setProperty("/myCall/HerokuCommandLine", $command);
}

########################################################################

=head2 process_management
 
  Title    : process_management
  Usage    : process_management("ConfigName","Action","AppName","ProcessName","ProcessType","Quantity");
  Function : Method with parameters
  Returns  : none
  Args     : named arguments:
           : -ConfigName    => name of the configuration
           : -Action        => action to perform
           : -AppName       => name of the application
           : -ProcessName   => name of the process
           : -ProcessType   => type of the process
           : -Quantity      => quantity of processes to scale
           :
=cut

########################################################################
sub process_management {
    my ($ConfigName, $Action, $AppName, $ProcessName, $ProcessType, $Quantity) = @_;
    my $empty   = q{};
    my $Content = $empty;
    my $apiKey  = qq{};
    my $sshKey  = qq{};

    my %configuration = get_configuration($ConfigName);
    if (%configuration) {
        if ($configuration{'token'} && $configuration{'token'} ne "") {
            $apiKey = $configuration{'token'};
        }
        else {
            $ec->setProperty("outcome", "error");
            print "Error: API token cannot be empty\n";
            exit;
        }
        if ($configuration{'key'} && $configuration{'key'} ne "") {
            $sshKey = $configuration{'key'};
        }
    }

    if ($AppName eq "") {
        $ec->setProperty("outcome", "error");
        print "Error: Application Name cannot be empty\n";
        exit;
    }

    if ($Action eq "list") {
        $Content = "accept=application%2Fjson&action=GET+%2Fapps%2F" . $AppName . "%2Fps&params=&apikey=" . $apiKey;
    }
    elsif ($Action eq "restart") {
        if ($ProcessName ne "" and $ProcessType ne "") {
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fps%2Frestart&params=ps%3D" . $ProcessName . "%26type%3D" . $ProcessType . "&apikey=" . $apiKey;
        } elsif($ProcessName ne ""){            
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fps%2Frestart&params=ps%3D" . $ProcessName . "&apikey=" . $apiKey;
        } elsif($ProcessType ne ""){
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fps%2Frestart&params=type%3D" . $ProcessType . "&apikey=" . $apiKey;
        }
        else {    #restart all
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fps%2Frestart&params=apikey=" . $apiKey;
        }
    }
    elsif ($Action eq "stop") {
        if ($ProcessName ne "" and $ProcessType ne "") {
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fps%2Fstop&params=ps%3D" . $ProcessName . "%26type%3D" . $ProcessType . "&apikey=" . $apiKey;
        }
        else {    #stop all
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fps%2Fstop&params=apikey=" . $apiKey;
        }
    }
    else {        #scale
        if ($ProcessType eq "" or $Quantity eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Process Type and Quantity cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Fps%2Fscale&params=type%3D" . $ProcessType . "%26qty%3D" . $Quantity . "&apikey=" . $apiKey;
        }
    }

    heroku_api_request($Content);
}

########################################################################

=head2 releases_management
 
  Title    : releases_management
  Usage    : releases_management("ConfigName","Action","AppName","Release");
  Function : Method with parameters
  Returns  : none
  Args     : named arguments:
           : -ConfigName    => name of the configuration
           : -Action        => action to perform
           : -AppName       => name of the application
           : -Release       => name of the release
           :
=cut

########################################################################
sub releases_management {
    my ($ConfigName, $Action, $AppName, $Release) = @_;
    my $empty   = q{};
    my $Content = $empty;
    my $apiKey  = qq{};
    my $sshKey  = qq{};

    my %configuration = get_configuration($ConfigName);
    if (%configuration) {
        if ($configuration{'token'} && $configuration{'token'} ne "") {
            $apiKey = $configuration{'token'};
        }
        else {
            $ec->setProperty("outcome", "error");
            print "Error: API token cannot be empty\n";
            exit;
        }
        if ($configuration{'key'} && $configuration{'key'} ne "") {
            $sshKey = $configuration{'key'};
        }
    }

    if ($AppName eq "") {
        $ec->setProperty("outcome", "error");
        print "Error: Application Name cannot be empty\n";
        return;
    }

    if ($Action eq "list") {
        $Content = "accept=application%2Fjson&action=GET+%2Fapps%2F" . $AppName . "%2Freleases&params=&apikey=" . $apiKey;
    }
    else {
        if ($Release eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Process Type and Quantity cannot be empty\n";
            exit;
        }
        else {
            if ($Action eq "get") {
                $Content = "accept=application%2Fjson&action=GET+%2Fapps%2F" . $AppName . "%2Freleases%2F" . $Release . "&params=&apikey=" . $apiKey;
            }
            else {    #rollback
                $Content = "accept=application%2Fjson&action=POST+%2Fapps%2F" . $AppName . "%2Freleases&params=rollback%3D" . $Release . "&apikey=" . $apiKey;
            }
        }
    }
    heroku_api_request($Content);
}

########################################################################

=head2 ssh_keys_management
 
  Title    : ssh_keys_management
  Usage    : ssh_keys_management("ConfigName","Action","Key");
  Function : Method with parameters
  Returns  : none
  Args     : named arguments:
           : -ConfigName    => name of the configuration
           : -Action        => action to perform
           : -Key           => ssh key
           :
=cut

########################################################################
sub ssh_keys_management {
    my ($ConfigName, $Action, $Key) = @_;
    my $empty   = q{};
    my $Content = $empty;
    my $apiKey  = qq{};
    my $sshKey  = qq{};

    my %configuration = get_configuration($ConfigName);
    if (%configuration) {
        if ($configuration{'token'} && $configuration{'token'} ne "") {
            $apiKey = $configuration{'token'};
        }
        else {
            $ec->setProperty("outcome", "error");
            print "Error: API token cannot be empty\n";
            exit;
        }
        if ($configuration{'key'} && $configuration{'key'} ne "") {
            $sshKey = $configuration{'key'};
        }
    }

    if ($Action eq "view") {
        $Content = "accept=application%2Fjson&action=GET+%2Fuser%2Fkeys&params=&apikey=" . $apiKey;
    }
    elsif ($Action eq "associate") {
        if ($Key eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Key cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=POST+%2Fuser%2Fkeys&params=" . $Key . "&apikey=" . $apiKey;
        }
    }
    elsif ($Action eq "remove") {
        if ($Key eq "") {
            $ec->setProperty("outcome", "error");
            print "Error: Key cannot be empty\n";
            exit;
        }
        else {
            $Content = "accept=application%2Fjson&action=DELETE+%2Fuser%2Fkeys%2F" . $Key . "&params=&apikey=" . $apiKey;
        }
    }
    else {    #removeall
        $Content = "accept=application%2Fjson&action=DELETE+%2Fuser%2Fkeys&params=&apikey=" . $apiKey;
    }
    heroku_api_request($Content);
}

########################################################################

=head2 heroku_api_request
 
  Title    : heroku_api_request
  Usage    : heroku_api_request("Content");
  Function : Makes the request to Heroku API
  Returns  : none
  Args     : named arguments:
           : -Content    => request content, encapsulating all the parameters
           :
=cut

########################################################################
sub heroku_api_request {
    my ($Content) = @_;

    my $browser    = LWP::UserAgent->new;
    my $url        = URI->new("https://api-docs.heroku.com/request");
    my $whitespace = q{ };
    my $empty      = q{};
    my $size       = 0;
    my $req        = HTTP::Request->new(POST => $url);

    #Validate request content
    if ($Content eq $empty) {
        $ec->setProperty("outcome", "error");
        print "Error: Invalid parameters provided\n";
        exit;
    }

    #Set request content
    $req->content($Content);
    $req->content_type("application/x-www-form-urlencoded");

    print "Creating Request...\n";

    # Print Request Parameters
    print "> Request:\n" . $req->as_string;

    # Perform Request
    print "Sending Request to Heroku...\n";
    my $response = $browser->request($req);

    # Check for errors
    print "----------------------------------------------------------------------------------------------------\n";
    print "Response Received.\nChecking for errors...\n";
    if ($response->is_error) {
        $ec->setProperty("outcome", "error");
        if ($response->status_line ne $empty) { print "\nStatus: " . $response->status_line . "\n"; }
        print("Error: The server was unable to fulfil the request.\nPlease check your parameters.");
        return;
    }
    print "Proceed to print response.\n";

    # Print Response
    print "> Response\n";
    my @res = split("\n", $response->as_string);
    my $format = $empty;
    $size = @res;
    my $response_line = shift(@res);
    while (($size > 1) and ($response_line !~ m/(^{).*|(^\[).*|(^<).*/ixsmg)) {
        if ($response_line =~ m/Content-Type:\s(.*)\/([A-Za-z0-9-.]*)/ixsmg) { $format = $2; }
        print $response_line. "\n";
        $response_line = shift(@res);
        $size--;
    }
    my $response_body = $response->content();

    # Response Format Validation
    if ($format eq "json" or $format eq "javascript") {
        my $json        = JSON->new->allow_nonref;
        my $perl_scalar = $json->decode($response_body);
        print $json->pretty->encode($perl_scalar);
    }
    else {
        print $response_body;
    }
    return;
}

########################################################################

=head2 get_configuration
 
  Title    : get_configuration
  Usage    : get_configuration("Configuration name");
  Function : get the information of the configuration given 
  Returns  : hash containing the configuration information
  Args     : named arguments:
           : -configName => name of the configuration to retrieve
           :
=cut

########################################################################
sub get_configuration {
    my ($configName) = @_;

    my $ec = new ElectricCommander();

    my %config;

    my $pluginConfigs = new ElectricCommander::PropDB($ec, "/projects/@PLUGIN_KEY@-@PLUGIN_VERSION@/Heroku_cfgs");

    my %row = $pluginConfigs->getRow($configName);

    # Check if configuration exists
    unless (keys(%row)) {
        print qq{Credential "$configName" does not exist};
        return 1;
    }

    foreach my $c (keys %row) {

        #getting all values except the credential that was read previously
        if ($c ne "credential") {
            $config{$c} = $row{$c};
        }
    }

    return %config;
}

########################################################################

=head2 plugin_info
 
  Title    : plugin_info
  Usage    : plugin_info("Plugin name");
  Function : get the information of the given plugin
  Returns  : nothing
  Args     : named arguments:
           : -pluginKey  => name of the plugin
           :
=cut

########################################################################
sub plugin_info {

    # Print plugin Info
    my $pluginKey  = 'EC-Heroku';
    my $xpath      = $ec->getPlugin($pluginKey);
    my $pluginName = $xpath->findvalue('//pluginVersion')->value;
    print "Using plugin $pluginKey version $pluginName";
    print "\n----------------------------------------------------------------------------------------------------\n";
}

1;
