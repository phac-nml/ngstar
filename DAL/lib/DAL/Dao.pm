# =============================================================================

# Copyright Government of Canada 2014-2017

# Written by: Sukhdeep Sidhu Irish Medina, Public Health Agency of Canada,
#    National Microbiology Laboratory

# Funded by the Genomics Research and Development Initiative

# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at:

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

# =============================================================================

package DAL::Dao;

use 5.014002;
use strict;
use warnings;

use Catalyst qw( ConfigLoader );

# Schema.pm is located in /home/irish_m/ng-star/DatabaseObjects
use lib NGSTAR->config->{dal_databaseobjects_path};
use NGSTAR::Schema;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DAL::Dao ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	add_amino_acid
	add_amino_acid_profile
	check_amino_acid_profile
	check_aa_exists
	check_aa_pos_exists
	edit_amino_acid
	edit_amino_acid_profile
	delete_allele_with_metadata
	delete_sequence_type_profile_with_metadata
	edit_profile_metadata
	edit_allele_with_metadata
	edit_profile_with_metadata
	get_all_allele_length
	get_all_alleles
	get_all_alleles_by_loci
	get_all_loci
	get_all_loci_names
	get_all_sequence_types
	get_all_sequences
	get_allele
	get_allele_type
	get_loci
	get_loci_id
	get_loci_name_count
	get_amino_acids
	get_max_amino_acid_position
	get_allele_length
	get_allele_list
	get_allele_profile
	get_allele_length
	get_allele_list
	get_allele_profile
	get_last_ngstar_type
	get_loci_allele_count
	get_loci_alleles
	get_metadata_classification_id
	get_metadata_interpretations
	get_metadata_mics
	get_metadata
	get_onishi_sequences
	get_onishi_seq_by_id
	get_profile
	get_profile_by_type
	get_sequence_type
	get_sequence_type_count
	get_sequence_type_id
	get_sequences
	get_wild_type_allele_by_loci_id
	insert_allele_with_metadata
	insert_scheme
	insert_sequence_type_profile_with_metadata
	insert_batch_profile_metadata
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;
Readonly my $VALID_VAL => 1;

Readonly my $TYPE_NOT_FOUND => -1;

sub new
{

	my ($class) = @_;

	my $dsn = NGSTAR->config->{dsn_string};
	my $db_user = NGSTAR->config->{db_user};
	my $db_password = NGSTAR->config->{db_password};

	my $self = {
		_schema => NGSTAR::Schema->connect($dsn, $db_user, $db_password),
	};
	bless $self, $class;
	return $self;

}

sub add_amino_acid
{

	my ($self, $loci_name, $amino_acid, $amino_acid_position) = @_;

	my $loci_id = $self->get_loci_id($loci_name);

	my $guard = $self->{_schema}->txn_scope_guard;

	my $result = $self->{_schema}->resultset('TblAminoAcidPosition')->create({
		loci_id => $loci_id,
		amino_acid_char => $amino_acid,
		amino_acid_position => $amino_acid_position
	});


	$guard->commit;

	return $TRUE;

}

sub add_amino_acid_profile
{

	my ($self, $loci_name, $onishi_type, $mosaic, $aa_profile) = @_;

	my $loci_id = $self->get_loci_id($loci_name);

	my $guard = $self->{_schema}->txn_scope_guard;

	my $result = $self->{_schema}->resultset('TblOnishi')->create({
		loci_id => $loci_id,
		onishi_type => $onishi_type,
		mosaic => $mosaic,
		amino_acid_profile => $aa_profile
	});


	$guard->commit;

	return $TRUE;

}

sub check_aa_exists
{
	my ($self, $amino_acid, $amino_acid_position) = @_;

	my $aa_exists = $FALSE;

	my $amino_acid_obj = $self->{_schema}->resultset('TblAminoAcidPosition')->single({amino_acid_char => $amino_acid, amino_acid_position => $amino_acid_position});

	if ($amino_acid_obj)
	{
		$aa_exists = $TRUE;
	}

	return $aa_exists;

}

sub check_aa_pos_exists
{
	my ($self, $amino_acid_position) = @_;

	my $aa_exists = $FALSE;

	my $amino_acid_obj = $self->{_schema}->resultset('TblAminoAcidPosition')->single({amino_acid_position => $amino_acid_position});

	if ($amino_acid_obj)
	{
		$aa_exists = $TRUE;
	}

	return $aa_exists;

}

sub check_amino_acid_profile
{
	my ($self, $aa_profile) = @_;

	my $result = $FALSE;

	my $result_set = $self->{_schema}->resultset('TblOnishi')->search(
		{
			'amino_acid_profile' => $aa_profile
		},
	);

	if($result_set == $TRUE)
	{
		$result = $TRUE;
	}


	return $result;
}

sub edit_amino_acid
{

	my ($self, $id, $amino_acid, $amino_acid_position) = @_;

	my $amino_acid_obj = $self->{_schema}->resultset('TblAminoAcidPosition')->single({id => $id});
	my $result = $FALSE;

	if($amino_acid_obj)
	{
		$amino_acid_obj->amino_acid_char($amino_acid);
		$amino_acid_obj->amino_acid_position($amino_acid_position);
		$amino_acid_obj->update;

		$result = $TRUE;
	}

	return $result;
}

