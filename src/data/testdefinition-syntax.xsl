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
    <html>
      <head>
	<meta http-equiv="Content-Type" 
	      content="text/html; charset=UTF-8" />
	<title>Test Plan</title>
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
	    <h1 style="margin-top : 20px;">
	      <xsl:text>Test plan</xsl:text>
	    </h1>
	  </div>
	  
	  <div id="page">
	    <div class="page_content">
	      <!-- Page content comes here -->
	      <xsl:apply-templates select="testdefinition"/>
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
    <p>
      <xsl:text>Total cases: </xsl:text>
      <xsl:value-of select="count(//case)"/>
    </p>
    <br/>

    <!-- Handle suites -->
    <xsl:for-each select="suite">
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
	<xsl:call-template name="inheritedattribute">
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
	<xsl:call-template name="inheritedattribute">
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
	<xsl:call-template name="inheritedattribute">
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
	<xsl:call-template name="inheritedattribute">
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
  <xsl:template name="inheritedattribute">
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
	<xsl:call-template name="inheritedset">
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
	    <xsl:call-template name="inheritedset">
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
	    <!-- The booleanattribute template decides what to actually show -->
	    <xsl:call-template name="booleanattribute">
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

  <!-- Helper for the inheritedattribute to check set and suite levels.
       This checks the given setvalue and if that is something not to
       be shown, it calls inheritedsuite template.

       Params as in inheritedattribute but without casevalue
    -->
  <xsl:template name="inheritedset">
    <xsl:param name="setvalue"/>
    <xsl:param name="suitevalue"/>
    <xsl:param name="boolean"/>

    <xsl:choose>
      <!-- Set does not have it -->
      <xsl:when test="not($setvalue)">
	<!-- Check suite -->
	<xsl:call-template name="inheritedsuite">
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
	    <xsl:call-template name="inheritedsuite">
	      <xsl:with-param name="suitevalue"
			      select="$suitevalue"/>
	      <xsl:with-param name="boolean"
			      select="$boolean"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <!-- Show the value from set level -->
	    <xsl:call-template name="booleanattribute">
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

  <!-- Helper for the inheritedattribute to check suite level. This is
       again called from inheritedset and has the same parameters
       except for setvalue.
    -->
  <xsl:template name="inheritedsuite">
    <xsl:param name="suitevalue"/>
    <xsl:param name="boolean"/>

    <xsl:choose>
      <!-- Suite does not have it -->
      <xsl:when test="not($suitevalue)">
	<!-- Do nothing --> 
      </xsl:when>
      <!-- Show the value from suite level -->
      <xsl:otherwise>
	<xsl:call-template name="booleanattribute">
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
  <xsl:template name="booleanattribute">
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

</xsl:stylesheet>
