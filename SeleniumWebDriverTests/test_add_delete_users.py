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

CLASS_NAME = "TestCaseAddDeleteUsers"

class TestCaseAddDeleteUsers(unittest.TestCase):

    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.lockout_status = 0

        cls.user_ids = [1,2]

        cls.usernames = { 1 : "test01",
                           2 : "test02"}

        cls.passwords = {1 : "Mypass1!",
                          2 : "Mypass2!"}

        cls.f_names = {1 : "Joe",
                        2 : "John"}

        cls.l_names = {1 : "Smith",
                        2 : "Doe"}

        cls.encrypt_passwords = {1 : "{CRYPT}$2a$14$KNkheDcDPQjeWtdSimHYDOtAyhidsBuk5J5YwBjQthpX4K2kkKARu",
                                  2 : "{CRYPT}$2a$14$g8bRLOGc/xJLaTrvzznI3uU78h7HcGBKaf8ZWUWSrI9BvCIa12etO"}

        cls.email_addresses = { 1 : "t01@na.com",
                                 2 : "t02@na.com"}

        cls.password_history_ids = { 1 : 1,
                                     2 : 2}

        cls.lockout_ids = { 1 : 1,
                            2 : 2}

        cls.INSTITUTION_CITY = "Test"
        cls.INSTITUTION_COUNTRY = "Test"
        cls.INSTITUTION_NAME = "Test"


        cls.role_id = 2 #admin
        cls.failed_attempt_count = 0
        cls.ACTIVE_STATUS = 1

        if not cls.DRIVER:
            if constants.USE_CHROME_DRIVER:
                cls.driver = webdriver.Chrome(executable_path=constants.DRIVER_PATH)
            else:
                cls.driver = webdriver.Firefox()

            cls.driver.implicitly_wait(constants.IMPLICIT_WAIT)
            cls.driver.set_window_size(1024, 768)
        else:
            cls.driver = cls.DRIVER


    def test_insert_users_via_sql_positive_case(self):

        METHOD_NAME = "insertUsersViaSqlPositiveCase"

        driver = self.driver


        try:

        	conn = pymysql.connect(host=constants.DB_HOST, user=constants.DB_USERNAME, passwd=constants.DB_PASSWORD, db=constants.AUTH_DB_NAME)
        	cur = conn.cursor()

        except:

        	print "No connection"


        current_time = datetime.datetime.today()
        default_time = None


        for user_id in self.user_ids:

            p_id = self.password_history_ids[user_id]
            l_id = self.lockout_ids[user_id]
            username = self.usernames[user_id]
            email_address = self.email_addresses[user_id]
            first_name = self.f_names[user_id]
            last_name  = self.l_names[user_id]
            encrypt_password = self.encrypt_passwords[user_id]
            password = self.passwords[user_id]

            cur.execute ("""INSERT INTO tbl_lockout (lockout_id, username, failed_attempt_count, first_failed_attempt_timestamp, lockout_timestamp) VALUES(%s, %s, %s, %s, %s)""", (l_id, username, self.failed_attempt_count, default_time, default_time))
            conn.commit()

            cur.execute ("""INSERT INTO password_history (password_history_id, username, used_password, password_timestamp) VALUES(%s, %s, %s, %s)""", (p_id, username, encrypt_password, default_time))
            conn.commit()

            cur.execute ("""INSERT INTO users (id, username, password, email_address, first_name, last_name, active, institution_name, institution_city, institution_country, time_since_password_change, lockout_status, lockout_id)
            		VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s,  %s, %s, %s, %s)""", (user_id, username, password, email_address, first_name,  last_name, self.ACTIVE_STATUS, self.INSTITUTION_NAME, self.INSTITUTION_CITY, self.INSTITUTION_COUNTRY, current_time ,self.lockout_status, l_id))
            conn.commit()

            cur.execute("""UPDATE users SET password = %s WHERE username = %s""",(encrypt_password, username))
            conn.commit()

            cur.execute ("""INSERT INTO user_password_history (user_id, password_history_id) VALUES(%s, %s)""", (user_id, p_id))
            conn.commit()

            cur.execute ("""INSERT INTO user_role (user_id, role_id) VALUES(%s, %s)""", (user_id, self.role_id))
            conn.commit()

        cur.close()
        conn.close()


    def test_delete_users_via_sql_positive_case(self):

        METHOD_NAME = "deleteUsersViaSqlPositiveCase"

        driver = self.driver


        try:

        	conn = pymysql.connect(host=constants.DB_HOST, user=constants.DB_USERNAME, passwd=constants.DB_PASSWORD, db=constants.AUTH_DB_NAME)
        	cur = conn.cursor()

        except:

        	print "No connection"


        cur.execute("DELETE FROM user_password_history WHERE user_id in (1,2)")
        conn.commit()

        cur.execute("DELETE FROM password_history WHERE password_history_id in (1,2)")
        conn.commit()

        cur.execute("DELETE FROM users WHERE id in (1,2)")
        conn.commit()

        cur.execute("DELETE FROM tbl_lockout WHERE lockout_id in (1,2)")
        conn.commit()

        cur.close()
        conn.close()

    @classmethod
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()

if __name__=='__main__':
    unittest.main()
