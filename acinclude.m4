
dnl  DBMAIL_MSG_CONFIGURE_START()
dnl
AC_DEFUN([DBMAIL_MSG_CONFIGURE_START], [dnl
AC_MSG_RESULT([
This is dbmail's GNU configure script.
It's going to run a bunch of strange tests to hopefully
make your compile work without much twiddling.
])
])

dnl DBMAIL_BOTH_SQL_CHECK
dnl
AC_DEFUN([DBMAIL_BOTH_SQL_CHECK], [dnl
AC_ARG_WITH(mysql,
            [  --with-mysql            use MySQL as database. Uses mysql_config
	       		  for finding includes and libraries],
            mysqlheadername="$withval")
AC_ARG_WITH(pgsql,
	    [  --with-pgsql            use PostgreSQL as database. 
                          Uses pg_config for finding includes and libraries],
            pgsqlheadername="$withval")

WARN=0
# Make sure we only select one, mysql or pgsql
if test "${mysqlheadername-x}" = "x"
then
  if test "${pgsqlheadername-x}" = "x"
  then
    NEITHER=1
    mysqlheadername=""
#    MYSQLINC=""
#    PGSQLINC=""
  fi
fi
if test "$NEITHER" = 1
  then
     AC_MSG_ERROR([

     You have to specify --with-mysql or --with-pgsql to build.
])
fi

if test ! "${mysqlheadername-x}" = "x"
then
  if test ! "${pgsqlheadername-x}" = "x"
    then
      WARN=1
      mysqlheadername=""
#      MYSQLINC=""
#      PGSQLINC=""
  fi
fi
if test "$WARN" = 1
  then
     AC_MSG_ERROR([

     You cannot specify both --with-mysql and --with-pgsql on the same
     build...
])
fi
])