sub edit_amino_acid_profile
{

	my ($self, $loci_name, $id, $onishi_type, $mosaic, $aa_profile) = @_;

	my $onishi_obj = $self->{_schema}->resultset('TblOnishi')->single({id => $id});
	my $result = $FALSE;

	if($onishi_obj)
	{
		$onishi_obj->onishi_type($onishi_type);
		$onishi_obj->mosaic($mosaic);
		$onishi_obj->amino_acid_profile($aa_profile);
		$onishi_obj->update;

		$result = $TRUE;
	}

	return $result;
}

sub delete_amino_acid
{

	my ($self, $id) = @_;

	my $guard = $self->{_schema}->txn_scope_guard;

	my $result_set = $self->{_schema}->resultset('TblAminoAcidPosition')->single({id => $id});
	$result_set->delete;

	$guard->commit;

}

sub delete_amino_acid_profile
{

	my ($self, $id) = @_;

	my $guard = $self->{_schema}->txn_scope_guard;

	my $result_set = $self->{_schema}->resultset('TblOnishi')->single({id => $id});
	$result_set->delete;

	$guard->commit;

}

#start BusinessLogic::AddAllele

sub get_all_sequences
{

	my ($self, $loci_id) = @_;

	my @sequence_list;
	my $result_set = $self->{_schema}->resultset('TblAllele')->search(
		{
			loci_id => $loci_id                 #conditions go in first set of curly braces
		},
		{
			columns => [qw/ allele_sequence /]  #attributes go in second set of curly braces
		}
	);

	while (my $item = $result_set->next)
	{

		push @sequence_list, $item->allele_sequence;

	}

	return \@sequence_list;

}

sub get_sequences
{

	my ($self, $allele_type, $loci_id) = @_;

	my @sequence_list;
	my $result_set = $self->{_schema}->resultset('TblAllele')->search(
		{
			allele_type => {'!=' => $allele_type},
			loci_id => $loci_id                 #conditions go in first set of curly braces
		},
		{
			columns => [qw/ allele_sequence /]  #attributes go in second set of curly braces
		}
	);
	while (my $item = $result_set->next)
	{

		push @sequence_list, $item->allele_sequence;

	}

	return \@sequence_list;

}

sub get_wild_type_allele_by_loci_id
{

	my ($self, $loci_name) = @_;

	my $loci_id = $self->get_loci_id($loci_name);

	my $result_set = $self->{_schema}->resultset('TblAllele')->search({ loci_id => $loci_id });
	my $result_set_column = $result_set->get_column('allele_type');
	my $wild_type = $result_set_column->min;
	my $wild_type_sequence = $FALSE;

	if($wild_type)
	{
		$wild_type_sequence = $self->{_schema}->resultset('TblAllele')->single({
			loci_id => $loci_id,
			allele_type => $wild_type
		})->allele_sequence;
	}

	return $wild_type_sequence;

}

sub insert_allele
{

	my ($self, $allele_type, $allele_sequence, $loci_id, $metadata_id) = @_;

	my $result = $self->{_schema}->resultset('TblAllele')->create({
		allele_type => $allele_type,
		allele_sequence => $allele_sequence,
		loci_id => $loci_id,
		metadata_id => $metadata_id
	});

	return $result;

}

sub insert_allele_with_metadata
{

	my ($self, $allele_type, $allele_sequence, $loci_id, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by, $collection_date, $interpretation_map, $amr_marker_string) = @_;

	my $guard = $self->{_schema}->txn_scope_guard;

	my $metadata = $self->insert_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by,$collection_date, $interpretation_map, $amr_marker_string);

	my $metadata_id = $metadata->metadata_id;

	my $allele = $self->insert_allele($allele_type, $allele_sequence, $loci_id, $metadata_id);

	$guard->commit;

	return $allele;

}

#end BusinessLogic::AddAllele

#start BusinessLogic::AddMetadata

sub get_classification_id
{

	my ($self, $classification_code) = @_;

	my $classification_id = $self->{_schema}->resultset('TblIsolateClassification')->single({
		classification_code => $classification_code
	})->classification_id;

	return $classification_id;

}

sub get_mic_id
{

	my ($self, $antimicrobial_name) = @_;

	my $mic_id = $self->{_schema}->resultset('TblMic')->single({
	   antimicrobial_name => $antimicrobial_name
	})->mic_id;

	return $mic_id;

}

sub insert_batch_metadata
{

	my($self, $loci_name, $allele_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date ,$mics_determined_by, $mic_map, $interpretation_map, $amr_markers) =@_;

	my $result = $INVALID_VAL;

	my $allele = $self->get_allele($loci_name, $allele_type);

	if(defined $allele)
	{

		my $metadata_id = $allele->metadata_id;

		$self->edit_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $metadata_id, $mics_determined_by,$collection_date, $amr_markers);
		$self->insert_metadata_classifications($metadata_id, $classification_code);

		if(keys %$interpretation_map > 0)
		{

			$self->edit_metadata_interpretation($metadata_id, $interpretation_map);

		}
		else
		{

			$self->edit_metadata_mic($metadata_id, $mic_map);

		}

		$result = $VALID_VAL;

	}

	return $result;

}

