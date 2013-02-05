package Hyllekart::Schema::Result::Map;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Hyllekart::Schema::Result::Map

=cut

__PACKAGE__->table("maps");

=head1 ACCESSORS

=head2 map_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 library_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "map_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "library_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("map_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2013-02-05 12:42:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iXrxZk+u5q+FgIL3YpYIOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
