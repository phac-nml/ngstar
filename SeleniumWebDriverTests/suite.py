import unittest
import sys
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import subprocess32
import util
import constants
from test_account_lockout import TestCaseAccountLockout
from test_add_allele import TestCaseAddAllele
from test_add_allele_w_metadata import TestCaseAddAlleleWithMetadata
from test_add_amino_acid_profile import TestCaseAddAminoAcidProfile
from test_add_delete_users import TestCaseAddDeleteUsers
from test_allele_query import TestCaseAlleleQuery
from test_batch_add_allele import TestCaseBatchAddAllele
from test_batch_allele_query import TestCaseBatchAlleleQuery
from test_batch_profile_query import TestCaseBatchProfileQuery
from test_change_email_via_app import TestCaseChangeEmailViaApp
from test_change_password_via_app import TestCaseChangePasswordViaApp
from test_change_username_via_app import TestCaseChangeUsernameViaApp
from test_delete_allele import TestCaseDeleteAllele
from test_edit_allele import TestCaseEditAllele
from test_edit_allele_w_metadata import TestCaseEditAlleleWithMetadata
from test_edit_amino_acid_profile import TestCaseEditAminoAcidProfile
from test_login import TestCaseLogin
from test_update_account_lockout import TestCaseUpdateAccountLockout



def start_ngstar():
    subprocess32.Popen(constants.NGSTAR_CMD)
    util.wait_until_up(constants.NGSTAR_DOMAIN, constants.NGSTAR_PORT, constants.TIMEOUT)

def stop_ngstar():
    stopper = subprocess32.Popen(constants.NGSTAR_STOP, shell=True)
    stopper.wait()

def suite():

    suite = unittest.TestSuite()

    suite.addTest(TestCaseAddDeleteUsers('test_insert_users_via_sql_positive_case'))

    suite.addTest(TestCaseUpdateAccountLockout('test_insert_account_lockout_info_positive_case'))

    suite.addTest(TestCaseAccountLockout('test_account_lockout_positive_case'))

    suite.addTest(TestCaseUpdateAccountLockout('test_remove_account_lockout_info_positive_case'))


    suite.addTest(TestCaseBatchAlleleQuery('test_batch_allele_query_positive_cases'))
    suite.addTest(TestCaseBatchAlleleQuery('test_batch_allele_query_negative_cases'))
    suite.addTest(TestCaseBatchAlleleQuery('test_batch_allele_query_invalid_cases'))

    suite.addTest(TestCaseLogin('test_positive_cases'))
    suite.addTest(TestCaseLogin('test_negative_cases'))
    suite.addTest(TestCaseLogin('test_empty_cases'))
    suite.addTest(TestCaseLogin('test_short_cases'))
    suite.addTest(TestCaseLogin('test_long_cases'))
    suite.addTest(TestCaseLogin('test_invalid_cases'))
    suite.addTest(TestCaseLogin('test_repeated_cases'))

    suite.addTest(TestCaseAlleleQuery('test_full_gene_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_full_gene_partial_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_full_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_max_length_cases'))
    suite.addTest(TestCaseAlleleQuery('test_mixed_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_no_input_cases'))
    suite.addTest(TestCaseAlleleQuery('test_no_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_partial_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_primer_cases'))
    suite.addTest(TestCaseAlleleQuery('test_sampling_full_cases'))
    suite.addTest(TestCaseAlleleQuery('test_sampling_mixed_cases'))
    suite.addTest(TestCaseAlleleQuery('test_sampling_no_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_sampling_partial_cases'))
    suite.addTest(TestCaseAlleleQuery('test_single_full_cases'))
    suite.addTest(TestCaseAlleleQuery('test_single_no_match_cases'))
    suite.addTest(TestCaseAlleleQuery('test_single_partial_cases'))

    suite.addTest(TestCaseBatchProfileQuery('test_batch_profile_query_invalid_cases'))
    suite.addTest(TestCaseBatchProfileQuery('test_batch_profile_query_negative_cases'))
    suite.addTest(TestCaseBatchProfileQuery('test_batch_profile_query_positive_cases'))

    suite.addTest(TestCaseChangeEmailViaApp('test_change_email_empty_cases'))
    suite.addTest(TestCaseChangeEmailViaApp('test_change_email_invalid_cases'))
    suite.addTest(TestCaseChangeEmailViaApp('test_change_email_negative_cases'))
    suite.addTest(TestCaseChangeEmailViaApp('test_change_email_positive_cases'))

    suite.addTest(TestCaseChangeUsernameViaApp('test_change_username_empty_cases'))
    suite.addTest(TestCaseChangeUsernameViaApp('test_change_username_invalid_cases'))
    suite.addTest(TestCaseChangeUsernameViaApp('test_change_username_negative_cases'))
    suite.addTest(TestCaseChangeUsernameViaApp('test_change_username_positive_cases'))

    suite.addTest(TestCaseAddAllele('test_add_allele_positive_cases'))
    suite.addTest(TestCaseAddAllele('test_add_allele_negative_cases'))
    suite.addTest(TestCaseAddAllele('test_add_allele_invalid_cases'))
    suite.addTest(TestCaseAddAllele('test_add_allele_empty_cases'))

    suite.addTest(TestCaseAddAlleleWithMetadata('test_add_allele_metadata_negative_cases'))
    suite.addTest(TestCaseAddAlleleWithMetadata('test_add_allele_metadata_positive_cases'))

    suite.addTest(TestCaseBatchAddAllele('test_batch_add_allele_empty_cases'))
    suite.addTest(TestCaseBatchAddAllele('test_batch_add_allele_invalid_cases'))
    suite.addTest(TestCaseBatchAddAllele('test_batch_add_allele_negative_cases'))
    suite.addTest(TestCaseBatchAddAllele('test_batch_add_allele_positive_cases'))
    suite.addTest(TestCaseBatchAddAllele('test_batch_add_allele_wrong_loci_cases'))
    suite.addTest(TestCaseBatchAddAllele('test_batch_add_allele_wrong_length_cases'))

    suite.addTest(TestCaseEditAllele('test_edit_allele_empty_cases'))
    suite.addTest(TestCaseEditAllele('test_edit_allele_invalid_cases'))
    suite.addTest(TestCaseEditAllele('test_edit_allele_negative_cases'))
    suite.addTest(TestCaseEditAllele('test_edit_allele_positive_cases'))

    suite.addTest(TestCaseEditAlleleWithMetadata('test_edit_allele_metadata_positive_cases'))
    suite.addTest(TestCaseEditAlleleWithMetadata('test_edit_allele_metadata_negative_cases'))

    suite.addTest(TestCaseDeleteAllele('test_delete_allele_negative_cases'))
    suite.addTest(TestCaseDeleteAllele('test_delete_allele_positive_cases'))

    suite.addTest(TestCaseAddAminoAcidProfile('test_add_amino_acid_profile_positive_cases'))
    suite.addTest(TestCaseAddAminoAcidProfile('test_add_amino_acid_profile_negative_cases'))
    suite.addTest(TestCaseAddAminoAcidProfile('test_add_amino_acid_profile_invalid_cases'))
    suite.addTest(TestCaseAddAminoAcidProfile('test_add_amino_acid_profile_empty_cases'))

    suite.addTest(TestCaseEditAminoAcidProfile('test_edit_amino_acid_profile_positive_cases'))
    suite.addTest(TestCaseEditAminoAcidProfile('test_edit_amino_acid_profile_negative_cases'))
    suite.addTest(TestCaseEditAminoAcidProfile('test_edit_amino_acid_profile_invalid_cases'))
    suite.addTest(TestCaseEditAminoAcidProfile('test_edit_amino_acid_profile_empty_cases'))

    suite.addTest(TestCaseChangePasswordViaApp('test_change_password_empty_cases'))
    suite.addTest(TestCaseChangePasswordViaApp('test_change_password_invalid_cases'))
    suite.addTest(TestCaseChangePasswordViaApp('test_change_password_not_complex_cases'))
    suite.addTest(TestCaseChangePasswordViaApp('test_change_password_same_cases'))
    suite.addTest(TestCaseChangePasswordViaApp('test_change_password_negative_cases'))
    suite.addTest(TestCaseChangePasswordViaApp('test_change_password_positive_cases'))

    suite.addTest(TestCaseAddDeleteUsers('test_delete_users_via_sql_positive_case'))


    return suite

