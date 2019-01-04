use ElectricCommander;

my $ec   = new ElectricCommander();
my $code = $ec->getProperty("/myProject/Heroku")->findvalue("//value")->value();

eval($code) or die("Error loading Heroku library code: $@\n");

my $ConfigName   = ($ec->getProperty("ConfigName"))->findvalue('//value')->string_value;
my $Action       = ($ec->getProperty("Action"))->findvalue('//value')->string_value;
my $AppName      = ($ec->getProperty("AppName"))->findvalue('//value')->string_value;
my $EmailAccount = ($ec->getProperty("EmailAccount"))->findvalue('//value')->string_value;

plugin_info();
collaborator_management($ConfigName, $Action, $AppName, $EmailAccount);
