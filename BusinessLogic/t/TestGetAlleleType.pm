package TestGetAlleleType;

use base 'Test::Class';
use BusinessLogic::GetAlleleType;
use Test::More;

my $tbpb1 = "CGTCTGAAAACGGTAAGCTGACCACGGTTTTGGATGCGGTTGAATTGACACTAAACGGCAAGGAAATCAAAAATCTCGACAACTTCAGCAATGCCGCCCAACTGGTTGTCGACGGCATTATGATTCCGCTCCTGCCCACCGAAAGCGGGAACGGTCAGGTAGATAAAGGTAAAAACGGCGGAACAGCCTTTACCCGCGAATTTGTCCACACGCCGGAAAGCGATGAAAAAAACACCCAAGCCCAAACAGGCGCGGGCGGCACGCAAACCGCTTCGGGTGCGGCGGGCGTTAACGGCGGGCGGGCAGGAACAAAAACCTATGAAGTCAAAGTCTGCTGTTCCAACCTCAATTATCTGAAATACGGGTTGCTGACACGTGAAAACAACAATT";

my $por2 = "TTGAAGGGCGGCTTCGGTACCATCCGCGCCGGTAGCCTGAACAGCCCCCTGAAAAACACCGGCGCCAACGTCAATGCTTGGGAATCCGGCAAATTTACCGGCAATGTGCTGGAAATCAGCAGAATGGCCCAACGGGAACACCGCTACCTGTCCGTACGCTACGATTCTCCCGAATTTGCCGGCTTCAGCGGCAGCGTACAATACGCACCTAAAGACAATTCAGGCTCAAACGGCGAATCTTACCACGTTGGCTTGAACTACCGAAACAACGGCTTCTTCGCACAATACGCCGGCTTGTTCCAAAGATACGGCGAAGGCACTAAAAAAATGGAAGGATATTCATATAATATCCCCAGTTTGTTTGTTGAAAAACTGCAAGTTCACCGTTTGGTCGGCGGTTACGACAATAATGCCCTGTACGCCTCCGTAGCCGCACAACAACAAGATGCCAAATTGTATCAAAATCAATTAGTGCGTGATAATTCGCACA";

my $gki3 = "AACCTTAATTGGAAGGAAACTCAAGAAGTTGGTTCCGTTATTGAAAAAGAATTAGGTATTCCTTTTGCCATTGACAATGATGCTAATGTTGCTGCTCTTGGTGAACGTTGGGTAGGTGCTGGTGAAAATAACCCAGATGTGGTCTTCATGACACTTGGAACAGGTGTCGGTGGAGGCATTATTGCTGATGGTAACCTGATTCATGGTGTTGCAGGAGCAGGTGGTGAAATCGGCCACATGATTGTTGAGCCAGAAAATGGTTTTGCCTGTACTTGTGGGTCACATGGTTGTCTAGAAACAGTGGCTTCAGCAACAGGAGTTGTCAAGGTGGCACGCTTATTGGCAGAAGCCTACGAAGGAGATTCAGCTATCAAAGCAGCCATTGACAATGGCGAAGGTGTTACCAGTAAAGATATTTTCATGGCAGCTGAAGCAGGGGATTCCTTTGCTGATTCTGTTGTGGAAAAGGTTGGTTACTACCTTGGTCTTGCGTCAGCA";

my $muri4 = "GCATGCAATACCGCAACAGCGGTGGCTTGGGAAGAAGTAAAAGCAGCTTTAGATATTCCTGTTTTAGGAGTTGTCTTACCGGGGGCAAGCGCAGCTATTAAATCAACGACAAAAGGCCAGGTTGGGGTCATCGGAACCCCAATGACAGTGGCTTCAGACATTTATCGCAAAAAAATCCAGCTATTAGCACCATCTATTCAAGTAAGGAGTCTTGCTTGCCCGAAGTTTGTACCGATTGTGGAATCAAATGAGATGTGTTCGAGTATAGCTAAAAAAATAGTTTATGACAGTCTAGCACCATTAGTCGGTAAAATAGATACCCTTGTACTAGGATGTACTCACTATCCCTTGTTACGACCAATTATCCAAAATGTTATGGGGCCATCTGTTAAGCTGATTGACAGTGGAGCAGAATGCGTCCGAGATATCTCTGTCTTA";