sub insert_batch_profile_metadata
{

	my($self, $sequence_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date, $mic_map, $amr_markers) =@_;

	my $result = $INVALID_VAL;

	my $profile = $self->get_profile_by_type($sequence_type);

	if(defined $profile)
	{

		my $metadata_id = $profile->metadata_id;

		$self->edit_profile_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $metadata_id, $collection_date, $amr_markers);

		$self->insert_metadata_classifications($metadata_id, $classification_code);

		if(keys %$mic_map > 0)
		{

			$self->edit_metadata_mic($metadata_id, $mic_map);

		}

		$result = $VALID_VAL;

	}

	return $result;

}

sub insert_metadata
{

	my ($self, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by,$collection_date,$interpretation_map, $amr_marker_string) = @_;

	my $guard = $self->{_schema}->txn_scope_guard;
	my $classification_id;

	my $result = $self->{_schema}->resultset('TblMetadata')->create({
		country => $country,
		patient_gender => $patient_gender,
		patient_age => $patient_age,
		epi_data => $epi_data,
		beta_lactamase => $beta_lactamase,
		curator_comment => $curator_comment,
		mics_determined_by => $mics_determined_by,
		collection_date => $collection_date,
		amr_markers => $amr_marker_string
	});

	my $metadata_id = $result->metadata_id;

	$self->insert_metadata_classifications($metadata_id, $classification_code);

	if(keys %$interpretation_map > 0)
	{

		$self->insert_metadata_interpretation($metadata_id, $interpretation_map);

	}
	else
	{

		$self->insert_metadata_mic($metadata_id, $mic_map);

	}

	$guard->commit;

	return $result;

}

sub insert_metadata_classifications
{

	my ($self, $metadata_id, $classification_code) = @_;

	my @classification_ids = split("/",$classification_code);
	 my $classification_id;
	my $result;

	if(scalar @classification_ids > 0)
	{

		foreach my $classification (@classification_ids)
		{

			if($classification ne "Unknown")
			{

				$classification_id = $self->get_classification_id($classification);

				if(not my $result_set_exists = $self->{_schema}->resultset('TblMetadataIsolateClassification')->single(
					{metadata_id => $metadata_id, classification_id => $classification_id}))
				{

					$result = $self->{_schema}->resultset('TblMetadataIsolateClassification')->create({
						metadata_id => $metadata_id,
						classification_id => $classification_id
					});

				}

			}

		}

	}

}

sub insert_metadata_interpretation
{

	my ($self, $metadata_id, $interpretation_map) = @_;

	my $name_list = $self->get_mic_antimicrobial_names();

	foreach my $name (@$name_list)
	{

		my $interpretation_value = $interpretation_map->{$name}{interpretation_value};
		my $mic_id = $self->get_mic_id($name);

		$self->{_schema}->resultset('TblMetadataMic')->create({
			metadata_id => $metadata_id,
			mic_id => $mic_id,
			interpretation_value => $interpretation_value
		});

	}

}

sub insert_metadata_mic
{

	my ($self, $metadata_id, $mic_map) = @_;

	my $name_list = $self->get_mic_antimicrobial_names();

	foreach my $name (@$name_list)
	{

		my $mic_comparator = $mic_map->{$name}{mic_comparator};
		my $mic_value = $mic_map->{$name}{mic_value};
		my $mic_id = $self->get_mic_id($name);

		$self->{_schema}->resultset('TblMetadataMic')->create({
			metadata_id => $metadata_id,
			mic_id => $mic_id,
			mic_comparator => $mic_comparator,
			mic_value => $mic_value
		});

	}

}

#end BusinessLogic::AddMetadata

#start BusinessLogic::AddScheme

sub get_all_scheme_names
{

	my ($self) = @_;

	my @scheme_name_list;

	my $result_set = $self->{_schema}->resultset('TblScheme')->search(
		undef,
		{
			columns => [qw/ scheme_name /]
		}
	);

	while (my $item = $result_set->next)
	{

		push @scheme_name_list, $item->scheme_name;

	}

	return \@scheme_name_list;

}

sub insert_scheme
{

	my ($self, $scheme_name) = @_;

	my $result = $self->{_schema}->resultset('TblScheme')->create({
		scheme_name => $scheme_name
	});

	return $result;

}

#end BusinessLogic::AddScheme

#start BusinessLogic::AddSequenceTypeProfile

sub get_allele_id
{

	my ($self, $loci_name, $allele_type) = @_;

	my $loci_id = $self->get_loci_id($loci_name);

	my $allele_id = $self->{_schema}->resultset('TblAllele')->single({
		allele_type => $allele_type,
		loci_id => $loci_id
	})->allele_id;

	return $allele_id;

}

sub get_sequence_type
{

	my ($self, $seq_type_value) = @_;

	my $sequence_type = $self->{_schema}->resultset('TblSequenceType')->single({
		seq_type_value => $seq_type_value
	});

	return $sequence_type;

}

sub get_sequence_type_id
{

	my ($self, $seq_type_value) = @_;

	my $seq_type_id = $self->{_schema}->resultset('TblSequenceType')->single({
		seq_type_value => $seq_type_value
	})->seq_type_id;

	return $seq_type_id;

}

