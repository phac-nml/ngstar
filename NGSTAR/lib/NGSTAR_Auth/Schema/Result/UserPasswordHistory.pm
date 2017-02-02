use utf8;
package NGSTAR_Auth::Schema::Result::UserPasswordHistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::UserPasswordHistory

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

=head1 TABLE: C<user_password_history>

=cut

__PACKAGE__->table("user_password_history");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 password_history_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "password_history_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</password_history_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "password_history_id");

=head1 RELATIONS

=head2 password_history

Type: belongs_to

Related object: L<NGSTAR_Auth::Schema::Result::PasswordHistory>

=cut

__PACKAGE__->belongs_to(
  "password_history",
  "NGSTAR_Auth::Schema::Result::PasswordHistory",
  { password_history_id => "password_history_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<NGSTAR_Auth::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "NGSTAR_Auth::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-10-11 14:41:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TC0Y5kob0rcTnO2mKyeQ4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
