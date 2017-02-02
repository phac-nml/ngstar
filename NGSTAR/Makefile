# This Makefile is for the NGSTAR extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.66 (Revision: 66600) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     ABSTRACT => q[Catalyst based application]
#     AUTHOR => [q[Irish Medina]]
#     BUILD_REQUIRES => { ExtUtils::MakeMaker=>q[6.36], Test::More=>q[0.88] }
#     CONFIGURE_REQUIRES => {  }
#     DISTNAME => q[NGSTAR]
#     EXE_FILES => [q[script/ngstar_cgi.pl], q[script/ngstar_create.pl], q[script/ngstar_fastcgi.pl], q[script/ngstar_server.pl], q[script/ngstar_test.pl]]
#     LICENSE => q[perl]
#     NAME => q[NGSTAR]
#     NO_META => q[1]
#     PREREQ_PM => { Catalyst::Plugin::Session::State::Cookie=>q[0], Catalyst::Plugin::Authentication=>q[0], Catalyst::Action::RenderView=>q[0], Catalyst::Plugin::ConfigLoader=>q[0], HTML::FormHandler::Model::DBIC=>q[0], Test::More=>q[0.88], ExtUtils::MakeMaker=>q[6.36], Config::General=>q[0], Catalyst::Plugin::Static::Simple=>q[0], Moose=>q[0], Catalyst::Plugin::Session=>q[0], HTML::FormHandler=>q[0], Catalyst::Plugin::StackTrace=>q[0], namespace::autoclean=>q[0], Catalyst::Plugin::Session::Store::File=>q[0], Catalyst::Plugin::Authorization::Roles=>q[0], Catalyst::Runtime=>q[5.90053] }
#     TEST_REQUIRES => {  }
#     VERSION => q[0.01]
#     VERSION_FROM => q[lib/NGSTAR.pm]
#     dist => {  }
#     realclean => { FILES=>q[MYMETA.yml] }
#     test => { TESTS=>q[t/01app.t t/02pod.t t/03podcoverage.t t/controller_Account.t t/controller_Admin.t t/controller_Allele.t t/controller_Curator.t t/controller_ForgotPassword.t t/controller_Login.t t/controller_Logout.t t/controller_ProjectInfo.t t/controller_ResetPassword.t t/controller_Scheme.t t/controller_SequenceType.t t/model_AddAllele.t t/model_AddBatchMetadata.t t/model_AddMetadata.t t/model_AddNewUser.t t/model_AddResetRequest.t t/model_AddScheme.t t/model_AddSequenceTypeProfile.t t/model_BatchAddAllele.t t/model_BatchAddMetadata.t t/model_BatchAddProfile.t t/model_DB.t t/model_DeleteAllele.t t/model_DeleteSequenceTypeProfile.t t/model_EditAllele.t t/model_EditSequenceTypeProfile.t t/model_GetAlleleInfo.t t/model_GetAlleleType.t t/model_GetError.t t/model_GetIntegerType.t t/model_GetMetadata.t t/model_GetSequenceType.t t/model_GetSequenceTypeInfo.t t/model_GetUserInfo.t t/model_UpdateUserInformation.t t/model_UpdateUserPassword.t t/model_ValidateBatchAlleles.t t/model_ValidateBatchMetadata.t t/model_ValidateBatchProfiles.t t/model_ValidateEmailForm.t t/model_ValidateForgotPasswordInfo.t t/model_ValidateMetadata.t t/model_ValidateNewUser.t t/model_ValidateNewUsername.t t/view_Email-Template.t t/view_Email.t t/view_HTML.t t/view_TT-NoWrap.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib/perl/5.18/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = cc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,-E
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = cc
LDDLFLAGS = -shared -L/usr/local/lib -fstack-protector
LDFLAGS =  -fstack-protector -L/usr/local/lib
LIBC = 
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 3.2.0-58-generic
RANLIB = :
SITELIBEXP = /usr/local/share/perl/5.18.2
SITEARCHEXP = /usr/local/lib/perl/5.18.2
SO = so
VENDORARCHEXP = /usr/lib/perl5
VENDORLIBEXP = /usr/share/perl5


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = NGSTAR
NAME_SYM = NGSTAR
VERSION = 0.01
VERSION_MACRO = VERSION
VERSION_SYM = 0_01
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.01
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1p
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = /usr
PERLPREFIX = $(PREFIX)
SITEPREFIX = $(PREFIX)/local
VENDORPREFIX = $(PREFIX)
INSTALLPRIVLIB = $(PERLPREFIX)/share/perl/5.18
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = $(SITEPREFIX)/share/perl/5.18.2
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = $(VENDORPREFIX)/share/perl5
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(PERLPREFIX)/lib/perl/5.18
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = $(SITEPREFIX)/lib/perl/5.18.2
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = $(VENDORPREFIX)/lib/perl5
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(PERLPREFIX)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(SITEPREFIX)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = $(VENDORPREFIX)/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(PERLPREFIX)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = $(SITEPREFIX)/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = $(VENDORPREFIX)/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = $(PERLPREFIX)/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(SITEPREFIX)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = $(VENDORPREFIX)/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(PERLPREFIX)/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(SITEPREFIX)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = $(VENDORPREFIX)/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /usr/lib/perl/5.18
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib/perl/5.18/CORE
PERL = /usr/bin/perl "-Iinc"
FULLPERL = /usr/bin/perl "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/share/perl/5.18/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.66
MM_REVISION = 66600

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = NGSTAR
BASEEXT = NGSTAR
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/NGSTAR.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = script/ngstar_cgi.pl \
	script/ngstar_create.pl \
	script/ngstar_fastcgi.pl \
	script/ngstar_server.pl \
	script/ngstar_test.pl