my $recp5 = "CCTATGGCCTATGTTCTTTGGAATCACTTCATGAACATCAATCCCAAAACAAGCCGTAATTGGTCAAACAGAGACCGTTTTATCCTATCAGCAGGTCATGGAAGTGCCATGCTTTATAGCTTGTTGCATTTAGCAGGTTATGATTTATCTGTAGAAGATTTAAAGAACTTCCGTCAATGGGGATCTAAAACACCAGGTCACCCAGAAGTGAACCACACAGACGGTGTCGAAGCAACCACAGGACCTCTTGGTCAAGGGATCGCAAATGCCGTTGGTATGGCCATGGCAGAAGCTCACCTAGCAGCTAAATTTAACAAACCAGGCTTTGACATCGTTGATCACTACACATTTGCTTTGAATGGTGACGGTGACCTTATGGAAGGGGTCAGCCAAGAAGCAGCAAGTATGGCAGGACATTTAAAACTTGGGAAATTGGTCTTGCTATATGATTCAAACGAC";

my $xpt6 = "GGAGAGAATATTCTAAAGGTAGATAATTTTTTAACTCATCAAGTTGATTACCGGTTGATGAAAGCAATTGGTAAAGTGTTTGCTCAAAAATATGCTGAGGCTGGCATTACAAAAGTGGTTACAATCGAAGCTTCAGGTATTGCACCAGCCGTATACGCTGCAGAAGCAATGGATGTTCCTATGATTTTTGCGAAAAAACATAAAAACATTACCATGACAGAAGGCATTTTGACAGCAGAAGTTTATTCTTTCACTAAACAAGTGACGAGCACGGTGTCTATCGCTGGTAAATTCCTATCTAAAGAAGACAAGGTTTTGATTATTGATGACTTTTTAGCTAATGGTCAGGCAGCCAAAGGTTTGATCGAGATTATTGGTCAAGCAGGGGCACAAGTCGTCGGCGTTGGTATTGTGATTGAGAAATCTTTCCAAGATGGTCGTCGATTGATT";

my $tbpbpart1 = "CGTCTGAAAACGGTAAGCTGACCACGGTTTTGGATGCGGTTGAATTGACACTAAACGGCAAGGAAATCAAAAATCTCGACAACTTCAGCAATGCCGCCC";

my $tbpbpart2 = "TCAAAAATCTCGACAACTTCAGCAATGCCGCCCAACTGGTTGTCGACGGCATTATGATTCCGCTCCTGCCCACCGAAAGCGGGAACGGTCAGGTAGATA";

my $tbpbpart3 = "TGTCGACGGCATTATGATTCCGCTCCTGCCCACCGAAAGCGGGAACGGTCAGGTAGATAAAGGTAAAAACGGCGGAACAGCCTTTACCCGCGAATTTGT";

my $tbpbpart4 = "CGCGGGCGGCACGCAAACCGCTTCGGGTGCGGCGGGCGTTAACGGCGGGCGGGCAGGAACAAAAACCTATGAAGTCAAAGTCTGCTGTTCCAACCTCAA";

my $tbpbpart5 = "ACGGCGGGCGGGCAGGAACAAAAACCTATGAAGTCAAAGTCTGCTGTTCCAACCTCAATTATCTGAAATACGGGTTGCTGACACGTGAAAACAACAATT";

my $porpart1 = "TAGCCTGAACAGCCCCCTGAAAAACACCGGCGCCAACGTCAATGCTTGGGAATCCGGCAAATTTACCGGCAATGTGCTGGAAATCAGCAGAATGGCCCAACGGGAACACCGCTACCTGTCCGTACGCTACGATTCTCCCGAATTTGCCGGCTTCAGCGGC";

my $porpart2 = "GTACAATACGCACCTAAAGACAATTCAGGCTCAAACGGCGAATCTTACCACGTTGGCTTGAACTACCGAAACAACGGCTTCTTCGCACAATACGCCGGCTTGTTCCAAAGATACGGCGAAGGCACTAAAAAAATGGAAGGATATTCATATAATATCCCCAGTTTGTTTGTTGAAAAAC";

