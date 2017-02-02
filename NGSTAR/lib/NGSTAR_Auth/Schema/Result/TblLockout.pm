use utf8;
package NGSTAR_Auth::Schema::Result::TblLockout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::TblLockout

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<tbl_lockout>

=cut

__PACKAGE__->table("tbl_lockout");

=head1 ACCESSORS

=head2 lockout_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 failed_attempt_count

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 first_failed_attempt_timestamp

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 lockout_timestamp

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "lockout_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "failed_attempt_count",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "first_failed_attempt_timestamp",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "lockout_timestamp",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</lockout_id>

=back

=cut

__PACKAGE__->set_primary_key("lockout_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<username_UNIQUE>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username_UNIQUE", ["username"]);

=head1 RELATIONS

=head2 users

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "NGSTAR_Auth::Schema::Result::User",
  { "foreign.lockout_id" => "self.lockout_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-10-11 14:41:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gNSB8Q73YZlwLBpZr2ub4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