MAN3PODS = lib/NGSTAR.pm \
	lib/NGSTAR/Controller/Account.pm \
	lib/NGSTAR/Controller/Admin.pm \
	lib/NGSTAR/Controller/Allele.pm \
	lib/NGSTAR/Controller/Curator.pm \
	lib/NGSTAR/Controller/ForgotPassword.pm \
	lib/NGSTAR/Controller/Login.pm \
	lib/NGSTAR/Controller/Logout.pm \
	lib/NGSTAR/Controller/ProjectInfo.pm \
	lib/NGSTAR/Controller/ResetPassword.pm \
	lib/NGSTAR/Controller/Root.pm \
	lib/NGSTAR/Controller/Scheme.pm \
	lib/NGSTAR/Controller/SequenceType.pm \
	lib/NGSTAR/Model/DB.pm \
	lib/NGSTAR/View/HTML.pm \
	lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm \
	lib/NGSTAR_Auth/Schema/Result/Role.pm \
	lib/NGSTAR_Auth/Schema/Result/User.pm \
	lib/NGSTAR_Auth/Schema/Result/UserRole.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/NGSTAR.pm \
	lib/NGSTAR/Controller/Account.pm \
	lib/NGSTAR/Controller/Admin.pm \
	lib/NGSTAR/Controller/Allele.pm \
	lib/NGSTAR/Controller/Curator.pm \
	lib/NGSTAR/Controller/ForgotPassword.pm \
	lib/NGSTAR/Controller/Login.pm \
	lib/NGSTAR/Controller/Logout.pm \
	lib/NGSTAR/Controller/ProjectInfo.pm \
	lib/NGSTAR/Controller/ResetPassword.pm \
	lib/NGSTAR/Controller/Root.pm \
	lib/NGSTAR/Controller/Scheme.pm \
	lib/NGSTAR/Controller/SequenceType.pm \
	lib/NGSTAR/Form/AddAlleleForm.pm \
	lib/NGSTAR/Form/AddProfileForm.pm \
	lib/NGSTAR/Form/AddSchemeForm.pm \
	lib/NGSTAR/Form/AlleleForm.pm \
	lib/NGSTAR/Form/BatchAddAlleleForm.pm \
	lib/NGSTAR/Form/BatchAddMetadataForm.pm \
	lib/NGSTAR/Form/BatchAddProfileForm.pm \
	lib/NGSTAR/Form/BatchAddProfileMetadataForm.pm \
	lib/NGSTAR/Form/CreateAccountForm.pm \
	lib/NGSTAR/Form/EditAccountForm.pm \
	lib/NGSTAR/Form/EditAlleleForm.pm \
	lib/NGSTAR/Form/EditProfileForm.pm \
	lib/NGSTAR/Form/EmailAlleleForm.pm \
	lib/NGSTAR/Form/ForgotPasswordForm.pm \
	lib/NGSTAR/Form/ResetPasswordForm.pm \
	lib/NGSTAR/Form/SequenceTypeForm.pm \
	lib/NGSTAR/Form/SignInForm.pm \
	lib/NGSTAR/Form/UpdateEmailForm.pm \
	lib/NGSTAR/Form/UpdatePasswordForm.pm \
	lib/NGSTAR/Form/UpdateUsernameForm.pm \
	lib/NGSTAR/Model/AddAllele.pm \
	lib/NGSTAR/Model/AddBatchMetadata.pm \
	lib/NGSTAR/Model/AddMetadata.pm \
	lib/NGSTAR/Model/AddNewUser.pm \
	lib/NGSTAR/Model/AddResetRequest.pm \
	lib/NGSTAR/Model/AddScheme.pm \
	lib/NGSTAR/Model/AddSequenceTypeProfile.pm \
	lib/NGSTAR/Model/BatchAddAllele.pm \
	lib/NGSTAR/Model/BatchAddMetadata.pm \
	lib/NGSTAR/Model/BatchAddProfile.pm \
	lib/NGSTAR/Model/CuratorEmail.pm \
	lib/NGSTAR/Model/DB.pm \
	lib/NGSTAR/Model/DB.pm.new \
	lib/NGSTAR/Model/DeleteAllele.pm \
	lib/NGSTAR/Model/DeleteSequenceTypeProfile.pm \
	lib/NGSTAR/Model/EditAllele.pm \
	lib/NGSTAR/Model/EditSequenceTypeProfile.pm \
	lib/NGSTAR/Model/Email.pm \
	lib/NGSTAR/Model/GetAlleleInfo.pm \
	lib/NGSTAR/Model/GetAlleleType.pm \
	lib/NGSTAR/Model/GetError.pm \
	lib/NGSTAR/Model/GetIntegerType.pm \
	lib/NGSTAR/Model/GetMetadata.pm \
	lib/NGSTAR/Model/GetSequenceType.pm \
	lib/NGSTAR/Model/GetSequenceTypeInfo.pm \
	lib/NGSTAR/Model/GetUserInfo.pm \
	lib/NGSTAR/Model/UpdateUserInformation.pm \
	lib/NGSTAR/Model/ValidateBatchAlleles.pm \
	lib/NGSTAR/Model/ValidateBatchMetadata.pm \
	lib/NGSTAR/Model/ValidateBatchProfiles.pm \
	lib/NGSTAR/Model/ValidateEditUserAccount.pm \
	lib/NGSTAR/Model/ValidateEmailForm.pm \
	lib/NGSTAR/Model/ValidateForgotPasswordInfo.pm \
	lib/NGSTAR/Model/ValidateMetadata.pm \
	lib/NGSTAR/Model/ValidateNewUser.pm \
	lib/NGSTAR/View/HTML.pm \
	lib/NGSTAR_Auth/Schema.pm \
	lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm \
	lib/NGSTAR_Auth/Schema/Result/Role.pm \
	lib/NGSTAR_Auth/Schema/Result/User.pm \
	lib/NGSTAR_Auth/Schema/Result/UserRole.pm

