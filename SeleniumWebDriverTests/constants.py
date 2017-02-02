import getpass

DRIVER_PATH = "/usr/lib/chromium-browser/chromedriver"
USE_CHROME_DRIVER = True

BASE_URL = "localhost:3000"
URL_PREFIX = "http://"
ADD_ALLELE_URL = BASE_URL + "/allele/add_allele"
ADD_PROFILE_BASE_URL = BASE_URL + "/sequencetype/add_profile/"
ALLELE_QUERY_URL = BASE_URL + "/allele/form"
ALLELE_QUERY_URL_WITH_PREFIX = URL_PREFIX + BASE_URL + "/allele/form"
BATCH_ADD_ALLELE_URL = BASE_URL + "/allele/batch_add_allele"
BATCH_ALLELE_QUERY_URL = BASE_URL + "/allele/batch_allele_query/"
BATCH_PROFILE_QUERY_URL = BASE_URL + "/sequencetype/batch_profile_query/"
CHANGE_PASSWORD_URL = BASE_URL + "/account/change_account_password"
HOME_URL = BASE_URL + "/allele/form"
LIST_LOCI_ALLELES_BASE_URL = BASE_URL + "/allele/list_loci_alleles/"
LIST_PROFILES_BASE_URL = BASE_URL + "/sequencetype/list_profiles/"
VIEW_LOCI_ALLELES_BASE_URL = BASE_URL + "/allele/view_loci_alleles/"
WELCOME_URL = BASE_URL + "/welcome/language_selection"
EDIT_AA_PROFILE_URL = BASE_URL + "/curator/edit_amino_acid_profile/"


IMPLICIT_WAIT = 100 # seconnds

TIMEOUT = 600 # seconds
USER = getpass.getuser()
NGSTAR_CMD = ['NGSTAR/script/ngstar_server.pl']
NGSTAR_DOMAIN = 'localhost'
NGSTAR_PORT = 3000
NGSTAR_STOP = 'pkill -u '+ USER + ' -f "NGSTAR/script/ngstar_server.pl"'


#####################################################
#DB AUTH SETTINGS YOU MUST CHANGE THESE OR TESTS WILL FAIL
#
DB_HOST = "localhost"
DB_USERNAME = "root"
DB_PASSWORD = "password"
AUTH_DB_NAME = "NGSTAR_Auth"
DB_NAME = "NGSTAR"
#
######################################################

#####################################################
#DB SETTINGS YOU MUST CHANGE THESE OR TESTS WILL FAIL
#
DB_HOST = "localhost"
DB_USERNAME = "root"
DB_PASSWORD = "password"
NGSTAR_DB_NAME = "NGSTAR"
#
######################################################