my $porpart3 = "GAAAAACTGCAAGTTCACCGTTTGGTCGGCGGTTACGACAATAATGCCCTGTACGCCTCCGTAGCCGCACAACAACAAGATGCCAAATTGTATCAAAATCAATTAGTGCGT";

my $gkipart1 = "AACCTTAATTGGAAGGAAACTCAAGAAGTTGGTTCCGTTATTGAAAAAGAATTAGGTATTCCTTTTGCCATTGACAATGATGCTAATGTTGCTGCTCTTGGTGAACGTTGGGTAGGTGCTG";

my $muripart1 = "GGCCAGGTTGGGGTCATCGGAACCCCAATGACAGTGGCTTCAGACATTTATCGCAAAAAAATCCAGCTATTAGCACCATCTATTCAAGTAAGGAGTCTTGCTTGCCCGAAGTTTGTACCGATTGTGGAATCAAATGA";

my $recppart1 = "TGGCAGAAGCTCACCTAGCAGCTAAATTTAACAAACCAGGCTTTGACATCGTTGATCACTACACATTTGCTTTGAATGGTGACGGTGACCTTATGGAAGGGGTCAGCCAAGAAGCAGCAAGTATGGCAGGACATTTAAAACTTGGGAA";

my $xptpart1 = "TGGTCAGGCAGCCAAAGGTTTGATCGAGATTATTGGTCAAGCAGGGGCACAAGTCGTCGGCGTTGGTATTGTGATTGAGAAATCTTTCCAAGATGGTCGTCGATTGATT";

my $tbpblong = "ATCGAGATCGATGAGTAGCGAGTGAGATCGCGTCTGAAAACGGTAAGCTGACCACGGTTTTGGATGCGGTTGAATTGACACTAAACGGCAAGGAAATCAAAAATCTCGACAACTTCAGCAATGCCGCCCAACTGGTTGTCGACGGCATTATGATTCCGCTCCTGCCCACCGAAAGCGGGAACGGTCAGGTAGATAAAGGTAAAAACGGCGGAACAGCCTTTACCCGCGAATTTGTCCACACGCCGGAAAGCGATGAAAAAAACACCCAAGCCCAAACAGGCGCGGGCGGCACGCAAACCGCTTCGGGTGCGGCGGGCGTTAACGGCGGGCGGGCAGGAACAAAAACCTATGAAGTCAAAGTCTGCTGTTCCAACCTCAATTATCTGAAATACGGGTTGCTGACACGTGAAAACAACAATTATCGAGAGAGTAGCCCCCCGATGACGTCGAGT";

my $porlong = "ATCGAGGGGGGGGGAAAGTGACGTTGAAGGGCGGCTTCGGTACCATCCGCGCCGGTAGCCTGAACAGCCCCCTGAAAAACACCGGCGCCAACGTCAATGCTTGGGAATCCGGCAAATTTACCGGCAATGTGCTGGAAATCAGCAGAATGGCCCAACGGGAACACCGCTACCTGTCCGTACGCTACGATTCTCCCGAATTTGCCGGCTTCAGCGGCAGCGTACAATACGCACCTAAAGACAATTCAGGCTCAAACGGCGAATCTTACCACGTTGGCTTGAACTACCGAAACAACGGCTTCTTCGCACAATACGCCGGCTTGTTCCAAAGATACGGCGAAGGCACTAAAAAAATGGAAGGATATTCATATAATATCCCCAGTTTGTTTGTTGAAAAACTGCAAGTTCACCGTTTGGTCGGCGGTTACGACAATAATGCCCTGTACGCCTCCGTAGCCGCACAACAACAAGATGCCAAATTGTATCAAAATCAATTAGTGCGTGATAATTCGCACAAAAAAAAAATACGAGACGATGACGTCGAGATGCGAGTGCAGA";

