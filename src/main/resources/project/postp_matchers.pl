@::gMatchers = (
  {
        id =>           "HerokuError",
        pattern =>      q{.*fatal:\s(.*)},
        action =>       q{&addSimpleError("HerokuError", "Error: $1");setProperty("outcome", "error" );updateSummary();},
  },
  {
    id =>               "PluginError",
    pattern =>          q{.*Error:\s(.*)},
    action =>           q{&addSimpleError("PluginError", "Error: $1");setProperty("outcome", "error" );updateSummary();},
  },
  {
    id =>               "ConfigError",
    pattern =>          q{.*Failed\sto\sfind\sproperty\s'Heroku_cfgs'.*},
    action =>           q{&addSimpleError("ConfigError", "Failed to find configuration");setProperty("outcome", "error" );updateSummary();},
  },
);

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty ($name, $customError);
    }
}

sub updateSummary() {    
    my $summary = (defined $::gProperties{"HerokuError"}) ? $::gProperties{"HerokuError"} . "\n" : "";
    $summary .= (defined $::gProperties{"PluginError"}) ? $::gProperties{"PluginError"} . "\n" : "";    
    $summary .= (defined $::gProperties{"ConfigError"}) ? $::gProperties{"ConfigError"} . "\n" : "";    

    setProperty ("summary", $summary);
}
