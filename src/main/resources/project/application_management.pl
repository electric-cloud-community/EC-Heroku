use ElectricCommander;

my $ec   = new ElectricCommander();
my $code = $ec->getProperty("/myProject/Heroku")->findvalue("//value")->value();

eval($code) or die("Error loading Heroku library code: $@\n");

my $ConfigName  = ($ec->getProperty("ConfigName"))->findvalue('//value')->string_value;
my $Action      = ($ec->getProperty("Action"))->findvalue('//value')->string_value;
my $AppName     = ($ec->getProperty("AppName"))->findvalue('//value')->string_value;
my $NewAppName  = ($ec->getProperty("NewAppName"))->findvalue('//value')->string_value;
my $Stack       = ($ec->getProperty("Stack"))->findvalue('//value')->string_value;
my $NewAppOwner = ($ec->getProperty("NewAppOwner"))->findvalue('//value')->string_value;

plugin_info();
application_management($ConfigName, $Action, $AppName, $NewAppName, $Stack, $NewAppOwner);
