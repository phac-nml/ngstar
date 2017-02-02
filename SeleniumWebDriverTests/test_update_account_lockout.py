import constants
import unittest
import pymysql
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import datetime

CLASS_NAME = "TestCaseUpdateAccountLockout"

class TestCaseUpdateAccountLockout(unittest.TestCase):

    def setUp(self):

        self.lockout_status_pos = 1
        self.lockout_status_neg = 0

        self.user_id = 2

        self.username = "test02"

        self.lockout_id = 2

        self.failed_attempt_count_orig = 0
        self.failed_attempt_count_max = 10



        if constants.USE_CHROME_DRIVER:
        	self.driver = webdriver.Chrome(executable_path=constants.DRIVER_PATH)
        else:
        	self.driver = webdriver.Firefox()

        self.driver.implicitly_wait(constants.IMPLICIT_WAIT)
        self.driver.set_window_size(1024, 768)


    def test_insert_account_lockout_info_positive_case(self):

        METHOD_NAME = "insertAccountLockoutInfoPositiveCase"

        driver = self.driver


        try:

        	conn = pymysql.connect(host=constants.DB_HOST, user=constants.DB_USERNAME, passwd=constants.DB_PASSWORD, db=constants.AUTH_DB_NAME)
        	cur = conn.cursor()

        except:

        	print "No connection"


        current_time = datetime.datetime.today()

        cur.execute ("""UPDATE users SET lockout_status=%s, lockout_id=%s WHERE username=%s""", (self.lockout_status_pos, self.lockout_id, self.username))
        conn.commit()

        cur.execute ("""UPDATE tbl_lockout SET failed_attempt_count=%s, first_failed_attempt_timestamp=%s, lockout_timestamp=%s  WHERE lockout_id=%s""", (self.failed_attempt_count_max, current_time, current_time, self.lockout_id))
        conn.commit()



        cur.close()
        conn.close()


    def test_remove_account_lockout_info_positive_case(self):

        METHOD_NAME = "removeAccountLockoutInfoPositiveCase"

        driver = self.driver


        try:

        	conn = pymysql.connect(host=constants.DB_HOST, user=constants.DB_USERNAME, passwd=constants.DB_PASSWORD, db=constants.AUTH_DB_NAME)
        	cur = conn.cursor()

        except:

        	print "No connection"


        default_time = None


        cur.execute ("""UPDATE tbl_lockout SET failed_attempt_count=%s, first_failed_attempt_timestamp=%s, lockout_timestamp=%s  WHERE lockout_id=%s""", (self.failed_attempt_count_orig, default_time, default_time, self.lockout_id))
        conn.commit()

        cur.execute ("""UPDATE users SET lockout_status=%s WHERE username=%s""", (self.lockout_status_neg, self.username))
        conn.commit()


        cur.close()
        conn.close()

    def tearDown(self):
        self.driver.close()

if __name__=='__main__':
    unittest.main()
