use utf8;
package NGSTAR_Auth::Schema::Result::PasswordHistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::PasswordHistory

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

=head1 TABLE: C<password_history>

=cut

__PACKAGE__->table("password_history");

=head1 ACCESSORS

=head2 password_history_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 used_password

  data_type: 'text'
  is_nullable: 1

=head2 password_timestamp

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "password_history_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "used_password",
  { data_type => "text", is_nullable => 1 },
  "password_timestamp",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</password_history_id>

=back

=cut

__PACKAGE__->set_primary_key("password_history_id");

=head1 RELATIONS

=head2 user_password_histories

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::UserPasswordHistory>

=cut

__PACKAGE__->has_many(
  "user_password_histories",
  "NGSTAR_Auth::Schema::Result::UserPasswordHistory",
  { "foreign.password_history_id" => "self.password_history_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: many_to_many

Composing rels: L</user_password_histories> -> user

=cut

__PACKAGE__->many_to_many("users", "user_password_histories", "user");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-10-11 14:41:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fgH6U4EnUt19Wr10m7tdaA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->add_columns(
    'used_password' => {
        passphrase       => 'rfc2307',
        passphrase_class => 'BlowfishCrypt',
        passphrase_args  => {
            cost        => 14,
            salt_random => 20,
        },
        passphrase_check_method => 'check_password',
    },
);

__PACKAGE__->meta->make_immutable;
1;
