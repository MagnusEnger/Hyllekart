package Hyllekart::Schema::Result::UserLibrary;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Hyllekart::Schema::Result::UserLibrary

=cut

__PACKAGE__->table("user_libraries");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 library_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "library_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("user_id", "library_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Hyllekart::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Hyllekart::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 library

Type: belongs_to

Related object: L<Hyllekart::Schema::Result::Library>

=cut

__PACKAGE__->belongs_to(
  "library",
  "Hyllekart::Schema::Result::Library",
  { id => "library_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2013-02-05 12:39:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:neP3DUKBUJUNHgnIUCEHbQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
