import constants
import unittest
import pymysql
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

CLASS_NAME = "TestCaseAddAllele"


class TestCaseAddAllele(unittest.TestCase):
    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.PASSWORD_TEXTBOX_ID = "password"
        cls.ADD_ALLELE_TYPE_TEXTBOX_ID = "allele_type"
        cls.ADD_ALLELE_SEQ_TEXTBOX_ID = "allele_sequence"
        cls.ADD_ALLELE_SUCCESS_MSG = "Allele submitted successfully!"
        cls.ALLELE_TYPE_EXISTS = "Please enter a different allele type."
        cls.ALLELE_LIST_ALERT_ID = "allele_list_alert"
        cls.ALLELE_QUERY_SUBMIT_BTN_CSS_SEL = "button[type='submit'][value='allele']"
        cls.ALLELE_QUERY_TEXTBOX_IDS = {"penA": "seq0",
                                         "mtrR": "seq1",
                                         "porB": "seq2",
                                         "ponA": "seq3",
                                         "gyrA": "seq4",
                                         "parC": "seq5",
                                         "23S": "seq6"}
        cls.ALLELE_TYPE_CHAR_ERROR = "Please enter a valid type. This field can only contain numbers and decimals"
        cls.ALLELE_TYPE_EMPTY = "Please enter an allele type"
        cls.DELETE_ALLELE_BTN_CSS_SEL = "delete-allele"
        cls.DELETE_ALLELE_ALERT_BTN_ID = "delete-ok"
        cls.DELETE_ALLELE_SUCCESS_MSG = "Allele deleted successfully!"
        cls.ERROR_MODAL_ID = "errorModal"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.SEQUENCE_CHAR_ERROR ="Please enter a valid sequence. This field can only contain the following letters [ A , T , C , G ]"
        cls.SEQUENCE_EMPTY = "Please enter a sequence"
        cls.ALLELE_SEQ_EXISTS = "The sequence you have submitted already exists for the loci"
        cls.SIGN_IN_ALERT_ID = "sign_in_alert"
        cls.SIGN_IN_BTN_NAME = "Sign In"
        cls.SIGN_IN_SUCCESS_VAL = "You have successfully signed in!"
        cls.SIGN_OUT_BTN_NAME = "Sign Out"
        cls.SUBMIT_BTN_CSS_SEL = "button[type='submit']"
        cls.SUBMIT_BTN_ID = "submit"
        cls.USERNAME_TEXTBOX_ID = "username"


        cls.loci_names = ["penA",
                           "mtrR",
                           "porB",
                           "ponA",
                           "gyrA",
                           "parC",
                           "23S"]
        cls.allele_types = {"penA": "0.000",
                                         "mtrR": "1",
                                         "porB": "2",
                                         "ponA": "3",
                                         "gyrA": "4",
                                         "parC": "5",
                                         "23S": "6"}
        cls.allele_types_clear_db = {"penA": "0.000",
                                      "mtrR": "1",
                                      "porB": "2",
                                      "ponA": "3",
                                      "gyrA": "4",
                                      "parC": "5",
                                      "23S":  "6"}

        cls.positive_allele_types = {"penA": "1.000",
                                         "mtrR": "2",
                                         "porB": "3",
                                         "ponA": "4",
                                         "gyrA": "5",
                                         "parC": "6",
                                         "23S": "7"}


        cls.negative_allele_types = {"penA": "0.000",
                                         "mtrR": "1",
                                         "porB": "2",
                                         "ponA": "3",
                                         "gyrA": "4",
                                         "parC": "5",
                                         "23S": "6"}

        cls.invalid_allele_types = {"penA": "0.00a",
                                         "mtrR": "$1",
                                         "porB": "2&",
                                         "ponA": "#",
                                         "gyrA": "*",
                                         "parC": "!",
                                         "23S": "@#$a"}


        cls.empty_allele_types = {"penA": "",
                                         "mtrR": "",
                                         "porB": "",
                                         "ponA": "",
                                         "gyrA": "",
                                         "parC": "",
                                         "23S": ""}


        cls.positive_sequences = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGCGCCAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S":  "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
        }

        cls.negative_sequences = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGCGCCAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S":  "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
        }

        cls.invalid_sequences = {
                "penA": "BTGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAARACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGCGCCAACGTCAATGCTTGe",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCYAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgkttccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATJCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S":  "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGATCGATTTGGGCAAAACCGCCCCCCGCGfdGATGGAACTCAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
        }

        cls.empty_sequences = {
                "penA": "",
                "mtrR": "",
                "porB": "",
                "ponA": "",
                "gyrA": "",
                "parC": "",
                "23S" : "",
        }

        cls.seq_exists_msgs = {
                "The sequence you have submitted already exists for the loci penA with allele type 0.000.",
                "The sequence you have submitted already exists for the loci mtrR with allele type 1.",
                "The sequence you have submitted already exists for the loci porB with allele type 2.",
                "The sequence you have submitted already exists for the loci ponA with allele type 3.",
                "The sequence you have submitted already exists for the loci gyrA with allele type 4.",
                "The sequence you have submitted already exists for the loci penA with allele type 5.",
                "The sequence you have submitted already exists for the loci penA with allele type 6.",
        }

        cls.allele_type_exists_msgs = {
                "Please enter a different allele type. A sequence with type 0.000 for the loci penA already exists.",
                "Please enter a different allele type. A sequence with type 1 for the loci mtrR already exists.",
                "Please enter a different allele type. A sequence with type 2 for the loci porB already exists.",
                "Please enter a different allele type. A sequence with type 3 for the loci ponA already exists.",
                "Please enter a different allele type. A sequence with type 4 for the loci gyrA already exists.",
                "Please enter a different allele type. A sequence with type 5 for the loci parC already exists.",
                "Please enter a different allele type. A sequence with type 6 for the loci 23S already exists.",
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


    # running test suite is terminated if an assert is thrown (if an assert is
    # thrown in populateDB, or any other method, tests won't continue which is
    # what we want)

    #positive sequences and types
    def test_add_allele_positive_cases(self):

        driver = self.driver
        self.signIn()
        self.populateDB()
        self.signOut()
        self.clearDB()

    def test_add_allele_negative_cases(self):

        driver = self.driver
        self.signIn()

        self.populateDB()

        for loci_name in self.loci_names:


            driver.get(constants.ADD_ALLELE_URL)

            allele_type = self.positive_allele_types[loci_name]
            sequence = self.negative_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
            )

	    for seq_exists_msg in self.seq_exists_msgs:
		self.ALLELE_SEQ_EXISTS = seq_exists_msg

		if element.text == self.ALLELE_SEQ_EXISTS:

			self.assertIn(self.ALLELE_SEQ_EXISTS, element.text)

        for loci_name in self.loci_names:


            driver.get(constants.ADD_ALLELE_URL)

            allele_type = self.negative_allele_types[loci_name]
            sequence = self.positive_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            element = WebDriverWait(driver, 60).until(
            	EC.presence_of_element_located((By.ID, self.ERROR_MODAL_ID))
            )


            for allele_type_exists_msg in self.allele_type_exists_msgs:

                self.ALLELE_TYPE_DUPLICATE = allele_type_exists_msg

                if element.text == self.ALLELE_TYPE_DUPLICATE:

                    self.assertIn(self.ALLELE_TYPE_DUPLICATE, element.text)

        self.signOut()
        self.clearDB()



    def test_add_allele_invalid_cases(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names:

            allele_type = self.allele_types[loci_name]
            sequence = self.invalid_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            driver.get(constants.ADD_ALLELE_URL)

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.SEQUENCE_CHAR_ERROR, error_msgs, error_msgs)

        for loci_name in self.loci_names:

            allele_type = self.invalid_allele_types[loci_name]
            sequence = self.positive_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            driver.get(constants.ADD_ALLELE_URL)

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.ALLELE_TYPE_CHAR_ERROR, error_msgs, error_msgs)

        self.signOut()


    def test_add_allele_empty_cases(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names:

            allele_type = self.allele_types[loci_name]
            sequence = self.empty_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            driver.get(constants.ADD_ALLELE_URL)

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.SEQUENCE_EMPTY, error_msgs, error_msgs)

        for loci_name in self.loci_names:

            allele_type = self.empty_allele_types[loci_name]
            sequence = self.positive_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            driver.get(constants.ADD_ALLELE_URL)

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"

            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.ALLELE_TYPE_EMPTY, error_msgs, error_msgs)

        self.signOut()

    def populateDB(self):

        driver = self.driver

        for loci_name in self.loci_names:

            allele_type = self.allele_types[loci_name]
            sequence = self.positive_sequences[loci_name]

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            driver.get(constants.ADD_ALLELE_URL)

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.send_keys(allele_type)
            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)
            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            element = WebDriverWait(driver, 10).until(
            	EC.presence_of_element_located((By.ID, self.ALLELE_LIST_ALERT_ID))
            )

            self.assertIn(self.ADD_ALLELE_SUCCESS_MSG, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[1]")
            self.assertIn(allele_type, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[2]")
            self.assertIn(loci_name, element.text)



    def clearDB(self):

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
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()


if __name__ == '__main__':
    unittest.main()