sub insert_sequence_type_profile
{

	my ($self, $seq_type_value, $profile_map, $metadata_id) = @_;

	my $result;
	#wrap all related database statements in a transaction
	my $guard = $self->{_schema}->txn_scope_guard;

	$self->{_schema}->resultset('TblSequenceType')->create({
		seq_type_value => $seq_type_value,
		metadata_id => $metadata_id
	});

	my $seq_type_id = $self->get_sequence_type_id($seq_type_value);

	foreach my $loci_name (keys %$profile_map)
	{

		my $allele_type = $profile_map->{$loci_name};
		my $allele_id = $self->get_allele_id($loci_name, $allele_type);
		$result = $self->{_schema}->resultset('TblAlleleSequenceType')->create({
			allele_id => $allele_id,
			seq_type_id => $seq_type_id
		});
	}

	$guard->commit;

	return $result;

}

sub insert_sequence_type_profile_with_metadata
{

	my ($self, $seq_type_value, $profile_map, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $amr_marker_string) = @_;

	my $guard = $self->{_schema}->txn_scope_guard;

	my $metadata = $self->insert_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, undef, $collection_date, undef, $amr_marker_string);

	my $metadata_id = $metadata->metadata_id;

	my $profile = $self->insert_sequence_type_profile($seq_type_value, $profile_map, $metadata_id);

	$guard->commit;

	return $profile;

}

#end BusinessLogic::AddSequenceTypeProfile

#start BusinessLogic::AddSequenceTypeProfile

sub get_sequence_type_count
{

	my ($self) = @_;
	my $count = $self->{_schema}->resultset('TblSequenceType')->count;

	return $count;

}

#end BusinessLogic::AddSequenceTypeProfile

#start BusinessLogic::DeleteAllele

sub delete_allele
{

	my ($self, $loci_name, $allele_type) = @_;

	my $allele = $self->get_allele($loci_name, $allele_type);
	$allele->delete;

}

sub delete_allele_with_metadata
{

	my ($self, $loci_name, $allele_type) = @_;

	my $result = $INVALID_VAL;
	my $guard = $self->{_schema}->txn_scope_guard;

	my $allele = $self->get_allele($loci_name, $allele_type);
	my $metadata_id = $allele->metadata_id;

	$self->delete_allele($loci_name, $allele_type);
	$self->delete_metadata_mics($metadata_id);
	$self->delete_metadata_classifications($metadata_id);
	$self->delete_metadata($metadata_id);

	$guard->commit;
	$result = $VALID_VAL;

	return $result;

}

sub delete_metadata
{

	my ($self, $metadata_id) = @_;

	my $result_set = $self->{_schema}->resultset('TblMetadata')->single({metadata_id => $metadata_id});
	$result_set->delete;

}

sub delete_metadata_classifications
{

	my ($self, $metadata_id) = @_;

	$self->{_schema}->resultset('TblMetadataIsolateClassification')->search(
	{
		metadata_id => $metadata_id
	})->delete;

}

sub delete_metadata_mics
{

	my ($self, $metadata_id) = @_;

	my $result_set = $self->{_schema}->resultset('TblMetadataMic')->search(
		{
			metadata_id => $metadata_id
		}
	);

	$result_set->delete;

}

#end BusinessLogic::DeleteAllele

#start BusinessLogic::DeleteSequenceTypeProfile

sub delete_sequence_type_profile
{

	my ($self, $seq_type_value) = @_;

	my $result = $INVALID_VAL;
	my $guard = $self->{_schema}->txn_scope_guard;

	my $seq_type_id = $self->get_sequence_type_id($seq_type_value);

	$self->{_schema}->resultset('TblAlleleSequenceType')->search(
		{
			seq_type_id => $seq_type_id
		}
	)->delete;

	my $st = $self->get_sequence_type_by_id($seq_type_id);
	$st->delete;

	$guard->commit;

	$result = $VALID_VAL;

	return $result;

}

sub delete_sequence_type_profile_with_metadata
{

	my ($self, $seq_type_value) = @_;

	my $result = $INVALID_VAL;
	my $guard = $self->{_schema}->txn_scope_guard;

	my $profile = $self->get_sequence_type($seq_type_value);
	my $metadata_id = $profile->metadata_id;

	$self->delete_sequence_type_profile($seq_type_value);
	$self->delete_metadata_mics($metadata_id);
	$self->delete_metadata($metadata_id);

	$guard->commit;

	$result = $VALID_VAL;

	return $result;

}

#end BusinessLogic::DeleteSequenceTypeProfile

#start BusinessLogic::EditAllele

sub edit_allele
{

	my ($self, $loci_name_prev, $allele_type_prev, $loci_name_new, $allele_type_new, $sequence) = @_;

	my $is_update = $FALSE;
	my $allele = $self->get_allele($loci_name_prev, $allele_type_prev);

	if(lc($loci_name_prev) ne lc($loci_name_new))
	{

		my $loci_id = $self->get_loci_id($loci_name_new);
		$allele->loci_id($loci_id);
		$is_update = $TRUE;

	}

	if($allele_type_prev != $allele_type_new)
	{

		$allele->allele_type($allele_type_new);
		$is_update = $TRUE;

	}

	if(lc($allele->allele_sequence) ne lc($sequence))
	{

		$allele->allele_sequence($sequence);
		$is_update = $TRUE;

	}

	if($is_update)
	{

		$allele->update;

	}

}

