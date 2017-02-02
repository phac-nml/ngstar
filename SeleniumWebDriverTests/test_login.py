import constants
import unittest
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait


CLASS_NAME = "TestCaseLogin"


class TestCaseLogin(unittest.TestCase):
    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.ALERT_CLASS = "alert"
        cls.ENTER_PASSWORD_MSG = "Please enter a password"
        cls.ENTER_USERNAME_MSG = "Please enter username or email address"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.PASSWORD_TEXTBOX_ID = "password"
        cls.SIGN_IN_ALERT_ID = "sign_in_alert"
        cls.SIGN_IN_BTN_NAME = "Sign In"
        cls.SIGN_IN_HEADING_ID = "wb-cont"
        cls.SIGN_IN_HEADING_VAL = "Please sign in"
        cls.SIGN_IN_INVALID_VAL = "Invalid username or password! Please try again"
        cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
        cls.SIGN_OUT_BTN_NAME = "Sign Out"
        cls.USERNAME_TEXTBOX_ID = "username"

        if not cls.DRIVER:
            if constants.USE_CHROME_DRIVER:
                cls.driver = webdriver.Chrome(executable_path=constants.DRIVER_PATH)
            else:
                cls.driver = webdriver.Firefox()

            cls.driver.implicitly_wait(constants.IMPLICIT_WAIT)
            cls.driver.set_window_size(1024, 768)
        else:
            cls.driver = cls.DRIVER


    def test_positive_cases(self):

        METHOD_NAME = "test_positive_cases"

        driver = self.driver
        test_number = 1

        user_accounts = {"test01" : "Mypass1!",
                        "test02" : "Mypass2!",
						"t01@na.com" : "Mypass1!",
						"t02@na.com" : "Mypass2!"}


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


        for username in user_accounts:

            test_input = (username, user_accounts[username])

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

            password = user_accounts[username]

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
            element = driver.find_element_by_link_text(self.SIGN_OUT_BTN_NAME)
            element.click()
            test_number = test_number + 1

    def test_negative_cases(self):

        METHOD_NAME = "test_negative_cases"

        driver = self.driver
        test_number = 1

        user_accounts = {"Pikachu": "12345678",
                         "Yoshi": "aaaaaaaa",
                         "Squishy": "3ns0dsL2N0s1d90"}

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


        for username in user_accounts:

            test_input = (username, user_accounts[username])

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
            password = user_accounts[username]

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
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "the heading [{4}]".format(test_number,
                                           CLASS_NAME,
                                           METHOD_NAME,
                                           test_input,
                                           self.SIGN_IN_HEADING_VAL)
            element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
            self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
            test_number = test_number + 1

            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "the message [{4}]".format(test_number,
                                           CLASS_NAME,
                                           METHOD_NAME,
                                           test_input,
                                           self.SIGN_IN_INVALID_VAL)
            element = driver.find_element_by_class_name(self.ALERT_CLASS)
            self.assertIn(self.SIGN_IN_INVALID_VAL, element.text, msg)
            test_number = test_number + 1

    def test_empty_cases(self):

        METHOD_NAME = "test_empty_cases"

        driver = self.driver
        test_number = 1

        user_accounts = [("", ""),
                         ("myusername", ""),
                         ("", "mypassword"),
                         (" ", " "),
                         ("    ", "    "),
                         ("", "")]

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
        msg = "{0} in {1} Test #{2}: " \
            "Could not find [{3}] button".format(CLASS_NAME,
                                                 METHOD_NAME,
                                                 test_number,
                                                 self.SIGN_IN_BTN_NAME)
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        test_input = user_accounts[0]
        username = user_accounts[0][0]
        password = user_accounts[0][1]
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

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
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: " \
            "Could not find the heading [{4}]".format(test_number,
                                                      CLASS_NAME,
                                                      METHOD_NAME,
                                                      test_input,
                                                      self.SIGN_IN_HEADING_VAL)
        element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
        self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
        test_number = test_number + 1

        elements = driver.find_elements_by_class_name(self.HELP_BLOCK_NAME)
        error_msgs = [e.text for e in elements]

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_USERNAME_MSG)
        self.assertIn(self.ENTER_USERNAME_MSG, error_msgs, msg)
        test_number = test_number + 1

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_PASSWORD_MSG)
        self.assertIn(self.ENTER_PASSWORD_MSG, error_msgs, msg)
        test_number = test_number + 1

        # click Sign In button
        driver.get(constants.HOME_URL)
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "[{4}] button".format(test_number,
                                  CLASS_NAME,
                                  METHOD_NAME,
                                  test_input,
                                  self.SIGN_IN_BTN_NAME)
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        test_input = user_accounts[1]
        username = user_accounts[1][0]
        password = user_accounts[1][1]
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

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
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the heading [{4}]".format(test_number,
                                       CLASS_NAME,
                                       METHOD_NAME,
                                       test_input,
                                       self.SIGN_IN_HEADING_VAL)
        element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
        self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
        test_number = test_number + 1

        elements = driver.find_elements_by_class_name(self.HELP_BLOCK_NAME)
        error_msgs = [e.text for e in elements]

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: " \
            "Found the error message [{4}] when its not " \
            "supposed to be found".format(test_number,
                                          CLASS_NAME,
                                          METHOD_NAME,
                                          test_input,
                                          self.ENTER_USERNAME_MSG)
        self.assertNotIn(self.ENTER_USERNAME_MSG, error_msgs, msg)
        test_number = test_number + 1

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_PASSWORD_MSG)
        self.assertIn(self.ENTER_PASSWORD_MSG, error_msgs, msg)
        test_number = test_number + 1

        # click Sign In button
        driver.get(constants.HOME_URL)
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "[{4}] button".format(test_number,
                                  CLASS_NAME,
                                  METHOD_NAME,
                                  test_input,
                                  self.SIGN_IN_BTN_NAME)
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        test_input = user_accounts[2]
        username = user_accounts[2][0]
        password = user_accounts[2][1]
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

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
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the heading [{4}]".format(test_number,
                                       CLASS_NAME,
                                       METHOD_NAME,
                                       test_input,
                                       self.SIGN_IN_HEADING_VAL)
        element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
        self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
        test_number = test_number + 1

        elements = driver.find_elements_by_class_name(self.HELP_BLOCK_NAME)
        error_msgs = [e.text for e in elements]

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_USERNAME_MSG)
        self.assertIn(self.ENTER_USERNAME_MSG, error_msgs, msg)
        test_number = test_number + 1

        msg = "Test #{0} in {1} in {2} with " \
            "[Input: {3}]: Found the error message [{4}] " \
            "when its not supposed to be found".format(test_number,
                                                       CLASS_NAME,
                                                       METHOD_NAME,
                                                       test_input,
                                                       self.ENTER_PASSWORD_MSG)
        self.assertNotIn(self.ENTER_PASSWORD_MSG, error_msgs, msg)
        test_number = test_number + 1


        # click Sign In button
        driver.get(constants.HOME_URL)
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "[{4}] button".format(test_number,
                                  CLASS_NAME,
                                  METHOD_NAME,
                                  test_input,
                                  self.SIGN_IN_BTN_NAME)
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        test_input = user_accounts[3]
        username = user_accounts[3][0]
        password = user_accounts[3][1]
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

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
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the heading [{4}]".format(test_number,
                                       CLASS_NAME,
                                       METHOD_NAME,
                                       test_input,
                                       self.SIGN_IN_HEADING_VAL)
        element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
        self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
        test_number = test_number + 1

        elements = driver.find_elements_by_class_name(self.HELP_BLOCK_NAME)
        error_msgs = [e.text for e in elements]

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_USERNAME_MSG)
        self.assertIn(self.ENTER_USERNAME_MSG, error_msgs, msg)
        test_number = test_number + 1

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_PASSWORD_MSG)
        self.assertIn(self.ENTER_PASSWORD_MSG, error_msgs, msg)
        test_number = test_number + 1


        # click Sign In button
        driver.get(constants.HOME_URL)
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "[{4}] button".format(test_number,
                                  CLASS_NAME,
                                  METHOD_NAME,
                                  test_input,
                                  self.SIGN_IN_BTN_NAME)
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        test_input = user_accounts[4]
        username = user_accounts[4][0]
        password = user_accounts[4][1]
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

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
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the heading [{4}]".format(test_number,
                                       CLASS_NAME,
                                       METHOD_NAME,
                                       test_input,
                                       self.SIGN_IN_HEADING_VAL)
        element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
        self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
        test_number = test_number + 1

        elements = driver.find_elements_by_class_name(self.HELP_BLOCK_NAME)
        error_msgs = [e.text for e in elements]

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_USERNAME_MSG)
        self.assertIn(self.ENTER_USERNAME_MSG, error_msgs, msg)
        test_number = test_number + 1

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the error message [{4}]".format(test_number,
                                             CLASS_NAME,
                                             METHOD_NAME,
                                             test_input,
                                             self.ENTER_PASSWORD_MSG)
        self.assertIn(self.ENTER_PASSWORD_MSG, error_msgs, msg)
        test_number = test_number + 1


        # click Sign In button
        driver.get(constants.HOME_URL)
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "[{4}] button".format(test_number,
                                  CLASS_NAME,
                                  METHOD_NAME,
                                  test_input,
                                  self.SIGN_IN_BTN_NAME)
        self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
        element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
        element.click()
        test_number = test_number + 1

        # input username and password on Sign In page
        test_input = user_accounts[5]
        username = user_accounts[5][0]
        password = user_accounts[5][1]
        element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

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
        msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
            "the heading [{4}]".format(test_number,
                                       CLASS_NAME,
                                       METHOD_NAME,
                                       test_input,
                                       self.SIGN_IN_HEADING_VAL)
        element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
        self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
        test_number = test_number + 1

        elements = driver.find_elements_by_class_name(self.HELP_BLOCK_NAME)
        error_msgs = [e.text for e in elements]

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: " \
            "Found the error message [{4}] when its " \
            "not supposed to be found".format(test_number,
                                              CLASS_NAME,
                                              METHOD_NAME,
                                              test_input,
                                              self.ENTER_USERNAME_MSG)
        self.assertIn(self.ENTER_USERNAME_MSG, error_msgs, msg)
        test_number = test_number + 1

        msg = "Test #{0} in {1} in {2} with [Input: {3}]: " \
            "Found the error message [{4}] when its " \
            "not supposed to be found".format(test_number,
                                              CLASS_NAME,
                                              METHOD_NAME,
                                              test_input,
                                              self.ENTER_PASSWORD_MSG)
        self.assertIn(self.ENTER_PASSWORD_MSG, error_msgs, msg)
        test_number = test_number + 1

    def test_short_cases(self):

        METHOD_NAME = "test_short_cases"

        driver = self.driver
        test_number = 1

        user_accounts = {"a": "b",
                         "01": "23",
                         "a1b": "2c3",
                         "abcd": "efgh",
                         "abcdefghi": "a",
                         "abcdefghi": "ab",
                         "0": "012345678",
                         "01": "012345678"}

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


        for username in user_accounts:

            test_input = (username, user_accounts[username])

            # click Sign In button
            driver.get(constants.HOME_URL)
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "[{4}] button".format(test_number,
                                      CLASS_NAME,
                                      METHOD_NAME,
                                      test_input,
                                      self.SIGN_IN_BTN_NAME)
            self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
            element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
            element.click()
            test_number = test_number + 1

            element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)

            # input username and password on Sign In page
            password = user_accounts[username]

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
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "the heading [{4}]".format(test_number,
                                           CLASS_NAME,
                                           METHOD_NAME,
                                           test_input,
                                           self.SIGN_IN_HEADING_VAL)
            element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
            self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
            test_number = test_number + 1

    def test_long_cases(self):

        METHOD_NAME = "test_long_cases"

        driver = self.driver
        test_number = 1

        user_accounts = {"abcdefghijkl": "01234567891011121314",
                         "abcdefghijklmnopqrstuvwxyz": "0123456789101112131415",
                         "4QlG9FghLQm87MC4q9NMyiyadbzxyxNI08DJaTh0Ib0WAeGrhmPaswIg2YziUAK": "djB0MHrGVCboHqVCKvDJ4mPsRE7AaQTWloHTZBsAnFFLXqhUjGyd2R5a8G8HWXD",
                         "mrXuqOKeG2ukiFEakZdBGbEe3JkEtXBVd66qaA050BZwV1zYyCRfrx0fw5BQ0A3nDysBQT4T9YyVjfZ7H072FD2JR9KrAsyQfVdtT7aAmQOdLf4LQlGEXRYFusjZvq":
                         "X6tYwVGTMJjDG3kB0FFlvwjFBiXqoZOQPvPdzYDP4oQr8a3zmQoxcYg1kLX0i2bIV6z2vS7K768RydswzKValRbfVrpwRJTUiAWWoqtOw8xHL0ilIUa3Dufkce8OMR",
                         "0123456": "VMMls7bRD8Wp87tbzOAYnH59Ddx9BHekEE3ggqEtnDBESJpwJPOPtXZ3wRjYscB",
                         "D7ci16TVVsh0MucnZXFx3Ykn8Y5E4i7DzgPyqYBpKAT17IDf2Rz1X0cWSkxe5Uf": "0123456"}

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


        for username in user_accounts:

            test_input = (username, user_accounts[username])

            # click Sign In button
            driver.get(constants.HOME_URL)
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "[{4}] button".format(test_number,
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
            password = user_accounts[username]

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
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "the heading [{4}]".format(test_number,
                                           CLASS_NAME,
                                           METHOD_NAME,
                                           test_input,
                                           self.SIGN_IN_HEADING_VAL)
            element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
            self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
            test_number = test_number + 1

    def test_invalid_cases(self):

        METHOD_NAME = "test_invalid_cases"

        driver = self.driver
        test_number = 1

        user_accounts = {"@": "",
                         "": "%",
                         "{": "*",
                         "$%": "()",
                         "!){#": "@($+=",
                         "abcdefghi": "0123$5678",
                         "ab%defghi": "012345678",
                         "ab^def(hi": "0]234'678",
                         "!Jvm4^*~QfV$zl": "L]u8\"i7r)s}k#",
                         "*$&%(@#($": "!)@(#{}~(@",
                         "I>2z/}:d,~?Qm!=,EU)_`,GCa,{rW=,N>(7HEY1`lhW{-zF84wj]$qAa\sX96(D": "8:~_B~/Ii6RuQGVtc*Hpd@mGBJd8am1*pGAHT]'=WY;o)+EraC)p}?#R1#ZgB$c",
                         "H@ll0w!": "W0r[D!!!"}

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


        for username in user_accounts:

            test_input = (username, user_accounts[username])

            # click Sign In button
            driver.get(constants.HOME_URL)
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "[{4}] button".format(test_number,
                                      CLASS_NAME,
                                      METHOD_NAME,
                                      test_input,
                                      self.SIGN_IN_BTN_NAME)
            self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
            element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
            element.click()
            test_number = test_number + 1

            # input username and password on Sign In page
            # we don't use a execute script here because some invalid inputs
            # contain "'" which break the string
            element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)
            element.send_keys(username)
            element = driver.find_element_by_id(self.PASSWORD_TEXTBOX_ID)
            password = user_accounts[username]
            element.send_keys(password)
            element.submit()

            # ensure that we were not able to sign in
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "the heading [{4}]".format(test_number,
                                           CLASS_NAME,
                                           METHOD_NAME,
                                           test_input,
                                           self.SIGN_IN_HEADING_VAL)
            element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
            self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
            test_number = test_number + 1

    def test_repeated_cases(self):

        METHOD_NAME = "test_repeated_cases"

        driver = self.driver
        test_number = 1

        user_accounts = {"000000": "000000",
                         "aaaaaaaa": "aaaaaaaa",
                         "BBBBBBBBB": "BBBBBBBBB",
                         "______": "______",
                         "-------": "-------"}

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


        for username in user_accounts:

            test_input = (username, user_accounts[username])

            # click Sign In button
            driver.get(constants.HOME_URL)
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "[{4}] button".format(test_number,
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
            password = user_accounts[username]

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
            msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find " \
                "the heading [{4}]".format(test_number,
                                           CLASS_NAME,
                                           METHOD_NAME,
                                           test_input,
                                           self.SIGN_IN_HEADING_VAL)
            element = driver.find_element_by_id(self.SIGN_IN_HEADING_ID)
            self.assertIn(self.SIGN_IN_HEADING_VAL, element.text, msg)
            test_number = test_number + 1

    @classmethod
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()

if __name__ == '__main__':
    unittest.main()
