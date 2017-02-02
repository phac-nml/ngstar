#!/usr/bin/env perl
use strict;
use warnings;

use DBI;
use Getopt::Long;
use Pod::Usage;

my $host="localhost";
my $user="root";
my $password;
my $port=3000;
my $help=0;

GetOptions("h|host=s" => \$host,
           "u|user=s" => \$user,
           "p|password=s" => \$password,
           "port=i" => \$port,
           "help|?" => \$help);

pod2usage(-verbose => 1) if $help;

my $dsn="dbi:mysql:;host=$host;port=$port";
my $dbh=DBI->connect($dsn, $user, $password);

open(FILE, '<', $ARGV[0]) or die 'Could not open file: ' . $!;

undef $/;
my @sql = split(/;\n/, <FILE>);

foreach my $sql_statement (@sql) {
    chomp;
    next if $sql_statement =~ /^$/;
	$dbh->do($sql_statement);
}

__END__

=head1 NAME

execute_sql.pl - run sql statements

=head1 SYNOPSIS

execute_sql.pl [options] (sql file)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<-h|--host>

DB host to connect to.

=item B<-u|--user>

DB user.

=item B<-p|--password>

DB password.

=item <--port>

DB port

=back

=cut