sub edit_allele_with_metadata
{

	my ($self, $loci_name_prev, $allele_type_prev, $loci_name_new, $allele_type_new, $sequence, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by,$collection_date, $interpretation_map, $amr_marker_string) = @_;

	my $result = $INVALID_VAL;
	#wrap editing both alleles and metadata in a database transaction
	my $guard = $self->{_schema}->txn_scope_guard;

	my $allele = $self->get_allele($loci_name_prev, $allele_type_prev);
	$self->edit_allele($loci_name_prev, $allele_type_prev, $loci_name_new, $allele_type_new, $sequence);
	my $metadata_id = $allele->metadata_id;

	$self->edit_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $metadata_id, $mics_determined_by,$collection_date, $amr_marker_string);

	if(keys %$interpretation_map > 0 || keys %$mic_map > 0)
	{

		if(keys %$interpretation_map > 0)
		{

			$self->edit_metadata_interpretation($metadata_id, $interpretation_map);

		}
		elsif(keys %$mic_map > 0)
		{

			$self->edit_metadata_mic($metadata_id, $mic_map);

		}

	}

	$self->edit_metadata_classifications($metadata_id, $classification_code);

	$guard->commit;
	$result = $VALID_VAL;


	return $result;

}

sub edit_metadata
{

	my ($self, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase,  $metadata_id, $mics_determined_by,$collection_date, $amr_marker_string) = @_;

	my $metadata = $self->{_schema}->resultset('TblMetadata')->single({metadata_id => $metadata_id});

	$metadata->country($country);
	$metadata->patient_gender($patient_gender);
	$metadata->patient_age($patient_age);
	$metadata->epi_data($epi_data);
	$metadata->beta_lactamase($beta_lactamase);
	$metadata->curator_comment($curator_comment);
	$metadata->mics_determined_by($mics_determined_by);
	$metadata->collection_date($collection_date);
	$metadata->amr_markers($amr_marker_string);
	$metadata->update;

}


sub edit_profile_metadata
{

	my ($self, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase,  $metadata_id, $collection_date, $amr_marker_string) = @_;

	my $metadata = $self->{_schema}->resultset('TblMetadata')->single({metadata_id => $metadata_id});

	$metadata->country($country);
	$metadata->patient_gender($patient_gender);
	$metadata->patient_age($patient_age);
	$metadata->epi_data($epi_data);
	$metadata->beta_lactamase($beta_lactamase);
	$metadata->curator_comment($curator_comment);
	$metadata->collection_date($collection_date);
	$metadata->amr_markers($amr_marker_string);
	$metadata->update;
}


sub edit_metadata_classifications
{

	my ($self, $metadata_id, $classification_code) = @_;

	$self->delete_metadata_classifications($metadata_id);

	$self->insert_metadata_classifications($metadata_id, $classification_code);

}

sub edit_metadata_interpretation
{

	my ($self, $metadata_id, $interpretation_map) = @_;

	my $name_list = $self->get_mic_antimicrobial_names();

	foreach my $name (@$name_list)
	{

		my $interpretation_value = $interpretation_map->{$name}{interpretation_value};
		my $mic_id = $self->get_mic_id($name);

		my $metadata_interpretation = $self->{_schema}->resultset('TblMetadataMic')->single({metadata_id => $metadata_id, mic_id => $mic_id});

		if($metadata_interpretation)
		{

			$metadata_interpretation->interpretation_value($interpretation_value);
			$metadata_interpretation->mic_comparator(undef);
			$metadata_interpretation->mic_value(undef);
			$metadata_interpretation->update;

		}

	}

}


sub edit_metadata_mic
{

	my ($self, $metadata_id, $mic_map) = @_;

	my $name_list = $self->get_mic_antimicrobial_names();

	foreach my $name (@$name_list)
	{
		my $mic_comparator = $mic_map->{$name}{mic_comparator};
		my $mic_value = $mic_map->{$name}{mic_value};
		my $mic_id = $self->get_mic_id($name);

		my $metadata_mic = $self->{_schema}->resultset('TblMetadataMic')->single({metadata_id => $metadata_id, mic_id => $mic_id});

		if($metadata_mic)
		{
			$metadata_mic->mic_comparator($mic_comparator);
			$metadata_mic->mic_value($mic_value);
			$metadata_mic->interpretation_value(undef);
			$metadata_mic->update;
		}
	}
}

#end BusinessLogic::EditAllele

#start BusinessLogic::EditSequenceTypeProfile

sub get_allele_st
{

	my ($self, $allele_id, $seq_type_id) = @_;

	my $allele_st = $self->{_schema}->resultset('TblAlleleSequenceType')->single({allele_id => $allele_id, seq_type_id => $seq_type_id});

	return $allele_st;

}

sub get_sequence_type_by_id
{

	my ($self, $seq_type_id) = @_;

	my $st = $self->{_schema}->resultset('TblSequenceType')->find($seq_type_id);

	return $st;

}

