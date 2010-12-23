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
   XSL transformation for results matching testdefinition-result.xsd
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

  <xsl:variable name="passed_cases"
		select="count(//case[@result='PASS'])"/>
  <xsl:variable name="failed_cases"
		select="count(//case[@result='FAIL'])"/>
  <xsl:variable name="na_cases"
		select="count(//case[@result='N/A'])"/>
  <xsl:variable name="total_cases"
		select="count(//case)"/>
  <xsl:variable name="exec_cases"
		select="$passed_cases + $failed_cases"/>

  <!-- The root template defining the main page structure -->
  <xsl:template match="/">
    <html>
      <head>
	<meta http-equiv="Content-Type"
	      content="text/html; charset=UTF-8"/>
	<title><xsl:text>Test Results</xsl:text></title>
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
	    <h1>
	      <xsl:text>Test Results</xsl:text>
	    </h1>
	    <!-- Top "navigation" links -->
	    <p>
	      <a href="#test_results" title="Result Summary" class="navilink">
		<xsl:text>Result Summary &gt;</xsl:text>
	      </a>
	      <a href="#test_set" title="Test Results by Test Set" 
		 class="navilink">
		<xsl:text>Test Results by Test Set &gt;</xsl:text>
	      </a>
	      <a href="#detailed_results" title="Detailed Test Results" 
		 class="navilink">
		<xsl:text>Detailed Test Results &gt;</xsl:text>
	      </a>
	    </p>	    
	  </div>
	  
	  <div id="page">
	    <div class="page_content">
	      <xsl:apply-templates /> 
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
  <xsl:template match="/testresults">
    <h2 id="environment">Test Environment</h2>
    <ul>
      <li>
	<xsl:text>Hardware: </xsl:text>
	<xsl:choose>
	  <xsl:when test="@hwproduct!=''">
	    <xsl:value-of select="@hwproduct"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>N/A</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </li>
      <li>
	<xsl:text>Environment: </xsl:text>
	<xsl:choose>
	  <xsl:when test="@environment!=''">
	    <xsl:value-of select="@environment"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>N/A</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </li>
    </ul>

    <div class="section emphasized_section">
      <h2 id="test_results"><xsl:text>Test Results</xsl:text></h2>
      <div class="container">
	<xsl:call-template name="result_summary"/>
	
	<xsl:call-template name="results_by_set"/>

      </div>
    </div>

    <xsl:call-template name="detailed_results"/>

  </xsl:template>

  <!-- Summary of test results -->
  <xsl:template name="result_summary">
    <h3 class="first"><xsl:text>Result Summary</xsl:text></h3>
    <div class="wrap">
      <table id="test_result_overview">
        <tr class="even">
          <td class="title"><xsl:text>Total test cases</xsl:text></td>
          <td class="value">
	    <strong>
	      <xsl:value-of select="$total_cases"/>
	    </strong>
	  </td>
          <td rowspan="7" style="background-color: white;">
	    <div class="bvs_wrap">
	      <xsl:element name="img">
		<xsl:attribute name="class">
		  <xsl:text>bvs</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="src">
		  <xsl:text>http://chart.apis.google.com/chart?</xsl:text>
		  <!-- Chart type -->
		  <xsl:text>cht=bvs</xsl:text>
		  <!-- Chart area size -->
		  <xsl:text>&amp;chs=150x200</xsl:text>
		  <!-- Bar colors -->
		  <xsl:text>&amp;chco=73a20c,ec4343,CACACA</xsl:text>
		  <!-- Data to plot -->
		  <xsl:text>&amp;chd=t:</xsl:text>
		  <xsl:value-of select="$passed_cases"/>
		  <xsl:text>|</xsl:text>
		  <xsl:value-of select="$failed_cases"/>
		  <xsl:text>|</xsl:text>
		  <xsl:value-of select="$na_cases"/>
		  <!-- Data scaling -->
		  <xsl:text>&amp;chds=0,</xsl:text>
		  <xsl:value-of select="round($total_cases * 1.1)"/> 
		  <!-- Background fill -->
		  <xsl:text>&amp;chf=bg,s,ffffffff</xsl:text>
		  <!-- Bar width and spacing -->
		  <xsl:text>&amp;chbh=90,30,30</xsl:text>
		  <!-- Visible axes -->
		  <xsl:text>&amp;chxt=x,y</xsl:text>
		  <!-- X axis labels -->
		  <xsl:text>&amp;chl=Current</xsl:text>
		  <!-- Axis range: axis, start val, end val, step -->
		  <xsl:text>&amp;chxr=1,0,</xsl:text>
		  <xsl:value-of select="round($total_cases * 1.1)"/>
		</xsl:attribute>
		<xsl:attribute name="alt">
		  <xsl:text>Graph</xsl:text>
		</xsl:attribute>
	      </xsl:element>
	    </div>
	  </td>
        </tr>
        <tr class="odd">
          <td><xsl:text>Passed</xsl:text></td>
          <td>
	    <strong class="pass">
	      <xsl:value-of select="$passed_cases"/>
	    </strong>
	  </td>
        </tr>
        <tr class="even">
          <td><xsl:text>Failed</xsl:text></td>
          <td>
	    <strong class="fail">
	      <xsl:value-of select="$failed_cases"/>
	    </strong>
	  </td>
        </tr>
        <tr class="odd">
          <td><xsl:text>Not testable</xsl:text></td>
          <td>
	    <strong>
	      <xsl:value-of select="$na_cases"/>
	    </strong>
	  </td>
        </tr>
        <tr class="even">
          <td><xsl:text>Run rate</xsl:text></td>
	  <xsl:call-template name="percentage_cell">
	    <xsl:with-param name="dividend" select="$exec_cases"/>
	    <xsl:with-param name="divisor" select="$total_cases"/>
	  </xsl:call-template>
        </tr>
        <tr class="odd">
          <td><xsl:text>Pass rate of total</xsl:text></td>
	  <xsl:call-template name="percentage_cell">
	    <xsl:with-param name="dividend" select="$passed_cases"/>
	    <xsl:with-param name="divisor" select="$total_cases"/>
	  </xsl:call-template>
        </tr>
        <tr class="even">
          <td>Pass rate of executed</td>
	  <xsl:call-template name="percentage_cell">
	    <xsl:with-param name="dividend" select="$passed_cases"/>
	    <xsl:with-param name="divisor" select="$exec_cases"/>
	  </xsl:call-template>
        </tr>
      </table>
    </div>
  </xsl:template>

  <!-- Create the test results by test set section -->
  <xsl:template name="results_by_set">
    <h3 id="test_set"><xsl:text>Test Results by Test Set</xsl:text></h3>

    <table id="test_results">
      <thead class="even">
	<tr>
          <th class="th_feature">Test Set</th>
          <th class="th_total">Total</th>
          <th class="th_passed">Passed</th>
          <th class="th_failed">Failed</th>
          <th class="th_not_testable">Not testable</th>
          <th class="th_graph">&#160;</th>
	</tr>
      </thead>

      <xsl:for-each select="//set">
	<xsl:variable name="set_total" select="count(case)"/>
	<xsl:variable name="set_pass" select="count(case[@result='PASS'])"/>
	<xsl:variable name="set_fail" select="count(case[@result='FAIL'])"/>
	<xsl:variable name="set_na" select="count(case[@result='N/A'])"/>
	<tr class="feature_record even" 
	    id="test-set-TODO">
    	  <td>
            <a href="#test-set-TODO">
	      <xsl:value-of select="@name"/>
            </a>
	  </td>
	  <td class="total">
	    <xsl:value-of select="$set_total"/>
	  </td>
	  <td class="pass">
	    <xsl:value-of select="$set_pass"/>
	  </td>
	  <td class="fail">
	    <xsl:value-of select="$set_fail"/>
	  </td>
	  <td class="na">
	    <xsl:value-of select="$set_na"/>
	  </td>
	  <td>
	    <div class="bhs_wrap">
	      <xsl:element name="img">
		<xsl:attribute name="class">
		  <xsl:text>bhs</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="alt">
		  <xsl:text>Graph</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="src">
		  <xsl:text>http://chart.apis.google.com/chart?</xsl:text>
		  <xsl:text>cht=bhs:nda</xsl:text>
		  <xsl:text>&amp;chs=386x14</xsl:text>
		  <xsl:text>&amp;chco=73a20c,ec4343,CACACA</xsl:text>
		  <xsl:text>&amp;chd=t:</xsl:text>
		  <xsl:value-of select="$set_pass"/>
		  <xsl:text>|</xsl:text>
		  <xsl:value-of select="$set_fail"/>
		  <xsl:text>|</xsl:text>
		  <xsl:value-of select="$set_na"/>
		  <xsl:text>&amp;chds=0,</xsl:text>
		  <xsl:value-of select="$set_total"/>
		  <xsl:text>&amp;chma=0,0,0,0</xsl:text>
		  <xsl:text>&amp;chf=bg,s,ffffff00</xsl:text>
		  <xsl:text>&amp;chbh=14,0,0</xsl:text>
		</xsl:attribute>
	      </xsl:element>
	    </div>
	  </td>
	</tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <!-- Detailed result listing -->
  <xsl:template name="detailed_results">
    <h2 id="detailed_results">Detailed Test Results</h2>
    
    <table id="detailed_results">
      <thead>
	<tr>
	  <th id="th_test_case"><xsl:text>Test case</xsl:text></th>
	  <th id="th_result"><xsl:text>Result</xsl:text></th>
	  <th id="th_notes">
	    <div style="position:relative;">
	      <xsl:text>Notes </xsl:text>
	      <span class="sort">
		<a href="#" 
		   id="see_only_failed_button" 
		   class="sort_btn active">
		  <xsl:text>See only failed</xsl:text>
		</a>
		<a href="#" 
		   id="see_all_button" 
		   class="sort_btn">
		  <xsl:text>See all</xsl:text>
		</a>
	      </span>
	    </div>
	  </th>
        </tr>
      </thead>
      
      <xsl:for-each select="//set">
	<tbody>
	  <tr class="feature_name" id="test-set-TODO">
	    <td colspan="3">
	      <xsl:value-of select="@name"/>
	      <a href="#" class="see_all_toggle">
		<xsl:text>+ see passing tests</xsl:text>
	      </a>
	    </td>
	  </tr>
	</tbody>
	  
	<xsl:for-each select="case"> 
	  <xsl:element name="tr">
	    <xsl:attribute name="id">
	      <xsl:text>TODO</xsl:text>
	    </xsl:attribute>
	    <xsl:attribute name="class">
	      <xsl:text>testcase </xsl:text>
	      <xsl:choose>
		<xsl:when test="@result='PASS'">
		  <xsl:text>result_pass</xsl:text>
		</xsl:when>
		<xsl:when test="@result='FAIL'">
		  <xsl:text>result_fail</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:text>result_na</xsl:text>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:attribute name="style">
	      <xsl:if test="@result='PASS'">
		<xsl:text>display : none;</xsl:text>
	      </xsl:if>
	    </xsl:attribute>
	    <td class="testcase_name">
	      <xsl:value-of select="@name"/>
	    </td>
	    <xsl:element name="td">
	      <xsl:attribute name="class">
		<xsl:text>testcase_result </xsl:text>
		<xsl:choose>
		  <xsl:when test="@result='PASS'">
		    <xsl:text>pass</xsl:text>
		  </xsl:when>
		  <xsl:when test="@result='FAIL'">
		    <xsl:text>fail</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text>na</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:attribute>
	      <span class="content">
		<xsl:value-of select="@result"/>
	      </span>
	    </xsl:element>
	    <td class="testcase_notes">
	      <div class="content">
		<xsl:if test="@bugzilla_id!=''">
		  <xsl:element name="a">
		    <xsl:attribute name="class">
		      <xsl:text>
			bugzilla fetch bugzilla bugzilla_status 
			bugzilla_append
		      </xsl:text>
		    </xsl:attribute>
		    <xsl:attribute name="href">
		      <xsl:text>http://bugs.meego.com/show_bug.cgi?id=</xsl:text>
		      <xsl:value-of select="@bugzilla_id"/>
		    </xsl:attribute>
		    <xsl:value-of select="@bugzilla_id"/>
		    <br/>
		  </xsl:element>
		</xsl:if>
		<xsl:value-of select="@comment"/>
	      </div>
	    </td>
	  </xsl:element>
	</xsl:for-each>
      </xsl:for-each>
    </table>
  </xsl:template>
  
  <!-- Create a percentage cell to the result summary -->
  <xsl:template name="percentage_cell">
    <xsl:param name="dividend"/>
    <xsl:param name="divisor"/>

    <td>
      <strong>
	<xsl:choose>
	  <xsl:when test="$divisor">
	    <xsl:value-of 
	       select="format-number(
		       $dividend div $divisor,
		       '0.00%')"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>N/A</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </strong>
    </td>
  </xsl:template>

</xsl:stylesheet>