PM_TO_BLIB = lib/NGSTAR/Model/DeleteAllele.pm \
	blib/lib/NGSTAR/Model/DeleteAllele.pm \
	lib/NGSTAR/Model/AddScheme.pm \
	blib/lib/NGSTAR/Model/AddScheme.pm \
	lib/NGSTAR/Model/AddMetadata.pm \
	blib/lib/NGSTAR/Model/AddMetadata.pm \
	lib/NGSTAR/Model/ValidateBatchAlleles.pm \
	blib/lib/NGSTAR/Model/ValidateBatchAlleles.pm \
	lib/NGSTAR/Form/ForgotPasswordForm.pm \
	blib/lib/NGSTAR/Form/ForgotPasswordForm.pm \
	lib/NGSTAR/Form/EditProfileForm.pm \
	blib/lib/NGSTAR/Form/EditProfileForm.pm \
	lib/NGSTAR/Model/GetUserInfo.pm \
	blib/lib/NGSTAR/Model/GetUserInfo.pm \
	lib/NGSTAR/Model/AddResetRequest.pm \
	blib/lib/NGSTAR/Model/AddResetRequest.pm \
	lib/NGSTAR/Model/DB.pm.new \
	blib/lib/NGSTAR/Model/DB.pm.new \
	lib/NGSTAR/Model/CuratorEmail.pm \
	blib/lib/NGSTAR/Model/CuratorEmail.pm \
	lib/NGSTAR/Controller/ForgotPassword.pm \
	blib/lib/NGSTAR/Controller/ForgotPassword.pm \
	lib/NGSTAR/Form/EditAlleleForm.pm \
	blib/lib/NGSTAR/Form/EditAlleleForm.pm \
	lib/NGSTAR/Model/AddAllele.pm \
	blib/lib/NGSTAR/Model/AddAllele.pm \
	lib/NGSTAR/Form/EditAccountForm.pm \
	blib/lib/NGSTAR/Form/EditAccountForm.pm \
	lib/NGSTAR/Form/AddProfileForm.pm \
	blib/lib/NGSTAR/Form/AddProfileForm.pm \
	lib/NGSTAR/Model/GetAlleleType.pm \
	blib/lib/NGSTAR/Model/GetAlleleType.pm \
	lib/NGSTAR/Model/GetMetadata.pm \
	blib/lib/NGSTAR/Model/GetMetadata.pm \
	lib/NGSTAR/Model/AddNewUser.pm \
	blib/lib/NGSTAR/Model/AddNewUser.pm \
	lib/NGSTAR_Auth/Schema.pm \
	blib/lib/NGSTAR_Auth/Schema.pm \
	lib/NGSTAR/Controller/Root.pm \
	blib/lib/NGSTAR/Controller/Root.pm \
	lib/NGSTAR/Controller/Allele.pm \
	blib/lib/NGSTAR/Controller/Allele.pm \
	lib/NGSTAR_Auth/Schema/Result/Role.pm \
	blib/lib/NGSTAR_Auth/Schema/Result/Role.pm \
	lib/NGSTAR/Controller/ProjectInfo.pm \
	blib/lib/NGSTAR/Controller/ProjectInfo.pm \
	lib/NGSTAR/Model/ValidateEditUserAccount.pm \
	blib/lib/NGSTAR/Model/ValidateEditUserAccount.pm \
	lib/NGSTAR/Form/UpdateEmailForm.pm \
	blib/lib/NGSTAR/Form/UpdateEmailForm.pm \
	lib/NGSTAR/Controller/Logout.pm \
	blib/lib/NGSTAR/Controller/Logout.pm \
	lib/NGSTAR/Model/GetAlleleInfo.pm \
	blib/lib/NGSTAR/Model/GetAlleleInfo.pm \
	lib/NGSTAR.pm \
	blib/lib/NGSTAR.pm \
	lib/NGSTAR/Controller/SequenceType.pm \
	blib/lib/NGSTAR/Controller/SequenceType.pm \
	lib/NGSTAR/Model/BatchAddMetadata.pm \
	blib/lib/NGSTAR/Model/BatchAddMetadata.pm \
	lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm \
	blib/lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm \
	lib/NGSTAR/Form/SignInForm.pm \
	blib/lib/NGSTAR/Form/SignInForm.pm \
	lib/NGSTAR/Form/CreateAccountForm.pm \
	blib/lib/NGSTAR/Form/CreateAccountForm.pm \
	lib/NGSTAR/Model/UpdateUserInformation.pm \
	blib/lib/NGSTAR/Model/UpdateUserInformation.pm \
	lib/NGSTAR/Model/ValidateBatchProfiles.pm \
	blib/lib/NGSTAR/Model/ValidateBatchProfiles.pm \
	lib/NGSTAR/Form/UpdatePasswordForm.pm \
	blib/lib/NGSTAR/Form/UpdatePasswordForm.pm \
	lib/NGSTAR_Auth/Schema/Result/UserRole.pm \
	blib/lib/NGSTAR_Auth/Schema/Result/UserRole.pm \
	lib/NGSTAR/Form/EmailAlleleForm.pm \
	blib/lib/NGSTAR/Form/EmailAlleleForm.pm \
	lib/NGSTAR/Model/Email.pm \
	blib/lib/NGSTAR/Model/Email.pm \
	lib/NGSTAR/Model/BatchAddProfile.pm \
	blib/lib/NGSTAR/Model/BatchAddProfile.pm \
	lib/NGSTAR/Model/AddSequenceTypeProfile.pm \
	blib/lib/NGSTAR/Model/AddSequenceTypeProfile.pm \
	lib/NGSTAR/Controller/Login.pm \
	blib/lib/NGSTAR/Controller/Login.pm \
	lib/NGSTAR/Model/GetSequenceType.pm \
	blib/lib/NGSTAR/Model/GetSequenceType.pm \
	lib/NGSTAR/Controller/ResetPassword.pm \
	blib/lib/NGSTAR/Controller/ResetPassword.pm \
	lib/NGSTAR/Model/ValidateNewUser.pm \
	blib/lib/NGSTAR/Model/ValidateNewUser.pm \
	lib/NGSTAR/Model/ValidateMetadata.pm \
	blib/lib/NGSTAR/Model/ValidateMetadata.pm \
	lib/NGSTAR/Form/SequenceTypeForm.pm \
	blib/lib/NGSTAR/Form/SequenceTypeForm.pm \
	lib/NGSTAR/Form/AlleleForm.pm \
	blib/lib/NGSTAR/Form/AlleleForm.pm \
	lib/NGSTAR/Model/EditAllele.pm \
	blib/lib/NGSTAR/Model/EditAllele.pm \
	lib/NGSTAR/Form/UpdateUsernameForm.pm \
	blib/lib/NGSTAR/Form/UpdateUsernameForm.pm \
	lib/NGSTAR/Form/AddSchemeForm.pm \
	blib/lib/NGSTAR/Form/AddSchemeForm.pm \
	lib/NGSTAR/Form/AddAlleleForm.pm \
	blib/lib/NGSTAR/Form/AddAlleleForm.pm \
	lib/NGSTAR/Model/GetSequenceTypeInfo.pm \
	blib/lib/NGSTAR/Model/GetSequenceTypeInfo.pm \
	lib/NGSTAR/Form/BatchAddMetadataForm.pm \
	blib/lib/NGSTAR/Form/BatchAddMetadataForm.pm \
	lib/NGSTAR_Auth/Schema/Result/User.pm \
	blib/lib/NGSTAR_Auth/Schema/Result/User.pm \
	lib/NGSTAR/Form/BatchAddProfileForm.pm \
	blib/lib/NGSTAR/Form/BatchAddProfileForm.pm \
	lib/NGSTAR/Controller/Account.pm \
	blib/lib/NGSTAR/Controller/Account.pm \
	lib/NGSTAR/View/HTML.pm \
	blib/lib/NGSTAR/View/HTML.pm \
	lib/NGSTAR/Model/DeleteSequenceTypeProfile.pm \
	blib/lib/NGSTAR/Model/DeleteSequenceTypeProfile.pm \
	lib/NGSTAR/Model/GetIntegerType.pm \
	blib/lib/NGSTAR/Model/GetIntegerType.pm \
	lib/NGSTAR/Model/AddBatchMetadata.pm \
	blib/lib/NGSTAR/Model/AddBatchMetadata.pm \
	lib/NGSTAR/Form/BatchAddAlleleForm.pm \
	blib/lib/NGSTAR/Form/BatchAddAlleleForm.pm \
	lib/NGSTAR/Model/ValidateForgotPasswordInfo.pm \
	blib/lib/NGSTAR/Model/ValidateForgotPasswordInfo.pm \
	lib/NGSTAR/Model/ValidateEmailForm.pm \
	blib/lib/NGSTAR/Model/ValidateEmailForm.pm \
	lib/NGSTAR/Model/EditSequenceTypeProfile.pm \
	blib/lib/NGSTAR/Model/EditSequenceTypeProfile.pm \
	lib/NGSTAR/Form/ResetPasswordForm.pm \
	blib/lib/NGSTAR/Form/ResetPasswordForm.pm \
	lib/NGSTAR/Model/GetError.pm \
	blib/lib/NGSTAR/Model/GetError.pm \
	lib/NGSTAR/Model/DB.pm \
	blib/lib/NGSTAR/Model/DB.pm \
	lib/NGSTAR/Model/ValidateBatchMetadata.pm \
	blib/lib/NGSTAR/Model/ValidateBatchMetadata.pm \
	lib/NGSTAR/Form/BatchAddProfileMetadataForm.pm \
	blib/lib/NGSTAR/Form/BatchAddProfileMetadataForm.pm \
	lib/NGSTAR/Controller/Admin.pm \
	blib/lib/NGSTAR/Controller/Admin.pm \
	lib/NGSTAR/Controller/Curator.pm \
	blib/lib/NGSTAR/Controller/Curator.pm \
	lib/NGSTAR/Controller/Scheme.pm \
	blib/lib/NGSTAR/Controller/Scheme.pm \
	lib/NGSTAR/Model/BatchAddAllele.pm \
	blib/lib/NGSTAR/Model/BatchAddAllele.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 6.66
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = NGSTAR
DISTVNAME = NGSTAR-0.01


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	LD="$(LD)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	script/ngstar_server.pl \
	script/ngstar_create.pl \
	script/ngstar_cgi.pl \
	script/ngstar_fastcgi.pl \
	script/ngstar_test.pl \
	lib/NGSTAR/Controller/Root.pm \
	lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm \
	lib/NGSTAR/Controller/Allele.pm \
	lib/NGSTAR_Auth/Schema/Result/Role.pm \
	lib/NGSTAR/Controller/ProjectInfo.pm \
	lib/NGSTAR_Auth/Schema/Result/UserRole.pm \
	lib/NGSTAR/Controller/Account.pm \
	lib/NGSTAR/View/HTML.pm \
	lib/NGSTAR/Controller/Login.pm \
	lib/NGSTAR/Controller/ForgotPassword.pm \
	lib/NGSTAR/Controller/Logout.pm \
	lib/NGSTAR/Controller/ResetPassword.pm \
	lib/NGSTAR.pm \
	lib/NGSTAR/Model/DB.pm \
	lib/NGSTAR/Controller/Curator.pm \
	lib/NGSTAR/Controller/Admin.pm \
	lib/NGSTAR/Controller/SequenceType.pm \
	lib/NGSTAR/Controller/Scheme.pm \
	lib/NGSTAR_Auth/Schema/Result/User.pm
	$(NOECHO) $(POD2MAN) --section=$(MAN1EXT) --perm_rw=$(PERM_RW) \
	  script/ngstar_server.pl $(INST_MAN1DIR)/ngstar_server.pl.$(MAN1EXT) \
	  script/ngstar_create.pl $(INST_MAN1DIR)/ngstar_create.pl.$(MAN1EXT) \
	  script/ngstar_cgi.pl $(INST_MAN1DIR)/ngstar_cgi.pl.$(MAN1EXT) \
	  script/ngstar_fastcgi.pl $(INST_MAN1DIR)/ngstar_fastcgi.pl.$(MAN1EXT) \
	  script/ngstar_test.pl $(INST_MAN1DIR)/ngstar_test.pl.$(MAN1EXT) 
	$(NOECHO) $(POD2MAN) --section=$(MAN3EXT) --perm_rw=$(PERM_RW) \
	  lib/NGSTAR/Controller/Root.pm $(INST_MAN3DIR)/NGSTAR::Controller::Root.$(MAN3EXT) \
	  lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm $(INST_MAN3DIR)/NGSTAR_Auth::Schema::Result::PasswordResetRequest.$(MAN3EXT) \
	  lib/NGSTAR/Controller/Allele.pm $(INST_MAN3DIR)/NGSTAR::Controller::Allele.$(MAN3EXT) \
	  lib/NGSTAR_Auth/Schema/Result/Role.pm $(INST_MAN3DIR)/NGSTAR_Auth::Schema::Result::Role.$(MAN3EXT) \
	  lib/NGSTAR/Controller/ProjectInfo.pm $(INST_MAN3DIR)/NGSTAR::Controller::ProjectInfo.$(MAN3EXT) \
	  lib/NGSTAR_Auth/Schema/Result/UserRole.pm $(INST_MAN3DIR)/NGSTAR_Auth::Schema::Result::UserRole.$(MAN3EXT) \
	  lib/NGSTAR/Controller/Account.pm $(INST_MAN3DIR)/NGSTAR::Controller::Account.$(MAN3EXT) \
	  lib/NGSTAR/View/HTML.pm $(INST_MAN3DIR)/NGSTAR::View::HTML.$(MAN3EXT) \
	  lib/NGSTAR/Controller/Login.pm $(INST_MAN3DIR)/NGSTAR::Controller::Login.$(MAN3EXT) \
	  lib/NGSTAR/Controller/ForgotPassword.pm $(INST_MAN3DIR)/NGSTAR::Controller::ForgotPassword.$(MAN3EXT) \
	  lib/NGSTAR/Controller/Logout.pm $(INST_MAN3DIR)/NGSTAR::Controller::Logout.$(MAN3EXT) \
	  lib/NGSTAR/Controller/ResetPassword.pm $(INST_MAN3DIR)/NGSTAR::Controller::ResetPassword.$(MAN3EXT) \
	  lib/NGSTAR.pm $(INST_MAN3DIR)/NGSTAR.$(MAN3EXT) \
	  lib/NGSTAR/Model/DB.pm $(INST_MAN3DIR)/NGSTAR::Model::DB.$(MAN3EXT) \
	  lib/NGSTAR/Controller/Curator.pm $(INST_MAN3DIR)/NGSTAR::Controller::Curator.$(MAN3EXT) \
	  lib/NGSTAR/Controller/Admin.pm $(INST_MAN3DIR)/NGSTAR::Controller::Admin.$(MAN3EXT) \
	  lib/NGSTAR/Controller/SequenceType.pm $(INST_MAN3DIR)/NGSTAR::Controller::SequenceType.$(MAN3EXT) \
	  lib/NGSTAR/Controller/Scheme.pm $(INST_MAN3DIR)/NGSTAR::Controller::Scheme.$(MAN3EXT) \
	  lib/NGSTAR_Auth/Schema/Result/User.pm $(INST_MAN3DIR)/NGSTAR_Auth::Schema::Result::User.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = script/ngstar_cgi.pl script/ngstar_create.pl script/ngstar_fastcgi.pl script/ngstar_server.pl script/ngstar_test.pl

