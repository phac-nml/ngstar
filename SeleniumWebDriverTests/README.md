# Selenium WebDriver Testing

## Requirements
We require the following Python packages and tools for our Selenium WebDriver tests. Installation instructions are included below.

1. pip
2. virtualenv
3. selenium
4. chromedriver
5. unittest
6. flake8

## Installation

Install the Python package installer called pip:

    sudo apt-get install python-pip

Install virtualenv using pip:

    sudo pip install virtualenv

Change directory to the **SeleniumWebDriverTests** directory in the project.

In the **SeleniumWebDriverTests** directory, create a virtual environment using virtualenv:

    virtualenv myvenv

This will create a directory called **myvenv** in the **SeleniumWebDriverTests** directory.

Activate the virtual environment:

    source myvenv/bin/activate

You should see the name of the virtual environment to the left of your shell prompt. Your shell prompt should look similar to this:

`(myvenv)irish_m@Orion:~/ng-star/SeleniumWebDriverTests$`

Next, install the required Python packages for testing **in your virtual environment** (you are inside your virtual environment if you see the name of your virtual environment in parenthesis to the left of your shell prompt):

    (myvenv)irish_m@Orion:~/ng-star/SeleniumWebDriverTests$ pip install selenium

    (myvenv)irish_m@Orion:~/ng-star/SeleniumWebDriverTests$ pip install flake8

Download the latest version of Chrome driver:
https://sites.google.com/a/chromium.org/chromedriver/home

Change directory to your Chrome driver download and unzip the Chrome driver file:

    unzip chromedriver_myplatform.zip

You should end up with a file called **chromedriver**.

You must move the file **chromedriver** to **/usr/bin**. To do this, run the following command in the directory where **chromedriver** is:

    sudo mv chromedriver /usr/bin

## Running Tests

Change directory to the **SeleniumWebDriverTests** directory.

Activate the virtual environment:

    source myvenv/bin/activate

Run the test suite:

    (myvenv)irish_m@Orion:~/ng-star/SeleniumWebDriverTests$ python suite.py

All test cases are independent of each other and can be run separately. You can run an individual test case by running the following command:

    (myvenv)irish_m@Orion:~/ng-star/SeleniumWebDriverTests$ python name_of_test_case.py

You must have your virtual environment activated in order to run tests (because the Python packages required for testing have been installed in your virtual environment).

## PEP8 Style Guide for Python Code

We will follow the coding style guide as suggested in PEP8 (https://www.python.org/dev/peps/pep-0008/).

After you have written your tests, you can check whether your code has PEP8 compliance by using the flake8 tool.

First, change directory to the **SeleniumWebDriverTests** directory.

Make sure that you have activated your virtual environment:

    source myvenv/bin/activate

Run flake8 on your test script:

    flake8 name_of_test_script.py

flake8 will output style suggestions that you can fix manually. You eventually want flake8 to output nothing, meaning that your test script has PEP8 compliance.
    
## Documentation

Python Virtual Environments:
http://docs.python-guide.org/en/latest/dev/virtualenvs/

Selenium Python Bindings:
https://selenium-python.readthedocs.org/index.html

unittest - Python Unit Testing Framework:
https://docs.python.org/3/library/unittest.html

PEP8 Style Guide for Python Code:
https://www.python.org/dev/peps/pep-0008/

flake8:
https://pypi.python.org/pypi/flake8
