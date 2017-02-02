import constants
import unittest
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select

CLASS_NAME = "TestCaseChangeEmailViaApp"

class TestCaseChangeEmailViaApp(unittest.TestCase):
	DRIVER=None

	@classmethod
	def setUpClass(cls):

		cls.ACCT_SETTINGS_BTN_NAME = "Account Settings"
		cls.ALERT_ID = "errorModal"
		cls.CHANGE_EMAIL_BTN_NAME = "Change Email Address"
		cls.EMAIL_FORMAT_MSG = "Email should be of the format someuser@example.com"
		cls.CONFIRM_NEW_EMAIL_TEXTBOX_ID = "confirm_new_email"
		cls.EMAIL_CURRENT = "This is your current email address. Please enter a different email address."
		cls.EMAIL_IN_USE = "The email address is already in use. Please enter another email address."
		cls.EMAIL_NO_MATCH = "The entered emails do not match. Please ensure both emails match."
		cls.ENTER_EMAIL_MSG = "Please enter an email address"
		cls.NEW_EMAIL_TEXTBOX_ID = "new_email"
		cls.PASSWORD_TEXTBOX_ID = "password"
		cls.SIGN_IN_ALERT_ID = "sign_in_alert"
		cls.SIGN_IN_BTN_NAME = "Sign In"
		cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
		cls.SIGN_OUT_BTN_NAME = "Sign Out"
		cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
		cls.SUBMIT_BTN_ID = "submit"
		cls.UPDATE_EMAIL_HEADING_CLASS = "form-signin-heading"
		cls.UPDATE_EMAIL_HEADING_VAL = "Update your NG-STAR email"
		cls.UPDATED_EMAIL_ALERT_ID = "updated_email_alert"
		cls.UPDATED_EMAIL_SUCCESS_MSG = "Your email address has been successfully changed!"
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

		#click Sign In button
		driver.get(constants.HOME_URL)
		msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.SIGN_IN_BTN_NAME)
		self.assertIn(self.SIGN_IN_BTN_NAME, driver.page_source, msg)
		element = driver.find_element_by_link_text(self.SIGN_IN_BTN_NAME)
		element.click()
		test_number = test_number + 1

		#input username and password on Sign In page
		element = driver.find_element_by_id(self.USERNAME_TEXTBOX_ID)
		element.send_keys(username)
		element = driver.find_element_by_id(self.PASSWORD_TEXTBOX_ID)
		element.send_keys(password)
		element.submit()

		# logout
		msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.SIGN_OUT_BTN_NAME)
		self.assertIn(self.SIGN_OUT_BTN_NAME, driver.page_source, msg)
		test_number = test_number + 1


	def signOut(self):

		METHOD_NAME = "signOut"

		driver = self.driver
		test_number = 1

		test_input = ("test01", "Mypass1!")

		driver.get(constants.HOME_URL)
		msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.SIGN_OUT_BTN_NAME)
		self.assertIn(self.SIGN_OUT_BTN_NAME, driver.page_source, msg)
		element = driver.find_element_by_link_text(self.SIGN_OUT_BTN_NAME)
		element.click()
		test_number = test_number + 1


	def test_change_email_same_cases(self):

		METHOD_NAME = "changeEmailSameCases"

		driver = self.driver
		self.signIn()

		email_accounts={"t01@na.com" : "t01@na.com"}


		for email in email_accounts:

			element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
			element.click()
			element = driver.find_element_by_link_text(self.CHANGE_EMAIL_BTN_NAME)
			element.click()

			test_input = (email, email_accounts[email])
			new_email = email
			confirm_new_email = email_accounts[email]

			#input new email address and confirm new email address on Change Email page
			element = driver.find_element_by_id(self.NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(new_email)
			element = driver.find_element_by_id(self.CONFIRM_NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(confirm_new_email)
			element.submit()

			element = driver.find_element_by_id(self.ALERT_ID)
			self.assertIn(self.EMAIL_CURRENT, element.text, element.text)


		self.signOut()



	def test_change_email_empty_cases(self):

		METHOD_NAME = "changeEmailEmptyCases"

		driver = self.driver
		self.signIn()

		email_accounts={"" : "",
						"" : "test@test.com",
						"test@test.com" : ""}

		test_number=1

		for email in email_accounts:

			element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
			element.click()
			element = driver.find_element_by_link_text(self.CHANGE_EMAIL_BTN_NAME)
			element.click()

			test_input = (email, email_accounts[email])
			new_email = email
			confirm_new_email = email_accounts[email]

			#input new email address and confirm new email address on Change Email page
			element = driver.find_element_by_id(self.NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(new_email)
			element = driver.find_element_by_id(self.CONFIRM_NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(confirm_new_email)
			element.submit()


			msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.UPDATED_EMAIL_ALERT_ID)
			self.assertNotIn(self.UPDATED_EMAIL_ALERT_ID, driver.page_source, msg)


			elements = driver.find_elements_by_class_name("help-block")
			error_msgs = [element.text for element in elements]

			self.assertIn(self.ENTER_EMAIL_MSG, error_msgs)

		test_number = test_number + 1


		self.signOut()

	def test_change_email_invalid_cases(self):

		METHOD_NAME = "changeEmailInvalidCases"

		driver = self.driver
		self.signIn()

		test_number=1

		email_accounts={"@" : "&(**@&HDGD3434",
						"" : "%",
						"{" : "*",
						"$%" : "()",
						"!){#" : "@($+=",
						"abcdefghi" : "0123$5678",
						"ab%defghi" : "012345678",
						"ab^def(hi" : "0]234'678",
						"!Jvm4^*~QfV$zl" : "L]u8\"i7r)s}k#",
						"*$&%(@#($" : "!)@(#{}~(@",
						"I>2z/}:d,~?Qm!=,EU)_`,GCa,{rW=,N>(7HEY1`lhW{-zF84wj]$qAa\sX96(D" : "8:~_B~/Ii6RuQGVtc*Hpd@mGBJd8am1*pGAHT]'=WY;o)+EraC)p}?#R1#ZgB$c",
						"H@ll0w!" : "W0r[D!!!",
						"test@test":"test@test"}

		element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
		element.click()
		element = driver.find_element_by_link_text(self.CHANGE_EMAIL_BTN_NAME)
		element.click()

		for email in email_accounts:

			test_input = (email, email_accounts[email])
			new_email = email
			confirm_new_email = email_accounts[email]

			#input new email address and confirm new email address on Change Email page
			element = driver.find_element_by_id(self.NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(new_email)
			element = driver.find_element_by_id(self.CONFIRM_NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(confirm_new_email)
			element.submit()

			msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.UPDATED_EMAIL_ALERT_ID)
			self.assertNotIn(self.UPDATED_EMAIL_ALERT_ID, driver.page_source, msg)

			elements = driver.find_elements_by_class_name("help-block")
			error_msgs = [element.text for element in elements]

			self.assertIn(self.EMAIL_FORMAT_MSG, error_msgs)

		test_number = test_number + 1

		self.signOut()


	def test_change_email_positive_cases(self):

		METHOD_NAME = "changeEmailPositiveCases"

		driver = self.driver
		self.signIn()

		email_accounts = {"t01@na.com" : "t01@na.com", "abcde@abcde.com" : "abcde@abcde.com"}

		for email in email_accounts:

			test_input = (email, email_accounts[email])
			new_email = email
			confirm_new_email = email_accounts[email]

			element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
			element.click()
			element = driver.find_element_by_link_text(self.CHANGE_EMAIL_BTN_NAME)
			element.click()

			#input new email address and confirm new email address on Change Email page
			element = driver.find_element_by_id(self.NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(new_email)
			element = driver.find_element_by_id(self.CONFIRM_NEW_EMAIL_TEXTBOX_ID)
			element.send_keys(confirm_new_email)
			element.submit()

			element = driver.find_element_by_id(self.UPDATED_EMAIL_ALERT_ID)
			self.assertIn(self.UPDATED_EMAIL_SUCCESS_MSG, element.text)

		self.signOut()


	def test_change_email_negative_cases(self):

		METHOD_NAME = "changeEmailNegativeCases"

		driver = self.driver
		self.signIn()

		test_input = ("t02@na.com", "t02@na.com")
		new_email = test_input[0]
		confirm_new_email = test_input[1]

		element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
		element.click()
		element = driver.find_element_by_link_text(self.CHANGE_EMAIL_BTN_NAME)
		element.click()

		#input new email address and confirm new email address on Change Email page
		element = driver.find_element_by_id(self.NEW_EMAIL_TEXTBOX_ID)
		element.send_keys(new_email)
		element = driver.find_element_by_id(self.CONFIRM_NEW_EMAIL_TEXTBOX_ID)
		element.send_keys(confirm_new_email)
		element.submit()

		element = driver.find_element_by_id(self.ALERT_ID)
		self.assertIn(self.EMAIL_IN_USE, element.text, element.text)

		self.signOut()


	@classmethod
	def tearDownClass(cls):
		if not cls.DRIVER:
			cls.driver.close()

if __name__=='__main__':
	unittest.main()
