<?xml version="1.0" encoding="utf-8"?>
<!--

  This file is part of test-definition
 
  Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).

  Contact: Vesa Poikajärvi <vesa.poikajarvi@digia.com>

  This package is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License
  version 2.1 as published by the Free Software Foundation.
 
  This package is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.
 
  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
  02110-1301 USA
 
-->

<!-- 
   XSL transformation for tests matching testdefinition-syntax.xsd
   schema. Shows the XML as XHTML using stylesheets from 
   qa-reports.meego.com
   
   To use this in your XMLs, you'll need to link it by adding
   the following row just after XML declaration:
   <?xml-stylesheet type="text/xsl" href="URI-to-this-file.xsl"?>
  -->

<!-- The default namespace is the magic to get XHTML output as needed -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0"
		xmlns="http://www.w3.org/1999/xhtml">
  
  <!-- XHTML 1.0 Transitional output, the CSS stylesheet requires this.
       XML declaration is omitted due to some browsers not knowing what
       to do when they see one -->
  <xsl:output method="xml"
	      indent="yes"
	      omit-xml-declaration="yes"
	      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
	      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
	      encoding="utf-8"/>

  <!-- The <Not defined> string -->
  <xsl:variable name="notdefined">
    <xsl:text>&lt;Not defined&gt;</xsl:text>
  </xsl:variable>

  <!-- HTML warning -->
  <xsl:variable name="html_warning">
    <xsl:element name="div">
      <xsl:attribute name="class">
	<xsl:text>error_msg_wrap</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="style">
	<xsl:text>margin-bottom : 15px;</xsl:text>
      </xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="class">
	  <xsl:text>error_msg</xsl:text>
	</xsl:attribute>
	<xsl:element name="p">
	  <xsl:text>HTML descriptions found</xsl:text>
	</xsl:element>
	<xsl:element name="p">
	  <xsl:text>Using HTML inside XML is frowned upon. It will not be
	    rendered due to possible problems in the output. If the schema
	    is not suitable for your descriptions, try </xsl:text>
	  <xsl:element name="a">
	    <xsl:attribute name="href">
	      <xsl:text>http://bugs.meego.com/enter_bug.cgi?product=Development Tools</xsl:text>
	    </xsl:attribute>
	    <xsl:attribute name="title">
	      <xsl:text>MeeGo Bugzilla</xsl:text>
	    </xsl:attribute>
	    <xsl:text>filing</xsl:text>
	  </xsl:element>
	  <xsl:text> a feature request.</xsl:text>
	</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:variable>

  <!-- The keys for looping over stuff -->
  <xsl:key name="domains" match="suite" use="@domain"/>
  <xsl:key name="types" match="*" use="@type"/>
  <xsl:key name="features" match="set" use="@feature"/>

  <!-- The root template defining the main page structure -->
  <xsl:template match="/">
    <!-- This stylesheet uses HTML tags and even attributes. To be super
	 elegant one may want to change all of these to xml:elements,
	 but one will then lose a lot in the readability -->
    <html>
      <head>
	<meta http-equiv="Content-Type"
	      content="text/html; charset=UTF-8"/>
	<title><xsl:text>Test Plan</xsl:text></title>
	<link href="http://qa-reports.meego.com/stylesheets/jqModal.css"
	      media="screen" 
	      rel="stylesheet" 
	      type="text/css" />
	<link href="http://qa-reports.meego.com/stylesheets/jquery-ui-1.8.5.custom.css" 
	      media="screen" 
	      rel="stylesheet" 
	      type="text/css" />
	<link href="http://qa-reports.meego.com/stylesheets/screen.css" 
	      media="screen" 
	      rel="stylesheet" 
	      type="text/css" />
	<xsl:element name="style">
	  <xsl:attribute name="type">
	    <xsl:text>text/css</xsl:text>
	  </xsl:attribute>
	  <xsl:text>
	    table.basictable {
	      width : auto;
	    }

	    p.smaller_margin {
	      margin-bottom : 5px;
	    }

	    img.logoimage {
	      float : right;
	    }

	    a.navilink {
	      padding-right : 30px;
	    }

	    div.sectioncontainer {
	      padding-left : 30px; 
	      padding-right : 30px;
	    }

	    tr.separator {
	      line-height : 1px;
	    }

	    th.matrixtype,
	    td.matrixnumber,
	    td.matrixnumberbold {
	      text-align : center;
	    }
	    
	    td.domaintitle,
	    td.matrixnumberbold {
	      font-weight : bold;
	    }

	    tr.feature {
	      font-size : 0.8em
	    }

	  </xsl:text>
	</xsl:element>
      </head>
      <body>
	<div id="wrapper">
	  <!-- Override the stylesheets #header a bit -->
	  <div id="header" style="padding-top : 30px; height : 70px;">
	    <img class="logoimage"
		 alt="MeeGo"
		 src="http://meego.com/sites/all/themes/meego/images/site_name.png"/>
	    <!-- When browsers support XSLT 2.0 an improvement idea for
		 this would be to add the name of the file in question.
		 That requires splitting of the URI which is currently
		 not supported (some workaround could be implemented 
		 as well though). Same goes for the page title -->
	    <h1>
	      <xsl:text>Test plan</xsl:text>
	    </h1>
	    <p>
	      <a href="#cases" class="navilink">
		<xsl:text>Test cases &gt;</xsl:text>
	      </a>
	      <xsl:if 
		 test="count(//*[@type!='']) &gt;0 and 
		       count(//*[@domain!='']) &gt;0">
		<a href="#matrix" class="navilink">
		  <xsl:text>Feature coverage matrix &gt;</xsl:text>
		</a>
	      </xsl:if>
	    </p>	    
	  </div>
	  
	  <div id="page">
	    <div class="page_content">
	      <xsl:call-template name="html_description_warning"/>
	      <!-- Page content comes here -->
	      <xsl:apply-templates />
	      
	      <!-- Show the matrix only if we have type and domain
		   attributes. May not still be correct as there may
		   be no cases that have both, but at least basic problems
		   are solved -->
	      <xsl:if 
		 test="count(//*[@type!='']) &gt;0 and 
		       count(//*[@domain!='']) &gt;0">
		<a id="matrix"></a>
		<h2><xsl:text>Feature coverage matrix</xsl:text></h2>
		<xsl:call-template name="feature_coverage_matrix"/>
	      </xsl:if>
	    </div>
	  </div>
	  <br/>
	  <br/>
	  <div id="footer">
	
	  </div>
	</div>
      </body>
    </html>
  </xsl:template>

  <!-- Start the processing. This template shows the main level information
       and calls suite templates -->
  <xsl:template match="/testdefinition">
    <p>
      <strong><xsl:text>Description: </xsl:text></strong>
      <xsl:call-template name="description">
	<xsl:with-param name="nodevalue"
			select="description"/>
	<xsl:with-param name="attrvalue"
			select="@description"/>
      </xsl:call-template>
    </p>
    <table class="basictable">
      <tr>
	<td><xsl:text>Total cases: </xsl:text></td>
	<td><xsl:value-of select="count(//case)"/></td>
      </tr>
      <tr class="separator">
	<td colspan="2"><xsl:text>&#160;</xsl:text></td>
      </tr>
      <tr>
	<td colspan="2"><xsl:text>Cases by domain:</xsl:text></td>
      </tr>
      <xsl:call-template name="cases_by_domain"/>
    </table>
    <br/>
    <br/>
    
    <a id="cases"></a>
    <h1><xsl:text>Test cases</xsl:text></h1>
    <!-- Handle suites -->
    <xsl:for-each select="suite">
      <xsl:sort select="@name"/>
      <xsl:apply-templates select="."/>
      <br/>
      <br/>
      <br/>
    </xsl:for-each>

  </xsl:template>

  <!-- Process a single suite, its sets and their cases -->
  <xsl:template match="suite">
    <h2><xsl:value-of select="@name"/></h2>

    <p class="smaller_margin">
      <strong><xsl:text>Domain: </xsl:text></strong>
      <xsl:choose>
	<!-- No domain attribute, nothing to show -->
	<xsl:when test="not(@domain)">
	  <xsl:copy-of select="$notdefined"/>
	</xsl:when>
	<!-- Has domain but it's empty -->
	<xsl:when test="@domain=''">
	  <xsl:copy-of select="$notdefined"/>
	</xsl:when>
	<!-- All good, show the value -->
	<xsl:otherwise>
	  <xsl:value-of select="@domain"/>
	</xsl:otherwise>
      </xsl:choose>
    </p>
    <!-- Suite description -->
    <p>
      <strong><xsl:text>Description: </xsl:text></strong>
      <xsl:call-template name="description">
	<xsl:with-param name="nodevalue"
			select="description"/>
	<xsl:with-param name="attrvalue"
			select="@description"/>
      </xsl:call-template>
    </p>

    <!-- Handle the sets of this suite -->
    <xsl:for-each select="set">
      <xsl:sort select="@name"/>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>

  
  <!-- Handle a single test set. Creates a test_results classed div
       with test set information and a table of test cases -->
  <xsl:template match="set">
    <div class="sectioncontainer">
      <div class="test_results">
	<h2 id="test_results"
	    style="font-size : 1.1em;"><xsl:value-of select="@name"/></h2>

	<div class="container">
	  <p class="smaller_margin">
	    <strong><xsl:text>Feature: </xsl:text></strong>
	    <xsl:choose>
	      <!-- No feature, nothing to show -->
	      <xsl:when test="not(@feature)">
		<xsl:copy-of select="$notdefined"/>
	      </xsl:when>
	      <!--  Feature attribute found but is emtpy -->
	      <xsl:when test="@feature=''">
		<xsl:copy-of select="$notdefined"/>
	      </xsl:when>
	      <!-- All good, show it -->
	      <xsl:otherwise>
		<xsl:value-of select="@feature"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </p>
	  <p>
	    <strong><xsl:text>Description: </xsl:text></strong>
	    <xsl:call-template name="description">
	      <xsl:with-param name="nodevalue"
			      select="description"/>
	      <xsl:with-param name="attrvalue"
			      select="@description"/>
	    </xsl:call-template>
	  </p>
	  
	  <!-- Table for test cases -->
	  <table>
	    <thead class="even">
	      <tr>
		<th><xsl:text>Test Case</xsl:text></th>
		<th><xsl:text>Description</xsl:text></th>
		<th><xsl:text>Requirement</xsl:text></th>
		<th><xsl:text>Type</xsl:text></th>
		<th><xsl:text>Level</xsl:text></th>
		<th><xsl:text>Manual</xsl:text></th>
	      </tr>
	    </thead>
	    
	    <!-- Handle the cases from this set -->
	    <xsl:for-each select="case">
	      <xsl:sort select="@name"/>
	      <!-- Variable needed for coloring every other row -->
	      <xsl:variable name="color">
		<xsl:choose>
		  <xsl:when test="position() mod 2 = 0">even</xsl:when>
		  <xsl:otherwise>odd</xsl:otherwise>
		</xsl:choose>
	      </xsl:variable>
	      
	      <!-- Apply templates, ie. run template "case" with
		   the row CSS class as parameter -->
	      <xsl:apply-templates select=".">
		<xsl:with-param name="rowclass"
				select="$color"/>
	      </xsl:apply-templates>
	    </xsl:for-each>
	    
	  </table>
	  
	</div>
      </div>
    </div>
  </xsl:template>

  <!-- Process single test case. Produces a row to a table -->
  <xsl:template match="case">
    <xsl:param name="rowclass"/>
    
    <xsl:element name="tr">
      <xsl:attribute name="class">
	<xsl:value-of select="$rowclass"/>
      </xsl:attribute>
      <td><xsl:value-of select="@name"/></td>
      <td>
	<!-- Case description, not inherited -->
	<xsl:call-template name="description">
	  <xsl:with-param name="nodevalue"
			  select="description"/>
	  <xsl:with-param name="attrvalue"
			  select="@description"/>
	</xsl:call-template>
      </td>
      <td>
	<!-- Requirement, can be inherited -->
	<xsl:value-of select="(ancestor-or-self::*/@requirement)[last()]"/>
      </td>
      <td>
	<!-- Type, can be inherited -->
	<xsl:value-of select="(ancestor-or-self::*/@type)[last()]"/>
      </td>
      <td>
	<!-- Level, also inherited -->
	<xsl:value-of select="(ancestor-or-self::*/@level)[last()]"/>
      </td>
      <td>
	<!-- Manual, inherited as well. We show "Yes" if the manual
	     attribute is set to true, and nothing otherwise -->
	<xsl:if test="(ancestor-or-self::*/@manual)[last()] = 'true'">
	  <xsl:text>Yes</xsl:text>
	</xsl:if>
      </td>
    </xsl:element>
  </xsl:template>

  <!-- Template for description fields to handle the descriptions as
       it can be given as a node or as an attribute. Node is preferred
       over attribute.

       Notice, that passing fully functional DOM nodes as attribute
       parameters does not work without tricks, thas asking for two parameters
    -->
  <xsl:template name="description">
    <!-- The node/description value, preferred over attribute -->
    <xsl:param name="nodevalue"/>
    <!-- The node/@description value --> 
    <xsl:param name="attrvalue"/>
    
    <xsl:choose>
      <!-- Node found -->
      <xsl:when test="$nodevalue">
	<xsl:choose>
	  <!-- No text inside -->
	  <xsl:when test="$nodevalue[not(text())]">
	    <xsl:copy-of select="$notdefined"/>
	  </xsl:when>
	  <!-- Had text, show it -->
	  <xsl:otherwise>
	    <xsl:call-template name="description-trim-and-newline">
	      <xsl:with-param name="string" select="$nodevalue"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- No node, check attribute -->
      <xsl:otherwise>
	<xsl:choose>
	  <!-- Attribute not there at all -->
	  <xsl:when test="not($attrvalue)">
	    <xsl:copy-of select="$notdefined"/>
	  </xsl:when>
	  <!-- Empty value in it -->
	  <xsl:when test="$attrvalue=''">
	    <xsl:copy-of select="$notdefined"/>
	  </xsl:when>
	  <!-- All good, show the value -->
	  <xsl:otherwise>
	    <xsl:call-template name="description-trim-and-newline">
	      <xsl:with-param name="string" select="$attrvalue"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Strip leading newlines and finally call newlines_to_br -->
  <xsl:template name="description-trim-and-newline">
    <xsl:param name="string"/>
    
    <xsl:if test="string-length($string) &gt; 1">
      <xsl:choose>
	<xsl:when test="substring($string, 1, 1)='&#10;'">
	  <xsl:call-template name="description-trim-and-newline">
	    <xsl:with-param name="string" select="substring($string, 2)"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="newlines_to_br">
	    <xsl:with-param name="string" select="$string"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Convert newlines to <br/> from given string -->
  <xsl:template name="newlines_to_br">
    <xsl:param name="string"/>

    <xsl:choose>
      <xsl:when test="contains($string, '&#10;')">
	<xsl:value-of select="substring-before($string, '&#10;')"/>
	<br/>
	<xsl:call-template name="newlines_to_br">
	  <xsl:with-param name="string"
			  select="substring-after($string, '&#10;')"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Print case counts by domains as table rows. This is practically
       useful for the case count table in the beginning of the page -->
  <xsl:template name="cases_by_domain">
    <xsl:for-each 
       select="//suite[generate-id()=generate-id(key('domains',@domain)[1])]">
      <xsl:sort select="@domain"/>
      <xsl:variable name="current_domain">
	<xsl:value-of select="@domain"/>
      </xsl:variable>
      <!-- The key contains also empty domains, skip those and count
	   together with the ones that don't have domain at all -->
      <xsl:if test="$current_domain!=''">
	<tr>
	  <td>
	    <xsl:value-of select="$current_domain"/><xsl:text>:</xsl:text>
	  </td>
	  <td>
	    <xsl:value-of 
	       select="count(//suite[@domain=$current_domain]/set/case)"/>
	  </td>
	</tr>
      </xsl:if>
    </xsl:for-each>
    
    <!-- Get case counts from suites not having a domain or having an 
	 empty one -->
    <xsl:if test="count(//suite[not(@domain)]) &gt; '0' or 
		  count(//suite[@domain='']) &gt; '0'">
      <tr>
	<td><xsl:text>N/A:</xsl:text></td>
	<td><xsl:value-of 
	       select="count(//suite[not(@domain)]/set/case) + 
		       count(//suite[@domain='']/set/case)"/></td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- Show a warning for files containing HTML in description elements -->
  <xsl:template name="html_description_warning">
    <!-- XSLT 1.0 does not have regexp support so check if there's
	 <br or <p in the content of the description element and if so,
	 display a warning -->
    <xsl:if 
       test="count(//description[contains(text(), '&lt;br')]) 
	     or count(//description[contains(text(), '&lt;p')])
	     ">
      <xsl:copy-of select="$html_warning"/>
    </xsl:if>
  </xsl:template>

  <!-- Print the feature coverage matrix table. This is quite long 
       template but not being able to send full nodes as template
       parameters this is just the way it is now.
    -->
  <xsl:template name="feature_coverage_matrix">
    <div class="sectioncontainer">
      <table class="basictable">
	<!-- Print header -->
	<thead>
	  <tr>
	    <th><xsl:text>Domain/Type</xsl:text></th>
	    <!-- We need the types for header level -->
	    <xsl:for-each
	       select="//*[generate-id()=generate-id(key('types',@type)[1])]">
	      <!-- Just skip the empty types -->
	      <xsl:if test="@type!=''">
		<th class="matrixtype">
		  <xsl:value-of select="@type"/>
		</th>
	      </xsl:if>
	    </xsl:for-each>
	    <th class="matrixtype"><xsl:text>Total</xsl:text></th>
	  </tr>
	</thead>
	
	<!-- Start going through the domains, and inside each go through
	     the features and the test types and count cases -->
	<xsl:for-each 
	   select="//suite[generate-id()=
		   generate-id(key('domains',@domain)[1])]">
	  <xsl:variable name="current_domain">
	    <xsl:value-of select="@domain"/>
	  </xsl:variable>
	  
	  <!-- Skip empty domains -->
          <xsl:if test="$current_domain!=''">
	    <tr class="even">
	      <td class="domaintitle">
		<xsl:value-of select="$current_domain"/>
	      </td>
	      <!-- Go through the types -->
	      <xsl:for-each
		 select="//*[generate-id() = 
			 generate-id(key('types',@type)[1])]">
		<xsl:variable name="current_type">
		  <xsl:value-of select="@type"/>
		</xsl:variable>
		
		<!-- Skip also empty types -->
		<xsl:if test="$current_type!=''">
		  <td class="matrixnumberbold">
		    <xsl:value-of
		       select="count(
			       //suite[@domain=$current_domain]
			       /set/case
			       [(ancestor-or-self::*/@type)[last()]=
			       $current_type])"/>
		  </td>
		</xsl:if>
	      </xsl:for-each>

	      <!-- Row sum -->
	      <td class="matrixnumberbold">
		<!-- Cases from current domain that have a type -->
		<xsl:value-of
		   select="count(
			   //suite[@domain=$current_domain]
			   /set/case
			   [(ancestor-or-self::*/@type)[last()]!=''])"/>
	      </td>
	    </tr>

	    <!-- Features for this domain -->
	    <xsl:for-each 
	       select="//suite[@domain=$current_domain]/set[generate-id() =
		       generate-id(key('features',@feature)[1])]">
	      <xsl:variable name="current_feature">
		<xsl:value-of select="@feature"/>
	      </xsl:variable>

	      <!-- Skip empty features -->
	      <xsl:if test="$current_feature!=''">
		<tr class="feature">
		  <td><xsl:value-of select="$current_feature"/></td>
		  
		  <!-- Go through the types -->
		  <xsl:for-each
		     select="//*[generate-id() = 
			     generate-id(key('types',@type)[1])]">
		    <xsl:variable name="current_type">
		      <xsl:value-of select="@type"/>
		    </xsl:variable>
		    
		    <!-- Skip also empty types -->
		    <xsl:if test="$current_type!=''">
		      <td class="matrixnumber">
			<xsl:value-of
			   select="count(
				   //suite[@domain=$current_domain]
				   /set[@feature=$current_feature]/case
				   [(ancestor-or-self::*/@type)[last()]=
				   $current_type])"/>
		      </td>
		    </xsl:if>
		  </xsl:for-each>
		  <!-- And the row sum -->
		  <td class="matrixnumber">
		    <!-- Domain/feature match + some type -->
		    <xsl:value-of
		       select="count(
			       //suite[@domain=$current_domain]
			       /set[@feature=$current_feature]/case
			       [(ancestor-or-self::*/@type)[last()]!=''])"/>
		  </td>
		</tr>
	      </xsl:if>
	    </xsl:for-each>
	  </xsl:if>
	</xsl:for-each>

	<!-- Last row holds column totals -->
	<tr class="even">
	  <td class="domaintitle"><xsl:text>Total</xsl:text></td>
	  <xsl:for-each
	     select="//*[generate-id() = generate-id(key('types',@type)[1])]">
	    <xsl:variable name="current_type">
	      <xsl:value-of select="@type"/>
	    </xsl:variable>
	    
	    <xsl:if test="$current_type!=''">
	      <td class="matrixnumberbold">
		<xsl:value-of
		   select="count(
			   //case[(ancestor-or-self::*/@type)[last()]=
			   $current_type])"/>
	      </td>
	    </xsl:if>
	  </xsl:for-each>
	  <!-- Total of totals, but not the count of all cases
	       since we skipped the empty features and types -->
	  <td class="matrixnumberbold">
	    <xsl:value-of
	       select="count(//suite[@domain!='']/set/case
		       [(ancestor-or-self::*/@type)[last()]!=''])"/>
	  </td>
	</tr>
      </table>
    </div>
  </xsl:template>

</xsl:stylesheet>
