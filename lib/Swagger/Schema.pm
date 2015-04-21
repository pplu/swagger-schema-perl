package Swagger::Schema {
  use MooseX::DataModel;

  key swagger => (isa => 'Str', required => 1); #Must be '2.0'
  key info => (isa => 'Swagger::Schema::Info', required => 1);
  key host => (isa => 'Str'); #MAY contain a port
  key basePath => (isa => 'Str'); #Must start with leading slash
  array schemes => (isa => 'Str'); #Strs must be http https ws wss
  array consumes => (isa => 'Str'); #Str must be mime type: https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#mimeTypes
  array produces => (isa => 'Str');
  key paths => (isa => 'Swagger::Schema::Paths');
  #key definitions => (isa => 'Swagger::Schema::Definition');
  #key parameters => (isa => 'Swagger::Schema::Parameter');
  #key responses => (isa => 'Swagger::Schema::Response');
  #key securityDefinitions => (isa => 'Swagger::Schema::Security');
  #key security => (isa => 'ArrayRef[Str]');
  array tags => (isa => 'Swagger::Schema::Tag');
  key externalDocs => (isa => 'Swagger::Schema::ExternalDocumentation');    
}

package Swagger::Schema::Operation {
  use MooseX::DataModel;
  array tags => (isa => 'Str');
  key summary => (isa => 'Str');
  key description => (isa => 'Str');
  key externalDocs => (isa => 'Swagger::Schema::ExternalDocumentation');
  key operationId => (isa => 'Str');
  key consumes => (isa => 'Str'); #Must be a Mime Type
  key produces => (isa => 'Str'); #Must be a Mime Type
  #key parameters => 
  #key responses => (
  key schemes => (isa => 'Str');
  key deprecated => (isa => 'Bool');
  #key security => (isa =>
  #TODO: x-^ fields  
}

package Swagger::Schema::Response {
  use MooseX::DataModel;
  #key default => (isa =>
  #TODO: patterned fields  
}

package Swagger::Schema::ExternalDocumentation {
  use MooseX::DataModel;
  key description => (isa => 'Str');
  key url => (isa => 'Str', required => 1); #Must be in the format of a URL
}

package Swagger::Schema::Info {
  use MooseX::DataModel;
  key title => (isa => 'Str', required => 1);
  key description => (isa => 'Str');
  key termsOfService => (isa => 'Str');
  key contact => (isa => 'Swagger::Schema::Contact');
  key license => (isa => 'Swagger::Schema::Info');
  key version => (isa => 'Str');
  #TODO: x-^ extensions
}

package Swagger::Schema::License {
  use MooseX::DataModel;
  key name => (isa => 'Str', required => 1);
  key url => (isa => 'Str'); #Must be in the format of a URL
}

package Swagger::Schema::Contact {
  use MooseX::DataModel;
  key name => (isa => 'Str');
  key url => (isa => 'Str');
  key email => (isa => 'Str');
}