if __name__ == '__main__':
	# stop then start ngstar_server
    stop_ngstar()
    start_ngstar()

    if constants.USE_CHROME_DRIVER:
        driver = webdriver.Chrome(executable_path=constants.DRIVER_PATH)
    else:
        driver = webdriver.Firefox()

    driver.implicitly_wait(constants.IMPLICIT_WAIT)
    driver.set_window_size(1024, 768)

    TestCaseAccountLockout.DRIVER = driver
    TestCaseAddAminoAcidProfile.DRIVER = driver
    TestCaseAddDeleteUsers.DRIVER = driver
    TestCaseLogin.DRIVER = driver
    TestCaseAlleleQuery.DRIVER = driver
    TestCaseChangeEmailViaApp.DRIVER = driver
    TestCaseChangeUsernameViaApp.DRIVER = driver
    TestCaseAddAllele.DRIVER = driver
    TestCaseAddAlleleWithMetadata.DRIVER = driver
    TestCaseBatchAddAllele.DRIVER = driver
    TestCaseBatchAlleleQuery.DRIVER = driver
    TestCaseBatchProfileQuery.DRIVER = driver
    TestCaseEditAllele.DRIVER = driver
    TestCaseEditAlleleWithMetadata.DRIVER = driver
    TestCaseEditAminoAcidProfile.DRIVER = driver
    TestCaseDeleteAllele.DRIVER = driver
    TestCaseChangePasswordViaApp.DRIVER = driver

    test_suite = suite()
    runner = unittest.TextTestRunner()
    result = runner.run(test_suite)

    driver.close()

    # stop ngstar_server
    stop_ngstar()

    # return test status (failure or success)
    sys.exit(not result.wasSuccessful())