pure_all :: $(INST_SCRIPT)/ngstar_server.pl $(INST_SCRIPT)/ngstar_fastcgi.pl $(INST_SCRIPT)/ngstar_test.pl $(INST_SCRIPT)/ngstar_create.pl $(INST_SCRIPT)/ngstar_cgi.pl
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/ngstar_server.pl $(INST_SCRIPT)/ngstar_fastcgi.pl \
	  $(INST_SCRIPT)/ngstar_test.pl $(INST_SCRIPT)/ngstar_create.pl \
	  $(INST_SCRIPT)/ngstar_cgi.pl 

$(INST_SCRIPT)/ngstar_server.pl : script/ngstar_server.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/ngstar_server.pl
	$(CP) script/ngstar_server.pl $(INST_SCRIPT)/ngstar_server.pl
	$(FIXIN) $(INST_SCRIPT)/ngstar_server.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/ngstar_server.pl

$(INST_SCRIPT)/ngstar_fastcgi.pl : script/ngstar_fastcgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/ngstar_fastcgi.pl
	$(CP) script/ngstar_fastcgi.pl $(INST_SCRIPT)/ngstar_fastcgi.pl
	$(FIXIN) $(INST_SCRIPT)/ngstar_fastcgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/ngstar_fastcgi.pl

