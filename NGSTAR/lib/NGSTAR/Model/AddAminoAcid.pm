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

package NGSTAR::Model::AddAminoAcid;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
	class       => 'BusinessLogic::AddAminoAcid',
	constructor => 'new',
);

1;