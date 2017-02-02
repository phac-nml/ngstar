use utf8;
package NGSTAR_Auth::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email_address

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=head2 institution_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 institution_city

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 institution_country

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 time_since_password_change

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 lockout_status

  data_type: 'tinyint'
  is_nullable: 1

=head2 lockout_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "email_address",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
  "institution_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "institution_city",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "institution_country",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "time_since_password_change",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "lockout_status",
  { data_type => "tinyint", is_nullable => 1 },
  "lockout_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email_address_UNIQUE>

=over 4

=item * L</email_address>

=back

=cut

__PACKAGE__->add_unique_constraint("email_address_UNIQUE", ["email_address"]);

=head2 C<username>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username", ["username"]);

=head1 RELATIONS

=head2 lockout

Type: belongs_to

Related object: L<NGSTAR_Auth::Schema::Result::TblLockout>

=cut

__PACKAGE__->belongs_to(
  "lockout",
  "NGSTAR_Auth::Schema::Result::TblLockout",
  { lockout_id => "lockout_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 password_reset_requests

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::PasswordResetRequest>

=cut

__PACKAGE__->has_many(
  "password_reset_requests",
  "NGSTAR_Auth::Schema::Result::PasswordResetRequest",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_password_histories

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::UserPasswordHistory>

=cut

__PACKAGE__->has_many(
  "user_password_histories",
  "NGSTAR_Auth::Schema::Result::UserPasswordHistory",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "NGSTAR_Auth::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 password_histories

Type: many_to_many

Composing rels: L</user_password_histories> -> password_history

=cut

__PACKAGE__->many_to_many(
  "password_histories",
  "user_password_histories",
  "password_history",
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-10-11 14:41:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ejcpivS9tD4Zqvfk7wm5KQ

# These lines were loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NGSTAR_Auth::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email_address

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=head2 institution_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 institution_city

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 institution_country

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "email_address",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
  "institution_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "institution_city",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "institution_country",
  { data_type => "varchar", is_nullable => 1, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email_address_UNIQUE>

=over 4

=item * L</email_address>

=back

=cut

__PACKAGE__->add_unique_constraint("email_address_UNIQUE", ["email_address"]);

=head2 C<username>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username", ["username"]);

=head1 RELATIONS

=head2 password_reset_requests

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::PasswordResetRequest>

=cut

__PACKAGE__->has_many(
  "password_reset_requests",
  "NGSTAR_Auth::Schema::Result::PasswordResetRequest",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "NGSTAR_Auth::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-01-29 17:46:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AR1Mw8eGJH8Ld806OQSF4Q
# These lines were loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NGSTAR_Auth::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email_address

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "email_address",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email_address_UNIQUE>

=over 4

=item * L</email_address>

=back

=cut

__PACKAGE__->add_unique_constraint("email_address_UNIQUE", ["email_address"]);

=head2 C<username>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username", ["username"]);

=head1 RELATIONS

=head2 password_reset_requests

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::PasswordResetRequest>

=cut

__PACKAGE__->has_many(
  "password_reset_requests",
  "NGSTAR_Auth::Schema::Result::PasswordResetRequest",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "NGSTAR_Auth::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-06-15 16:54:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lBszE2HjTccbLJNKu+Zi/w
# These lines were loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NGSTAR_Auth::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email_address

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "email_address",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email_address_UNIQUE>

=over 4

=item * L</email_address>

=back

=cut

__PACKAGE__->add_unique_constraint("email_address_UNIQUE", ["email_address"]);

=head2 C<username>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username", ["username"]);

=head1 RELATIONS

=head2 password_reset_requests

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::PasswordResetRequest>

=cut

__PACKAGE__->has_many(
  "password_reset_requests",
  "NGSTAR_Auth::Schema::Result::PasswordResetRequest",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "NGSTAR_Auth::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-06-11 17:28:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U/sMFbjWXkzVhan2ufbD4A
# These lines were loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NGSTAR_Auth::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NGSTAR_Auth::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<username>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username", ["username"]);

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<NGSTAR_Auth::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "NGSTAR_Auth::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-07-30 16:40:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hHgG8/xI/dDVlRP5YDY5uw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->add_columns(
    'password' => {
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
# End of lines loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/usr/local/share/perl/5.18.2/NGSTAR_Auth/Schema/Result/User.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