$(INST_SCRIPT)/ngstar_test.pl : script/ngstar_test.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/ngstar_test.pl
	$(CP) script/ngstar_test.pl $(INST_SCRIPT)/ngstar_test.pl
	$(FIXIN) $(INST_SCRIPT)/ngstar_test.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/ngstar_test.pl

$(INST_SCRIPT)/ngstar_create.pl : script/ngstar_create.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/ngstar_create.pl
	$(CP) script/ngstar_create.pl $(INST_SCRIPT)/ngstar_create.pl
	$(FIXIN) $(INST_SCRIPT)/ngstar_create.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/ngstar_create.pl

$(INST_SCRIPT)/ngstar_cgi.pl : script/ngstar_cgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/ngstar_cgi.pl
	$(CP) script/ngstar_cgi.pl $(INST_SCRIPT)/ngstar_cgi.pl
	$(FIXIN) $(INST_SCRIPT)/ngstar_cgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/ngstar_cgi.pl



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  *perl.core core \
	  $(BASEEXT).bso lib$(BASEEXT).def \
	  perl blibdirs.ts \
	  core.[0-9][0-9][0-9][0-9][0-9] core.*perl.*.? \
	  core.[0-9][0-9] pm_to_blib \
	  $(BASEEXT).x perl.exe \
	  $(INST_ARCHAUTODIR)/extralibs.ld perl$(EXE_EXT) \
	  $(BASEEXT).exp MYMETA.yml \
	  mon.out so_locations \
	  tmon.out *$(OBJ_EXT) \
	  $(MAKE_APERL_FILE) pm_to_blib.ts \
	  MYMETA.json $(INST_ARCHAUTODIR)/extralibs.all \
	  $(BOOTSTRAP) core.[0-9][0-9][0-9][0-9] \
	  core.[0-9] core.[0-9][0-9][0-9] \
	  *$(LIB_EXT) perlmain.c \
	  $(BASEEXT).def 
	- $(RM_RF) \
	  blib 
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(FIRST_MAKEFILE) $(MAKEFILE_OLD) 
	- $(RM_RF) \
	  $(DISTVNAME) MYMETA.yml 


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(NOOP)


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old 



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir  
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $$$${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) } ' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) umask 022; $(MOD_INSTALL) \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install :: all
	$(NOECHO) umask 02; $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install :: all
	$(NOECHO) umask 022; $(MOD_INSTALL) \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLVENDORSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install :: all

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLSITEARCH)/perllocal.pod
	-$(NOECHO) umask 02; $(MKPATH) $(DESTINSTALLSITEARCH)
	-$(NOECHO) umask 02; $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLSITEARCH)/perllocal.pod