my $gkilong = "AGAGTTTTTTTTTGGCCCCCCCCCCCAGACCCAAAAAAAAAAAAAAAAAAAAAAAACCTTAATTGGAAGGAAACTCAAGAAGTTGGTTCCGTTATTGAAAAAGAATTAGGTATTCCTTTTGCCATTGACAATGATGCTAATGTTGCTGCTCTTGGTGAACGTTGGGTAGGTGCTGGTGAAAATAACCCAGATGTGGTCTTCATGACACTTGGAACAGGTGTCGGTGGAGGCATTATTGCTGATGGTAACCTGATTCATGGTGTTGCAGGAGCAGGTGGTGAAATCGGCCACATGATTGTTGAGCCAGAAAATGGTTTTGCCTGTACTTGTGGGTCACATGGTTGTCTAGAAACAGTGGCTTCAGCAACAGGAGTTGTCAAGGTGGCACGCTTATTGGCAGAAGCCTACGAAGGAGATTCAGCTATCAAAGCAGCCATTGACAATGGCGAAGGTGTTACCAGTAAAGATATTTTCATGGCAGCTGAAGCAGGGGATTCCTTTGCTGATTCTGTTGTGGAAAAGGTTGGTTACTACCTTGGTCTTGCGTCAGCATAGTGAGTGACGAGTGAGAAAAAAAAAAAAAAAA";

my $murilong = "AGTGAGCGGCGGTGTGAGAGCGAAAAGGGTGGCATGCAATACCGCAACAGCGGTGGCTTGGGAAGAAGTAAAAGCAGCTTTAGATATTCCTGTTTTAGGAGTTGTCTTACCGGGGGCAAGCGCAGCTATTAAATCAACGACAAAAGGCCAGGTTGGGGTCATCGGAACCCCAATGACAGTGGCTTCAGACATTTATCGCAAAAAAATCCAGCTATTAGCACCATCTATTCAAGTAAGGAGTCTTGCTTGCCCGAAGTTTGTACCGATTGTGGAATCAAATGAGATGTGTTCGAGTATAGCTAAAAAAATAGTTTATGACAGTCTAGCACCATTAGTCGGTAAAATAGATACCCTTGTACTAGGATGTACTCACTATCCCTTGTTACGACCAATTATCCAAAATGTTATGGGGCCATCTGTTAAGCTGATTGACAGTGGAGCAGAATGCGTCCGAGATATCTCTGTCTTAAAAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGGGGGTTGTG";

my $recplong = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCTATGGCCTATGTTCTTTGGAATCACTTCATGAACATCAATCCCAAAACAAGCCGTAATTGGTCAAACAGAGACCGTTTTATCCTATCAGCAGGTCATGGAAGTGCCATGCTTTATAGCTTGTTGCATTTAGCAGGTTATGATTTATCTGTAGAAGATTTAAAGAACTTCCGTCAATGGGGATCTAAAACACCAGGTCACCCAGAAGTGAACCACACAGACGGTGTCGAAGCAACCACAGGACCTCTTGGTCAAGGGATCGCAAATGCCGTTGGTATGGCCATGGCAGAAGCTCACCTAGCAGCTAAATTTAACAAACCAGGCTTTGACATCGTTGATCACTACACATTTGCTTTGAATGGTGACGGTGACCTTATGGAAGGGGTCAGCCAAGAAGCAGCAAGTATGGCAGGACATTTAAAACTTGGGAAATTGGTCTTGCTATATGATTCAAACGACCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC";

my $xptlong = "GGGGGGGGGGGGGGCCCCCCCCCCCCCAAAAAAAAGGGGGGGGGAGAGAATATTCTAAAGGTAGATAATTTTTTAACTCATCAAGTTGATTACCGGTTGATGAAAGCAATTGGTAAAGTGTTTGCTCAAAAATATGCTGAGGCTGGCATTACAAAAGTGGTTACAATCGAAGCTTCAGGTATTGCACCAGCCGTATACGCTGCAGAAGCAATGGATGTTCCTATGATTTTTGCGAAAAAACATAAAAACATTACCATGACAGAAGGCATTTTGACAGCAGAAGTTTATTCTTTCACTAAACAAGTGACGAGCACGGTGTCTATCGCTGGTAAATTCCTATCTAAAGAAGACAAGGTTTTGATTATTGATGACTTTTTAGCTAATGGTCAGGCAGCCAAAGGTTTGATCGAGATTATTGGTCAAGCAGGGGCACAAGTCGTCGGCGTTGGTATTGTGATTGAGAAATCTTTCCAAGATGGTCGTCGATTGATTTTTTTTTTTTTTAAAAAAAAAAAAGGGGGGGGGGGGGG";

