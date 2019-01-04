use ElectricCommander;

my $ec = new ElectricCommander();
my $code = $ec->getProperty("/myProject/Heroku")->findvalue("//value")->value();

eval($code) or die("Error loading Heroku library code: $@\n");

my $AppPath             = ($ec->getProperty( "AppPath" ))->findvalue('//value')->string_value;
my $Branch              = ($ec->getProperty( "Branch" ))->findvalue('//value')->string_value;

plugin_info();
deploy_application($AppPath,$Branch);