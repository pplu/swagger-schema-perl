requires 'MooseX::DataModel';
requires 'MooseX::Getopt';
requires 'File::Slurp';
requires 'Template';
requires 'Template::Plugin::Dumper';
requires 'Moose';
requires 'Path::Class';

on develop => sub {
  requires 'Dist::Zilla';
  requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
  requires 'Dist::Zilla::Plugin::VersionFromModule';
  requires 'Dist::Zilla::PluginBundle::Git';
};