sub edit_profile
{

	my ($self, $seq_type_prev, $seq_type_new, $profile_map_prev, $profile_map_new) = @_;

	my $seq_type_id = $self->get_sequence_type_id($seq_type_prev);

	if($seq_type_prev != $seq_type_new)
	{

		my $st = $self->get_sequence_type_by_id($seq_type_id);
		$st->seq_type_value($seq_type_new);
		$st->update;

	}

	foreach my $loci_name (keys %$profile_map_prev)
	{

		my $allele_type_prev = $profile_map_prev->{$loci_name};
		my $allele_type_new = $profile_map_new->{$loci_name};

		if($allele_type_prev != $allele_type_new)
		{

			my $allele_id_prev = $self->get_allele_id($loci_name, $allele_type_prev);
			my $allele_id_new = $self->get_allele_id($loci_name, $allele_type_new);

			my $allele_st = $self->get_allele_st($allele_id_prev, $seq_type_id);
			$allele_st->allele_id($allele_id_new);
			$allele_st->update;

		}

	}

}

sub edit_profile_with_metadata
{

	my ($self, $seq_type_prev, $seq_type_new, $profile_map_prev, $profile_map_new, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $amr_marker_string) = @_;

	my $result = $INVALID_VAL;
	my $guard = $self->{_schema}->txn_scope_guard;

	my $profile = $self->get_sequence_type($seq_type_prev);
	$self->edit_profile($seq_type_prev, $seq_type_new, $profile_map_prev, $profile_map_new);
	my $metadata_id = $profile->metadata_id;
	$self->edit_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $metadata_id, undef, $collection_date, $amr_marker_string);
	$self->edit_metadata_mic($metadata_id, $mic_map);
	$self->edit_metadata_classifications($metadata_id, $classification_code);

	$guard->commit;
	$result = $VALID_VAL;

	return $result;

}

#end BusinessLogic::EditSequenceTypeProfile

#start BusinessLogic::GetAlleleInfo

sub get_all_allele_count
{

	my ($self) = @_;

	my $count = $self->{_schema}->resultset('TblAllele')->count;

	return $count;

}

sub get_all_allele_length
{

	my ($self, $info_map) = @_;

	my $result = $VALID_VAL;

	foreach my $loci_name(keys %$info_map)
	{

		my $length = $self->{_schema}->resultset('TblLoci')->single({loci_name => $loci_name})->sequence_length;

		if(defined $length)
		{

			$info_map->{$loci_name} = $length;

		}
		else
		{

			$result = $INVALID_VAL;

		}

	}

	return $result;

}

sub get_allele_length
{

	my ($self, $loci_name) = @_;

	my $length = $self->{_schema}->resultset('TblLoci')->single({loci_name => $loci_name})->sequence_length;

	return $length;

}

sub get_allele_list
{

	my ($self) = @_;

	my @allele_list;

	my $result_set = $self->{_schema}->resultset('TblAllele')->search(
		undef,
		{
			columns => [qw/ allele_type allele_sequence loci.loci_name /],
			join => 'loci',
			'+select' => [qw/ loci.loci_name /]
		}
	);

	while(my $allele = $result_set->next)
	{

		my $sequence_length = length $allele->allele_sequence;

		push @allele_list, {allele_type => $allele->allele_type,
							allele_sequence => $allele->allele_sequence,
							loci_name => $allele->loci->loci_name,
							allele_sequence_length => $sequence_length};
	}

	return \@allele_list;

}

sub get_loci_allele_count
{

	my ($self, $loci_name) = @_;

	my $count = $self->{_schema}->resultset('TblAllele')->search(
		{
			'loci.loci_name' => $loci_name
		},
		{
			join => 'loci'
		})->count;

	return $count;

}

sub get_loci_alleles
{

	my ($self, $loci_name) = @_;

	my @allele_list;

	my $result_set = $self->{_schema}->resultset('TblAllele')->search(
		{
			'loci.loci_name' => $loci_name
		},
		{
			columns => [qw/ allele_type allele_sequence loci.loci_name metadata_id /],
			join => 'loci',
			'+select' => [qw/ loci.loci_name /]
		}
	);

	while(my $allele = $result_set->next)
	{

		my $sequence_length = length $allele->allele_sequence;

		push @allele_list, {allele_type => $allele->allele_type,
							allele_sequence => $allele->allele_sequence,
							loci_name => $allele->loci->loci_name,
							allele_sequence_length => $sequence_length,
							metadata_id => $allele->metadata_id};

	}

	return \@allele_list;

}


sub get_all_alleles
{

	my ($self) = @_;

	my @allele_list;
	my $result_set = $self->{_schema}->resultset('TblAllele');

	while (my $allele = $result_set->next)
	{

		push @allele_list, {allele_type => $allele->allele_type,
							allele_sequence => $allele->allele_sequence,
							loci_id => $allele->loci_id};
	}

	return \@allele_list;

}

sub get_all_alleles_by_loci
{

	my ($self, $loci_list) = @_;

	my @allele_list;

	my $result_set = $self->{_schema}->resultset('TblAllele')->search(
		{
			'loci.loci_name' => $loci_list
		},
		{
			join => 'loci'
		}
	);

	while (my $allele = $result_set->next)
	{

		push @allele_list, {allele_type => $allele->allele_type,
							allele_sequence => $allele->allele_sequence,
							loci_id => $allele->loci_id};

	}

	return \@allele_list;

}

