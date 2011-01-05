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

  <xsl:variable name="report_bug">
    <xsl:text>http://bugs.meego.com/enter_bug.cgi?product=</xsl:text>
    <xsl:text>MeeGo Quality Assurance</xsl:text>
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
              <xsl:value-of select="$report_bug"/>
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

  <!-- The keys for looping over attributes when creating the matrix -->
  <xsl:key name="domains" match="*" use="@domain"/>
  <xsl:key name="components" match="*" use="@component"/>

  <!-- Some tests needed in more than one location -->
  <!-- Do we have other than planned cases? -->
  <xsl:variable 
     name="has_cases"
     select="count(//case[@state='Design' or @state='design'])!=count(//case)"/>
  <!-- Do we have planned cases? -->
  <xsl:variable 
     name="has_planned_cases"
     select="count(//case[@state='Design' or @state='design']) &gt; 0"/>
  <!-- Should we show the matrix? -->
  <xsl:variable
     name="show_matrix"
     select="count(
	     //case[
	     (ancestor-or-self::*/@domain)[last()]!=''
	     and
	     (ancestor-or-self::*/@component)[last()]!=''
	     ]) &gt; 0"/>
  
  <!-- The root template defining the main page structure -->
  <xsl:template match="/">
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
	    margin-top : 0px;
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

	    td {
	    vertical-align : top;
	    }

	    td.noborder {
	    border : none;
	    }

	    tr.separator {
	    line-height : 1px;
	    }

	    td.center
	    {
	    text-align : center;
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
	    <h1>
	      <xsl:text>Test plan</xsl:text>
	    </h1>
	    <!-- Top "navigation" links -->
	    <p>
	      <xsl:if test="$has_cases">
		<a href="#cases" title="Test cases" class="navilink">
		  <xsl:text>Test cases &gt;</xsl:text>
		</a>
	      </xsl:if>
	      <xsl:if test="$has_planned_cases">
		<a href="#planned_cases" title="Planned cases" class="navilink">
		  <xsl:text>Planned cases &gt;</xsl:text>
		</a>
	      </xsl:if>
	      <xsl:if test="$show_matrix"> 
		<a href="#matrix" 
		   title="Component vertical matrix" class="navilink">
		  <xsl:text>Component vertical matrix &gt;</xsl:text>
		</a>
	      </xsl:if>
	    </p>	    
	  </div>
	  
	  <div id="page">
	    <div class="page_content">
	      <xsl:call-template name="html_description_warning"/>
	      <!-- Page content (the default scenario) comes here -->
	      <xsl:apply-templates /> 
	      
	      <xsl:if test="$show_matrix">
		<a id="matrix"></a>
		<h2><xsl:text>Component vertical matrix</xsl:text></h2>
		<xsl:call-template name="component_vertical_matrix"/>
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
    
    <xsl:if test="$has_cases">
      <a id="cases"></a>
      <h1><xsl:text>Test cases</xsl:text></h1>

      <!-- Handle suites -->
      <xsl:for-each select="suite">
	<xsl:sort select="@name"/>
	<!-- If suite has only planned cases, skip it -->
	<xsl:if test="count(set/case[@state='Design' or @state='design'])
		      != count(set/case)">
	  <xsl:apply-templates select=".">
	    <xsl:with-param name="planned_cases_mode" select="0"/>
	  </xsl:apply-templates>
	</xsl:if>
	<br/>
	<br/>
	<br/>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="$has_planned_cases">
      <a id="planned_cases"></a>
      <h1><xsl:text>Planned cases</xsl:text></h1>

      <!-- Handle suites -->
      <xsl:for-each select="suite">
	<xsl:sort select="@name"/>
	
	<!-- If suite has no planned cases, skip it -->
	<xsl:if test="count(set/case[@state='Design' or @state='design'])
		      &gt; 0">
	  <xsl:apply-templates select=".">
	    <xsl:with-param name="planned_cases_mode" select="1"/>
	  </xsl:apply-templates>
	</xsl:if>
	<br/>
	<br/>
	<br/>
      </xsl:for-each>
    </xsl:if>

  </xsl:template>

  <!-- Process a single suite, its sets and their cases -->
  <xsl:template match="suite">
    <!-- Set to 0 to show other than planned cases, and to 1 to show only 
	 planned cases. Passed on to set and case as well. If set to 0,
	 sets containing only planned cases are skipped and vice versa -->
    <xsl:param name="planned_cases_mode"/>

    <h2><xsl:value-of select="@name"/></h2>

    <p class="smaller_margin">
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
      <!-- When not in planned cases mode: if the count of planned cases is
	   not equal to count of all cases, process the set.
	   
	   When in planned cases mode: if the count of planned cases is more
	   than zero, process the set -->
      <xsl:if test="(not($planned_cases_mode) and
  		    count(case[@state='Design' or @state='design']) 
		    != count(case)) 
		    or
		    ($planned_cases_mode and
  		    count(case[@state='Design' or @state='design']) &gt; 0)">
	<xsl:apply-templates select=".">
	  <xsl:with-param name="planned_cases_mode" 
			  select="$planned_cases_mode"/>
	</xsl:apply-templates>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  
  <!-- Handle a single test set. Creates a test_results classed div
       with test set information and a table of test cases -->
  <xsl:template match="set">
    <xsl:param name="planned_cases_mode"/>

    <div class="sectioncontainer">
      <div class="test_results">
	<h2 id="test_results"
	    style="font-size : 1.1em;"><xsl:value-of select="@name"/></h2>

	<div class="container">
	  <p class="smaller_margin">
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
		<th><xsl:text>Attributes</xsl:text></th>
	      </tr>
	    </thead>
	    
	    <!-- Handle the cases from this set -->

	    <!-- When not in planned cases mode, get cases that don't have
		 state or the state is not Design|design.

		 When in planned cases mode, get cases that have state
		 Design|design -->
	    <xsl:for-each select="case[
				  (not($planned_cases_mode) and
				  (not(@state) or
				  (@state != 'Design' and @state != 'design')))
				  or
				  ($planned_cases_mode and
				  (@state = 'Design' or @state = 'design'))
				  ]">
	      <xsl:sort select="@name"/>
	      <!-- Variable needed for coloring every other row -->
	      <xsl:variable name="color">
		<xsl:choose>
		  <xsl:when test="position() mod 2 = 0">
		    <xsl:text>even</xsl:text></xsl:when>
		  <xsl:otherwise><xsl:text>odd</xsl:text></xsl:otherwise>
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
	<!-- Table inside a table for the attributes. Not using rowspan
	     for name and description since this way is simpler to use -->
	<table>
	  <tr>
	    <td><xsl:text>Type:</xsl:text></td>
	    <td class="noborder"><xsl:value-of 
				    select="(ancestor-or-self::*/@type)[last()]"/></td>
	  </tr>
	  <tr>
	    <td><xsl:text>Domain:</xsl:text></td>
	    <td class="noborder">
	      <xsl:value-of 
		 select="(ancestor-or-self::*/@domain)[last()]"/>
	    </td>
	  </tr>
	  <tr>
	    <td><xsl:text>Feature:</xsl:text></td>
	    <td class="noborder">
	      <xsl:value-of 
		 select="(ancestor-or-self::*/@feature)[last()]"/>
	    </td>
	  </tr>
	  <tr>
	    <td><xsl:text>Execution&#160;type:</xsl:text></td>
	    <td class="noborder">
	      <xsl:choose>
		<xsl:when test="(ancestor-or-self::*/@manual)[last()] = 'true'">
		  <xsl:text>Manual</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:text>Auto</xsl:text>
		</xsl:otherwise>
	      </xsl:choose>
	    </td>
	  </tr>
	  <tr>
	    <td><xsl:text>Component:</xsl:text></td>
	    <td class="noborder">
	      <xsl:value-of 
		 select="(ancestor-or-self::*/@component)[last()]"/>
	    </td>
	  </tr>
	  <tr>
	    <td><xsl:text>Level:</xsl:text></td>
	    <td class="noborder">
	      <xsl:value-of 
		 select="(ancestor-or-self::*/@level)[last()]"/>
	    </td>
	  </tr>
	</table>
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

  <!-- Strip leading newlines and call newlines_to_br which then calls
       keyword_highligh -->
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
	<xsl:call-template name="keyword_highlight">
	  <xsl:with-param name="string"
			  select="normalize-space(
				  substring-before($string, '&#10;')
				  )"/>
	</xsl:call-template>
	<br/>
	<xsl:call-template name="newlines_to_br">
	  <xsl:with-param name="string"
			  select="substring-after($string, '&#10;')"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="keyword_highlight">
	  <xsl:with-param name="string"
			  select="normalize-space($string)"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- No lower-case support in XSLT 1.0 -->
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

  <!-- Highlight certain keywords from description templates -->
  <xsl:template name="keyword_highlight">
    <xsl:param name="string"/>
    
    <xsl:variable name="lcase">
      <xsl:value-of select="translate($string, $uppercase, $lowercase)"/>
    </xsl:variable>

    <xsl:choose>
      <!-- If the string starts with a keyword we know (including colon),
	   highlight the keyword. -->
      <xsl:when test="
		      starts-with($lcase, 'purpose:') or
		      starts-with($lcase, 'method:') or
		      starts-with($lcase, 'references:') or
		      starts-with($lcase, 'pre/post-conditions:') or
		      starts-with($lcase, 'run instructions:') or
		      starts-with($lcase, 'pass/fail criteria:') or
		      starts-with($lcase, 'test environment:') or
		      starts-with($lcase, 'required test data:') or
		      starts-with($lcase, 'change history:')
		      ">
	<strong><xsl:value-of select="substring-before($string, ':')"/><xsl:text>:</xsl:text></strong><xsl:value-of select="substring-after($string, ':')"/>
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
       select="//*[generate-id()=generate-id(key('domains',@domain)[1])]">
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
	       select="count(
		       //suite/set/case
		       [(ancestor-or-self::*/@domain)[last()]=
		       $current_domain])"/>
	  </td>
	</tr>
      </xsl:if>
    </xsl:for-each>
    
    <!-- Get case counts from suites not having a domain or having an 
	 empty one -->
    <xsl:if test="count(
		  //case[(ancestor-or-self::*/@domain)[last()]='']
		  ) &gt; 0
		  or
		  count(
		  //case[not((ancestor-or-self::*/@domain)[last()])]
		  ) &gt; 0">
      <tr>
	<td><xsl:text>N/A:</xsl:text></td>
	<td><xsl:value-of 
	       select="count(
		       //case[(ancestor-or-self::*/@domain)[last()]='']
		       )
		       +
		       count(
		       //case[not((ancestor-or-self::*/@domain)[last()])]
		       )"/></td>
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

  <!-- Print the component vertical matrix -->
  <xsl:template name="component_vertical_matrix">
    <div class="sectioncontainer">
      <table class="basictable">
	<!-- Print header -->
	<thead>
	  <tr>
	    <th><xsl:text>Component/Vertical</xsl:text></th>
	    <!-- Headers are domains (ie. verticals) -->
	    <xsl:for-each 
	       select="//*[generate-id()=
		       generate-id(key('domains',@domain)[1])]">
	      <!-- Just skip the empty domains -->
	      <xsl:if test="@domain!=''">
		<th class="center">
		  <xsl:value-of select="@domain"/>
		</th>
	      </xsl:if>
	    </xsl:for-each>
	    <th class="center"><xsl:text>Total</xsl:text></th>
	  </tr>
	</thead>
	
	<!-- Start going through the components, and inside each go through
	     the domains and count cases -->
	<xsl:for-each 
	   select="//*[generate-id()=
		   generate-id(key('components',@component)[1])]">
	  <xsl:variable name="current_component">
	    <xsl:value-of select="@component"/>
	  </xsl:variable>
	  
	  <!-- Skip empty components -->
          <xsl:if test="$current_component!=''">
	    <!-- Check that cases with this component and non-empty 
		 domain exist -->
	    <xsl:if test="count(//case
			  [
			  (ancestor-or-self::*/@component)[last()]=
			  $current_component 
			  and
			  (ancestor-or-self::*/@domain)[last()]!=''
			  ])">
	      <tr>
		<td>
		  <xsl:value-of select="$current_component"/>
		</td>
		<!-- Go through the domains -->
		<xsl:for-each
		   select="//*[generate-id() = 
			   generate-id(key('domains',@domain)[1])]">
		  <xsl:variable name="current_domain">
		    <xsl:value-of select="@domain"/>
		  </xsl:variable>
		  
		  <!-- Skip also empty domains -->
		  <xsl:if test="$current_domain!=''">
		    <td class="center">
		      <xsl:value-of
			 select="count(
				 //case
				 [
				 (ancestor-or-self::*/@component)[last()]=
				 $current_component 
				 and
				 (ancestor-or-self::*/@domain)[last()]=
				 $current_domain
				 ])"/>
		    </td>
		  </xsl:if>
		</xsl:for-each>
		
		<!-- Row sum -->
		<td class="center">
		  <!-- Cases from current component that have a domain -->
		  <xsl:value-of
		     select="count(
			     //case
			     [
			     (ancestor-or-self::*/@domain)[last()]!=''
			     and
			     (ancestor-or-self::*/@component)[last()]=
			     $current_component
			     ])"/>
		</td>
	      </tr>
	    </xsl:if>
	  </xsl:if>
	</xsl:for-each>
	
	<!-- Last row holds column totals -->
	<tr>
	  <td><xsl:text>Total</xsl:text></td>
	  <xsl:for-each
	     select="//*[generate-id()=generate-id(key('domains',@domain)[1])]">
	    <xsl:variable name="current_domain">
	      <xsl:value-of select="@domain"/>
	    </xsl:variable>
	    
	    <xsl:if test="$current_domain!=''">
	      <td class="center">
		<xsl:value-of
		   select="count(
			   //case[
			   (ancestor-or-self::*/@domain)[last()]=
			   $current_domain
			   and
			   (ancestor-or-self::*/@component)[last()]!=''
			   ])"/>
	      </td>
	    </xsl:if>
	  </xsl:for-each>
	  <!-- Total of totals, but not the count of all cases
	       since we skipped the empty components and domains -->
	  <td class="center">
	    <xsl:value-of
	       select="count(//case
		       [
		       (ancestor-or-self::*/@domain)[last()]!=''
		       and
		       (ancestor-or-self::*/@component)[last()]!=''
		       ])"/>
	  </td>
	</tr>
      </table>
    </div>
  </xsl:template>

</xsl:stylesheet>
