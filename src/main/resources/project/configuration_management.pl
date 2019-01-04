use ElectricCommander;

my $ec   = new ElectricCommander();
my $code = $ec->getProperty("/myProject/Heroku")->findvalue("//value")->value();

eval($code) or die("Error loading Heroku library code: $@\n");

my $ConfigName = ($ec->getProperty("ConfigName"))->findvalue('//value')->string_value;
my $Action     = ($ec->getProperty("Action"))->findvalue('//value')->string_value;
my $AppName    = ($ec->getProperty("AppName"))->findvalue('//value')->string_value;
my $Body       = ($ec->getProperty("Body"))->findvalue('//value')->string_value;
my $Key        = ($ec->getProperty("Key"))->findvalue('//value')->string_value;

plugin_info();
configuration_management($ConfigName, $Action, $AppName, $Body, $Key);