sub get_all_loci
{

	my ($self) = @_;

	my @loci_list;
	my $result_set = $self->{_schema}->resultset('TblLoci');

	while(my $loci = $result_set->next)
	{

		push @loci_list, {loci_id => $loci->loci_id,
						loci_name => $loci->loci_name,
						sequence_length => $loci->sequence_length,
						is_allele_type_int => $loci->is_allele_type_int,
						is_onishi_type => $loci->is_onishi_type};


	}

	return \@loci_list;

}

sub get_all_loci_names
{

	my ($self) = @_;

	my @loci_name_list;

	my $result_set = $self->{_schema}->resultset('TblLoci')->search(
		undef,
		{
			columns => [qw/ loci_name /]
		}
	);

	while (my $item = $result_set->next)
	{

		push @loci_name_list, $item->loci_name;

	}

	return \@loci_name_list;

}

sub get_allele
{

	my ($self, $loci_name, $type) = @_;

	my $loci_id = $self->get_loci_id($loci_name);

	my $allele = $self->{_schema}->resultset('TblAllele')->single({
		allele_type => $type,
		loci_id => $loci_id
	});

	return $allele;

}

sub get_allele_type
{

	my ($self, $loci_name, $sequence) = @_;

	my $allele_type;
	my $result;
	my $loci_id = $self->get_loci_id($loci_name);
	my $type_found = 0;

	my $allele = $self->{_schema}->resultset('TblAllele')->single({
		loci_id => $loci_id,
		allele_sequence => $sequence
	});

	if($allele)
	{

		$allele_type = $allele->allele_type;
		$result = $allele_type;

	}
	else
	{

		$result = $INVALID_VAL;
		$type_found = $TYPE_NOT_FOUND;

	}

	return ($result, $type_found);

}

sub get_loci
{

	my ($self, $loci_id) = @_;

	my $loci = $self->{_schema}->resultset('TblLoci')->find($loci_id);

	return $loci;

}

sub get_loci_id
{

	my ($self, $loci_name) = @_;

	my $loci_id = $self->{_schema}->resultset('TblLoci')->single({loci_name => $loci_name})->loci_id;

	return $loci_id;

}

#end BusinessLogic::GetAlleleType

#start BusinessLogic::GetMetadata

sub get_all_isolate_classifications
{

	my ($self) = @_;

	my @classification_list;

	my $result_set = $self->{_schema}->resultset('TblIsolateClassification');

	while (my $item = $result_set->next)
	{

		push @classification_list, {classification_name => $item->classification_name,
									classification_code => $item->classification_code};

	}

	return \@classification_list;

}

sub get_metadata_classification_id
{

	my ($self, $metadata_id) = @_;

	my $classification_id = $self->{_schema}->resultset('TblMetadata')->single({metadata_id => $metadata_id})->classification_id;

	return $classification_id;

}

sub get_metadata_classifications
{

	my ($self, $metadata_id) = @_;

	my @classifications_list;

	my $result_set = $self->{_schema}->resultset('TblMetadataIsolateClassification')->search(
		{
			metadata_id => $metadata_id
		},
		{
			join => 'classification',
		}
	);

	while(my $item = $result_set->next)
	{

		push @classifications_list, {classification_code => $item->classification->classification_code,
									 classification_name => $item->classification->classification_name};

	}

	return \@classifications_list;

}

sub get_metadata_interpretations
{

	my ($self, $metadata_id) = @_;

	my @interpretation_list;

	my $result_set = $self->{_schema}->resultset('TblMetadataMic')->search(
		{
			metadata_id => $metadata_id
		},
		{
			join => 'mic',
		}
	);

	while(my $item = $result_set->next)
	{

		push @interpretation_list, {antimicrobial_name => $item->mic->antimicrobial_name,
							   interpretation_value => $item->interpretation_value};

	}

	return \@interpretation_list;

}

sub get_metadata_mics
{

	my ($self, $metadata_id) = @_;

	my @mic_list;

	my $result_set = $self->{_schema}->resultset('TblMetadataMic')->search(
		{
			metadata_id => $metadata_id
		},
		{
			join => 'mic',
		}
	);

	while(my $item = $result_set->next)
	{

		push @mic_list, {antimicrobial_name => $item->mic->antimicrobial_name,
						mic_comparator => $item->mic_comparator,
						mic_value => $item->mic_value};

	}

	return \@mic_list;

}

sub get_metadata
{

	my ($self, $metadata_id) = @_;

	my $result_set = $self->{_schema}->resultset('TblMetadata')->find(
		{
			metadata_id => $metadata_id
		}
	);

	my %metadata = (
		country => $result_set->country,
		patient_gender => $result_set->patient_gender,
		patient_age => $result_set->patient_age,
		epi_data => $result_set->epi_data,
		beta_lactamase => $result_set->beta_lactamase,
		curator_comment => $result_set->curator_comment,
		mics_determined_by => $result_set->mics_determined_by,
		collection_date => $result_set->collection_date,
		amr_markers => $result_set->amr_markers

	);

	return \%metadata;

}

sub get_mic_antimicrobial_names
{

	my ($self) = @_;

	my @name_list;

	my $result_set = $self->{_schema}->resultset('TblMic');

	while (my $item = $result_set->next)
	{

		push @name_list, $item->antimicrobial_name;

	}

	return \@name_list;

}

#end BusinessLogic::GetMetadata

#start BusinessLogic::GetSequenceType