dnl DBMAIL_CHECK_SQL_LIBS
dnl
AC_DEFUN([DBMAIL_CHECK_SQL_LIBS], [dnl
#Look for include files and libs needed to link
#use the configuration utilities (mysql_config and pg_config for this)
# MySQL first
if test ! "${mysqlheadername-x}" = "x"
then
    AC_PATH_PROG(mysqlconfig,mysql_config)
    if test [ -z "$mysqlconfig" ]
    then
        AC_MSG_ERROR([mysql_config executable not found. Make sure mysql_config is in your path])
    else
	AC_MSG_CHECKING([MySQL headers])
	MYSQLINC=`${mysqlconfig} --cflags`
	AC_MSG_RESULT([$MYSQLINC])	
        AC_MSG_CHECKING([MySQL libraries])
        SQLLIB=`${mysqlconfig} --libs`
        SQLALIB="mysql/.libs/libmysqldbmail.a"
	SQLLTLIB="mysql/libmysqldbmail.la"
        AC_MSG_RESULT([$SQLLIB])
   fi
else
  if test ! "${pgsqlheadername-x}" = "x"
  then
    AC_PATH_PROG(pgsqlconfig,pg_config)
    if test [ -z "$pgsqlconfig" ]
    then
        AC_MSG_ERROR([pg_config executable not found. Make sure pg_config is in your path])
    else
	AC_MSG_CHECKING([PostgreSQL headers])
	PGINCDIR=`${pgsqlconfig} --includedir`
	PGSQLINC="-I$PGINCDIR"
	AC_MSG_RESULT([$PGSQLINC])
        AC_MSG_CHECKING([PostgreSQL libraries])
        PGLIBDIR=`${pgsqlconfig} --libdir`
        SQLLIB="-L$PGLIBDIR -lpq"
        SQLALIB="pgsql/.libs/libpgsqldbmail.a"
	SQLLTLIB="pgsql/libpgsqldbmail.la"
        AC_MSG_RESULT([$SQLLIB])
    fi
  fi
fi
])
dnl DBMAIL_SIEVE_CONF
dnl check for ldap or sql authentication
AC_DEFUN([DBMAIL_SIEVE_CONF], [dnl
AC_MSG_RESULT([checking for sorting configuration])
AC_ARG_WITH(sieve,[  --with-sieve=PATH	  full path to libSieve header directory (don't use, not stable)],
	sieveheadername="$withval$")
dnl This always needs to be defined
SORTALIB="sort/.libs/libsortdbmail.a"
SORTLTLIB="sort/libsortdbmail.la"

WARN=0
if test ! "${sieveheadername-x}" = "x"
then
  # --with-sieve was specified
  AC_MSG_RESULT([using Sieve sorting])
  if test "$withval" != "yes"
  then
    AC_MSG_CHECKING([for sieve2_interface.h (user supplied)])
    if test -r "$sieveheadername/sieve2_interface.h"
      then
      # found
        AC_MSG_RESULT([$sieveheadername/sieve2_interface.h])
        SIEVEINC=$sieveheadername
      else 
      # Not found
        AC_MSG_RESULT([not found])
        SIEVEINC=""
        sieveheadername=""
        AC_MSG_ERROR([
  Unable to find sieve2_inteface.h where you specified, try just --with-sieve to 
  have configure guess])
    fi
  else
    # Lets look in our standard paths
    AC_MSG_CHECKING([for sieve2_interface.h])
    for sievepaths in $sieveheaderpaths
    do
      if test -r "$sievepaths/sieve2_interface.h"
      then
        SIEVEINC="$sievepaths"
        AC_MSG_RESULT([$sievepaths/sieve2_interface.h])
        break
      fi
    done
    if test -z "$SIEVEINC"
    then
      AC_MSG_RESULT([no])
      AC_MSG_ERROR([
  Unable to locate sieve2_inteface.h, try specifying with --with-sieve])
    fi
  fi
else
  AC_MSG_RESULT([not using any sorting])
fi
])

dnl DBMAIL_CHECK_SIEVE_LIBS
dnl
AC_DEFUN([DBMAIL_CHECK_SIEVE_LIBS], [dnl
# Look for libs needed to link to SIEVE first
if test ! "${sieveheadername-x}" = "x"
then
  AC_CHECK_LIB(sieve,sieve2_listextensions,[ SIEVELIB="-lsieve"], [SIEVELIB=""])
  if test -z "$SIEVELIB"
  then
    AC_MSG_ERROR([
  Unable to link against libSieve.  It appears you are missing the
  development libraries or they aren't in your linker's path
  ])
  fi
else
  #no Sieve needed
  SIEVELIB=""
fi
])
	
dnl DBMAIL_AUTH_CONF
dnl check for ldap or sql authentication
AC_DEFUN([DBMAIL_AUTH_CONF], [dnl
AC_MSG_RESULT([checking for authentication configuration])
AC_ARG_WITH(auth-ldap,[  --with-auth-ldap=PATH	  full path to ldap header directory],
	authldapheadername="$withval$")
dnl This always needs to be defined
AUTHALIB="auth/.libs/libauthdbmail.a"
AUTHLTLIB="auth/libauthdbmail.la"

WARN=0
if test ! "${authldapheadername-x}" = "x"
then
  # --with-auth-ldap was specified
  AC_MSG_RESULT([using LDAP authentication])
  if test "$withval" != "yes"
  then
    AC_MSG_CHECKING([for ldap.h (user supplied)])
    if test -r "$authldapheadername/ldap.h"
      then
      # found
        AC_MSG_RESULT([$authldapheadername/ldap.h])
        LDAPINC=$authldapheadername
      else 
      # Not found
        AC_MSG_RESULT([not found])
        LDAPINC=""
        authldapheadername=""
        AC_MSG_ERROR([
  Unable to find ldap.h where you specified, try just --with-auth-ldap to 
  have configure guess])
    fi
  else
    # Lets look in our standard paths
    AC_MSG_CHECKING([for ldap.h])
    for ldappaths in $ldapheaderpaths
    do
      if test -r "$ldappaths/ldap.h"
      then
        LDAPINC="$ldappaths"
        AC_MSG_RESULT([$ldappaths/ldap.h])
        break
      fi
    done
    if test -z "$LDAPINC"
    then
      AC_MSG_RESULT([no])
      AC_MSG_ERROR([
  Unable to locate ldap.h, try specifying with --with-ldap])
    fi
  fi
else
  AC_MSG_RESULT([using SQL authentication])
fi
])

dnl DBMAIL_CHECK_LDAP_LIBS
dnl
AC_DEFUN([DBMAIL_CHECK_LDAP_LIBS], [dnl
# Look for libs needed to link to LDAP first
if test ! "${authldapheadername-x}" = "x"
then
  AC_CHECK_LIB(ldap,ldap_bind,[ LDAPLIB="-lldap"], [LDAPLIB=""])
  if test -z "$LDAPLIB"
  then
    AC_MSG_ERROR([
  Unable to link against ldap.  It appears you are missing the
  development libraries or they aren't in your linker's path
  ])
  fi
else
  #no ldap needed
  LDAPLIB=""
fi
])
dnl AC_COMPILE_WARNINGS
dnl set to compile with '-W -Wall'
AC_DEFUN([AC_COMPILE_WARNINGS],
[AC_MSG_CHECKING(maximum warning verbosity option)
if test -n "$CXX"
then
  if test "$GXX" = "yes"
  then
    ac_compile_warnings_opt='-Wall'
  fi
  CXXFLAGS="$CXXFLAGS $ac_compile_warnings_opt"
  ac_compile_warnings_msg="$ac_compile_warnings_opt for C++"
fi
if test -n "$CC"
then
  if test "$GCC" = "yes"
  then
    ac_compile_warnings_opt='-W -Wall -Wpointer-arith -Wstrict-prototypes'
  fi
  CFLAGS="$CFLAGS $ac_compile_warnings_opt"
  ac_compile_warnings_msg="$ac_compile_warnings_msg $ac_compile_warnings_opt for C"
fi
AC_MSG_RESULT($ac_compile_warnings_msg)
unset ac_compile_warnings_msg
unset ac_compile_warnings_opt
])

dnl DBMAIL_CHECK_GLIB
dnl
AC_DEFUN([DBMAIL_CHECK_GLIB], [dnl
#Look for include files and libs needed to link
#use the configuration utilities (pkg-config for this)
AC_PATH_PROG(glibconfig,pkg-config)
if test [ -z "$glibconfig" ]
then
	AC_MSG_ERROR([pkg-config executable not found. Make sure pkg-config is in your path])
else
	AC_MSG_CHECKING([GLib headers])
	ac_glib_cflags=`${glibconfig} --cflags glib-2.0`
	CFLAGS="$CFLAGS $ac_glib_cflags"
	AC_MSG_RESULT([$ac_glib_cflags])
        AC_MSG_CHECKING([Glib libraries])
	ac_glib_libs=`${glibconfig} --libs glib-2.0`
	LDFLAGS="$LDFLAGS $ac_glib_libs"
        AC_MSG_RESULT([$ac_glib_libs])
fi
])

dnl DBMAIL_CHECK_GMIME
dnl
AC_DEFUN([DBMAIL_CHECK_GMIME], [dnl
#Look for include files and libs needed to link
#use the configuration utilities (pkg-config for this)
AC_PATH_PROG(gmimeconfig,pkg-config)
if test [ -z "$gmimeconfig" ]
then
	AC_MSG_ERROR([pkg-config executable not found. Make sure pkg-config is in your path])
else
	AC_MSG_CHECKING([GMime headers])
	ac_gmime_cflags=`${gmimeconfig} --cflags gmime-2.0`
	CFLAGS="$CFLAGS $ac_gmime_cflags"
	AC_MSG_RESULT([$ac_gmime_cflags])
        AC_MSG_CHECKING([GMime libraries])
	ac_gmime_libs=`${gmimeconfig} --libs gmime-2.0`
	LDFLAGS="$LDFLAGS $ac_gmime_libs"
        AC_MSG_RESULT([$ac_gmime_libs])
fi
])

dnl also compile iniparser
AC_DEFUN([DBMAIL_SET_INIPARSER], [dnl
# set iniparser library. Thi is a library that we have added
# locally
INIPARSERALIB="lib/iniparser-2.14/src/.libs/libiniparser.a"
INIPARSERLTLIB="lib/iniparser-2.14/src/libiniparser.la"
])

