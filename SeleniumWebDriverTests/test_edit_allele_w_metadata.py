import constants
import unittest
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait


CLASS_NAME = "TestCaseEditAlleleWithMetadata"


class TestCaseEditAlleleWithMetadata(unittest.TestCase):
    DRIVER=None

    @classmethod
    def setUpClass(cls):

        cls.PASSWORD_TEXTBOX_ID="password"
        cls.ADD_ALLELE_COUNTRY_TEXTBOX_ID="country"
        cls.ADD_ALLELE_CURATOR_COMMENT_TEXTBOX_ID="curator_comment"
        cls.ADD_ALLELE_EPI_DATA_TEXTBOX_ID="epi_data"
        cls.ADD_ALLELE_ISOLATE_CLASSIFICATION_TEXTBOX_ID="isolate_classification"
        cls.ADD_ALLELE_PATIENT_AGE_TEXTBOX_ID="patient_age"
        cls.ADD_ALLELE_TYPE_TEXTBOX_ID="allele_type"
        cls.ADD_ALLELE_SEQ_TEXTBOX_ID="allele_sequence"
        cls.ADD_ALLELE_SUCCESS_MSG="Allele submitted successfully!"
        cls.ALLELE_LIST_ALERT_ID="allele_list_alert"
        cls.ALLELE_TYPE_CHAR_ERROR="Please enter a valid type. This field can only contain numbers"
        cls.ALLELE_TYPE_EMPTY="Please enter an allele type"
        cls.ALERT_ID="errorModal"
        cls.ALLELE_COLLECTION_DATE_CHAR_ERROR = "Please enter a valid date in the format YYYY-MM-DD. This field can only contain numbers and dashes"
        cls.ALLELE_COUNTRY_CHAR_ERROR = "Please enter a valid country. This field can only contain letters and dashes"
        cls.ALLELE_CURATOR_COMMENT_CHAR_ERROR = "Please enter valid comments. This field can only contain letters, numbers, and these special characters [ . , : ; / ]"
        cls.ALLELE_EPI_DATA_CHAR_ERROR = "Please enter valid epidemiological data. This field can only contain letters, numbers, and these special characters [ . , : ; / ]"
        cls.ALLELE_MIC_VALUE_CHAR_ERROR = "Please enter a valid MIC"
        cls.ALLELE_PATIENT_AGE_CHAR_ERROR = "Please enter a valid age. This field can only contain numbers"
        cls.COLLECTION_DATE_TEXTBOX_ID = "datepicker"
        cls.DELETE_ALLELE_BTN_CSS_SEL = "delete-allele"
        cls.DELETE_ALLELE_ALERT_BTN_ID = "delete-ok"
        cls.DELETE_ALLELE_SUCCESS_MSG = "Allele deleted successfully!"
        cls.EDIT_ALLELE_BTN_CSS_SEL = "button[type='button'][name='option'][value='edit']"
        cls.HELP_BLOCK_NAME = "help-block"
        cls.SEQUENCE_CHAR_ERROR ="Please enter a valid sequence. This field can only contain the following letters [ A , T , C , G]"
        cls.SEQUENCE_DUPLICATE ="The sequence you have submitted already exists"
        cls.SEQUENCE_EMPTY = "Please enter a sequence"
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
                                         "23S" : "6"}

        cls.allele_types_additional = {"penA": "2.000",
                                         "mtrR": "3",
                                         "porB": "4",
                                         "ponA": "5",
                                         "gyrA": "6",
                                         "parC": "7",
                                         "23S" : "8"}


        cls.allele_types_edited = {"penA": "1.000",
                                         "mtrR": "2",
                                         "porB": "3",
                                         "ponA": "4",
                                         "gyrA": "5",
                                         "parC": "6",
                                         "23S" : "7"}

        cls.allele_types_radio_btns = {"penA": "0.000",
                                      "mtrR": "1",
                                      "porB": "2",
                                      "ponA": "3",
                                      "gyrA": "4",
                                      "parC": "5",
                                      "23S" : "6"}


        cls.allele_types_clear_db = {"penA": "0.000",
                                      "mtrR": "1",
                                      "porB": "2",
                                      "ponA": "3",
                                      "gyrA": "4",
                                      "parC": "5",
                                      "23S" : "6"}

        cls.allele_types_clear_db_edited = {"penA": "1.000",
                                      "mtrR": "2",
                                      "porB": "3",
                                      "ponA": "4",
                                      "gyrA": "5",
                                      "parC": "6",
                                      "23S" : "7"}

        cls.allele_types_clear_db_additional = {"penA": "2.000",
                                      "mtrR": "3",
                                      "porB": "4",
                                      "ponA": "5",
                                      "gyrA": "6",
                                      "parC": "7",
                                      "23S" : "8"}

        cls.negative_allele_types = {"penA": "0.000",
                                         "mtrR": "1",
                                         "porB": "2",
                                         "ponA": "3",
                                         "gyrA": "4",
                                         "parC": "5",
                                         "23S" : "6"}

        cls.invalid_allele_types = {"penA": "0.00a",
                                         "mtrR": "$1",
                                         "porB": "2&",
                                         "ponA": "#",
                                         "gyrA": "*",
                                         "parC": "!",
                                         "23S" : "%#@"}


        cls.empty_allele_types = {"penA": "",
                                         "mtrR": "",
                                         "porB": "",
                                         "ponA": "",
                                         "gyrA": "",
                                         "parC": "",
                                         "23S" : ""}

        cls.collection_date = {"penA": "2009-10-01",
                                         "mtrR": "2009-08-27",
                                         "porB": "2009-09-03",
                                         "ponA": "2009-05-01",
                                         "gyrA": "2010-01-05",
                                         "parC": "2010-06-17",
                                         "23S": "2010-06-22"}

        cls.negative_collection_date = {"penA": "2009-10-0a",
                                         "mtrR": "2009-0@-27",
                                         "porB": "200&-09-03",
                                         "ponA": "20!9-05-01",
                                         "gyrA": "2o7@-01-05",
                                         "parC": "2010-E06-17",
                                         "23S": "2010-06-&22"}

        cls.country = {"penA": "Canada",
                        "mtrR": "USA",
                        "porB": "Mexico",
                        "ponA": "Australia",
                        "gyrA": "Sweden",
                        "parC": "China",
                        "23S": "England"}

        cls.negative_country = {"penA": "2Canada",
                                    "mtrR": "$USA",
                                    "porB": "Me@xico",
                                    "ponA": "Au5tralia",
                                    "gyrA": "Swed3n",
                                    "parC": "Chi4a",
                                    "23S": "Eng!and"}

        cls.patient_age = {"penA": "19",
                        "mtrR": "20",
                        "porB": "21",
                        "ponA": "22",
                        "gyrA": "23",
                        "parC": "24",
                        "23S": "25"}

        cls.negative_patient_age = {"penA": "!9",
                        "mtrR": "2@",
                        "porB": "2l",
                        "ponA": "22%",
                        "gyrA": "2E",
                        "parC": "2N",
                        "23S": "2S"}

        cls.patient_gender = {"penA": "M",
                        "mtrR": "U",
                        "porB": "F",
                        "ponA": "F",
                        "gyrA": "U",
                        "parC": "M",
                        "23S": "F"}

        cls.beta_lactamase = {"penA": "Positive",
                        "mtrR": "Negative",
                        "porB": "Unknown",
                        "ponA": "Unknown",
                        "gyrA": "Positive",
                        "parC": "Negative",
                        "23S": "Positive"}

        cls.isolate_classifications = {"penA": "azr",
                        "mtrR": "S",
                        "porB": "CeDS",
                        "ponA": "CipR",
                        "gyrA": "PPNG",
                        "parC": "Probable-CMRNG",
                        "23S": "TetR"}

        cls.negative_isolate_classifications = {"penA": "azrsp3cr",
                        "mtrR": "Susceptibl3 Stra!n",
                        "porB": "C3DS/3ryR",
                        "ponA": "C!pRP3nR",
                        "gyrA": "PP4G/TR4G",
                        "parC": "CX05/Pr@bab!e-CMR4G",
                        "23S": "CMR4GT3tR"}

        cls.mics_determined_by = {"penA": "Disc Diffusion",
                        "mtrR": "E-Test",
                        "porB": "Agar Dilution",
                        "ponA": "E-Test",
                        "gyrA": "Disc Diffusion",
                        "parC": "Agar Dilution",
                        "23S": "E-Test"}


        cls.interpretation_keys = {0:"Azithromycin_interpretation_option",
                                    1:"Cefixime_interpretation_option",
                                    2:"Ceftriaxone_interpretation_option",
                                    3:"Ciprofloxacin_interpretation_option",
                                    4:"Erythromycin_interpretation_option",
                                    5:"Penicillin_interpretation_option",
                                    6:"Spectinomycin_interpretation_option",
                                    7:"Tetracycline_interpretation_option"}


        cls.interpretation_values = {0:"Resistant",
                                        1:"Intermediate",
                                        2:"Susceptible",
                                        3:"Unknown",
                                        4:"Susceptible",
                                        5:"Intermediate",
                                        6:"Resistant",
                                        7:"Unknown"}



        cls.mic_comparator_keys = {0:"Azithromycin_comparator_option",
                                    1:"Cefixime_comparator_option",
                                    2:"Ceftriaxone_comparator_option",
                                    3:"Ciprofloxacin_comparator_option",
                                    4:"Erythromycin_comparator_option",
                                    5:"Penicillin_comparator_option",
                                    6:"Spectinomycin_comparator_option",
                                    7:"Tetracycline_comparator_option"}

        cls.mic_comparator = {0:"=",
                                    1:"<",
                                    2:">",
                                    3:">",
                                    4:"<",
                                    5:"=",
                                    6:u"\u2264",
                                    7:u"\u2265"}

        cls.mic_textbox_ids = {0:"Azithromycin",
                                    1:"Cefixime",
                                    2:"Ceftriaxone",
                                    3:"Ciprofloxacin",
                                    4:"Erythromycin",
                                    5:"Penicillin",
                                    6:"Spectinomycin",
                                    7:"Tetracycline"}

        cls.mic_values = {0:"0.008",
                                    1:"1.025",
                                    2:"0.5",
                                    3:"0.025",
                                    4:"0.005",
                                    5:"0.25",
                                    6:"64",
                                    7:"512"}

        cls.negative_mic_values = {0:"@.008",
                                    1:"1.o25",
                                    2:"0.S",
                                    3:"0.@2S",
                                    4:"0.00S",
                                    5:"o.25",
                                    6:"6N",
                                    7:"S!2"}

        cls.epi_data = {"penA":"penA 12.2, WHO-O-G",
                            "mtrR":"mtrR 12.2, WHO-O-L",
                            "porB":"porB 12.2, WHO-O-A",
                            "ponA":"ponA 12.2, WHO-O-T",
                            "gyrA":"gyrA 12.2 WHO-O-W",
                            "parC":"parC 12.2 WHO-O-Z",
                            "23S":"23S 12.2 WHO-O-M"}

        cls.negative_epi_data = {"penA":"p@nA 12.2, WHO-O-G",
                            "mtrR":"mtrR 12.2{ , } WHO-O-L",
                            "porB":"porB 12.2*&$, WHO-O-A",
                            "ponA":"ponA 12.2+, WHO-O-T",
                            "gyrA":"gyrA 12.2_+_)(*^) WHO-O-W",
                            "parC":"pa@C 12.2 WHO-O-Z",
                            "23S":"2#* 12.2 WHO-O-M"}

        cls.curator_comment = {"penA":"penA 12.2, WHO-O-G",
                            "mtrR":"mtrR 12.2, WHO-O-L",
                            "porB":"porB 12.2, WHO-O-A",
                            "ponA":"ponA 12.2, WHO-O-T",
                            "gyrA":"gyrA 12.2 WHO-O-W",
                            "parC":"parC 12.2 WHO-O-Z",
                            "23S":"23S 12.2 WHO-O-M"}

        cls.negative_curator_comment = {"penA":"p@nA 12.2, WHO-O-G",
                            "mtrR":"mtrR 12.2{ , } WHO-O-L",
                            "porB":"porB 12.2}+&#%#$, WHO-O-A",
                            "ponA":"ponA 12.2+, WHO-O-T",
                            "gyrA":"gyrA 12.2_+_)(*^) WHO-O-W",
                            "parC":"pa@C 12.2 WHO-O-Z",
                            "23S":"2#* 12.2 WHO-O-M"}

        cls.sequences = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAACCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGCGCCAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgtaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCCGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S" : "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
        }

        cls.sequences_additional = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGACGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGCCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATTGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGACGCGCTCTATTGGCATTTCAAAAATAAGGAAGACTTGTTTGACGCGTTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGTTCTTGGACGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCCACTACAAATTCCACAACATCCTGTTTTTAAAGTGCGAACATACGGAACAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGACGACAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGGGCCGTTGCCGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "CTGTACGCGATGCACGAGCTGAAAAATAACTGGAATGCCGCCTACAAAAAATCGGCGCGCATCGTCGGCGACGTCATCGGTAAATACCACCCCCACGGCGATTTCGCAGTTTACGCCACCATCGTCCGTATGGCGCAAAATTTCGCTATGCGTTATGTGCTGATAGACGGACAGGGCAACTTCGGATCGGTGGACGGGCTTGCCGCCGCAGCCATGCGCTATACCGAAATCCGCATGGCGAAAATCTCACATGAAATGCTGGCA",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCAACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTATCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTCACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S" : "TAGACGGAGAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
        }

        cls.edited_positive_sequences = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAGACACCGGCGGCTTCAATCCTTGGGAG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGGGGTTCAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S" : "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCTCTATCT",
        }

        cls.negative_sequences = {
                "penA": "ATGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAAAACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGGCGCCAACGTCAATGCTTGG",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGAGCCGTTGCTGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgattccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATGCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S" : "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAAAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
        }

        cls.invalid_sequences = {
                "penA": "BTGTTGATTAAAAGCGAATATAAGCCCCGGATGCTGCCCAAAGAAGAGCAGGTCAAAAAGCCGATGACCAGTAACGGACGGATTAGCTTCGTCCTGATGGCAATGGCGGTCTTGTTTGCCTGTCTGATTGCCCGCGGGCTGTATCTGCAGACGGTAACGTATAACTTTTTGAAAGAACAGGGCGACAACCGGATTGTGCGGACTCAAGCATTGCCGGCTACACGCGGTACGGTTTCGGACCGGAACGGTGCGGTTTTGGCGTTGAGCGCGCCGACGGAGTCCCTGTTTGCCGTGCCTAAAGATATGAAGGAAATGCCGTCTGCCGCCCAATTGGAACGCCTGTCCGAGCTTGTCGATGTGCCGGTCGATGTTTTGAGGAACAAACTCGAACAGAAAGGCAAGTCGTTTATTTGGATCAAGCGGCAGCTCGATCCCAAGGTTGCCGAAGAGGTCAAAGCCTTGGGTTTGGAAAACTTTGTATTTGAAAAAGAATTAAAACGCCATTACCCGATGGGCAACCTGTTTGCACACGTCATCGGATTTACCGATATTGACGGCAAAGGTCAGGAAGGTTTGGAACTTTCGCTTGAAGACAGCCTGTATGGCGAAGACGGCGCGGAAGTTGTTTTGCGGGACCGGCAGGGCAATATTGTGGACAGCTTGGACTCCCCGCGCAATAAAGCACCGCAAAACGGCAAAGACATCATCCTTTCCCTCGATCAGAGGATTCAGACCTTGGCCTATGAAGAGTTGAACAAGGCGGTCGAATACCATCAGGCAAAAGCCGGAACGGTGGTGGTTTTGGATGCCCGCACGGGGGAAATCCTCGCCTTGGCCAATACGCCCGCCTACGATCCCAACAGACCCGGCCGGGCAGACAGCGAACAGCGGCGCAACCGTGCCGTAACCGATATGATCGAACCTGGTTCGGCAATCAAACCGTTCGTGATTGCGAAGGCATTGGATGCGGGCAAAACCGATTTGAACGAACGGCTGAATACGCAGCCTTATAAAATCGGACCGTCTCCCGTGCGCGATGATACCCATGTTTACCCCTCTTTGGATGTGCGCGGCATTATGCAGAAATCGTCCAACGTCGGCACAAGCAAACTGTCTGCGCGTTTCGGCGCCGAAGAAATGTATGACTTCTATCATGAATTGGGCATCGGTGTGCGTATGCACTCGGGCTTTCCGGGGGAAACTGCAGGTTTGTTGAGAAATTGGCGCAGGTGGCGGCCCATCGAACAGGCGACGATGTCTTTCGGTTACGGTCTGCAATTGAGCCTGCTGCAATTGGCGCGCGCCTATACCGCACTGACGCACGACGGCGTTTTGCTGCCGCTCAGCTTTGAGAAGCAGGCGGTTGCGCCGCAAGGCAAACGCATATTCAAAGAATCGACCGCGCGCGAGGTACGCAATCTGATGGTTTCCGTAACCGAGCCGGGCGGCACCGGTACGGCGGGTGCGGTGGACGGTTTCGATGTCGGCGCTAAAACCGGCACGGCGCGCAAGTTCGTCAACGGGCGTTATGCCGACAACAAACACGTCGCTACCTTTATCGGTTTTGCCCCCGCCAAAAACCCCCGTGTGATTGTGGCGGTAACCATCGACGAACCGACTGCCCACGGCTATTACGGCGGCGTAGTGGCAGGGCCGCCCTTCAAAAAAATTATGGGCGGCAGCCTGAACATCTTGGGCATTTCCCCGACCAAGCCACTGACCGCCGCAGCCGTCAAAACACCGTCTTAA",
                "mtrR": "TTGCACGGATAAAAAGTCTTTTTTTATAATCCGCCCTCGTCAAACCGACCCGAAACGAARACGCCATTATGAGAAAAACCAAAACCGAAGCCTTGAAAACCAAAGAACACCTGATGCTTGCCGCCTTGGAAACCTTTTACCGCAAAGGGATTGCCCGCACCTCGCTCAACGAAATCGCCCAAGCCGCCGGCGTAACGCGCGGCGCGCTTTATTGGCATTTCAAAAATAAGGAAGACTTGTTCGACGCGCTGTTCCAACGTATCTGCGACGACATCGAAAACTGCATCGCGCAAGATGCCGCAGATGCCGAAGGAGGGTCTTGGGCGGTATTCCGCCACACGCTGCTGCACTTTTTCGAGCGGCTGCAAAGCAACGACATCTACTACAAATTCCACAACATCCTGTTTTTAAAATGCGAACACACGGAGCAAAACGCCGCCGTTATCGCCATTGCCCGCAAGCATCAGGCAATCTGGCGCGAGAAAATTACCGCCGTTTTGACCGAAGCGGTGGAAAATCAGGATTTGGCTGACGATTTGGACAAGGAAACGGCGGTCATCTTCATCAAATCGACGTTGGACGGGCTGATTTGGCGTTGGTTCTCTTCCGGCGAAAGTTTCGATTTGGGCAAAACCGCCCCCCGCGCATCATCGGGATAATGATGGACAACTTGGAAAACCATCCCTGCCTGCGCCGGAAATAA",
                "porB": "AAAAACACCGACGACAACGTCAATGCTTGe",
                "ponA": "AAAAACAACGGCGGGCGTTGGGCGGTGGTTCAAGYGGCCGTTGCCGCAGGGGGCTTTGGTTTCGCTGGATGCAAAA",
                "gyrA": "ctgtacgcgatgcacgagctgaaaaataactggaatgccgcctacaaaaaatcggcgcgcatcgtcggcgacgtcatcggtaaataccacccccacggcgkttccgcagtttacgacaccatcgtccgtatggcgcaaaatttcgctatgcgttatgtgctgatagacggacagggcaacttcggatcggtggacgggcttgccgccgcagccatgcgctataccgaaatccgcatggcgaaaatctcacatgaaatgctggca",
                "parC": "GTTTCAGACGGCCAAAAGCCCGTGCAGCGGCGCATTTTGTTTGCCATJCGCGATATGGGTTTGACGGCGGGGGCGAAGCCGGTGAAATCGGCGCGCGTGGTCGGCGAGATTTTGGGTAAATACCATCCGCACGGCGACAGTTCCGCCTATGAGGCGATGGTGCGCATGGCTCAGGATTTTACCTTGCGCTACCCCTTAATCGACGGCATCGGCAACTTCGGTTCGCGCGACGGCGACGGGGCGGCGGCGATGCGTTACACCGAAGCGCGGCTGACGCCGATTGCGGAATTGCTGTTGTCCGAAATCAATCAGGGGACGGTGGATTTTATGCC",
                "23S" : "TAGACGGAAAGACCCCGTGAACCTTTACTGTAGCTTTGCATTGGACTTTGAAGTCACTTGTGTAGGATAGGTGGGAGGCTTGGAAGCAGAGACGCCAGTCTCTGTGGAGTCGTCCTTGAAATACCACCCTGGTGTCTTTGAGGTTCTAACCCAGACCCGTCATCCGGGTCGGGGACCGTGCATGGTAGGCAGTTTGACTGGGGCGGTCTCCTCCCAAAGCGTAACGGAGGAGTTCGAAGGTTACCTAGGTCCGGTCGGAAATCGGACTGATAGTGCAATGGCAAAAGGTAGCTTAACTGCGAGACCGACAAGTCGGGCAGGTGCGAAAGCAGGACATAGTGATCCGGTGGTTCTGTATGGAAGGGCCATCGCTCAACGGATAAAAGGTACTCCGGGGATAACAGGCTGATTCCGCCCAAGAGTTCATATCGACGGCGGAGTTTGGCACCTCGATGTCGGCTCATCACATCCTGGGGCTGTAGTCGGTCCCAAGGGTATGGCTGTTCGCCATTTAARAGTGGTACGTGAGCTGGGTTTAAAACGTCGTGAGACAGTTTGGTCCCTATCT",
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

        cls.success_msgs = {
                "Allele with Allele Type 1.000 Edited Successfully!",
                "Allele with Allele Type 2 Edited Successfully!",
                "Allele with Allele Type 3 Edited Successfully!",
                "Allele with Allele Type 4 Edited Successfully!",
                "Allele with Allele Type 5 Edited Successfully!",
                "Allele with Allele Type 6 Edited Successfully!",
                "Allele with Allele Type 7 Edited Successfully!",
        }

        cls.seq_exists_msgs = {
                "The sequence you have submitted already exists for the loci penA with allele type 2.000.",
                "The sequence you have submitted already exists for the loci mtrR with allele type 3.",
                "The sequence you have submitted already exists for the loci porB with allele type 4.",
                "The sequence you have submitted already exists for the loci ponA with allele type 5.",
                "The sequence you have submitted already exists for the loci gyrA with allele type 6.",
                "The sequence you have submitted already exists for the loci penA with allele type 7.",
                "The sequence you have submitted already exists for the loci penA with allele type 8.",
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


    def populateDB(self):

        driver = self.driver

        for loci_name in self.loci_names:

            allele_type = self.allele_types[loci_name]
            sequence = self.sequences[loci_name]

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

            element = driver.find_element_by_id(self.ALLELE_LIST_ALERT_ID)
            self.assertIn(self.ADD_ALLELE_SUCCESS_MSG, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[1]")
            self.assertIn(allele_type, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[2]")
            self.assertIn(loci_name, element.text)

    def populateDB_ADDITIONAL(self):

        driver = self.driver

        for loci_name in self.loci_names:

            allele_type = self.allele_types_additional[loci_name]
            sequence = self.sequences_additional[loci_name]

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

            element = driver.find_element_by_id(self.ALLELE_LIST_ALERT_ID)
            self.assertIn(self.ADD_ALLELE_SUCCESS_MSG, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[1]")
            self.assertIn(allele_type, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[2]/td[2]")
            self.assertIn(loci_name, element.text)


    def test_edit_allele_metadata_positive_cases(self):

        driver = self.driver
        self.signIn()

        self.populateDB()

        for loci_name in self.loci_names:

            allele_type = self.allele_types_radio_btns[loci_name]
            allele_type_edited = self.allele_types_edited[loci_name]
            sequence = self.edited_positive_sequences[loci_name]

            collection_date = self.collection_date[loci_name]
            country = self.country[loci_name]
            patient_age = self.patient_age[loci_name]
            patient_gender = self.patient_gender[loci_name]
            beta_lactamase = self.beta_lactamase[loci_name]
            isolate_classification = self.isolate_classifications[loci_name]
            mics_determined_by = self.mics_determined_by[loci_name]
            epi_data = self.epi_data[loci_name]
            curator_comment = self.curator_comment[loci_name]

            radio_button_value = loci_name + ":" + allele_type
            driver.get(constants.LIST_LOCI_ALLELES_BASE_URL + loci_name)

            element = driver.find_element_by_css_selector("input[type='radio'][value='" + radio_button_value + "']")
            element.click()
            element = driver.find_element_by_css_selector(self.EDIT_ALLELE_BTN_CSS_SEL)
            element.click()

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            element = driver.find_element_by_xpath('//*[@id="select2-loci_name_option-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(loci_name)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_id(self.ADD_ALLELE_TYPE_TEXTBOX_ID)
            element.clear()
            element.send_keys(allele_type_edited)

            script = "var $item = $('#" + self.ADD_ALLELE_SEQ_TEXTBOX_ID + "'); \
                            $($item).val('" + sequence + "');"
            driver.execute_script(script)

            script = "var $item = $('#" + self.COLLECTION_DATE_TEXTBOX_ID + "'); \
                            $($item).val('" + collection_date + "');"
            driver.execute_script(script)

            element = driver.find_element_by_id(self.ADD_ALLELE_COUNTRY_TEXTBOX_ID)
            element.send_keys(country)

            element = driver.find_element_by_id(self.ADD_ALLELE_PATIENT_AGE_TEXTBOX_ID)
            element.send_keys(patient_age)

            element = driver.find_element_by_xpath('//*[@id="select2-patient_gender-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(patient_gender)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_xpath('//*[@id="select2-beta_lactamase-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(beta_lactamase)
            element.send_keys(Keys.RETURN)


            element = driver.find_element_by_id(self.ADD_ALLELE_ISOLATE_CLASSIFICATION_TEXTBOX_ID)
            element.send_keys(isolate_classification)

            element = driver.find_element_by_css_selector("input[type='radio'][value='" + mics_determined_by + "']")
            element.click()

            if mics_determined_by != "":

                if mics_determined_by == "Disc Diffusion":
                    for key in self.interpretation_keys:

                        element = driver.find_element_by_xpath('//*[@id="select2-'+ self.interpretation_keys[key] +'-container"]')
                        element.click()
                        element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
                        element.click()
                        element.send_keys(self.interpretation_values[key])
                        element.send_keys(Keys.RETURN)

                elif mics_determined_by == "E-Test" or mics_determined_by == "Agar Dilution":
                    for key in self.mic_comparator_keys:

                        element = driver.find_element_by_xpath('//*[@id="select2-'+ self.mic_comparator_keys[key] +'-container"]')
                        element.click()
                        element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
                        element.click()
                        element.send_keys(self.mic_comparator[key])
                        element.send_keys(Keys.RETURN)

                    for key in self.mic_textbox_ids:
                        script = "var $item = $('#" + self.mic_textbox_ids[key] + "'); \
                                        $($item).val('" + self.mic_values[key] + "');"
                        driver.execute_script(script)


            script = "var $item = $('#" + self.ADD_ALLELE_EPI_DATA_TEXTBOX_ID + "'); \
                            $($item).val('" + epi_data + "');"
            driver.execute_script(script)


            script = "var $item = $('#" + self.ADD_ALLELE_CURATOR_COMMENT_TEXTBOX_ID + "'); \
                            $($item).val('" + curator_comment + "');"
            driver.execute_script(script)

            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            element = driver.find_element_by_id(self.ALLELE_LIST_ALERT_ID)

            for edit_success_msg in self.success_msgs:

                self.EDIT_ALLELE_SUCCESS_MSG = edit_success_msg

                if element.text == self.EDIT_ALLELE_SUCCESS_MSG:

                    self.assertIn(self.EDIT_ALLELE_SUCCESS_MSG, element.text)

            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[1]")
            self.assertIn(allele_type_edited, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[2]")
            self.assertIn(loci_name, element.text)
            element = driver.find_element_by_xpath("//table/tbody/tr[1]/td[4]")
            self.assertIn(curator_comment, element.text)

        self.signOut()
        self.clearDB_edited_alleles()

    def test_edit_allele_metadata_negative_cases(self):

        driver = self.driver
        self.signIn()

        self.populateDB()

        for loci_name in self.loci_names:

            allele_type = self.allele_types_radio_btns[loci_name]
            sequence = self.edited_positive_sequences[loci_name]

            collection_date = self.negative_collection_date[loci_name]
            country = self.negative_country[loci_name]
            patient_age = self.negative_patient_age[loci_name]
            patient_gender = self.patient_gender[loci_name]
            beta_lactamase = self.beta_lactamase[loci_name]
            isolate_classification = self.negative_isolate_classifications[loci_name]
            mics_determined_by = self.mics_determined_by[loci_name]
            epi_data = self.negative_epi_data[loci_name]
            curator_comment = self.negative_curator_comment[loci_name]

            radio_button_value = loci_name + ":" + allele_type
            driver.get(constants.LIST_LOCI_ALLELES_BASE_URL + loci_name)

            element = driver.find_element_by_css_selector("input[type='radio'][value='" + radio_button_value + "']")
            element.click()
            element = driver.find_element_by_css_selector(self.EDIT_ALLELE_BTN_CSS_SEL)
            element.click()

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

            script = "var $item = $('#" + self.COLLECTION_DATE_TEXTBOX_ID + "'); \
                            $($item).val('" + collection_date + "');"
            driver.execute_script(script)

            element = driver.find_element_by_id(self.ADD_ALLELE_COUNTRY_TEXTBOX_ID)
            element.send_keys(country)

            element = driver.find_element_by_id(self.ADD_ALLELE_PATIENT_AGE_TEXTBOX_ID)
            element.send_keys(patient_age)

            element = driver.find_element_by_xpath('//*[@id="select2-patient_gender-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(patient_gender)
            element.send_keys(Keys.RETURN)

            element = driver.find_element_by_xpath('//*[@id="select2-beta_lactamase-container"]')
            element.click()
            element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
            element.click()
            element.send_keys(beta_lactamase)
            element.send_keys(Keys.RETURN)


            element = driver.find_element_by_id(self.ADD_ALLELE_ISOLATE_CLASSIFICATION_TEXTBOX_ID)
            element.send_keys(isolate_classification)


            element = driver.find_element_by_css_selector("input[type='radio'][value='" + mics_determined_by + "']")
            element.click()

            if mics_determined_by != "":

                if mics_determined_by == "E-Test" or mics_determined_by == "Agar Dilution":
                    for key in self.mic_comparator_keys:

                        element = driver.find_element_by_xpath('//*[@id="select2-'+ self.mic_comparator_keys[key] +'-container"]')
                        element.click()
                        element = driver.find_element_by_xpath('/html/body/span/span/span[1]/input')
                        element.click()
                        element.send_keys(self.mic_comparator[key])
                        element.send_keys(Keys.RETURN)

                    for key in self.mic_textbox_ids:
                        script = "var $item = $('#" + self.mic_textbox_ids[key] + "'); \
                                        $($item).val('" + self.negative_mic_values[key] + "');"
                        driver.execute_script(script)

            script = "var $item = $('#" + self.ADD_ALLELE_EPI_DATA_TEXTBOX_ID + "'); \
                            $($item).val('" + epi_data + "');"
            driver.execute_script(script)


            script = "var $item = $('#" + self.ADD_ALLELE_CURATOR_COMMENT_TEXTBOX_ID + "'); \
                            $($item).val('" + curator_comment + "');"
            driver.execute_script(script)

            element = driver.find_element_by_id(self.SUBMIT_BTN_ID)
            element.click()

            elements = driver.find_elements_by_class_name("help-block")
            error_msgs = [element.text for element in elements]
            self.assertIn(self.ALLELE_COLLECTION_DATE_CHAR_ERROR, error_msgs, error_msgs)
            self.assertIn(self.ALLELE_COUNTRY_CHAR_ERROR, error_msgs, error_msgs)
            self.assertIn(self.ALLELE_PATIENT_AGE_CHAR_ERROR, error_msgs, error_msgs)

            self.assertIn(self.ALLELE_EPI_DATA_CHAR_ERROR, error_msgs, error_msgs)
            self.assertIn(self.ALLELE_CURATOR_COMMENT_CHAR_ERROR, error_msgs, error_msgs)

        self.signOut()
        self.clearDB()

    def clearDB(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names:
            allele_type = self.allele_types_clear_db[loci_name]

            radio_button_value = loci_name + ":" + allele_type
            driver.get(constants.LIST_LOCI_ALLELES_BASE_URL + loci_name)

            element = driver.find_element_by_css_selector("input[type='radio'][value='" + radio_button_value + "']")
            element.click()
            element = driver.find_element_by_id(self.DELETE_ALLELE_BTN_CSS_SEL)
            element.click()

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            script = "window.jQuery(document).ready(function() { \
                          $('" + "#" + self.DELETE_ALLELE_ALERT_BTN_ID + "').click(); \
                      })"
            driver.execute_script(script)
            elements = driver.find_elements_by_tag_name("strong")
            msgs = [e.text for e in elements]
            self.assertIn(self.DELETE_ALLELE_SUCCESS_MSG, msgs)

        self.signOut()

    def clearDB_edited_alleles(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names:
            allele_type = self.allele_types_clear_db_edited[loci_name]

            radio_button_value = loci_name + ":" + allele_type
            driver.get(constants.LIST_LOCI_ALLELES_BASE_URL + loci_name)

            element = driver.find_element_by_css_selector("input[type='radio'][value='" + radio_button_value + "']")
            element.click()
            element = driver.find_element_by_id(self.DELETE_ALLELE_BTN_CSS_SEL)
            element.click()

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            script = "window.jQuery(document).ready(function() { \
                          $('" + "#" + self.DELETE_ALLELE_ALERT_BTN_ID + "').click(); \
                      })"
            driver.execute_script(script)
            elements = driver.find_elements_by_tag_name("strong")
            msgs = [e.text for e in elements]
            self.assertIn(self.DELETE_ALLELE_SUCCESS_MSG, msgs)

        self.signOut()

    def clearDB_alleles_additional(self):

        driver = self.driver
        self.signIn()

        for loci_name in self.loci_names:
            allele_type = self.allele_types_clear_db_additional[loci_name]

            radio_button_value = loci_name + ":" + allele_type
            driver.get(constants.LIST_LOCI_ALLELES_BASE_URL + loci_name)

            element = driver.find_element_by_css_selector("input[type='radio'][value='" + radio_button_value + "']")
            element.click()
            element = driver.find_element_by_id(self.DELETE_ALLELE_BTN_CSS_SEL)
            element.click()

            WebDriverWait(driver, 10).until(lambda driver: driver.execute_script("return window.jQuery && window.jQuery.active === 0;"))

            script = "window.jQuery(document).ready(function() { \
                          $('" + "#" + self.DELETE_ALLELE_ALERT_BTN_ID + "').click(); \
                      })"
            driver.execute_script(script)
            elements = driver.find_elements_by_tag_name("strong")
            msgs = [e.text for e in elements]
            self.assertIn(self.DELETE_ALLELE_SUCCESS_MSG, msgs)

        self.signOut()


    @classmethod
    def tearDownClass(cls):
        if not cls.DRIVER:
            cls.driver.close()

if __name__ == '__main__':
    unittest.main()
