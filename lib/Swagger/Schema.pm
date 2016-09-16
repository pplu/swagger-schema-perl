use Moose::Util::TypeConstraints;

coerce 'Swagger::Schema::Parameter',
  from 'HashRef',
   via {
     if      (exists $_->{ in } and $_->{ in } eq 'body') {
       return Swagger::Schema::BodyParameter->new($_);
     } elsif ($_->{ '$ref' }) {
       return Swagger::Schema::RefParameter->new($_);
     } else {
       return Swagger::Schema::OtherParameter->new($_);
     }
   };

package Swagger::Schema {
  our $VERSION = '0.02';
  #ABSTRACT: Object model for Swagger schema files
  use MooseX::DataModel;

  key swagger => (isa => enum([ '2.0' ]), required => 1);
  key info => (isa => 'Swagger::Schema::Info', required => 1);
  key host => (isa => 'Str'); #MAY contain a port
  key basePath => (isa => subtype(as 'Str', where { $_ =~ /^\// }));
  array schemes => (isa => enum([ 'http', 'https', 'ws', 'wss']));
  array consumes => (isa => 'Str'); #Str must be mime type: https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#mimeTypes
  array produces => (isa => 'Str');
  object paths => (isa => 'Swagger::Schema::Path', required => 1);
  object definitions => (isa => 'Swagger::Schema::Schema');
  object parameters => (isa => 'Swagger::Schema::Parameter');
  object responses => (isa => 'Swagger::Schema::Response');
  #key securityDefinitions => (isa => 'Swagger::Schema::Security');
  #key security => (isa => 'ArrayRef[Str]');
  array tags => (isa => 'Swagger::Schema::Tag');
  key externalDocs => (isa => 'Swagger::Schema::ExternalDocumentation');    
}

package Swagger::Schema::Path {
  use MooseX::DataModel;
  key get => (isa => 'Swagger::Schema::Operation');
  key put => (isa => 'Swagger::Schema::Operation');
  key post => (isa => 'Swagger::Schema::Operation');
  key delete => (isa => 'Swagger::Schema::Operation');
  key options => (isa => 'Swagger::Schema::Operation');
  key head => (isa => 'Swagger::Schema::Operation');
  key patch => (isa => 'Swagger::Schema::Operation');
  #array parameters => (isa => 'Swagger::Schema::Parameter|Swagger::Schema::Ref');
}

package Swagger::Schema::Tag {
  use MooseX::DataModel;
  key name => (isa => 'Str');
  key description => (isa => 'Str');
  key externalDocs => (isa => 'Swagger::Schema::ExternalDocumentation');
}

enum 'Swagger::Schema::ParameterTypes',
     [qw/string number integer boolean array file object/];

package Swagger::Schema::Schema {
  use MooseX::DataModel;

  key ref => (isa => 'Str', location => '$ref');

  key type => (isa => 'Swagger::Schema::ParameterTypes');
  key format => (isa => 'Str');
  key allowEmptyValue => (isa => 'Bool');
  #array items
  key collectionFormat => (isa => 'Str');
  key default => (isa => 'Any');
  key maximum => (isa => 'Int');
  key exclusiveMaximum => (isa => 'Int');
  key minimum => (isa => 'Int');
  key exclusiveMinumum => (isa => 'Int');
  key maxLength => (isa => 'Int');
  key minLength => (isa => 'Int');
  key pattern => (isa => 'Str');
  key maxItems => (isa => 'Int');
  key minItems => (isa => 'Int');
  key uniqueItems => (isa => 'Bool');
  array enum => (isa => 'Any');
  key multipleOf => (isa => 'Num');
  #x-^ patterned fields

  key items => (isa => 'Swagger::Schema::Schema');
  #allOf
  object properties => (isa => 'Swagger::Schema::Schema');
  #additionalProperties
  key readOnly => (isa => 'Bool');
  #key xml => (isa => 'Swagger::Schema::XML');
  key externalDocs => (isa => 'Swagger::Schema::ExternalDocumentation');
  key example => (isa => 'Any');

  no MooseX::DataModel;
}

package Swagger::Schema::Parameter {
  use MooseX::DataModel;
  key name => (isa => 'Str');
  key in => (isa => 'Str');
  key description => (isa => 'Str');
  key required => (isa => 'Bool');
}

package Swagger::Schema::RefParameter {
  use MooseX::DataModel;
  extends 'Swagger::Schema::Parameter';
  key 'ref' => (isa => 'Str', location => '$ref');
}

package Swagger::Schema::BodyParameter {
  use MooseX::DataModel;
  extends 'Swagger::Schema::Parameter';
  key schema => (isa => 'Swagger::Schema::Schema', required => 1);
}

package Swagger::Schema::OtherParameter {
  use MooseX::DataModel;
  extends 'Swagger::Schema::Parameter';

  key type => (isa => 'Swagger::Schema::ParameterTypes', required => 1);
  key format => (isa => 'Str');
  key allowEmptyValue => (isa => 'Bool');
  #array items
  key collectionFormat => (isa => 'Str');
  key default => (isa => 'Any');
  key maximum => (isa => 'Int');
  key exclusiveMaximum => (isa => 'Int');
  key minimum => (isa => 'Int');
  key exclusiveMinumum => (isa => 'Int');
  key maxLength => (isa => 'Int');
  key minLength => (isa => 'Int');
  key pattern => (isa => 'Str');
  key maxItems => (isa => 'Int');
  key minItems => (isa => 'Int');
  key uniqueItems => (isa => 'Bool');
  array enum => (isa => 'Any');
  key multipleOf => (isa => 'Num');
  #x-^ patterned fields

  no MooseX::DataModel;
}

package Swagger::Schema::Operation {
  use MooseX::DataModel;
  array tags => (isa => 'Str');
  key summary => (isa => 'Str');
  key description => (isa => 'Str');
  key externalDocs => (isa => 'Swagger::Schema::ExternalDocumentation');
  key operationId => (isa => 'Str');
  array consumes => (isa => 'Str'); #Must be a Mime Type
  array produces => (isa => 'Str'); #Must be a Mime Type
  array parameters => (isa => 'Swagger::Schema::Parameter');
  object responses => (isa => 'Swagger::Schema::Response');
  key schemes => (isa => 'Str');
  key deprecated => (isa => 'Bool');
  #key security => (isa =>
  #TODO: x-^ fields  
}

package Swagger::Schema::Response {
  use MooseX::DataModel;
  key description => (isa => 'Str');
  key schema => (isa => 'Swagger::Schema::Parameter');
  object headers => (isa => 'Swagger::Schema::Header');
  #key examples => (isa => '');
  #TODO: patterned fields  
}

package Swagger::Schema::Header {
  use MooseX::DataModel;
  key description => (isa => 'Str');
  key type => (isa => 'Str', required => 1);
  key format => (isa => 'Str');
  object items => (isa => 'HashRef');
  key collectionFormat => (isa => 'Str');
  key default => (isa => 'Any');
  key maximum => (isa => 'Int');
  key exclusiveMaximum => (isa => 'Int');
  key minimum => (isa => 'Int');
  key exclusiveMinumum => (isa => 'Int');
  key maxLength => (isa => 'Int');
  key minLength => (isa => 'Int');
  key pattern => (isa => 'Str');
  key maxItems => (isa => 'Int');
  key minItems => (isa => 'Int');
  key uniqueItems => (isa => 'Bool');
  array enum => (isa => 'Any');
  key multipleOf => (isa => 'Num');

  no MooseX::DataModel;
}

package Swagger::Schema::ExternalDocumentation {
  use MooseX::DataModel;
  key description => (isa => 'Str');
  key url => (isa => 'Str', required => 1); #Must be in the format of a URL
}

package Swagger::Schema::Info {
  use MooseX::DataModel;
  key title => (isa => 'Str', required => 1);
  key description => (isa => 'Str'); #Can contain GFM
  key termsOfService => (isa => 'Str');
  key contact => (isa => 'Swagger::Schema::Contact');
  key license => (isa => 'Swagger::Schema::License');
  key version => (isa => 'Str', required => 1);
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
