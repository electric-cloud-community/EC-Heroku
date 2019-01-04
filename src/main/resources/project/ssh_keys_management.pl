use ElectricCommander;

my $ec   = new ElectricCommander();
my $code = $ec->getProperty("/myProject/Heroku")->findvalue("//value")->value();

eval($code) or die("Error loading Heroku library code: $@\n");

my $ConfigName = ($ec->getProperty("ConfigName"))->findvalue('//value')->string_value;
my $Action     = ($ec->getProperty("Action"))->findvalue('//value')->string_value;
my $Key        = ($ec->getProperty("Key"))->findvalue('//value')->string_value;

plugin_info();
ssh_keys_management($ConfigName, $Action, $Key);
