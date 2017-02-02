import constants
import unittest
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

CLASS_NAME = "TestCaseChangePasswordViaApp"

class TestCaseChangePasswordViaApp(unittest.TestCase):

	DRIVER=None

	@classmethod
	def setUpClass(cls):

		cls.ACCT_SETTINGS_BTN_NAME = "Account Settings"
		cls.ALERT_ID = "errorModal"
		cls.ALERT_OK_BTN="modal-ok"
		cls.CHANGE_PASSWORD_BTN_NAME = "Change Password"
		cls.CONFIRM_NEW_PASSWORD_TEXTBOX_ID = "confirm_new_password"
		cls.ENTER_PASSWORD = "Please enter a password"
		cls.NEW_PASSWORD_TEXTBOX_ID = "new_password"
		cls.PASSWORD_ALREADY_USED = "You have already used this password. Please enter a different password."
		cls.PASSWORD_FORMAT = "Please enter a valid password. This field must contain one uppercase letter, one lowercase letter, one number, and one of these special characters [ . - _ ! ]"
		cls.PASSWORD_NO_MATCH = "The entered passwords do not match. Please ensure both passwords match."
		cls.PASSWORD_TEXTBOX_ID = "password"
		cls.SHORT_PASSWORD = "Field must be at least 6 characters. You entered 1"
		cls.SIGN_IN_ALERT_ID = "sign_in_alert"
		cls.SIGN_IN_BTN_NAME = "Sign In"
		cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
		cls.SIGN_OUT_BTN_NAME = "Sign Out"
		cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
		cls.SUBMIT_BTN_ID = "submit"
		cls.UPDATED_PASSWORD_ALERT_ID = "updated_password_alert"
		cls.UPDATED_PASSWORD_SUCCESS_MSG = "Your password has been successfully changed!"
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



	def test_change_password_same_cases(self):

		METHOD_NAME = "changePasswordSameCases"


		driver = self.driver
		self.signIn()

		passwords = [("Mypass1!","Mypass1!")]

		driver.get(constants.CHANGE_PASSWORD_URL)

		new_password = passwords[0][0]
		confirm_new_password = passwords[0][1]

		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()

		element = WebDriverWait(driver, 30).until(
			EC.presence_of_element_located((By.ID, self.ALERT_ID))
		)

		self.assertIn(self.PASSWORD_ALREADY_USED, element.text)


		self.signOut()

	def test_change_password_positive_cases(self):

		METHOD_NAME = "changePasswordPositiveCases"

		driver = self.driver
		self.signIn()

		passwords = {"Mypass5!":"Mypass5!",
			     "Mypass6!":"Mypass6!"}


		for password in passwords:

			driver.get(constants.CHANGE_PASSWORD_URL)

			test_input = (password, passwords[password])
			new_password = password
			confirm_new_password = passwords[password]

			#input password and confirm password on Change Password page
			element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
			element.send_keys(new_password)
			element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
			element.send_keys(confirm_new_password)
			element.submit()

			element = WebDriverWait(driver, 60).until(
				EC.presence_of_element_located((By.ID, self.UPDATED_PASSWORD_ALERT_ID))
			)

			self.assertIn(self.UPDATED_PASSWORD_SUCCESS_MSG, element.text)

		self.signOut()


	def test_change_password_negative_cases(self):

		METHOD_NAME = "changePasswordNegativeCases"

		driver = self.driver
		self.signIn()

		test_input = ("Mypass1!", "Mypass2!")
		new_password = test_input[0]
		confirm_new_password = test_input[1]

		element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
		element.click()


		element = driver.find_element_by_link_text(self.CHANGE_PASSWORD_BTN_NAME)
		element.click()


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()

		element = WebDriverWait(driver, 10).until(
			EC.presence_of_element_located((By.ID, self.ALERT_ID))
		)

		self.assertIn(self.PASSWORD_NO_MATCH, element.text, element.text)

		self.signOut()

	def test_change_password_invalid_cases(self):

		METHOD_NAME = "changePasswordInvalidCases"

		driver = self.driver
		self.signIn()

		passwords = [ ("Mypass1#" , "Mypass1#"),
					  ("&mypass1" , "&mypass1"),
					  ("Mypass!^", "Mypass!^"),
					  ("my*pass!" , "my*pass!"),
					  ("MYPASS1$!" , "MYPASS1$!")]


		element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
		element.click()


		element = driver.find_element_by_link_text(self.CHANGE_PASSWORD_BTN_NAME)
		element.click()


		test_input = passwords[0]
		new_password = passwords[0][0]
		confirm_new_password = passwords[0][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()



		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		test_input = passwords[1]
		new_password = passwords[1][0]
		confirm_new_password = passwords[1][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()



		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		test_input = passwords[2]
		new_password = passwords[2][0]
		confirm_new_password = passwords[2][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		test_input = passwords[3]
		new_password = passwords[3][0]
		confirm_new_password = passwords[3][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)


		test_input = passwords[4]
		new_password = passwords[4][0]
		confirm_new_password = passwords[4][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		self.signOut()




	def test_change_password_empty_cases(self):

		METHOD_NAME = "changePasswordEmptyCases"

		driver = self.driver
		self.signIn()

		passwords = [ ("Mypass1!" , ""),
					  ("" , "Mypass3!"),
					  ("0", "0"),
					  ("" , ""),
					  ("     " , "     ")]



		element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
		element.click()


		element = driver.find_element_by_link_text(self.CHANGE_PASSWORD_BTN_NAME)
		element.click()


		test_input = passwords[0]
		new_password = passwords[0][0]
		confirm_new_password = passwords[0][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.ENTER_PASSWORD, error_msgs, error_msgs)


		test_input = passwords[1]
		new_password = passwords[1][0]
		confirm_new_password = passwords[1][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.ENTER_PASSWORD, error_msgs, error_msgs)


		test_input = passwords[2]
		new_password = passwords[2][0]
		confirm_new_password = passwords[2][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)


		test_input = passwords[3]
		new_password = passwords[3][0]
		confirm_new_password = passwords[3][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.ENTER_PASSWORD, error_msgs, error_msgs)


		test_input = passwords[4]
		new_password = passwords[4][0]
		confirm_new_password = passwords[4][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.ENTER_PASSWORD, error_msgs, error_msgs)


		self.signOut()


	def test_change_password_not_complex_cases(self):

		METHOD_NAME = "changePasswordNotComplexCases"

		driver = self.driver
		self.signIn()

		passwords = [ ("Mypass1" , "Mypass1"),
					  ("mypass1" , "mypass1"),
					  ("Mypass!", "Mypass!"),
					  ("mypass!" , "mypass!"),
					  ("MYPASS1!" , "MYPASS1!")]


		element = driver.find_element_by_link_text(self.ACCT_SETTINGS_BTN_NAME)
		element.click()


		element = driver.find_element_by_link_text(self.CHANGE_PASSWORD_BTN_NAME)
		element.click()


		test_input = passwords[0]
		new_password = passwords[0][0]
		confirm_new_password = passwords[0][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		test_input = passwords[1]
		new_password = passwords[1][0]
		confirm_new_password = passwords[1][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		test_input = passwords[2]
		new_password = passwords[2][0]
		confirm_new_password = passwords[2][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()



		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		test_input = passwords[3]
		new_password = passwords[3][0]
		confirm_new_password = passwords[3][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()


		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)


		test_input = passwords[4]
		new_password = passwords[4][0]
		confirm_new_password = passwords[4][1]


		#input password and confirm password on Change Password page
		element = driver.find_element_by_id(self.NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(new_password)
		element = driver.find_element_by_id(self.CONFIRM_NEW_PASSWORD_TEXTBOX_ID)
		element.send_keys(confirm_new_password)
		element.submit()



		elements = driver.find_elements_by_class_name("help-block")
		error_msgs = [element.text for element in elements]

		self.assertIn(self.PASSWORD_FORMAT, error_msgs, error_msgs)

		self.signOut()


	@classmethod
	def tearDownClass(cls):
		if not cls.DRIVER:
			cls.driver.close()

if __name__=='__main__':
	unittest.main()