doc_vendor_install :: all


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::



# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/01app.t t/02pod.t t/03podcoverage.t t/controller_Account.t t/controller_Admin.t t/controller_Allele.t t/controller_Curator.t t/controller_ForgotPassword.t t/controller_Login.t t/controller_Logout.t t/controller_ProjectInfo.t t/controller_ResetPassword.t t/controller_Scheme.t t/controller_SequenceType.t t/model_AddAllele.t t/model_AddBatchMetadata.t t/model_AddMetadata.t t/model_AddNewUser.t t/model_AddResetRequest.t t/model_AddScheme.t t/model_AddSequenceTypeProfile.t t/model_BatchAddAllele.t t/model_BatchAddMetadata.t t/model_BatchAddProfile.t t/model_DB.t t/model_DeleteAllele.t t/model_DeleteSequenceTypeProfile.t t/model_EditAllele.t t/model_EditSequenceTypeProfile.t t/model_GetAlleleInfo.t t/model_GetAlleleType.t t/model_GetError.t t/model_GetIntegerType.t t/model_GetMetadata.t t/model_GetSequenceType.t t/model_GetSequenceTypeInfo.t t/model_GetUserInfo.t t/model_UpdateUserInformation.t t/model_UpdateUserPassword.t t/model_ValidateBatchAlleles.t t/model_ValidateBatchMetadata.t t/model_ValidateBatchProfiles.t t/model_ValidateEmailForm.t t/model_ValidateForgotPasswordInfo.t t/model_ValidateMetadata.t t/model_ValidateNewUser.t t/model_ValidateNewUsername.t t/view_Email-Template.t t/view_Email.t t/view_HTML.t t/view_TT-NoWrap.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="$(VERSION)">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>Catalyst based application</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Irish Medina</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Action::RenderView" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Authentication" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Authorization::Roles" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::ConfigLoader" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::State::Cookie" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::Store::File" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::StackTrace" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Static::Simple" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE VERSION="5.90053" NAME="Catalyst::Runtime" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Config::General" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="HTML::FormHandler" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="HTML::FormHandler::Model::DBIC" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Moose::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="namespace::autoclean" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="x86_64-linux-gnu-thread-multi-5.18" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/NGSTAR/Model/DeleteAllele.pm blib/lib/NGSTAR/Model/DeleteAllele.pm \
	  lib/NGSTAR/Model/AddScheme.pm blib/lib/NGSTAR/Model/AddScheme.pm \
	  lib/NGSTAR/Model/AddMetadata.pm blib/lib/NGSTAR/Model/AddMetadata.pm \
	  lib/NGSTAR/Model/ValidateBatchAlleles.pm blib/lib/NGSTAR/Model/ValidateBatchAlleles.pm \
	  lib/NGSTAR/Form/ForgotPasswordForm.pm blib/lib/NGSTAR/Form/ForgotPasswordForm.pm \
	  lib/NGSTAR/Form/EditProfileForm.pm blib/lib/NGSTAR/Form/EditProfileForm.pm \
	  lib/NGSTAR/Model/GetUserInfo.pm blib/lib/NGSTAR/Model/GetUserInfo.pm \
	  lib/NGSTAR/Model/AddResetRequest.pm blib/lib/NGSTAR/Model/AddResetRequest.pm \
	  lib/NGSTAR/Model/DB.pm.new blib/lib/NGSTAR/Model/DB.pm.new \
	  lib/NGSTAR/Model/CuratorEmail.pm blib/lib/NGSTAR/Model/CuratorEmail.pm \
	  lib/NGSTAR/Controller/ForgotPassword.pm blib/lib/NGSTAR/Controller/ForgotPassword.pm \
	  lib/NGSTAR/Form/EditAlleleForm.pm blib/lib/NGSTAR/Form/EditAlleleForm.pm \
	  lib/NGSTAR/Model/AddAllele.pm blib/lib/NGSTAR/Model/AddAllele.pm \
	  lib/NGSTAR/Form/EditAccountForm.pm blib/lib/NGSTAR/Form/EditAccountForm.pm \
	  lib/NGSTAR/Form/AddProfileForm.pm blib/lib/NGSTAR/Form/AddProfileForm.pm \
	  lib/NGSTAR/Model/GetAlleleType.pm blib/lib/NGSTAR/Model/GetAlleleType.pm \
	  lib/NGSTAR/Model/GetMetadata.pm blib/lib/NGSTAR/Model/GetMetadata.pm \
	  lib/NGSTAR/Model/AddNewUser.pm blib/lib/NGSTAR/Model/AddNewUser.pm \
	  lib/NGSTAR_Auth/Schema.pm blib/lib/NGSTAR_Auth/Schema.pm \
	  lib/NGSTAR/Controller/Root.pm blib/lib/NGSTAR/Controller/Root.pm \
	  lib/NGSTAR/Controller/Allele.pm blib/lib/NGSTAR/Controller/Allele.pm \
	  lib/NGSTAR_Auth/Schema/Result/Role.pm blib/lib/NGSTAR_Auth/Schema/Result/Role.pm \
	  lib/NGSTAR/Controller/ProjectInfo.pm blib/lib/NGSTAR/Controller/ProjectInfo.pm \
	  lib/NGSTAR/Model/ValidateEditUserAccount.pm blib/lib/NGSTAR/Model/ValidateEditUserAccount.pm \
	  lib/NGSTAR/Form/UpdateEmailForm.pm blib/lib/NGSTAR/Form/UpdateEmailForm.pm \
	  lib/NGSTAR/Controller/Logout.pm blib/lib/NGSTAR/Controller/Logout.pm \
	  lib/NGSTAR/Model/GetAlleleInfo.pm blib/lib/NGSTAR/Model/GetAlleleInfo.pm \
	  lib/NGSTAR.pm blib/lib/NGSTAR.pm \
	  lib/NGSTAR/Controller/SequenceType.pm blib/lib/NGSTAR/Controller/SequenceType.pm \
	  lib/NGSTAR/Model/BatchAddMetadata.pm blib/lib/NGSTAR/Model/BatchAddMetadata.pm \
	  lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm blib/lib/NGSTAR_Auth/Schema/Result/PasswordResetRequest.pm \
	  lib/NGSTAR/Form/SignInForm.pm blib/lib/NGSTAR/Form/SignInForm.pm \
	  lib/NGSTAR/Form/CreateAccountForm.pm blib/lib/NGSTAR/Form/CreateAccountForm.pm \
	  lib/NGSTAR/Model/UpdateUserInformation.pm blib/lib/NGSTAR/Model/UpdateUserInformation.pm \
	  lib/NGSTAR/Model/ValidateBatchProfiles.pm blib/lib/NGSTAR/Model/ValidateBatchProfiles.pm 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/NGSTAR/Form/UpdatePasswordForm.pm blib/lib/NGSTAR/Form/UpdatePasswordForm.pm \
	  lib/NGSTAR_Auth/Schema/Result/UserRole.pm blib/lib/NGSTAR_Auth/Schema/Result/UserRole.pm \
	  lib/NGSTAR/Form/EmailAlleleForm.pm blib/lib/NGSTAR/Form/EmailAlleleForm.pm \
	  lib/NGSTAR/Model/Email.pm blib/lib/NGSTAR/Model/Email.pm \
	  lib/NGSTAR/Model/BatchAddProfile.pm blib/lib/NGSTAR/Model/BatchAddProfile.pm \
	  lib/NGSTAR/Model/AddSequenceTypeProfile.pm blib/lib/NGSTAR/Model/AddSequenceTypeProfile.pm \
	  lib/NGSTAR/Controller/Login.pm blib/lib/NGSTAR/Controller/Login.pm \
	  lib/NGSTAR/Model/GetSequenceType.pm blib/lib/NGSTAR/Model/GetSequenceType.pm \
	  lib/NGSTAR/Controller/ResetPassword.pm blib/lib/NGSTAR/Controller/ResetPassword.pm \
	  lib/NGSTAR/Model/ValidateNewUser.pm blib/lib/NGSTAR/Model/ValidateNewUser.pm \
	  lib/NGSTAR/Model/ValidateMetadata.pm blib/lib/NGSTAR/Model/ValidateMetadata.pm \
	  lib/NGSTAR/Form/SequenceTypeForm.pm blib/lib/NGSTAR/Form/SequenceTypeForm.pm \
	  lib/NGSTAR/Form/AlleleForm.pm blib/lib/NGSTAR/Form/AlleleForm.pm \
	  lib/NGSTAR/Model/EditAllele.pm blib/lib/NGSTAR/Model/EditAllele.pm \
	  lib/NGSTAR/Form/UpdateUsernameForm.pm blib/lib/NGSTAR/Form/UpdateUsernameForm.pm \
	  lib/NGSTAR/Form/AddSchemeForm.pm blib/lib/NGSTAR/Form/AddSchemeForm.pm \
	  lib/NGSTAR/Form/AddAlleleForm.pm blib/lib/NGSTAR/Form/AddAlleleForm.pm \
	  lib/NGSTAR/Model/GetSequenceTypeInfo.pm blib/lib/NGSTAR/Model/GetSequenceTypeInfo.pm \
	  lib/NGSTAR/Form/BatchAddMetadataForm.pm blib/lib/NGSTAR/Form/BatchAddMetadataForm.pm \
	  lib/NGSTAR_Auth/Schema/Result/User.pm blib/lib/NGSTAR_Auth/Schema/Result/User.pm \
	  lib/NGSTAR/Form/BatchAddProfileForm.pm blib/lib/NGSTAR/Form/BatchAddProfileForm.pm \
	  lib/NGSTAR/Controller/Account.pm blib/lib/NGSTAR/Controller/Account.pm \
	  lib/NGSTAR/View/HTML.pm blib/lib/NGSTAR/View/HTML.pm \
	  lib/NGSTAR/Model/DeleteSequenceTypeProfile.pm blib/lib/NGSTAR/Model/DeleteSequenceTypeProfile.pm \
	  lib/NGSTAR/Model/GetIntegerType.pm blib/lib/NGSTAR/Model/GetIntegerType.pm \
	  lib/NGSTAR/Model/AddBatchMetadata.pm blib/lib/NGSTAR/Model/AddBatchMetadata.pm \
	  lib/NGSTAR/Form/BatchAddAlleleForm.pm blib/lib/NGSTAR/Form/BatchAddAlleleForm.pm \
	  lib/NGSTAR/Model/ValidateForgotPasswordInfo.pm blib/lib/NGSTAR/Model/ValidateForgotPasswordInfo.pm \
	  lib/NGSTAR/Model/ValidateEmailForm.pm blib/lib/NGSTAR/Model/ValidateEmailForm.pm \
	  lib/NGSTAR/Model/EditSequenceTypeProfile.pm blib/lib/NGSTAR/Model/EditSequenceTypeProfile.pm \
	  lib/NGSTAR/Form/ResetPasswordForm.pm blib/lib/NGSTAR/Form/ResetPasswordForm.pm \
	  lib/NGSTAR/Model/GetError.pm blib/lib/NGSTAR/Model/GetError.pm \
	  lib/NGSTAR/Model/DB.pm blib/lib/NGSTAR/Model/DB.pm 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/NGSTAR/Model/ValidateBatchMetadata.pm blib/lib/NGSTAR/Model/ValidateBatchMetadata.pm \
	  lib/NGSTAR/Form/BatchAddProfileMetadataForm.pm blib/lib/NGSTAR/Form/BatchAddProfileMetadataForm.pm \
	  lib/NGSTAR/Controller/Admin.pm blib/lib/NGSTAR/Controller/Admin.pm \
	  lib/NGSTAR/Controller/Curator.pm blib/lib/NGSTAR/Controller/Curator.pm \
	  lib/NGSTAR/Controller/Scheme.pm blib/lib/NGSTAR/Controller/Scheme.pm \
	  lib/NGSTAR/Model/BatchAddAllele.pm blib/lib/NGSTAR/Model/BatchAddAllele.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 1.06
