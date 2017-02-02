import constants
import unittest
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

CLASS_NAME = "TestCaseChangeUsernameViaApp"

class TestCaseChangeUsernameViaApp(unittest.TestCase):
	DRIVER=None

	@classmethod
	def setUpClass(cls):

		cls.ACCT_SETTINGS_BTN_NAME = "Account Settings"
		cls.ALERT_ID = "errorModal"
		cls.CHANGE_USERNAME_BTN_NAME = "Change Username"
		cls.CONFIRM_NEW_USERNAME_TEXTBOX_ID = "confirm_new_username"
		cls.ENTER_USERNAME_MSG = "Please enter a username"
		cls.NEW_USERNAME_TEXTBOX_ID = "new_username"
		cls.PASSWORD_TEXTBOX_ID = "password"
		cls.SIGN_IN_ALERT_ID = "sign_in_alert"
		cls.SIGN_IN_BTN_NAME = "Sign In"
		cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
		cls.SIGN_OUT_BTN_NAME = "Sign Out"
		cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
		cls.SUBMIT_BTN_ID = "submit"
		cls.UPDATED_USERNAME_ALERT_ID = "updated_username_alert"
		cls.UPDATED_USERNAME_SUCCESS_MSG = "Your username has been successfully changed!"
		cls.UPDATE_USERNAME_HEADING_CLASS = "form-signin-heading"
		cls.UPDATE_USERNAME_HEADING_VAL = "Update your NG-STAR username"
		cls.USERNAME_CURRENT = "This is your current username. Please enter a different username."
		cls.USERNAME_FORMAT_MSG = "Please enter a valid username. This field can only contain letters, numbers, and these special characters [ . - _ ]"
		cls.USERNAME_IN_USE = "The username is already in use. Please enter another username."
		cls.USERNAME_NO_MATCH = "The entered usernames do not match. Please ensure both usernames match."
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

	def test_change_username_same_cases(self):

		METHOD_NAME = "changeUsernameSameCases"

		driver = self.driver
		self.signIn()

		usernames={"test01" : "test01"}

		test_number = 1

		for username in usernames:


			element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
			element.click()



			element = driver.find_element_by_link_text(self.CHANGE_USERNAME_BTN_NAME)
			element.click()


			test_input = (username, usernames[username])
			new_username = username
			confirm_new_username = usernames[username]

			#input new username and confirm new username on Change Username page
			element = driver.find_element_by_id(self.NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(new_username)
			element = driver.find_element_by_id(self.CONFIRM_NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(confirm_new_username)
			element.submit()

			msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.UPDATED_USERNAME_ALERT_ID)
			self.assertNotIn(self.UPDATED_USERNAME_ALERT_ID, driver.page_source, msg)

			element = WebDriverWait(driver, 30).until(
				EC.presence_of_element_located((By.ID, self.ALERT_ID))
			)
			self.assertIn(self.USERNAME_CURRENT, element.text, element.text)

		test_number = test_number + 1

		self.signOut()


	def test_change_username_empty_cases(self):

		METHOD_NAME = "changeUsernameEmptyCases"

		driver = self.driver
		self.signIn()

		usernames={"" : "",
						"" : "test01",
						"test01" : ""}

		test_number = 1

		for username in usernames:

			element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
			element.click()



			element = driver.find_element_by_link_text(self.CHANGE_USERNAME_BTN_NAME)
			element.click()



			test_input = (username, usernames[username])
			new_username = username
			confirm_new_username = usernames[username]

			#input new username and confirm new username on Change Username page
			element = driver.find_element_by_id(self.NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(new_username)
			element = driver.find_element_by_id(self.CONFIRM_NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(confirm_new_username)
			element.submit()

			msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.UPDATED_USERNAME_ALERT_ID)
			self.assertNotIn(self.UPDATED_USERNAME_ALERT_ID, driver.page_source, msg)

			elements = driver.find_elements_by_class_name("help-block")
			error_msgs = [element.text for element in elements]

			self.assertIn(self.ENTER_USERNAME_MSG, error_msgs)


		test_number = test_number + 1

		self.signOut()


	def test_change_username_invalid_cases(self):

		METHOD_NAME = "changeUsernameInvalidCases"

		driver = self.driver
		self.signIn()

		usernames= {"@" : "&(**@&HDGD3434",
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


		element = driver.find_element_by_link_text(self.CHANGE_USERNAME_BTN_NAME)
		element.click()

		test_number = 1

		for username in usernames:

			test_input = (username, usernames[username])
			new_username = username
			confirm_new_username = usernames[username]

			#input new username and confirm new username on Change Username page
			element = driver.find_element_by_id(self.NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(new_username)
			element = driver.find_element_by_id(self.CONFIRM_NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(confirm_new_username)
			element.submit()

			msg = "Test #{0} in {1} in {2} with [Input: {3}]: Could not find [{4}] button".format(test_number, CLASS_NAME, METHOD_NAME, test_input, self.UPDATED_USERNAME_ALERT_ID)
			self.assertNotIn(self.UPDATED_USERNAME_ALERT_ID, driver.page_source, msg)

			elements = driver.find_elements_by_class_name("help-block")
			error_msgs = [element.text for element in elements]

			self.assertIn(self.USERNAME_FORMAT_MSG, error_msgs)


		test_number = test_number + 1

		self.signOut()

	def test_change_username_positive_cases(self):

		METHOD_NAME = "changeUsernamePositiveCases"

		driver = self.driver
		self.signIn()

		usernames = {"test00" : "test00", "test01" : "test01"}

		for username in usernames:

			test_input = (username, usernames[username])
			new_username = username
			confirm_new_username = usernames[username]

			element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
			element.click()


			element = driver.find_element_by_link_text(self.CHANGE_USERNAME_BTN_NAME)
			element.click()


			#input new username and confirm new username on Change Username page
			element = driver.find_element_by_id(self.NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(new_username)
			element = driver.find_element_by_id(self.CONFIRM_NEW_USERNAME_TEXTBOX_ID)
			element.send_keys(confirm_new_username)
			element.submit()

			element = WebDriverWait(driver, 30).until(
				EC.presence_of_element_located((By.ID, self.UPDATED_USERNAME_ALERT_ID))
			)
			self.assertIn(self.UPDATED_USERNAME_SUCCESS_MSG, element.text)

		self.signOut()


	def test_change_username_negative_cases(self):

		METHOD_NAME = "changeUsernameNegativeCases"

		driver = self.driver
		self.signIn()

		test_input = ("test02", "test02")
		new_username = test_input[0]
		confirm_new_username = test_input[1]

		element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
		element.click()


		element = driver.find_element_by_link_text(self.CHANGE_USERNAME_BTN_NAME)
		element.click()


		#input new username and confirm new username on Change Username page
		element = driver.find_element_by_id(self.NEW_USERNAME_TEXTBOX_ID)
		element.send_keys(new_username)
		element = driver.find_element_by_id(self.CONFIRM_NEW_USERNAME_TEXTBOX_ID)
		element.send_keys(confirm_new_username)
		element.submit()

		element = WebDriverWait(driver, 10).until(
			EC.presence_of_element_located((By.ID, self.ALERT_ID))
		)
		self.assertIn(self.USERNAME_IN_USE, element.text, element.text)

		self.signOut()


	@classmethod
	def tearDownClass(cls):
		if not cls.DRIVER:
			cls.driver.close()

if __name__=='__main__':
	unittest.main()
