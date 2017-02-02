import constants
import unittest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


CLASS_NAME = "TestCaseBatchProfileQuery"


class TestCaseBatchProfileQuery(unittest.TestCase):
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
        cls.BATCH_PROFILE_QUERY_TEXTBOX_ID = "batch_profile_query"
        cls.BATCH_PROFILE_QUERY_CHAR_ERROR = "Invalid characters in profiles. This field can only contain numbers and these special characters [ . , ]"
        cls.BATCH_PROFILE_QUERY_EMPTY_PROFILES ="No profiles were entered. Please enter atleast one profile to query."
        cls.BATCH_PROFILE_QUERY_INCORRECT_NUM_FIELDS = "Batch profile query data invalid. Please make sure the input is either comma separated or tab separated and has the required number of columns. Each line must include 8 columns (1 for the ID and 7 for the 7 different loci)."
        cls.BATCH_PROFILE_QUERY_NO_PROFILES_EXIST = "No profiles currently exist!"
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

        cls.add_profile_textbox_names = ["st",
                           "penA",
                           "mtrR",
                           "porB",
                           "ponA",
                           "gyrA",
                           "parC",
                           "23S"]


        cls.profile_allele_types = {"st": "1",
                                        "penA": "0.001",
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

        cls.csv_query_string = "44119,0.001,1,2,3,4,5,6\n44120,1.001,1,2,3,4,5,6\n44121,0.001,2,2,3,4,5,6\n44122,0.001,1,3,3,4,5,6\n"

        cls.csv_incorrect_fields_query_string = "44119,0.001,1,2,3,4,5\n44120,1.001,1,2,3,4,5\n44121,0.001,2,2,3,4,5\n44122,0.001,1,3,3,4,5\n"

        cls.csv_invalid_query_string = "44119(,)0.001,-1,+2,=3,4,5,6\n44120,1.001,1,2,3,4,5,6\n44121,0.001,_2,2,3,4,5,6\n44122,0.001,1,3,3,4,5,6\n"

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
        self.signIn()

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

        self.signOut()


    def populateProfiles(self):

        driver = self.driver
        self.signIn()

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

        self.signOut()



    def test_batch_profile_query_positive_cases(self):

        driver = self.driver

        self.populateDB()
        self.populateProfiles()

        driver.get(constants.BATCH_PROFILE_QUERY_URL)

        WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

        element = driver.find_element_by_id(self.BATCH_PROFILE_QUERY_TEXTBOX_ID)
        element.send_keys(self.csv_query_string)


        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        # 1 Comma separated

        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[1]")
        self.assertIn("44119", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[2]")
        self.assertIn("0.001", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[3]")
        self.assertIn("1", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[4]")
        self.assertIn("2", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[5]")
        self.assertIn("3", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[6]")
        self.assertIn("4", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[7]")
        self.assertIn("5", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[8]")
        self.assertIn("6", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[9]")
        self.assertIn("1", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[10]")
        self.assertIn("None", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[1]")
        self.assertIn("44120", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[2]")
        self.assertIn("1.001", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[3]")
        self.assertIn("1", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[4]")
        self.assertIn("2", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[5]")
        self.assertIn("3", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[6]")
        self.assertIn("4", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[7]")
        self.assertIn("5", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[8]")
        self.assertIn("6", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[9]")
        self.assertIn("--", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[10]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[1]")
        self.assertIn("44121", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[2]")
        self.assertIn("0.001", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[3]")
        self.assertIn("2", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[4]")
        self.assertIn("2", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[5]")
        self.assertIn("3", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[6]")
        self.assertIn("4", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[7]")
        self.assertIn("5", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[8]")
        self.assertIn("6", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[9]")
        self.assertIn("--", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[10]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[1]")
        self.assertIn("44122", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[2]")
        self.assertIn("0.001", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[3]")
        self.assertIn("1", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[4]")
        self.assertIn("3", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[5]")
        self.assertIn("3", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[6]")
        self.assertIn("4", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[7]")
        self.assertIn("5", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[8]")
        self.assertIn("6", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[9]")
        self.assertIn("--", element.text)
        element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[10]")
        self.assertIn("--", element.text)


        self.clearProfiles()
        self.clearAlleles()



    def test_batch_profile_query_negative_cases(self):

        driver = self.driver
        self.signIn()

        # 1 NO PROFILES IN SYSTEM CSV
        driver.get(constants.BATCH_PROFILE_QUERY_URL)

        element = driver.find_element_by_id(self.BATCH_PROFILE_QUERY_TEXTBOX_ID)
        element.send_keys("")

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = WebDriverWait(driver, 60).until(
        	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
        )

        self.assertIn(self.BATCH_PROFILE_QUERY_EMPTY_PROFILES, element.text)



        # 2 INVALID INPUT CHARS CSV
        driver.get(constants.BATCH_PROFILE_QUERY_URL)

        element = driver.find_element_by_id(self.BATCH_PROFILE_QUERY_TEXTBOX_ID)
        element.send_keys(self.csv_invalid_query_string)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        elements = driver.find_elements_by_class_name("help-block")
        error_msgs = [element.text for element in elements]
        self.assertIn(self.BATCH_PROFILE_QUERY_CHAR_ERROR, error_msgs, error_msgs)


        # 3 NO PROFILES EXIST
        driver.get(constants.BATCH_PROFILE_QUERY_URL)

        element = driver.find_element_by_id(self.BATCH_PROFILE_QUERY_TEXTBOX_ID)
        element.send_keys(self.csv_incorrect_fields_query_string)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = WebDriverWait(driver, 60).until(
        	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
        )

        self.assertIn(self.BATCH_PROFILE_QUERY_NO_PROFILES_EXIST, element.text)

        self.signOut()


    def test_batch_profile_query_invalid_cases(self):

        driver = self.driver

        self.populateDB()
        self.populateProfiles()

        # 3 INCORRECT NUM FIELDS
        driver.get(constants.BATCH_PROFILE_QUERY_URL)

        element = driver.find_element_by_id(self.BATCH_PROFILE_QUERY_TEXTBOX_ID)
        element.send_keys(self.csv_incorrect_fields_query_string)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = WebDriverWait(driver, 60).until(
        	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
        )

        self.assertIn(self.BATCH_PROFILE_QUERY_INCORRECT_NUM_FIELDS, element.text)

        self.clearProfiles()
        self.clearAlleles()


    def clearProfiles(self):

        driver = self.driver
        self.signIn()

        for seq_type in self.seq_types_stored:

            radio_button_value = seq_type

            driver.get(constants.LIST_PROFILES_BASE_URL)
            element = driver.find_element_by_css_selector("input[type='radio'][value='"+ radio_button_value +"']")
            element.click()
            element = driver.find_element_by_id(self.DELETE_PROFILE_BTN_CSS_SEL)
            element.click()


            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            script = "window.jQuery(document).ready(function() { \
                          $('" + "#" + self.DELETE_PROFILE_ALERT_BTN_ID + "').click(); \
                      })"
            driver.execute_script(script)


            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.PROFILE_LIST_ALERT_ID))
            )

            self.assertIn(self.DELETE_PROFILE_SUCCESS_MSG, element.text)

        self.signOut()


    def clearAlleles(self):

        driver = self.driver
        self.signIn()

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


    @classmethod
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()


if __name__ == '__main__':
    unittest.main()
