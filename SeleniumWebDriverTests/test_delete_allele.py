import constants
import unittest
import pymysql
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


CLASS_NAME = "TestCaseDeleteAllele"


class TestCaseDeleteAllele(unittest.TestCase):
    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.PASSWORD_TEXTBOX_ID = "password"
        cls.ADD_ALLELE_TYPE_TEXTBOX_ID = "allele_type"
        cls.ADD_ALLELE_SEQ_TEXTBOX_ID = "allele_sequence"
        cls.ADD_ALLELE_SUCCESS_MSG = "Allele submitted successfully!"
        cls.ADD_PROFILE_SUCCESS_MSG = "Profile submitted successfully!"
        cls.ADD_PROFILE_TEXTBOX_IDS = {"st": "sequence_type",
                                        "penA": "allele_type0",
                                         "mtrR": "allele_type1",
                                         "porB": "allele_type2",
                                         "ponA": "allele_type3",
                                         "gyrA": "allele_type4",
                                         "parC": "allele_type5",
                                         "23S": "allele_type6"}
        cls.ALLELE_LIST_ALERT_ID = "allele_list_alert"

        ### Following error code is for when an allele is a part of a profile
        ### Profile must be deleted before allele
        cls.ALLELE_TYPE_IN_PROFILE = "Error: 2001"

        cls.DELETE_ALLELE_BTN_CSS_SEL = "delete-allele"
        cls.DELETE_ALLELE_ALERT_BTN_ID = "delete-ok"
        cls.DELETE_ALLELE_SUCCESS_MSG = "Allele deleted successfully!"
        cls.DELETE_PROFILE_ALERT_BTN_ID = "delete-profile-ok"
        cls.DELETE_PROFILE_BTN_CSS_SEL = "delete-profile"
        cls.DELETE_PROFILE_SUCCESS_MSG = "Profile deleted successfully!"
        cls.ERROR_MODAL_ID = "errorModal"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.PROFILE_LIST_ALERT_ID = "my-alert"
        cls.SIGN_IN_ALERT_ID = "sign_in_alert"
        cls.SIGN_IN_BTN_NAME = "Sign In"
        cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
        cls.SIGN_OUT_BTN_NAME = "Sign Out"
        cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
        cls.SUBMIT_BTN_ID = "submit"
        cls.USERNAME_TEXTBOX_ID = "username"

        cls.DELETE_PROFILE_ALERT_ID="deleteProfileModal"

        cls.loci_names = ["penA",
                           "mtrR",
                           "porB",
                           "ponA",
                           "gyrA",
                           "parC",
                           "23S"]

        cls.add_profile_textbox_names = ["penA",
                           "mtrR",
                           "porB",
                           "ponA",
                           "gyrA",
                           "parC",
                           "23S"]


        cls.profile_allele_types = {"penA": "0.001",
                                         "mtrR": "1",
                                         "porB": "2",
                                         "ponA": "3",
                                         "gyrA": "4",
                                         "parC": "5",
                                         "23S": "6"}

        cls.allele_types = {"penA": "0.001",
                                         "mtrR": "1",
                                         "porB": "2",
                                         "ponA": "3",
                                         "gyrA": "4",
                                         "parC": "5",
                                         "23S": "6"}

        cls.seq_types_stored = ["1"]

        cls.allele_types_clear_db = {"penA": "0.001",
                                      "mtrR": "1",
                                      "porB": "2",
                                      "ponA": "3",
                                      "gyrA": "4",
                                      "parC": "5",
                                      "23S":  "6"}


        cls.positive_sequences = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGCGCCAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S":  "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
        }

        if not cls.DRIVER:
            if constants.USE_CHROME_DRIVER:
                cls.driver = webdriver.Chrome(executable_path=constants.DRIVER_PATH)
            else:
                cls.driver = webdriver.Firefox()

            cls.driver.implicitly_wait(constants.IMPLICIT_WAIT)
            cls.driver.set_window_size(1024, 768)
        else:
            cls.driver = cls.DRIVER

        #cls.populateDB()

    def signIn(self):

        METHOD_NAME = "signIn"

        driver = self.driver
        test_number = 1

        test_input = ("test01", "Mypass1!")
        username = test_input[0]
        password = test_input[1]

        cookies = driver.get_cookies()

        lang_selected = False
        eula_accepted = False

        for cookie in cookies:
            if cookie['name'] == 'ngstar_eula_acceptance':
                eula_accepted = True
            if cookie['name'] == 'ngstar_lang_pref':
                lang_selected = True

        if lang_selected == False:
            driver.get(constants.WELCOME_URL)
            element = driver.find_element_by_id("btn-en")
            element.click()

            element = driver.find_element_by_id("launch-ngstar")
            element.click()

        if eula_accepted == False:
            element = driver.find_element_by_id("eula_accept")
            element.click()

        # click Sign In button
        driver.get(constants.HOME_URL)
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: " \
            "Could not find [{4}] button".format(test_number,
                                                 CLASS_NAME,
                                                 METHOD_NAME,
                                                 test_input,
                                                 self.SIGN_IN_BTN_NAME)
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)
        element.send_keys(username)
        element = driver.find_element_by_id(self.PASSWORD_TEXTBOX_ID)
        element.send_keys(password)
        element.submit()

        # logout
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: " \
            "Could not find [{4}] button".format(test_number,
                                                 CLASS_NAME,
                                                 METHOD_NAME,
                                                 test_input,
                                                 self.SIGN_OUT_BTN_NAME)
        self.assertIn(self.SIGN_OUT_BTN_NAME, driver.page_source, msg)

        test_number = test_number + 1

    def signOut(self):

        METHOD_NAME = "signOut"

        driver = self.driver
        test_number = 1

        test_input = ("test01", "Mypass1!")

        driver.get(constants.HOME_URL)
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: " \
            "Could not find [{4}] button".format(test_number,
                                                 CLASS_NAME,
                                                 METHOD_NAME,
                                                 test_input,
                                                 self.SIGN_OUT_BTN_NAME)
        self.assertIn(self.SIGN_OUT_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_OUT_BTN_NAME)
        element.click()
        test_number = test_number + 1

    def populateDB(self):

        driver = self.driver

        for loci_name in self.loci_names:

            allele_type = self.allele_types[loci_name]
            sequence = self.positive_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            driver.get(constants.ADD_ALLELE_URL)

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            element = WebDriverWait(driver, 10).until(
            	EC.presence_of_element_located((By.ID, self.ALLELE_LIST_ALERT_ID))
            )

            self.assertIn(self.ADD_ALLELE_SUCCESS_MSG, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[1]")
            self.assertIn(allele_type, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[2]")
            self.assertIn(loci_name, element.text)

    def populateProfiles(self):

        driver = self.driver

        driver.get(constants.ADD_PROFILE_BASE_URL)

        for field_name in self.add_profile_textbox_names:

            profile_allele_type = self.profile_allele_types[field_name]

            element = driver.find_element_by_id(self.ADD_PROFILE_TEXTBOX_IDS[field_name])
            element.send_keys(profile_allele_type)

        element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
        element.click()

        element = WebDriverWait(driver, 10).until(
        	EC.presence_of_element_located((By.ID, self.PROFILE_LIST_ALERT_ID))
        )

        self.assertIn(self.ADD_PROFILE_SUCCESS_MSG, element.text)



    def test_delete_allele_positive_cases(self):

        driver = self.driver
        self.signIn()

        self.populateDB()

        for loci_name in self.loci_names:
            allele_type = self.allele_types_clear_db[loci_name]

            radio_button_value = loci_name + ":" + allele_type
            driver.get(constants.LIST_LOCI_ALLELES_BASE_URL + loci_name)
            element = driver.find_element_by_css_selector("input[type='radio'][value='" + radio_button_value + "']")
            element.click()
            element = driver.find_element_by_id(self.DELETE_ALLELE_BTN_CSS_SEL)
            element.click()

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            script = "window.jQuery(document).ready(function() { \
                          $('" + "#" + self.DELETE_ALLELE_ALERT_BTN_ID + "').click(); \
                      })"
            driver.execute_script(script)
            elements = driver.find_elements_by_tag_name("strong")
            msgs = [e.text for e in elements]
            self.assertIn(self.DELETE_ALLELE_SUCCESS_MSG, msgs)

        self.signOut()


    def test_delete_allele_negative_cases(self):

        driver = self.driver
        self.signIn()

        self.populateDB()
        self.populateProfiles()

        for loci_name in self.loci_names:
            allele_type = self.allele_types_clear_db[loci_name]

            radio_button_value = loci_name + ":" + allele_type
            driver.get(constants.LIST_LOCI_ALLELES_BASE_URL + loci_name)
            element = driver.find_element_by_css_selector("input[type='radio'][value='" + radio_button_value + "']")
            element.click()
            element = driver.find_element_by_id(self.DELETE_ALLELE_BTN_CSS_SEL)
            element.click()

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            script = "window.jQuery(document).ready(function() { \
                          $('" + "#" + self.DELETE_ALLELE_ALERT_BTN_ID + "').click(); \
                      })"
            driver.execute_script(script)

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
            )

            self.assertIn(self.ALLELE_TYPE_IN_PROFILE, element.text)

        self.signOut()
        self.clearAlleles()

    def clearAlleles(self):

        driver = self.driver

        try:

        	conn = pymysql.connect(host=constants.DB_HOST, user=constants.DB_USERNAME, passwd=constants.DB_PASSWORD, db=constants.NGSTAR_DB_NAME)
        	cur = conn.cursor()

        except:

        	print "No connection"


        cur.execute("DELETE FROM tbl_Allele_SequenceType")
        conn.commit()

        cur.execute("DELETE FROM tbl_SequenceType")
        conn.commit()

        cur.execute("DELETE FROM tbl_Allele")
        conn.commit()

        cur.execute("DELETE FROM tbl_Metadata_MIC")
        conn.commit()

        cur.execute("DELETE FROM tbl_Metadata_IsolateClassification")
        conn.commit()

        cur.execute("DELETE FROM tbl_Metadata")
        conn.commit()

        cur.close()
        conn.close()


    @classmethod
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()


if __name__ == '__main__':
    unittest.main()
