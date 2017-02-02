import constants
import unittest
import pymysql
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

CLASS_NAME = "TestCaseAddAminoAcidProfile"


class TestCaseAddAminoAcidProfile(unittest.TestCase):

    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.PASSWORD_TEXTBOX_ID = "password"
        cls.ERROR_MODAL_ID = "errorModal"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.SIGN_IN_ALERT_ID = "sign_in_alert"
        cls.SIGN_IN_BTN_NAME = "Sign In"
        cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
        cls.SIGN_OUT_BTN_NAME = "Sign Out"
        cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
        cls.SUBMIT_BTN_ID = "submit"
        cls.USERNAME_TEXTBOX_ID = "username"

        cls.CURATOR_TOOLS = "Curator Tools"
        cls.MANAGE_AA_PROFILES = "Manage Amino Acid Profiles"
        cls.NEW_AA_PROFILE = "new-aa-profile"

        cls.ONISHI_TYPE_TEXTBOX_ID = "onishi_type"
        cls.MOSAIC_TEXTBOX_ID = "mosaic"
        cls.AA_PROFILE_TEXTBOX_ID = "amino_acid_profile"

        cls.DELETE_AA_PROFILE_BTN_CSS_SEL = "delete-aa-profile"
        cls.DELETE_AA_PROFILE_ALERT_BTN_ID = "delete-aa-profile-ok"
        cls.CLOSE_MODAL = "close-error-modal"

        cls.ADD_SUCCESS_ALERT_ID = "add-success-alert"
        cls.EDIT_SUCCESS_ALERT_ID = "edit-success-alert"
        cls.DELETE_SUCCESS_ALERT_ID = "delete-success-alert"

        cls.ONISHI_TYPE_EMPTY = "Please enter an Onishi type"
        cls.MOSAIC_EMPTY = "Please select a mosaic type"
        cls.AA_PROFILE_EMPTY = "Please enter an amino acid profile"

        cls.ONISHI_TYPE_INVALID = "Please enter a valid onishi type. This field accepts letters and numbers only"
        cls.AA_PROFILE_INVALID = "Please enter a valid amino acid profile. This field accepts letters and periods only"

        cls.add_success_msgs = {
                "Amino acid profile with Onishi XXXXXXXXXIX was added successfully!",
                "Amino acid profile with Onishi XXXXXXXXXX was added successfully!",
                "Amino acid profile with Onishi XXXXXXXXXXI was added successfully!",
                "Amino acid profile with Onishi XXXXXXXXXXII was added successfully!",
                "Amino acid profile with Onishi XXXXXXXXXXIII was added successfully!",
                "Amino acid profile with Onishi XXXXXXXXXXIV was added successfully!",
        }

        cls.delete_success_msg = "Amino acid profile was deleted successfully!"

        cls.validate_amino_acid_profiles_msgs = {
                "Please enter a valid Onishi type. This field accepts roman numerals only",
                "Please enter a valid mosaic value. This field only accepts Yes, No, or Semi",
                "Please enter a valid amino acid profile. This field only accepts letters and periods",
                "Please enter a different NG-STAR type. This NG-STAR type already exists",
                "Please enter a different Onishi type. This Onishi type already exists",
                "Please enter a different amino acid profile. This amino acid profile already exists",

        }

        cls.aa_profiles_count = ["0",
                                   "1",
                                   "2",
                                   "3",
                                   "4",
                                   "5"]

        cls.aa_duplicates_count = ["0",
                                   "1",
                                   "2"]


        cls.aa_onishi_types = {"0": "XXXXXXXXXIX",
                                "1": "XXXXXXXXXX",
                                "2": "XXXXXXXXXXI",
                                "3": "XXXXXXXXXXII",
                                "4": "XXXXXXXXXXIII",
                                "5": "XXXXXXXXXXIV"}

        cls.aa_mosaic = {"0": "Yes",
                            "1": "No",
                            "2": "Semi",
                            "3": "No",
                            "4": "Yes",
                            "5": "Semi"}

        cls.aa_profiles = {"0": "ICAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ.TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVVNV",
                            "1": "ICAKDDVNYGEDQQAADRRAIVAGTDLNERLQPSPRDSRGAEFEITLNRRPAVLQIFESRENPTTAFANVAAHGGAPPKII.A",
                            "2": "MGTKEDVNHAGEQKAADRRAMTSGVDATDTFLPATQ.TMTPKFDVTLNRRPAVVQIFESRENPTTAFANIAAHGGAPPKII.A",
                            "3": "ICAKDDVNYGEDQQAADRRAIVAGTDLNERLQPSPRDSRGAEFEITLNRRPAVLQIFESRENPTTVLVNVGAHGGAAPKII.A",
                            "4": "ICAKDDVNYGEDQQAADRRVMTSGVDPTDTFLPATQ.TMTPKFDVTLSRQKVEVKVIASKKEASIALVYVAANGSTPVQVVNV",
                            "5": "MCIKDDVNYGEDQQAADRRAIVAGTDLNERLQPSPRDSMTPKFDVTLSRQKVEVKVIASKKEATTALVNVAANGGTPPKIV.A"}


        cls.aa_duplicate_onishi_types = {"0": "XXXXXXXXXIX",
                                "1": "C",
                                "2": "XXXXXXXXXXIV"}

        cls.aa_duplicate_profiles = {"0": "ICAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ.TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVVNV",
                            "1": "ICAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ.TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVVNV",
                            "2": "CGTKEDVNHAGEQKAADRRAMTSGVDATDTFLPATQ.TMTPKFDVTLNRRRVVAQIFESRENPTTAFANIAAHGGAPPKAA.A"}


        cls.aa_invalid_onishi_types = {"0": "*",
                                "1": "@s",
                                "2": "S1#",
                                "3": "F*^@",
                                "4": "!#$&@",
                                "5": "(#&$&d3)"}

        cls.aa_invalid_mosaic = {"0": "Maybe",
                            "1": "Ye",
                            "2": "Non",
                            "3": "$emi",
                            "4": "F^DF",
                            "5": "#!#$"}

        cls.aa_invalid_profiles = {"0": "ICAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ?TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVV",
                            "1": "@CAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ.TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVVNV",
                            "2": "@CAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ.TMTPKFDVTLSRQKVEVKVIASKKEATTALVYV4ANGSTPVQVVNV",
                            "3": "ICAKEDASHAGEEQ$#AVEKQAMTSGVDATDTFLSATQ.TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVVN",
                            "4": "9CAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ.TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVVNV",
                            "5": "@CAKEDASHAGEEQAVEKQAMTSGVDATDTFLSATQ&TMTPKFDVTLSRQKVEVKVIASKKEATTALVYVAANGSTPVQVV87"}


        cls.aa_empty_onishi_types = {"0": "",
                                "1": "",
                                "2": "",
                                "3": "",
                                "4": "",
                                "5": ""}

        cls.aa_empty_mosaic = {"0": "",
                            "1": "",
                            "2": "",
                            "3": "",
                            "4": "",
                            "5": ""}

        cls.aa_empty_profiles = {"0": "",
                            "1": "",
                            "2": "",
                            "3": "",
                            "4": "",
                            "5": ""}


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


    def test_add_amino_acid_profile_positive_cases(self):

        driver = self.driver
        self.signIn()

        element = driver.find_element_by_link_text(self.CURATOR_TOOLS)
        element.click()
        element = driver.find_element_by_link_text(self.MANAGE_AA_PROFILES)
        element.click()
        element = driver.find_element_by_id(self.NEW_AA_PROFILE)
        element.click()

        for count in self.aa_profiles_count:

            onishi_type = self.aa_onishi_types[count]
            mosaic = self.aa_mosaic[count]
            aa_profile = self.aa_profiles[count]


            element = driver.find_element_by_id(self.ONISHI_TYPE_TEXTBOX_ID)
            element.send_keys(onishi_type)

            element = driver.find_element_by_id(self.MOSAIC_TEXTBOX_ID)
            element.send_keys(mosaic)

            element = driver.find_element_by_id(self.AA_PROFILE_TEXTBOX_ID)
            element.send_keys(aa_profile)

            element.submit()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ADD_SUCCESS_ALERT_ID))
            )

            for add_success_msg in self.add_success_msgs:

                self.CURR_MSG = add_success_msg

                if element.text == self.CURR_MSG:

                    self.assertIn(self.CURR_MSG, element.text)

            element = driver.find_element_by_id(self.NEW_AA_PROFILE)
            element.click()

        self.signOut()
        self.clearNewAminoAcids()

    def test_add_amino_acid_profile_negative_cases(self):

        driver = self.driver
        self.signIn()

        element = driver.find_element_by_link_text(self.CURATOR_TOOLS)
        element.click()
        element = driver.find_element_by_link_text(self.MANAGE_AA_PROFILES)
        element.click()
        element = driver.find_element_by_id(self.NEW_AA_PROFILE)
        element.click()

        for count in self.aa_profiles_count:

            onishi_type = self.aa_onishi_types[count]
            mosaic = self.aa_mosaic[count]
            aa_profile = self.aa_profiles[count]


            element = driver.find_element_by_id(self.ONISHI_TYPE_TEXTBOX_ID)
            element.send_keys(onishi_type)

            element = driver.find_element_by_id(self.MOSAIC_TEXTBOX_ID)
            element.send_keys(mosaic)

            element = driver.find_element_by_id(self.AA_PROFILE_TEXTBOX_ID)
            element.send_keys(aa_profile)

            element.submit()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ADD_SUCCESS_ALERT_ID))
            )

            for add_success_msg in self.add_success_msgs:

                self.CURR_MSG = add_success_msg

                if element.text == self.CURR_MSG:

                    self.assertIn(self.CURR_MSG, element.text)

            element = driver.find_element_by_id(self.NEW_AA_PROFILE)
            element.click()


        for count in self.aa_duplicates_count:

            onishi_type = self.aa_duplicate_onishi_types[count]
            mosaic = self.aa_mosaic[count]
            aa_profile = self.aa_duplicate_profiles[count]

            element = driver.find_element_by_id(self.ONISHI_TYPE_TEXTBOX_ID)
            element.send_keys(onishi_type)

            element = driver.find_element_by_id(self.MOSAIC_TEXTBOX_ID)
            element.send_keys(mosaic)

            element = driver.find_element_by_id(self.AA_PROFILE_TEXTBOX_ID)
            element.send_keys(aa_profile)

            element.submit()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
            )

    	    for validation_msg in self.validate_amino_acid_profiles_msgs:

                self.CURR_MSG = validation_msg

                if element.text == self.CURR_MSG:

                    self.assertIn(self.CURR_MSG, element.text)

            element = driver.find_element_by_id(self.CLOSE_MODAL)
            element = element.click()

            element = driver.find_element_by_link_text(self.CURATOR_TOOLS)
            element.click()
            element = driver.find_element_by_link_text(self.MANAGE_AA_PROFILES)
            element.click()
            element = driver.find_element_by_id(self.NEW_AA_PROFILE)
            element.click()

        self.signOut()
        self.clearNewAminoAcids()

    def test_add_amino_acid_profile_invalid_cases(self):

        driver = self.driver
        self.signIn()

        element = driver.find_element_by_link_text(self.CURATOR_TOOLS)
        element.click()
        element = driver.find_element_by_link_text(self.MANAGE_AA_PROFILES)
        element.click()
        element = driver.find_element_by_id(self.NEW_AA_PROFILE)
        element.click()

        for count in self.aa_profiles_count:

            onishi_type = self.aa_invalid_onishi_types[count]
            mosaic = self.aa_invalid_mosaic[count]
            aa_profile = self.aa_invalid_profiles[count]

            element = driver.find_element_by_id(self.ONISHI_TYPE_TEXTBOX_ID)
            element.send_keys(onishi_type)

            element = driver.find_element_by_xpath('/html/body/main/form/div[3]/div/div/div/span/span[1]/span')
            element.click()
            element.send_keys(mosaic)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.AA_PROFILE_TEXTBOX_ID)
            element.send_keys(aa_profile)

            element.submit()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.ONISHI_TYPE_INVALID, error_msgs, error_msgs)
            self.assertIn(self.AA_PROFILE_INVALID, error_msgs, error_msgs)


            element = driver.find_element_by_link_text(self.CURATOR_TOOLS)
            element.click()
            element = driver.find_element_by_link_text(self.MANAGE_AA_PROFILES)
            element.click()
            element = driver.find_element_by_id(self.NEW_AA_PROFILE)
            element.click()

        self.signOut()

    def test_add_amino_acid_profile_empty_cases(self):

        driver = self.driver
        self.signIn()

        element = driver.find_element_by_link_text(self.CURATOR_TOOLS)
        element.click()
        element = driver.find_element_by_link_text(self.MANAGE_AA_PROFILES)
        element.click()
        element = driver.find_element_by_id(self.NEW_AA_PROFILE)
        element.click()

        for count in self.aa_profiles_count:

            onishi_type = self.aa_empty_onishi_types[count]
            aa_profile = self.aa_empty_profiles[count]

            element = driver.find_element_by_id(self.ONISHI_TYPE_TEXTBOX_ID)
            element.send_keys(onishi_type)

            element = driver.find_element_by_id(self.AA_PROFILE_TEXTBOX_ID)
            element.send_keys(aa_profile)

            element.submit()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.ONISHI_TYPE_EMPTY, error_msgs, error_msgs)
            self.assertIn(self.MOSAIC_EMPTY, error_msgs, error_msgs)
            self.assertIn(self.AA_PROFILE_EMPTY, error_msgs, error_msgs)


            element = driver.find_element_by_link_text(self.CURATOR_TOOLS)
            element.click()
            element = driver.find_element_by_link_text(self.MANAGE_AA_PROFILES)
            element.click()
            element = driver.find_element_by_id(self.NEW_AA_PROFILE)
            element.click()

        self.signOut()


    def clearNewAminoAcids(self):

        driver = self.driver

        try:

        	conn = pymysql.connect(host=constants.DB_HOST, user=constants.DB_USERNAME, passwd=constants.DB_PASSWORD, db=constants.DB_NAME)
        	cur = conn.cursor()

        except:

        	print "No connection"

        for count in self.aa_profiles_count:

		onishi_type = self.aa_onishi_types[count]

		cur.execute("DELETE FROM tbl_Onishi WHERE onishi_type=%s", (onishi_type))
		conn.commit()

        cur.close()
        conn.close()




    @classmethod
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()


if __name__ == '__main__':
    unittest.main()
