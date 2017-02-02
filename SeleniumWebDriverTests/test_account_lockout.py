import constants
import unittest
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

CLASS_NAME = "TestCaseAccountLockout"


class TestCaseAccountLockout(unittest.TestCase):


    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.ALERT_CLASS = "alert"
        cls.ERROR_MODAL_ID = "errorModal"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.PASSWORD_TEXTBOX_ID = "password"
        cls.SIGN_IN_ALERT_ID = "sign_in_alert"
        cls.SIGN_IN_BTN_NAME = "Sign In"
        cls.SIGN_IN_ACCT_LOCKED_VAL = "This account has been locked out due to too many failed sign in attempts. Please try again later."
        cls.SIGN_IN_HEADING_VAL = "Please sign in"
        cls.SIGN_IN_HEADING_ID = "wb-cont"
        cls.SIGN_IN_INVALID_VAL = "Invalid username or password! Please try again"
        cls.SIGN_OUT_BTN_NAME = "Sign Out"
        cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
        cls.SUBMIT_BTN_ID = "submit"
        cls.USERNAME_TEXTBOX_ID = "username"

        cls.username = "test02"
        cls.password = "Mypass2!"

        cls.iterations =[0,
                           1,
                           2,
                           3,
                           4,
                           5,
                           6,
                           7,
                           8,
                           9,
                           10,
                           11,
                           12]

        cls.user_accounts = {0: "test02",
                         1: "test02",
                         2: "test02",
                         3: "test02",
                         4: "test02",
                         5: "test02",
                         6: "test02",
                         7 : "test02",
                         8 : "test02",
                         9 : "test02",
                        10 : "test02",
                        11 : "test02",
                        12 : "test02"}

        cls.user_passwords = {0: "Mypass1!",
                         1: "Mypass1!",
                         2: "Mypass1!",
                         3: "Mypass1!",
                         4: "Mypass1!",
                         5: "Mypass1!",
                         6: "Mypass1!",
                         7 : "Mypass1!",
                         8 : "Mypass1!",
                         9 : "Mypass1!",
                        10 : "Mypass1!",
                        11 : "Mypass1!",
                        12 : "Mypass1!"}


        if not cls.DRIVER:
            if constants.USE_CHROME_DRIVER:
                cls.driver = webdriver.Chrome(executable_path=constants.DRIVER_PATH)
            else:
                cls.driver = webdriver.Firefox()

            cls.driver.implicitly_wait(constants.IMPLICIT_WAIT)
            cls.driver.set_window_size(1024, 768)
        else:
            cls.driver = cls.DRIVER



    #Test user account lockout due to too many failed attempts in x amount of time
    def test_account_lockout_positive_case(self):

        driver = self.driver
        METHOD_NAME = "test_account_lockout_case"

        driver = self.driver
        test_number = 1


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
        msg = "error"
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

        username = self.username
        password = self.password

        WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))


        script = "window.jQuery(document).ready(function() { \
                        var $username_textbox = window.jQuery('#" + self.USERNAME_TEXTBOX_ID + "'); \
                        window.jQuery($username_textbox).val('" + username + "'); \
                        var $password_textbox = window.jQuery('#" + self.PASSWORD_TEXTBOX_ID + "'); \
                        window.jQuery($password_textbox).val('" + password + "'); \
                  })"
        driver.execute_script(script)
        element.submit()

        # ensure that we were not able to sign in
        msg = "error"

        element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
        self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
        test_number = test_number + 1


        element = driver.find_element_by_class_name(self.ALERT_CLASS)
        self.assertIn(self.SIGN_IN_ACCT_LOCKED_VAL, element.text, msg)
        test_number = test_number + 1



    @classmethod
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()



if __name__ == '__main__':
    unittest.main()