sub get_all_sequence_types
{

	my ($self) = @_;

	my @sequence_type_list;

	my $result_set = $self->{_schema}->resultset('TblSequenceType');

	while (my $sequence_type = $result_set->next)
	{

		push @sequence_type_list, {seq_type_id => $sequence_type->seq_type_id,
									seq_type_value => $sequence_type->seq_type_value,
									metadata_id =>$sequence_type->metadata_id};

	}


	return \@sequence_type_list;

}

sub get_last_ngstar_type
{

	my ($self) = @_;

	my $result_set = $self->{_schema}->resultset('TblSequenceType');

	my $last_ngstar_type = $result_set->get_column('seq_type_value')->max();

	return $last_ngstar_type;

}

sub get_allele_profile
{

	my ($self, $id) = @_;

	my @allele_list;

	my $result_set = $self->{_schema}->resultset('TblSequenceType')->find($id)->alleles();

	while (my $allele = $result_set->next)
	{

		push @allele_list, {allele_type => $allele->allele_type,
							allele_sequence => $allele->allele_sequence,
							loci_id => $allele->loci_id};

	}

	return \@allele_list;

}

sub get_onishi_sequences
{

	my ($self, $loci_name) = @_;

	my $loci_id = $self->get_loci_id($loci_name);
	my @onishi_seq_list;

	my $result_set = $self->{_schema}->resultset('TblOnishi')->search(
		{
			'loci_id' => $loci_id
		},
	);

	while (my $onishi_seq = $result_set->next)
	{

		push @onishi_seq_list, {id => $onishi_seq->id,
								loci_id => $onishi_seq->loci_id,
								onishi_type => $onishi_seq->onishi_type,
								mosaic => $onishi_seq->mosaic,
								aa_profile => $onishi_seq->amino_acid_profile};

	}

	return \@onishi_seq_list;

}

sub get_onishi_seq_by_id
{

	my ($self, $id) = @_;

	my @onishi_seq_list;

	my $result_set = $self->{_schema}->resultset('TblOnishi')->search(
		{
			'id' => $id
		},
	);

	while (my $onishi_seq = $result_set->next)
	{

		push @onishi_seq_list, {id => $onishi_seq->id,
								loci_id => $onishi_seq->loci_id,
								onishi_type => $onishi_seq->onishi_type,
								mosaic => $onishi_seq->mosaic,
								aa_profile => $onishi_seq->amino_acid_profile};

	}

	return \@onishi_seq_list;

}


sub get_profile
{

	my ($self, $id) = @_;
	my %profile_map;
	my @allele_list = $self->{_schema}->resultset('TblSequenceType')->find($id)->alleles();

	foreach my $allele (@allele_list)
	{

		my $loci = $self->get_loci($allele->loci_id);
		my $loci_name = $loci->loci_name;
		my $allele_type = $allele->allele_type;
		$profile_map{$loci_name} = $allele_type;

	}

	return \%profile_map;

}

sub get_profile_by_type
{

	my ($self, $seq_type) = @_;

	my $profile = $self->{_schema}->resultset('TblSequenceType')->single({seq_type_value => $seq_type});;

	return $profile;

}

#end BusinessLogic::GetSequenceTypeInfo


sub get_amino_acids
{
	my ($self, $loci_name) = @_;

	my $loci_id = $self->get_loci_id($loci_name);
	my @amino_acid_list;

	my $result_set = $self->{_schema}->resultset('TblAminoAcidPosition')->search(
		{
			'loci_id' => $loci_id
		},
	);

	while (my $amino_acid = $result_set->next)
	{

		push @amino_acid_list, {id => $amino_acid->id,
								loci_id => $amino_acid->loci_id,
								aa_pos => $amino_acid->amino_acid_position,
								aa_char => $amino_acid->amino_acid_char};

	}

	return \@amino_acid_list;
}

sub get_amino_acid_by_id
{

	my ($self, $id) = @_;

	my @aa_list;

	my $result_set = $self->{_schema}->resultset('TblAminoAcidPosition')->search(
		{
			'id' => $id
		},
	);

	while (my $amino_acid = $result_set->next)
	{

		push @aa_list, {id => $amino_acid->id,
						loci_id => $amino_acid->loci_id,
						aa_pos => $amino_acid->amino_acid_position,
						aa_char => $amino_acid->amino_acid_char};

	}

	return \@aa_list;

}

sub get_max_amino_acid_position
{
	my ($self, $loci_name) = @_;

	my $loci_id = $self->get_loci_id($loci_name);
	my $max_position;

	my @amino_acid_list;

	my $result_set = $self->{_schema}->resultset('TblAminoAcidPosition')->search(
		{
			'loci_id' => $loci_id
		},
	);

	$max_position = $result_set->get_column('amino_acid_position')->max;

	return $max_position;
}


#start BusinessLogic::ValidateBatchProfiles

sub get_loci_name_count
{

	my ($self) = @_;
	my $count = $self->{_schema}->resultset('TblLoci')->count;
	return $count;

}

#end BusinessLogic::ValidateBatchProfiles

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

DAL::Dao - Perl extension for blah blah blah

=head1 SYNOPSIS

  use DAL::Dao;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for DAL::Dao, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Irish Medina, E<lt>irish_m@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Irish Medina

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