# --- Module::Install::AutoInstall section:

config :: installdeps
	$(NOECHO) $(NOOP)

checkdeps ::
	$(PERL) Makefile.PL --checkdeps

installdeps ::
	$(NOECHO) $(NOOP)

installdeps_notest ::
	$(NOECHO) $(NOOP)

upgradedeps ::
	$(PERL) Makefile.PL --config= --upgradedeps=Test::More,0.88,Catalyst::Runtime,5.90053,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Action::RenderView,0,Moose,0,namespace::autoclean,0,Config::General,0,Catalyst::Plugin::StackTrace,0,Catalyst::Plugin::Authentication,0,Catalyst::Plugin::Authorization::Roles,0,Catalyst::Plugin::Session,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Cookie,0,HTML::FormHandler::Model::DBIC,0,HTML::FormHandler,0

upgradedeps_notest ::
	$(PERL) Makefile.PL --config=notest,1 --upgradedeps=Test::More,0.88,Catalyst::Runtime,5.90053,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Action::RenderView,0,Moose,0,namespace::autoclean,0,Config::General,0,Catalyst::Plugin::StackTrace,0,Catalyst::Plugin::Authentication,0,Catalyst::Plugin::Authorization::Roles,0,Catalyst::Plugin::Session,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Cookie,0,HTML::FormHandler::Model::DBIC,0,HTML::FormHandler,0

listdeps ::
	@$(PERL) -le "print for @ARGV" 

listalldeps ::
	@$(PERL) -le "print for @ARGV" Test::More Catalyst::Runtime Catalyst::Plugin::ConfigLoader Catalyst::Plugin::Static::Simple Catalyst::Action::RenderView Moose namespace::autoclean Config::General Catalyst::Plugin::StackTrace Catalyst::Plugin::Authentication Catalyst::Plugin::Authorization::Roles Catalyst::Plugin::Session Catalyst::Plugin::Session::Store::File Catalyst::Plugin::Session::State::Cookie HTML::FormHandler::Model::DBIC HTML::FormHandler

