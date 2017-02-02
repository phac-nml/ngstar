# BusinessLogic Module

**BusinessLogic** is a separate Perl module that houses any business logic (such as logic that does BLAST queries and allelic profile queries). It acts as the BusinessLogic layer and is independent of Catalyst (so that the code can easily be re-used by other programs without having a Catalyst framework dependency and in order to have separation of concerns).

## Installation

To install the **BusinessLogic** module, change directory to the top level **BusinessLogic** directory and run the following commands:

    perl Makefile.PL
    make
    make install

This will install the **BusinessLogic** module in the **/usr/local/share/perl/x.y.z/** directory (or similar). The NGSTAR Catalyst project will look for **BusinessLogic** modules in the **/usr/local/share/perl/x.y.z/** directory.

## Creating a New BusinessLogic Module

When adding a new **.pm** file you must add it as a new entry to **MANIFEST**, which is located in the top level **Businesslogic** directory.

For example, if you created a new module called **AddAllele.pm** in **BusinessLogic/lib/BusinessLogic/** then you would add the following line to the end of the **MANIFEST** file:

    lib/BusinessLogic/AddAllele.pm

Then, run the following commands to install an updated **BusinessLogic** module in the **/usr/local/share/perl/x.y.z/** directory:

    perl Makefile.PL
    make
    make install

## Creating a Catalyst Adaptor

You will need a way to call the new **BusinessLogic** module from the NGSTAR Catalyst project. To do this, we utilize an Adaptor (design pattern).

Create a new adaptor by changing directory to **NGSTAR/** and running the following command:

    script/ngstar_create.pl model NameOfModule Adaptor BusinessLogic::NameOfModule new

For example, if you created a new module called **AddAllele.pm** in **BusinessLogic/lib/BusinessLogic/**, you would run the following command:

    script/ngstar_create.pl model AddAllele Adaptor BusinessLogic::AddAllele new

This will create a file called **AddAllele.pm** in the **NGSTAR/lib/NGSTAR/Model/** directory with the following contents:

    package NGSTAR::Model::AddAllele;
    use strict;
    use warnings;
    use base 'Catalyst::Model::Adaptor';

    __PACKAGE__->config(
        class       => 'BusinessLogic::AddAllele',
        constructor => 'new',
    );

    1;

You will now be able to call your business logic code from the NGSTAR Catalyst Controller like so:

    sub add :Local{
        my ($self, $c) = @_;

        my $form = AlleleDatabase::Form::AddAlleleForm->new;
        $c->stash(template => 'allele/AddAlleleForm.tt2', form => $form);

        $form->process(params => $c->request->params);
        return unless $form->validated;

        my $allele_type = $c->request->params->{allele_type};
        my $allele_sequence = $c->request->params->{allele_sequence};

        my $obj = $c->model('AddAllele');
        $obj->_add_allele($allele_type, $allele_sequence);

        $c->response->body('Allele successfully added!');
    }
