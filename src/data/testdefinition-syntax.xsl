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
      </head>
      <body>
	<a name="top"></a>
	<div id="wrapper">
	  <!-- Override the stylesheets #header a bit -->
	  <div id="header"
	       style="padding-top : 30px; height : 70px;">
	    <img style="float:right" 
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
	      <a href="#cases" style="padding-right : 30px;">
		<xsl:text>Test cases &gt;</xsl:text>
	      </a>
	      <xsl:if 
		 test="count(//*[@type!='']) &gt;0 and 
		       count(//*[@domain!='']) &gt;0">
		<a href="#matrix">
		  <xsl:text>Feature coverage matrix &gt;</xsl:text>
		</a>
	      </xsl:if>
	    </p>	    
	  </div>
	  
	  <div id="page">
	    <div class="page_content">
	      <!-- Page content comes here -->
	      <xsl:apply-templates />
	      
	      <!-- Show the matrix only if we have type and domain
		   attributes. May not still be correct as there may
		   be no cases that have both, but at least basic problems
		   are solved -->
	      <xsl:if 
		 test="count(//*[@type!='']) &gt;0 and 
		       count(//*[@domain!='']) &gt;0">
		<a id="matrix"/>
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
      <xsl:text>Description: </xsl:text>
      <xsl:call-template name="description">
	<xsl:with-param name="nodevalue"
			select="description"/>
	<xsl:with-param name="attrvalue"
			select="@description"/>
      </xsl:call-template>
    </p>
    <table style="width : auto;">
      <tr>
	<td><xsl:text>Total cases: </xsl:text></td>
	<td><xsl:value-of select="count(//case)"/></td>
      </tr>
      <tr style="line-height : 1px;">
	<td colspan="2"><xsl:text>&#160;</xsl:text></td>
      </tr>
      <tr>
	<td colspan="2"><xsl:text>Cases by domain:</xsl:text></td>
      </tr>
      <xsl:call-template name="cases_by_domain"/>
    </table>
    <br/>
    <br/>
    
    <a id="cases"/>
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

    <!-- Suite description -->
    <p style="margin-bottom : 5px;">
      <xsl:text>Description: </xsl:text>
      <xsl:call-template name="description">
	<xsl:with-param name="nodevalue"
			select="description"/>
	<xsl:with-param name="attrvalue"
			select="@description"/>
      </xsl:call-template>
    </p>
    <p>
      <xsl:text>Domain: </xsl:text>
      <xsl:choose>
	<!-- No domain attribute, nothing to show -->
	<xsl:when test="not(@domain)">
	  <xsl:call-template name="notdefined"/>
	</xsl:when>
	<!-- Has domain but it's empty -->
	<xsl:when test="@domain=''">
	  <xsl:call-template name="notdefined"/>
	</xsl:when>
	<!-- All good, show the value -->
	<xsl:otherwise>
	  <xsl:value-of select="@domain"/>
	</xsl:otherwise>
      </xsl:choose>
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
    <div class="test_results">
      <h2 id="test_results"><xsl:value-of select="@name"/></h2>      

      <div class="container">
	<p style="margin-bottom : 5px;">
	  <xsl:text>Description: </xsl:text>
	  <xsl:call-template name="description">
	    <xsl:with-param name="nodevalue"
			    select="description"/>
	    <xsl:with-param name="attrvalue"
			    select="@description"/>
	  </xsl:call-template>
	</p>
	<p>
	  <xsl:text>Feature: </xsl:text>
	  <xsl:choose>
	    <!-- No feature, nothing to show -->
	    <xsl:when test="not(@feature)">
	      <xsl:call-template name="notdefined"/>
	    </xsl:when>
	    <!--  Feature attribute found but is emtpy -->
	    <xsl:when test="@feature=''">
	      <xsl:call-template name="notdefined"/>
	    </xsl:when>
	    <!-- All good, show it -->
	    <xsl:otherwise>
	      <xsl:value-of select="@feature"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</p>

	<!-- Table for test cases -->
	<table cellspacing="0" cellpadding="0" style="width : 100%;">
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
	<xsl:call-template name="inherited_attribute">
	  <xsl:with-param name="casevalue"
			  select="@requirement"/>
	  <xsl:with-param name="setvalue"
			  select="../@requirement"/>
	  <xsl:with-param name="suitevalue"
			  select="../../@requirement"/>
	  <xsl:with-param name="boolean"
			  select="0"/>
	</xsl:call-template>
      </td>
      <td>
	<!-- Type, can be inherited -->
	<xsl:call-template name="inherited_attribute">
	  <xsl:with-param name="casevalue"
			  select="@type"/>
	  <xsl:with-param name="setvalue"
			  select="../@type"/>
	  <xsl:with-param name="suitevalue"
			  select="../../@type"/>
	  <xsl:with-param name="boolean"
			  select="0"/>
	</xsl:call-template>
      </td>
      <td>
	<!-- Level, also inherited -->
	<xsl:call-template name="inherited_attribute">
	  <xsl:with-param name="casevalue"
			  select="@level"/>
	  <xsl:with-param name="setvalue"
			  select="../@level"/>
	  <xsl:with-param name="suitevalue"
			  select="../../@level"/>
	  <xsl:with-param name="boolean"
			  select="0"/>
	</xsl:call-template>
      </td>
      <td>
	<!-- Manual, inherited as well. We show "Yes" if the manual
	     attribute is set to true, and nothing otherwise -->
	<xsl:call-template name="inherited_attribute">
	  <xsl:with-param name="casevalue"
			  select="@manual"/>
	  <xsl:with-param name="setvalue"
			  select="../@manual"/>
	  <xsl:with-param name="suitevalue"
			  select="../../@manual"/>
	  <xsl:with-param name="boolean"
			  select="1"/>
	</xsl:call-template>
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
	    <xsl:call-template name="notdefined"/>
	  </xsl:when>
	  <!-- Had text, show it -->
	  <xsl:otherwise>
	    <xsl:value-of select="$nodevalue"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- No node, check attribute -->
      <xsl:otherwise>
	<xsl:choose>
	  <!-- Attribute not there at all -->
	  <xsl:when test="not($attrvalue)">
	    <xsl:call-template name="notdefined"/>
	  </xsl:when>
	  <!-- Empty value in it -->
	  <xsl:when test="$attrvalue=''">
	    <xsl:call-template name="notdefined"/>
	  </xsl:when>
	  <!-- All good, show the value -->
	  <xsl:otherwise>
	    <xsl:value-of select="$attrvalue"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template for test case attributes that may inherit values
       from their parents. Used to shown most of the test case
       values in the case listing.

       When calling, you can just pass the parameters by calling 
       @att, ../@att and ../../@att regardless of their actual existance
    -->
  <xsl:template name="inherited_attribute">
    <!-- The attribute value from <case> node -->
    <xsl:param name="casevalue"/>
    <!-- The attribute value from case's parent <set> node -->
    <xsl:param name="setvalue"/>
    <!-- And the same but from <suite> level -->
    <xsl:param name="suitevalue"/>
    <!-- Set to "1" if the attribute is a boolean field and 
	 if you don't want to show true/false in the listing. If
	 set to 1, this template will put the word "Yes" in the
	 output when the value of that attribute equals "true" -->
    <xsl:param name="boolean"/>

    <xsl:choose>
      <!-- Case does not have it -->
      <xsl:when test="not($casevalue)">
	<!-- Check from set/suite -->
	<xsl:call-template name="inherited_set">
	  <xsl:with-param name="setvalue"
			  select="$setvalue"/>
	  <xsl:with-param name="suitevalue"
			  select="$suitevalue"/>
	  <xsl:with-param name="boolean"
			  select="$boolean"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<!-- Case has it but it may be empty -->
	<xsl:choose>
	  <!-- And empty it is -->
	  <xsl:when test="$casevalue=''">
	    <!-- Check from set/suite -->
	    <xsl:call-template name="inherited_set">
	      <xsl:with-param name="setvalue"
			      select="$setvalue"/>
	      <xsl:with-param name="suitevalue"
			      select="$suitevalue"/>
	      <xsl:with-param name="boolean"
			      select="$boolean"/>
	    </xsl:call-template>
	  </xsl:when>
	  <!-- Not empty, so show -->
	  <xsl:otherwise>
	    <!-- boolean_attribute template decides what to actually show -->
	    <xsl:call-template name="boolean_attribute">
	      <xsl:with-param name="attvalue"
			      select="$casevalue"/>
	      <xsl:with-param name="boolean"
			      select="$boolean"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Helper for the inherited_attribute to check set and suite levels.
       This checks the given setvalue and if that is something not to
       be shown, it calls inherited_suite template.

       Params as in inherited_attribute but without casevalue
    -->
  <xsl:template name="inherited_set">
    <xsl:param name="setvalue"/>
    <xsl:param name="suitevalue"/>
    <xsl:param name="boolean"/>

    <xsl:choose>
      <!-- Set does not have it -->
      <xsl:when test="not($setvalue)">
	<!-- Check suite -->
	<xsl:call-template name="inherited_suite">
	  <xsl:with-param name="suitevalue"
			  select="$suitevalue"/>
	  <xsl:with-param name="boolean"
			  select="$boolean"/>
	</xsl:call-template>
      </xsl:when>
      <!-- Set has it but it may be empty -->
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="$setvalue=''">
	    <!-- Check from suite -->
	    <xsl:call-template name="inherited_suite">
	      <xsl:with-param name="suitevalue"
			      select="$suitevalue"/>
	      <xsl:with-param name="boolean"
			      select="$boolean"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <!-- Show the value from set level -->
	    <xsl:call-template name="boolean_attribute">
	      <xsl:with-param name="attvalue"
			      select="$setvalue"/>
	      <xsl:with-param name="boolean"
			      select="$boolean"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Helper for the inherited_attribute to check suite level. This is
       again called from inherited_set and has the same parameters
       except for setvalue.
    -->
  <xsl:template name="inherited_suite">
    <xsl:param name="suitevalue"/>
    <xsl:param name="boolean"/>

    <xsl:choose>
      <!-- Suite does not have it -->
      <xsl:when test="not($suitevalue)">
	<!-- Do nothing --> 
      </xsl:when>
      <!-- Show the value from suite level -->
      <xsl:otherwise>
	<xsl:call-template name="boolean_attribute">
	  <xsl:with-param name="attvalue"
			  select="$suitevalue"/>
	  <xsl:with-param name="boolean"
			  select="$boolean"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Helper for inherited attributes. If boolean is set to "1" this checks
       the attribute value, and if it's true then prints out the word "Yes".
       If the boolean is set to "0", this will just output the given attribute
       value.
    -->
  <xsl:template name="boolean_attribute">
    <xsl:param name="attvalue"/>
    <xsl:param name="boolean"/>

    <!-- For booleans we show Yes if value is true,
	 otherwise we show the node value -->
    <xsl:if test="$boolean='1'">
      <xsl:if test="$attvalue='true'">
	<xsl:text>Yes</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$boolean='0'">
      <xsl:value-of select="$attvalue"/>
    </xsl:if>
  </xsl:template>
    

  <!-- What to show in case of something considered as not defined,
       e.g. a missing description -->
  <xsl:template name="notdefined">
    <xsl:text>&lt;not defined&gt;</xsl:text>
  </xsl:template>

  <!-- The keys for looping over stuff -->
  <xsl:key name="domains" match="suite" use="@domain"/>
  <xsl:key name="types" match="*" use="@type"/>
  <xsl:key name="features" match="set" use="@feature"/>

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

  <!-- Print the feature coverage matrix table. This is quite long 
       template but not being able to send full nodes as template
       parameters this is just the way it is now.
    -->
  <xsl:template name="feature_coverage_matrix">
    <table style="width : auto;">
      <!-- Print header -->
      <thead>
	<tr>
	  <th><xsl:text>Domain/Type</xsl:text></th>
	  <!-- We need the types for header level -->
	  <xsl:for-each
	     select="//*[generate-id()=generate-id(key('types',@type)[1])]">
	    <!-- Just skip the empty types -->
	    <xsl:if test="@type!=''">
	      <th style="text-align : center;">
		<xsl:value-of select="@type"/>
	      </th>
	    </xsl:if>
	  </xsl:for-each>
	  <th style="text-align : center;"><xsl:text>Total</xsl:text></th>
	</tr>
      </thead>
      
      <!-- Start going through the domains, and inside each go through
	   the features and the test types and count cases -->
      <xsl:for-each 
	 select="//suite[generate-id()=generate-id(key('domains',@domain)[1])]">
	<xsl:variable name="current_domain">
	  <xsl:value-of select="@domain"/>
	</xsl:variable>

	<!-- Skip empty domains -->
        <xsl:if test="$current_domain!=''">
	  <tr class="even">
	    <td style="font-weight : bold;">
	      <xsl:value-of select="$current_domain"/>
	    </td>
	    <!-- Go through the types -->
	    <xsl:for-each
	       select="//*[generate-id() = generate-id(key('types',@type)[1])]">
	      <xsl:variable name="current_type">
		<xsl:value-of select="@type"/>
	      </xsl:variable>
	      
	      <!-- Skip also empty types -->
	      <xsl:if test="$current_type!=''">
		<td style="text-align : center; font-weight : bold;">
		  <!-- Now count the cases matching both type and domain.
		       The big problem here is inheritance - the type may
		       come from case, set or suite level.

		       as TODO: figure out how to set the type for each case
		       and then just count with single XPath query:
		       /suite[@domain=$current_domain]
		       /set/case[@type=$current_type]
		       
		       So now where counting:
		       <cases with correct type> +
		       <cases without type from sets with correct types> +
		       <cases without type from sets without type from
			suites that have correct type>
			 -->
		  <xsl:value-of
		     select="
		       count(//suite[@domain=$current_domain]
		             /set/case[@type=$current_type])
		       +
		       count(//suite[@domain=$current_domain]
		             /set[@type=$current_type]
			     /case[not(@type) or @type=''])
		       +
		       count(//suite[@domain=$current_domain and
		                     @type=$current_type]
			     /set[not(@type) or @type='']
			     /case[not(@type) or @type=''])
			     "/>
		</td>
	      </xsl:if>
	    </xsl:for-each>
	    <!-- Row sum -->
	    <td style="text-align : center; font-weight : bold;">
	      <xsl:value-of 
		 select="
		       count(//suite[@domain=$current_domain]
		             /set/case[@type!=''])
		       +
		       count(//suite[@domain=$current_domain]
		             /set[@type!='']
			     /case[not(@type) or @type=''])
		       +
		       count(//suite[@domain=$current_domain and
		                     @type!='']
			     /set[not(@type) or @type='']
			     /case[not(@type) or @type=''])
			     "/>
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
	      <tr style="font-size : 0.8em">
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
		    <td style="text-align : center;">
		      <xsl:value-of
			 select="
  		           count(//suite[@domain=$current_domain]
		             /set[@feature=$current_feature]
			     /case[@type=$current_type])
			   +
			   count(//suite[@domain=$current_domain]
		             /set[@type=$current_type and
			     @feature=$current_feature]
			     /case[not(@type) or @type=''])
		           +
			   count(//suite[@domain=$current_domain and
		                     @type=$current_type]
			     /set[(not(@type) or @type='') and
			     @feature=$current_feature]
			     /case[not(@type) or @type=''])
			     "/>
		    </td>
		  </xsl:if>
		</xsl:for-each>
		<!-- And the row sum -->
		<td style="text-align : center;">
		  <xsl:value-of 
		     select="
		       count(//suite[@domain=$current_domain]
		             /set[@feature=$current_feature]/case[@type!=''])
		       +
		       count(//suite[@domain=$current_domain]
		             /set[@type!='' and @feature=$current_feature]
			     /case[not(@type) or @type=''])
		       +
		       count(//suite[@domain=$current_domain and
		                     @type!='']
			     /set[(not(@type) or @type='') and
			     @feature=$current_feature]
			     /case[not(@type) or @type=''])
			     "/>
		</td>
	      </tr>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:if>
      </xsl:for-each>

      <!-- Last row holds column totals -->
      <tr class="even">
	<td style="font-weight : bold;"><xsl:text>Total</xsl:text></td>
	<xsl:for-each
	   select="//*[generate-id() = generate-id(key('types',@type)[1])]">
	  <xsl:variable name="current_type">
	    <xsl:value-of select="@type"/>
	  </xsl:variable>
	      
	  <xsl:if test="$current_type!=''">
	    <td style="text-align : center; font-weight : bold;">
	      <xsl:value-of
		 select="
		       count(//suite/set/case[@type=$current_type])
		       +
		       count(//suite/set[@type=$current_type]
			     /case[not(@type) or @type=''])
		       +
		       count(//suite[@type=$current_type]
			     /set[not(@type) or @type='']
			     /case[not(@type) or @type=''])
			     "/>
	    </td>
	  </xsl:if>
	</xsl:for-each>
	<!-- Total of totals, but not the count of all cases
	     since we skipped the empty features and types -->
	<td style="text-align : center; font-weight : bold;">
	  <xsl:value-of
	     select="
		       count(//suite[@domain!='']
		             /set/case[@type!=''])
		       +
		       count(//suite[@domain!='']
		             /set[@type!='']
			     /case[not(@type) or @type=''])
		       +
		       count(//suite[@domain!='' and @type!='']
			     /set[not(@type) or @type='']
			     /case[not(@type) or @type=''])
			     "/>
	</td>
      </tr>
    </table>
  </xsl:template>

</xsl:stylesheet>
