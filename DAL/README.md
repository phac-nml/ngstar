# DAL Module

**DAL** is short for Data Access Layer, it is a separate Perl module that contains queries to the database. Instead of using plain SQL to query the database, an ORM called DBIx::Class is used. This layer is independent of Catalyst (so that the code can easily be re-used by other programs without having a Catalyst framework dependency and in order to have separation of concerns).

## Installation

To install the **DAL** module, change directory to the top level **DAL** directory and run the following commands:

    perl Makefile.PL
    make
    make install

This will install the **DAL** module in the **/usr/local/share/perl/x.y.z/** directory (or similar). Business logic layer code will look for **DAL** modules in the **/usr/local/share/perl/x.y.z/** directory.

## Creating a New DAL Module

When adding a new **.pm** you must add it as a new entry to **MANIFEST**, which is located in the top level **DAL** directory.

For example, if you created a new module called **Dao.pm** in **DAL/lib/DAL/** then you would add the following line to the end of the **MANIFEST** file:

    lib/DAL/Dao.pm

Then, run the following commands to install an updated **DAL** module in the **/usr/local/share/perl/x.y.z/** directory:

    perl Makefile.PL
    make
    make install

## Calling the Data Access Layer

From the business logic layer, you can to make calls to the data access layer like so:

    ...
    use DAL::Dao;
    ...
    sub new{
        my $class = shift;
        my $self = {
            _dao => DAL::Dao->new(),
        };
        bless $self, $class;
        return $self;
    }

    sub _add_allele{
        my ($self, $allele_type, $allele_sequence) = @_;
        $self->{_dao}->insert_allele($allele_type, $allele_sequence);
    }
    ...
