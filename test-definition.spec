Name:		test-definition		
Version:	1.1.1
Release:	1%{?dist}
Summary:	Provides schemas for validating test definition XML

Group:		testing
License:	GPL
URL:		http://meego.com
Source0:	%{name}_%{version}-1+0m6.tar.gz
BuildArch:      noarch
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

#BuildRequires:
#Requires:

%package tests
Summary: Acceptance tests for schemas in package test-definition
Requires: test-definition, ci-testing, libxml2-utils

%description
Provides two validation schemas; testdefinition-syntax.xsd for validating XML schematics and
more strict testdefinition-tm_terms.xsd for validating schematics + certain mandatory attributes.
See: https://projects.maemo.org/docs/testing/xml-definition.html.

%description tests
Acceptance tests for schemas in package test-definition


%prep
%setup -q -n %{name}-%{version}


%build
echo Nothing to build for test-definition

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/share/test-definition
mkdir -p $RPM_BUILD_ROOT/usr/share/man/man5
cp data/testdefinition-syntax.xsd $RPM_BUILD_ROOT/usr/share/test-definition/
cp data/testdefinition-tm_terms.xsd $RPM_BUILD_ROOT/usr/share/test-definition/
cp data/testdefinition-results.xsd $RPM_BUILD_ROOT/usr/share/test-definition/

groff -man -Tascii doc/test-definition.man > doc/test-definition.5
cp doc/test-definition.5 $RPM_BUILD_ROOT/usr/share/man/man5

mkdir -p $RPM_BUILD_ROOT/usr/share/test-definition-tests
mkdir -p $RPM_BUILD_ROOT/usr/share/test-definition-tests/data
cp tests/tests.xml $RPM_BUILD_ROOT/usr/share/test-definition-tests
cp tests/data/* $RPM_BUILD_ROOT/usr/share/test-definition-tests/data

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
%{_mandir}/man5/test-definition.5.gz
/usr/share/test-definition/*

%files tests
%defattr(-,root,root,-)
/usr/share/test-definition-tests/*


%changelog
* Mon Jun 7 2010 Sami Lahtinen <ext-sami.t.lahtinen@nokia.com> 1.1.1
- Added XML Schema for results file of testrunner-lite
* Fri Jun 4 2010 Sami Lahtinen <ext-sami.t.lahtinen@nokia.com> 1.1.0
- Test package for test-definition
* Mon May 10 2010 Timo Harkonen <timo.harkonen@digia.com> 1.0.1
- Initial RPM packaging
