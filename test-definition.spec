Name:		test-definition		
Version:	1.2.4
Release:	1
Summary:	Provides schemas for validating test definition XML

Group:		Development/Tools
License:	LGPL 2.1
URL:		http://meego.com
Source0:	%{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRoot:	mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-root

#BuildRequires:
#Requires:

%package tests
Summary: Acceptance tests for schemas in package test-definition
Requires: test-definition

%description
Provides two validation schemas; testdefinition-syntax.xsd for validating XML schematics and
more strict testdefinition-tm_terms.xsd for validating schematics + certain mandatory attributes.

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
cp src/data/testdefinition-syntax.xsd $RPM_BUILD_ROOT/usr/share/test-definition/
cp src/data/testdefinition-tm_terms.xsd $RPM_BUILD_ROOT/usr/share/test-definition/

cp src/data/testdefinition-results.xsd $RPM_BUILD_ROOT/usr/share/test-definition/
cp src/data/testdefinition-syntax.xsl $RPM_BUILD_ROOT/usr/share/test-definition/
groff -man -Tascii src/doc/test-definition.man > src/doc/test-definition.5
cp src/doc/test-definition.5 $RPM_BUILD_ROOT/usr/share/man/man5

mkdir -p $RPM_BUILD_ROOT/usr/share/test-definition-tests
mkdir -p $RPM_BUILD_ROOT/usr/share/test-definition-tests/data
cp src/tests/tests.xml $RPM_BUILD_ROOT/usr/share/test-definition-tests
cp src/tests/data/* $RPM_BUILD_ROOT/usr/share/test-definition-tests/data

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

