import constants
import unittest
import pymysql
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


CLASS_NAME = "TestCaseBatchAddAllele"


class TestCaseBatchAddAllele(unittest.TestCase):
    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.ALLELE_LIST_ALERT_ID = "allele_list_alert"
        cls.BATCH_ADD_ALLELE_SUCCESS_MSG = "Batch Alleles submitted successfully!"
        cls.BATCH_ERROR_MODAL_ID = "batchErrorModal"
        cls.BATCH_SEQUENCES_TEXTBOX_ID = "fasta_sequences"
        cls.DELETE_ALLELE_BTN_CSS_SEL = "delete-allele"
        cls.DELETE_ALLELE_ALERT_BTN_ID = "delete-ok"
        cls.DELETE_ALLELE_SUCCESS_MSG = "Allele deleted successfully!"
        cls.ERROR_MODAL_ID = "errorModal"
        cls.FASTA_SEQUENCE_ERROR = "Please enter sequences in valid fasta format. This field only accepts letters, numbers, and these special characters [ . - _ > ]"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.LOCI_NOT_MATCH ="Loci names do not match. Please make sure you are entering sequences for the selected loci."
        cls.NO_INPUT_PROVIDED = "No input provided. Please enter input into textbox or upload a file."
        cls.PASSWORD_TEXTBOX_ID = "password"
        cls.SEQUENCE_CHAR_ERROR ="Please enter a valid sequence. This field can only contain the following letters [ A , T , C , G]"
        cls.SEQUENCE_EMPTY = "Please enter a sequence"
        cls.SIGN_IN_ALERT_ID = "sign_in_alert"
        cls.SIGN_IN_BTN_NAME = "Sign In"
        cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
        cls.SIGN_OUT_BTN_NAME = "Sign Out"
        cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
        cls.SUBMIT_BTN_ID = "submit"
        cls.USERNAME_TEXTBOX_ID = "username"

        cls.loci_names = ["gyrA"]

        cls.loci_names_full = ["penA",
                                 "mtrR",
                                 "porB",
                                 "ponA",
                                 "gyrA",
                                 "parC",
                                 "23S"]


        cls.batch_alleles = {"gyrA":
        ">gyrA200\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA201\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacggcaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA202\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacaacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA203\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattacgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA204\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgcctccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA205\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n"}

        cls.batch_alleles_duplicate_types = {"gyrA":
        ">gyrA200\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA201\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacggcaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA202\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacaacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA203\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattacgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA204\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgcctccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA205\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n"}

        cls.batch_alleles_duplicate_sequences = {"gyrA":
        ">gyrA206\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA207\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacggcaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA208\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacaacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA209\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattacgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA210\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgcctccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>gyrA211\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n"}

        cls.batch_alleles_invalid_types = {
        "penA":">penA0.001$#\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
        "mtrR":">mtrR1&%\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
        "porB":">porB@$#\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
        "ponA":">ponA3*^3\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
        "gyrA":">gyrA2@#\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
        "parC":">parC6!@#\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
        "23S":">23S2^$#$@#\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
        }

        cls.batch_alleles_wrong_loci = {"gyrA":
        ">penA200\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>penA201\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacggcaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>penA202\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacaacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>penA203\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattacgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>penA204\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgcctccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n>penA205\nctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgatttcgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca\n"}

        cls.batch_alleles_wrong_length = {"penA":">penA0.001\nATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCA",
                                            "mtrR": ">mtrR1\nATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCA",
                                            "porB": ">porB2\nATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCA",
                                            "ponA": ">ponA3\nATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCA",
                                            "gyrA": ">gyrA4\nATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCA",
                                            "parC": ">parC5\nATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCA",
                                            "23S": ">23S6\nATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCAATCGTAGTCA"}

        cls.batch_alleles_empty = {"penA":"",
                                    "mtrR":"",
                                    "porB":"",
                                    "ponA":"",
                                    "gyrA":"",
                                    "parC":"",
                                    "23S":""}

        cls.allele_types_clear_db = {"gyrA_1": "200",
                                         "gyrA_2": "201",
                                         "gyrA_3": "202",
                                         "gyrA_4": "203",
                                         "gyrA_5": "204",
                                         "gyrA_6": "205"}

        cls.type_duplicate_msgs = {
                "FASTA Allele Type 200 Error: Please enter a different allele type. A gyrA allele with type 200 already exists in the database.",
                "FASTA Allele Type 201 Error: Please enter a different allele type. A gyrA allele with type 201 already exists in the database.",
                "FASTA Allele Type 202 Error: Please enter a different allele type. A gyrA allele with type 202 already exists in the database.",
                "FASTA Allele Type 203 Error: Please enter a different allele type. A gyrA allele with type 203 already exists in the database.",
                "FASTA Allele Type 204 Error: Please enter a different allele type. A gyrA allele with type 204 already exists in the database.",
                "FASTA Allele Type 205 Error: Please enter a different allele type. A gyrA allele with type 205 already exists in the database.",
        }

        cls.seq_duplicate_msgs = {
                "FASTA file with allele type 206 error: This sequence already exists in the database. Please remove the sequence with allele type 206 from your FASTA file.",
                "FASTA file with allele type 207 error: This sequence already exists in the database. Please remove the sequence with allele type 207 from your FASTA file.",
                "FASTA file with allele type 208 error: This sequence already exists in the database. Please remove the sequence with allele type 208 from your FASTA file.",
                "FASTA file with allele type 209 error: This sequence already exists in the database. Please remove the sequence with allele type 209 from your FASTA file.",
                "FASTA file with allele type 210 error: This sequence already exists in the database. Please remove the sequence with allele type 210 from your FASTA file.",
                "FASTA file with allele type 211 error: This sequence already exists in the database. Please remove the sequence with allele type 211 from your FASTA file.",
        }

        cls.loci_wrong_length_msgs = {
                "FASTA file with allele type 0.001 error: This sequence is not the appropriate length for a penA gene. Please ensure that you are including penA sequences only.",
                "FASTA file with allele type 1 error: This sequence is not the appropriate length for a mtrR gene. Please ensure that you are including mtrR sequences only.",
                "FASTA file with allele type 2 error: This sequence is not the appropriate length for a porB gene. Please ensure that you are including porB sequences only.",
                "FASTA file with allele type 3 error: This sequence is not the appropriate length for a ponA gene. Please ensure that you are including ponA sequences only.",
                "FASTA file with allele type 4 error: This sequence is not the appropriate length for a gyrA gene. Please ensure that you are including gyrA sequences only.",
                "FASTA file with allele type 5 error: This sequence is not the appropriate length for a parC gene. Please ensure that you are including parC sequences only.",
                "FASTA file with allele type 6 error: This sequence is not the appropriate length for a 23S gene. Please ensure that you are including 23S sequences only.",
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


    def test_batch_add_allele_wrong_loci_cases(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names:

            batch_allele = self.batch_alleles_wrong_loci[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
            )

            self.assertIn(self.LOCI_NOT_MATCH, element.text)

        self.signOut()

    def test_batch_add_allele_wrong_length_cases(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names_full:

            batch_allele = self.batch_alleles_wrong_length[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.BATCH_ERROR_MODAL_ID))
            )

            for loci_wrong_length_msg in self.loci_wrong_length_msgs:

                self.SEQ_WRONG_LENGTH = loci_wrong_length_msg

                if element.text == self.SEQ_WRONG_LENGTH:

                    self.assertIn(self.SEQ_WRONG_LENGTH, element.text)

        self.signOut()


    def test_batch_add_allele_positive_cases(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names:

            batch_allele = self.batch_alleles[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            element = WebDriverWait(driver, 10).until(
            	EC.presence_of_element_located((By.ID, self.ALLELE_LIST_ALERT_ID))
            )

            self.assertIn(self.BATCH_ADD_ALLELE_SUCCESS_MSG, element.text)

            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[1]")
            self.assertIn("200", element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[2]")
            self.assertIn("gyrA", element.text)

            element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[1]")
            self.assertIn("201", element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[2]")
            self.assertIn("gyrA", element.text)

            element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[1]")
            self.assertIn("202", element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[3]/td[2]")
            self.assertIn("gyrA", element.text)

            element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[1]")
            self.assertIn("203", element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[4]/td[2]")
            self.assertIn("gyrA", element.text)

            element = driver.find_element_by_xpath("//table/tbody/tr[5]/td[1]")
            self.assertIn("204", element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[5]/td[2]")
            self.assertIn("gyrA", element.text)

            element = driver.find_element_by_xpath("//table/tbody/tr[6]/td[1]")
            self.assertIn("205", element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[6]/td[2]")
            self.assertIn("gyrA", element.text)

        self.signOut()
        self.clearBatchAlleles()

    def test_batch_add_allele_negative_cases(self):

        driver = self.driver
        self.signIn()


        for loci_name in self.loci_names:

            batch_allele = self.batch_alleles[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            element = WebDriverWait(driver, 10).until(
            	EC.presence_of_element_located((By.ID, self.ALLELE_LIST_ALERT_ID))
            )

            self.assertIn(self.BATCH_ADD_ALLELE_SUCCESS_MSG, element.text)


        for loci_name in self.loci_names:

            batch_allele = self.batch_alleles_duplicate_types[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.BATCH_ERROR_MODAL_ID))
            )

            for type_duplicate_msg in self.type_duplicate_msgs:

                self.TYPE_EXISTS = type_duplicate_msg
                self.assertIn(self.TYPE_EXISTS, element.text)

        for loci_name in self.loci_names:

            batch_allele = self.batch_alleles_duplicate_sequences[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.BATCH_ERROR_MODAL_ID))
            )

            for seq_duplicate_msg in self.seq_duplicate_msgs:

                self.SEQ_EXISTS = seq_duplicate_msg
                self.assertIn(self.SEQ_EXISTS, element.text)

        self.signOut()
        self.clearBatchAlleles()


    def test_batch_add_allele_invalid_cases(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names_full:

            batch_allele = self.batch_alleles_invalid_types[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.FASTA_SEQUENCE_ERROR, error_msgs, error_msgs)

        self.signOut()


    def test_batch_add_allele_empty_cases(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names_full:

            batch_allele = self.batch_alleles_empty[loci_name]

            driver.get(constants.BATCH_ADD_ALLELE_URL)

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.BATCH_SEQUENCES_TEXTBOX_ID)
            element.send_keys(batch_allele)

            element = driver.find_element_by_css_selector(self.SUBMIT_BTN_CSS_SEL)
            element.click()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
            )

            self.assertIn(self.NO_INPUT_PROVIDED, element.text)

        self.signOut()


    def clearBatchAlleles(self):

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
    def tearDown(cls):
        if not cls.DRIVER:
            cls.driver.close()



if __name__ == '__main__':
    unittest.main()