my $gkinotfound = "AACCTTAATTGGAAGGAAACTCAAGAAGTTGGTTCCGTTATTGAAAAAGAATTAGGTATTCCTTTTGCCATTGACAATGATGCTAATGTTGCTGCTCTTGGTGAACGTTGGGTAGGTGCTGGTGAAAATAACCCAGATGTGGTCTTCATGACACTTGGAACAGGTGTCGGTGGAGGCATTATTGCTGATGGTAACCTGATTCATGGTGTTGCAGGAGCAGGTGGTCGAAATCGGCCACATGATTGTTGAGCCAGAAAATGGTTTTGCCTGTACTTGTGGGTCACATGGTTGTCTAGAAACAGTGGCTTCAGCAACAGGAGTTGTCAAGGTGGCACGCTTATTGGCAGAAGCCTACGAATGGAGATTCAGCTATCAAAGCAGCCATTGACAATGGCGAAGGTGTTACCAGTAAAGATATTTTCATGGCAGCTGAAGCAGGGGATTCCTTTGCTGATTCTGTTGTGGAAAAGAGTTGGTTACTACCTTGGTCTTGCGTCAGCA";

my $murinotfound = "GCATGCAATACCGCAACAGCGGTGGCTTGGGAAGAAGTAAAAGCAGCTTTAGATATTCCTGTTTTAGGAGTTGTCTTACCGGGGGCAAGCGCAGCTATTAAATCAACGACAAAAGGCCAGGTTGGGGTCATCGGAACCCCAATGACAGTGGCTTCAGACATTTATCGCAAAAAAATCCAGCTATTAGCACCATCTATTCAAGAAGGAGTCTTGCTTGCCCGAAGTTTGTACCGATTGTGGAATCAAATGAGATGTGTTCGAGTATAGCTAAAAAAATAGTTTATGACAGTCTAGCACCATTAGTCGGTAAAATAGATACCCTTGTACTAGGATGTACTCACTATCCCTTGTTACGACCAATTATCCAAAATGTTATGGGGCCATCTGTTAAGCTGATTGACAGTGGAGCAGAATGCGTCCGAGATATCTCTGTCTTA";

my $recpnotfound = "CCTATGGCCTATGTTCTTTGGAATCACTTCATGAACATCAATCCCAAAACAAGCCGTAATTGGTCAAACAGAGACCGTTTTATCCTATCAGCAGGTCATGGAAGTGCCATGCTTTATAGCTTGTTGCATTTAGCAGGTTATGATTTATCTGTAGAAGATTTAAAGAACTTCCGTCAATGGGGATCTAAAACACCAGGTCACCCCAGAAGTGAACCACACAGACGGTGTCGAAGCAACCACAGGACCTCTTGGTCAAGGGATCGCAAATGCCGTTGGTATGGCCATGGCAGAAGCTCACCTAGCAGCTAAATTTAACAAACCAGGCTTTGACATCGTTGATCACTACACATTTGCTTTGAATGGTGACGGTGACCTTATGGAAGGGGTCAGCCAAGAAGCAGCAAGTATGGCAGGACATTTAAAACTTGGGAAATTGGTCTTGCTATATGATTCAAACGAC";

my $repeatshort7 = "AAAATTTTCCCCGGGGAAAATTTTCCCCGGGG";

my $repeatmed8 = "AAAATTATGCTTTTTTCCCCAAAATAATTTGGGGGAGAAATATTTTTTTTCCGATGGGGGAACCCCCCCTTTTAAATGGGGCGATGACAAAAAAAAAAAAAAGGTGAGAGTCCCCCAAAAAAAAGTCGAAATCAGATGGGGGGGG";

