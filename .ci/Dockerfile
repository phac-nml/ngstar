FROM perl:5.20


USER root


#==============
# Perl modules
#==============
RUN cpanm -f MIME::Tools \
  && cpanm Catalyst::Runtime \
    Catalyst::Devel  \
    Devel::InnerPackage \
    Bio::Perl \
    Catalyst::Authentication::Store::DBIx::Class  \
    Catalyst::Helper::Model::Email  \
    Catalyst::Model::Adaptor  \
    Catalyst::Plugin::Authentication  \
    Catalyst::Plugin::Authorization::ACL  \
    Catalyst::Plugin::Authorization::Roles  \
    Catalyst::Plugin::AutoRestart  \
    Catalyst::Plugin::ConfigLoader  \
    Catalyst::Plugin::I18N \
    Catalyst::Plugin::Session  \
    Catalyst::Plugin::Session::State::Cookie  \
    Catalyst::Plugin::Session::Store::File  \
    Catalyst::Plugin::StackTrace  \
    Catalyst::Plugin::Static::Simple  \
    Catalyst::View::Email::Template  \
    Catalyst::View::TT  \
    Config::General  \
    Crypt::Blowfish  \
    Crypt::CBC  \
    Crypt::Eksblowfish::Bcrypt  \
    Crypt::Eksblowfish::Family  \
    DBD::mysql \
    DBI \
    DBIx::Class  \
    DBIx::Class::PassphraseColumn  \
    DBIx::Class::Schema::Loader  \
    DBIx::Class::TimeStamp  \
    DateTime  \
    Getopt::Long \
    HTML::FormHandler  \
    Mail::Builder::Simple  \
    Moose  \
    MooseX::NonMoose  \
    MooseX::Role::WithOverloading  \
    Net::SMTP \
    Net::SMTP::SSL \
    Pod::Usage \
    Readonly  \
    Session::Token  \
    String::Random  \
    Template  \
    Test::Class  \
    Test::More  \
    Text::Sprintf::Named  \
    namespace::autoclean


#================
# Xvfb and unzip
#================
RUN apt-get update -qqy \
  && apt-get -qqy install \
    xvfb unzip\
  && rm -rf /var/lib/apt/lists/*


#==========
# Selenium
#==========
RUN apt-get update -qqy \
  && apt-get -qqy install \
    python-dev python-pip \
  && pip install selenium \
  && pip install subprocess32 \
  && rm -rf /var/lib/apt/lists/*


#===============
# Google Chrome
#===============
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    google-chrome-stable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/*


#==================
# Chrome webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.21
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

#===================================
# Chrome Launch Script Modification
#===================================
COPY chrome_launcher.sh /opt/google/chrome/google-chrome
RUN chmod +x /opt/google/chrome/google-chrome


#=================
# NCBI Blast Plus
#=================
RUN apt-get update -qqy \
  && apt-get -qqy install \
    ncbi-blast+ \
  && rm -rf /var/lib/apt/lists/*

#=========
# pymysql
#=========
RUN pip install pymysql
