import constants
import unittest
import pymysql
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

CLASS_NAME = "TestCaseBatchAlleleQuery"


class TestCaseBatchAlleleQuery(unittest.TestCase):
    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.PASSWORD_TEXTBOX_ID = "password"
        cls.ADD_ALLELE_TYPE_TEXTBOX_ID = "allele_type"
        cls.ADD_ALLELE_SEQ_TEXTBOX_ID = "allele_sequence"
        cls.ADD_ALLELE_SUCCESS_MSG = "Allele submitted successfully!"
        cls.ALLELE_TYPE_EXISTS = "Please enter a different allele type."
        cls.ALLELE_LIST_ALERT_ID = "allele_list_alert"
        cls.ALLELE_QUERY_SUBMIT_BTN_CSS_SEL = "button[type='submit'][value='allele']"
        cls.DELETE_ALLELE_BTN_CSS_SEL = "delete-allele"
        cls.DELETE_ALLELE_ALERT_BTN_ID = "delete-ok"
        cls.DELETE_ALLELE_SUCCESS_MSG = "Allele deleted successfully!"
        cls.ALERT_ID = "errorModal"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.SIGN_IN_ALERT_ID = "sign_in_alert"
        cls.SIGN_IN_BTN_NAME = "Sign In"
        cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
        cls.SIGN_OUT_BTN_NAME = "Sign Out"
        cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
        cls.SUBMIT_BTN_ID = "submit"
        cls.USERNAME_TEXTBOX_ID = "username"
        cls.BATCH_ALLELES_QUERY_TEXTBOX_ID = "batch_fasta_sequences"
        cls.INVALID_HEADER = "Invalid fasta header in fasta input. Please see the batch allele query example page for valid headers."
        cls.INVALID_SAMPLE_NUMBER = "Invalid sample number. Sample numbers must be greater 0 with no decimals."
        cls.INVALID_INPUT_CHARS = "Please enter sequences in valid fasta format. This field only accepts letters, numbers, and these special characters [ . _ > ]"
        cls.INVALID_LOCI = "Invalid loci in fasta input. Loci accepted: penA,mtrR,porB,ponA,gyrA,parC,23S"
        cls.INVALID_SEQUENCE = "Invalid sequence in fasta input. Sequences must only include the following letters [A, C, T, G]."

        cls.loci_names = ["penA",
                           "mtrR",
                           "porB",
                           "ponA",
                           "gyrA",
                           "parC",
                           "23S"]

        cls.allele_types = {"penA": "0.001",
                                         "mtrR": "1",
                                         "porB": "2",
                                         "ponA": "3",
                                         "gyrA": "4",
                                         "parC": "5",
                                         "23S": "6"}

        cls.allele_types_additional = {"penA": "1.001",
                                         "mtrR": "2",
                                         "porB": "3",
                                         "ponA": "4",
                                         "gyrA": "5",
                                         "parC": "6",
                                         "23S": "7"}


        cls.sequences = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGCGCCAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "CTGTACGCGATGCACGAGCTGAAAAATAACTGGAATGCCGCCTACAAAAAATCGGCGCGCATCGTCGGCGACGTCATCGGTAAATACCACCCCCACGGCGATTCCGCAGTTTACGACACCATCGTCCGTATGGCGCAAAATTTCGCTATGCGTTATGTGCTGATAGACGGACAGGGCAACTTCGGATCGGTGGACGGGCTTGCCGCCGCAGCCATGCGCTATACCGAAATCCGCATGGCGAAAATCTCACATGAAATGCTGGCA",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S":  "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
        }

        cls.sequences_additional = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGACGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGCCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATTGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAGTCTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTCTATTGGCATTTCAAAAATAAGGAAGACTTGTTTGACGCGTTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGTTCTTGGACGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGTGCCAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGAGCCGTTGCCGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "CTGTACGCGATGCACGAGCTGAAAAATAACTGGAATGCCGCCTACAAAAAATCGGCGCGCATCGTCGGCGACGTCATCGGTAAATACCACCCCCACGGCGATTTCGCAGTTTACGGCACCATCGTCCGTATGGCGCAAAATTTCGCTATGCGTTATGTGCTGATAGACGGACAGGGCAACTTCGGATCGGTGGACGGGCTTGCCGCCGCAGCCATGCGCTATACCGAAATCCGCATGGCGAAAATCTCACATGAAATGCTGGCA",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTATCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTCACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S":  "TAGACGGAGAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
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


    def test_batch_allele_query_positive_cases(self):

        driver = self.driver

        self.populateDB()

        driver.get(constants.BATCH_ALLELE_QUERY_URL)

        fileToOpen = open('SeleniumWebDriverTests/queryfiles/fullmatches.fasta', 'r')

        fasta_sequences = ""

        for line in fileToOpen:
            fasta_sequences += line

        element = driver.find_element_by_id(self.BATCH_ALLELES_QUERY_TEXTBOX_ID)
        element.send_keys(fasta_sequences)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[1]")
        self.assertIn("1234", element.text)

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


        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[1]")
        self.assertIn("1235", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[2]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[3]")
        self.assertIn("2", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[4]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[5]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[6]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[7]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[8]")
        self.assertIn("7", element.text)


        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[1]")
        self.assertIn("1236", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[2]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[3]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[4]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[5]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[6]")
        self.assertIn("5", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[7]")
        self.assertIn("--", element.text)

        element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[8]")
        self.assertIn("--", element.text)


    def test_batch_allele_query_negative_cases(self):

        driver = self.driver

        driver.get(constants.BATCH_ALLELE_QUERY_URL)

        fileToOpen = open('SeleniumWebDriverTests/queryfiles/invalidheaders.fasta', 'r')

        fasta_sequences = ""

        for line in fileToOpen:
            fasta_sequences += line

        element = driver.find_element_by_id(self.BATCH_ALLELES_QUERY_TEXTBOX_ID)
        element.send_keys(fasta_sequences)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.ID, self.ALERT_ID))
        )

        self.assertIn(self.INVALID_HEADER, element.text)


        driver.get(constants.BATCH_ALLELE_QUERY_URL)

        fileToOpen = open('SeleniumWebDriverTests/queryfiles/invalidsamplenumbers.fasta', 'r')

        fasta_sequences = ""

        for line in fileToOpen:
            fasta_sequences += line

        element = driver.find_element_by_id(self.BATCH_ALLELES_QUERY_TEXTBOX_ID)
        element.send_keys(fasta_sequences)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.ID, self.ALERT_ID))
        )

        self.assertIn(self.INVALID_SAMPLE_NUMBER, element.text)


        driver.get(constants.BATCH_ALLELE_QUERY_URL)

        fileToOpen = open('SeleniumWebDriverTests/queryfiles/invalidloci.fasta', 'r')

        fasta_sequences = ""

        for line in fileToOpen:
            fasta_sequences += line

        element = driver.find_element_by_id(self.BATCH_ALLELES_QUERY_TEXTBOX_ID)
        element.send_keys(fasta_sequences)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.ID, self.ALERT_ID))
        )

        self.assertIn(self.INVALID_LOCI, element.text)


        driver.get(constants.BATCH_ALLELE_QUERY_URL)

        fileToOpen = open('SeleniumWebDriverTests/queryfiles/invalidsequences.fasta', 'r')

        fasta_sequences = ""

        for line in fileToOpen:
            fasta_sequences += line

        element = driver.find_element_by_id(self.BATCH_ALLELES_QUERY_TEXTBOX_ID)
        element.send_keys(fasta_sequences)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        element = WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.ID, self.ALERT_ID))
        )

        self.assertIn(self.INVALID_SEQUENCE, element.text)


        self.clearDB()


    def test_batch_allele_query_invalid_cases(self):

        driver = self.driver

        driver.get(constants.BATCH_ALLELE_QUERY_URL)

        fileToOpen = open('SeleniumWebDriverTests/queryfiles/invalidcharacters.fasta', 'r')

        fasta_sequences = ""

        for line in fileToOpen:
            fasta_sequences += line

        element = driver.find_element_by_id(self.BATCH_ALLELES_QUERY_TEXTBOX_ID)
        element.send_keys(fasta_sequences)

        element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
        element.click()

        elements = driver.find_elements_by_class_name("help-block")
        error_msgs = [element.text for element in elements]

        self.assertIn(self.INVALID_INPUT_CHARS, error_msgs, error_msgs)


    def populateDB(self):

        driver = self.driver

        self.signIn()

        for loci_name in self.loci_names:

            allele_type = self.allele_types[loci_name]
            sequence = self.sequences[loci_name]

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

        for loci_name in self.loci_names:

            allele_type = self.allele_types_additional[loci_name]
            sequence = self.sequences_additional[loci_name]

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
            element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[1]")
            self.assertIn(allele_type, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[2]")
            self.assertIn(loci_name, element.text)

        self.signOut()

    def clearDB(self):

        driver = self.driver

        try:

        	conn = pymysql.connect(host=constants.DB_HOST, user=constants.DB_USERNAME, passwd=constants.DB_PASSWORD, db=constants.NGSTAR_DB_NAME)
        	cur = conn.cursor()

        except:

        	print "No connection"

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