my $repeatlong9 = "AAAAAAAAAAAGACGGGGGGAAAAATTTAGTAAAAAAAAAAAAAAAAAGCGGGGGGGGAGGGGACGTGTGCGGGGTTTTTTTTTTAGTCCCCCCCGAGAGGGTTTTTTTTTTGGGCCCCCCCCGAGTGAGAGCCCCCCCAAAAAATTGAGGGGGCAGTAAACGAGTGGGGGCCAAAAAAAAAAAAAAGTGCCCCCCAGGGGGGGGGGGGGAGGGACGGGTGAGAAAAAAAGGCCCCCCCCTAGACGGGGCAAATCGGGAGATTTTTTACCAGAGTAGCGTGAGACCCCCCCAAACGAACCCCCCATTTGGGGTTTTTTTTTGACCCCAGAGTTTTTTTTTTCCCCCCAGATTTTTTTTTCCCCCCAGATGAGATTTTTGACCCCCGAGTGACCCCCC";

my $repeatprimer10 = "GGGGGGGGGGGGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGACGGGGGGAAAAATTTAGTAAAAAAAAAAAAAAAAAGCGGGGGGGGAGGGGACGTGTGCGGGGTTTTTTTTTTAGTCCCCCCCGAGAGGGTTTTTTTTTTGGGCCCCCCCCGAGTGAGAGCCCCCCCAAAAAATTGAGGGGGCAGTAAACGAGTGGGGGCCAAAAAAAAAAAAAAGTGCCCCCCAGGGGGGGGGGGGGAGGGACGGGTGAGAAAAAAAGGCCCCCCCCTAGACGGGGCAAATCGGGAGATTTTTTACCAGAGTAGCGTGAGACCCCCCCAAACGAACCCCCCATTTGGGGTTTTTTTTTGACCCCAGAGTTTTTTTTTTCCCCCCAGATTTTTTTTTCCCCCCAGATGAGATTTTTGACCCCCGAGTGACCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCGGGGGGGGGGGGGGGGGGGAAAAAAAAAAAA";

my $invalid1 = "XYZ";
my $invalid2 = "ATCCZY-TLSDKFASD!";
my $invalid3 = "qGTCTGAAAACGGTAAGCTGACCACGGTTTTGGATGCGGTTGAATTGACACTAAACGGCAAGGAzATCAAAAATCTCGACAACTTCAGCAATGCCGCCCAACTGGTTGTCGACGGCATTATGATTCCGCTCCTGCCCACCGAAAGCGGGAACGGTCAGGTAGATAAAGGTAAAAACGG#CGGAACAGCCTTTACCCGCGAATTTGTCCACACGCCGGAAAGCGATGAAAAAAACACCCAAGCCCAAACAGGCGCGGGCGGCACGCAAACCGCTTCGGGTGCGGCGGGCGTTAACGGCGGGCGGGCAGGAACAAAAACCTATGAAyTCAAAGTCTGCTGTTCCAACCTCAATTAxTGAAATACGGGTTGCTGACACGTGAAAACAACAATT";

my $invalid4 = "GCATGCAATACCGCAACAGCGGTGGCTTGGGAAGAAGTAAAAGCAGCTTTAGATATTCCTGTTTTAGGAGTTGTCTTACCGGGGGCAAGCGCAGCTAxTAAATCAACGACAAAAGGCCAGGTTGGGGTCATCGGAACCCCAATGACAGTGGCTTCAGACATTTATCGCAAAAAAATCCAGCTATTAGCACCATCTATTCAAGTAAGGAGTCTTGCTTGCCCGAAGTTTGTACCGATTGTGGAATCAAATGAGATGTGTTCGAGTATAGCTAAAAAAATAGTTTATGACAGTCTAGCACCATTAGTCGGTAAAATAGATACCCTTGTACTAGGATGTACTCACTATCCCTTGTTACGACCAATTATCCAAAATGTTATGGGGCCATCTGTTAAGCTGATTGACAGTGGAGCAGAATGCGTCCGAGATATCTCTGTCTTA";

my $empty1;
my $empty2 = "";
my $empty3 = " ";
my $empty4 = "                    ";

