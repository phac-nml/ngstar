                          NGSTAR Database Schema

Requirements: You must be familiar with ER Diagrams and the Relational Model.

You can open the NGSTAR Database Schema on MySQL Workbench by going to File, 
Open Model, and selecting either ng­star/MySQLWorkbench/NGSTAR.mwb or 
ng­star/MySQLWorkbench/NGSTAR_Auth.mwb.

Please note that this is not a live version of the schema, it is simply the state of the 
schema when it was saved. If you want to retrieve a schema that corresponds to the live 
version of the database, you must either Synchronize your existing model or open a new 
Model and Reverse Engineer the NGSTAR database or NGSTAR_Auth database.

NGSTAR Database Schema

Please note that the schema is not completely defined yet in terms of the loci and scheme 
tables (since this functionality has not been implemented yet).

Schema relationships:

1. tbl_Allele to tbl_Allele_SequenceType is one­to­many.
2. tbl_SequenceType to tbl_Allele_SequenceType is one­to­many.

(tbl_Allele_SequenceType exits because the relationship between tbl_Allele and 
tbl_SequenceType is many­to­many)

3. tbl_Loci to tbl_Allele is one­to­many.
4. tbl_Metadata to tbl_Allele is one­to­many.
5. tbl_Metadata to tbl_SequenceType is one­to­many.
6. tbl_IsolateClassification to tbl_Metadata is one­to­many.
7. tbl_Metadata to tbl_Metadata_MIC is one­to­many.
8. tbl_MIC to tbl_Metadata_MIC is one­to­many.

Schema relationships to be added:
1. tbl_Loci to tbl_Loci_Scheme will be one­to­many.
2. tbl_Scheme to tbl_Loci_Scheme will be one­to­many.

					NGSTAR_Auth Database Schema

The NGSTAR_Auth database is within the NGSTAR Catalyst project (unlike the 
NGSTAR database which is independent of the NGSTAR Catalyst project) because the 
Catalyst module that authenticates users must query the database directly from the 
model.