sub test_typical_cases : Test(75){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @name_list = ("tbpb", "por", "gki", "muri", "recp", "xpt");
    my @type_list = (1, 2, 3, 4, 5, 6);
    my @key_list = (0, 1, 2, 3, 4, 5);
    my %sequence_map = (
        $key_list[0] => $tbpb1,
        $key_list[1] => $por2,
        $key_list[2] => $gki3,
        $key_list[3] => $muri4,
        $key_list[4] => $recp5,
        $key_list[5] => $xpt6,
    );

    my $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    my $c = 0;
        foreach my $allele (@$allele_list){
        is($allele->{name}, $name_list[$c], "name equivalent");
        is($allele->{type}, $type_list[$c], "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
        $c ++;
    }	

    @name_list = ("por", "muri", "xpt"); 
    @type_list = (2, 4, 6);
    @key_list = (0, 1, 2);
    %sequence_map = (
        $key_list[0] => $por2,
        $key_list[1] => $muri4,
        $key_list[2] => $xpt6,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    $c = 0;
    foreach my $allele (@$allele_list){
        is($allele->{name}, $name_list[$c], "name equivalent");
        is($allele->{type}, $type_list[$c], "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
        $c ++;
    }

    @name_list = ("xpt", "recp", "muri", "gki", "por", "tbpb");
    @type_list = (6, 5, 4, 3, 2, 1);
    @key_list = (0, 1, 2, 3, 4, 5);
    %sequence_map = (
        $key_list[0] => $xpt6,
        $key_list[1] => $recp5,
        $key_list[2] => $muri4,
        $key_list[3] => $gki3,
        $key_list[4] => $por2,
        $key_list[5] => $tbpb1,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    $c = 0;
    foreach my $allele (@$allele_list){
        is($allele->{name}, $name_list[$c], "name equivalent");
        is($allele->{type}, $type_list[$c], "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
        $c ++;
    }
}

sub test_single_cases : Test(15){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @name_list = ("tbpb");
    my @key_list = (0);
    my %sequence_map = (
        $key_list[0] => $tbpb1,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    $c = 0;
    foreach my $allele (@$allele_list){
        is($allele->{name}, "tbpb", "name equivalent");
        is($allele->{type}, 1, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
        $c ++;
    }

    @name_list = ("xpt");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $xpt6,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    $c = 0;
    foreach my $allele (@$allele_list){
        is($allele->{name}, "xpt", "name equivalent");
        is($allele->{type}, 6, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
        $c ++;
    }
}

sub test_partial_cases : Test(67){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @name_list = ("tbpbpart1", "tbpbpart2", "tbpbpart3", "tbpbpart4", "tbpbpart5"); 
    my @key_list = (0, 1, 2, 3, 4);
    my %sequence_map = (
        $key_list[0] => $tbpbpart1,
        $key_list[1] => $tbpbpart2,
        $key_list[2] => $tbpbpart3,
        $key_list[3] => $tbpbpart4,
        $key_list[4] => $tbpbpart5,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "tbpb", "name equivalent");
        is($allele->{type}, 1, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("porpart1", "porpart2", "porpart3");	
    @key_list = (0, 1, 2);
    %sequence_map = (
        $key_list[0] => $porpart1,
        $key_list[1] => $porpart2,
        $key_list[2] => $porpart3,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "por", "name equivalent");
        is($allele->{type}, 2, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("gki");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $gkipart1,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "gki", "name equivalent");
        is($allele->{type}, 3, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("muri");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $muripart1,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "muri", "name equivalent");
        is($allele->{type}, 4, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("recp");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $recppart1,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "recp", "name equivalent");
        is($allele->{type}, 5, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("xpt");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $xptpart1,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, -1, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "xpt", "name equivalent");
        is($allele->{type}, 6, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }
}
#long cases are the full allele with primers at both ends
sub test_long_cases : Test(50){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @name_list = ("tbpb");
    my @key_list = (0);
    my %sequence_map = (
        $key_list[0] => $tbpblong,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "tbpb", "name equivalent");
        is($allele->{type}, 1, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("por");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $porlong,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "por", "name equivalent");
        is($allele->{type}, 2, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("gki");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $gkilong,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "gki", "name equivalent");
        is($allele->{type}, 3, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("muri");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $murilong,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "muri", "name equivalent");
        is($allele->{type}, 4, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("recp");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $recplong,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "recp", "name equivalent");
        is($allele->{type}, 5, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("xpt");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $xptlong,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "xpt", "name equivalent");
        is($allele->{type}, 6, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("repeatprimer");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $repeatprimer10,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "repeatlong", "name equivalent");
        is($allele->{type}, 9, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }
}

sub test_repeated_cases : Test(22){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @name_list = ("repeatshort");
    my @key_list = (0);
    my %sequence_map = (
        $key_list[0] => $repeatshort7,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    $c = 0;
    foreach my $allele (@$allele_list){
        is($allele->{name}, "repeatshort", "name equivalent");
        is($allele->{type}, 7, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
        $c ++;
    }

    @name_list = ("repeatmed");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $repeatmed8,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "repeatmed", "name equivalent");
        is($allele->{type}, 8, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }

    @name_list = ("repeatlong");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $repeatlong9,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "repeatlong", "name equivalent");
        is($allele->{type}, 9, "type equivalent");
        is($allele->{error_msg}, "OK", "error message equivalent");
    }
}
sub test_not_found_cases : Test(37){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @name_list = ("gki");
    my @key_list = (0);
    my %sequence_map = (
        $key_list[0] => $gkinotfound,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "--", "name equivalent");
        is($allele->{type}, "Not found", "type equivalent");
        is($allele->{error_msg}, "Not found", "error message equivalent");
    }

    @name_list = ("muri");
    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $murinotfound,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, 0, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "--", "name equivalent");
        is($allele->{type}, "Not found", "type equivalent");
        is($allele->{error_msg}, "Not found", "error message equivalent");
    }

    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $recpnotfound,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, -1, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "--", "name equivalent");
        is($allele->{type}, "Not found", "type equivalent");
        is($allele->{error_msg}, "Not found", "error message equivalent");
    }

    @sequence_list = ($gkinotfound, $murinotfound, $recpnotfound);
    @key_list = (0, 1, 2);
    %sequence_map = (
        $key_list[0] => $gkinotfound,
        $key_list[1] => $murinotfound,
        $key_list[2] => $recpnotfound,
    );

    $allele_list = $obj->_get_allele_types(\%sequence_map);
    isnt($allele_list, undef, "list undefined");
    isnt($allele_list, -1, "returned invalid flag");
    is(scalar @{$allele_list}, scalar keys %sequence_map);

    foreach my $allele (@$allele_list){
        is($allele->{name}, "--", "name equivalent");
        is($allele->{type}, "Not found", "type equivalent");
        is($allele->{error_msg}, "Not found", "error message equivalent");
    }
}

sub test_invalid_cases : Test(13){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @key_list = (0);
    my %sequence_map = (
        $key_list[0] => $invalid1,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $invalid2,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $invalid3,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $invalid4,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0, 1, 2, 3);
    %sequence_map = (
        $key_list[0] => $invalid1,
        $key_list[1] => $invalid2,
        $key_list[2] => $invalid3,
        $key_list[3] => $invalid4,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @sequence_list = ($tbpb1, $invalid2, $recp5);
    @key_list = (0, 1, 2);
    %sequence_map = (
        $key_list[0] => $tbpb1,
        $key_list[1] => $invalid2,
        $key_list[2] => $recp5,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");   
}

sub test_empty_cases : Test(17){

    my $obj = BusinessLogic::GetAlleleType->new();
    $obj->_setup_data("BusinessLogic/data_stub");
    isa_ok($obj, 'BusinessLogic::GetAlleleType');

    my @key_list = (0);
    my %sequence_map = (
        $key_list[0] => $empty1,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");   

    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $empty2,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $empty3,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0);
    %sequence_map = (
        $key_list[0] => $empty4,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0, 1, 2, 3);
    %sequence_map = (
        $key_list[0] => $empty1,
        $key_list[1] => $empty2,
        $key_list[2] => $empty3,
        $key_list[3] => $empty4,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0, 1);
    %sequence_map = (
        $key_list[0] => $tbpb1,
        $key_list[1] => $empty4,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0, 1, 2);
    %sequence_map = (
        $key_list[0] => $empty1,
        $key_list[1] => $recp5,
        $key_list[2] => $xpt6,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");

    @key_list = (0, 1, 2, 3);
    %sequence_map = (
        $key_list[0] => $muri4,
        $key_list[1] => $recp5,
        $key_list[2] => $xpt6,
        $key_list[3] => $empty3,
    );
    $result = $obj->_get_allele_types(\%sequence_map);
    isnt($result, undef, "result undefined");
    is($result, 0, "result invalid flag");
}
1;
