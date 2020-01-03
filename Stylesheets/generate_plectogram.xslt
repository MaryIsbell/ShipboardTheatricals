<?xml version="1.0" encoding="UTF-8"?>

<!-- 
 * generate_plectogram.xslt

 * © 2019 Syd Bauman and David Birnbaum
 * Available under terms of GPL 3.0.
 * See https://github.com/djbpitt/hwang/blob/master/LICENSE

 * This program is based very heavily on David Birnbaum's work
 * on plectograms, in particular on his wonderful starter set
 * available at https://github.com/djbpitt/hwang.
 
 * Summarily ignore the input file and instead read in two XML
 * files (defaulting to ../Bampfield.xml and ../McArthur.xml, but
 * that can be changed by setting the parameters "inS" and "inT")
 * and generate an SVG drawing of a "plectogram", and tiny HTML
 * wrapper for it, therefrom. For now look for and process temp-
 * orary @tmp:corresp attributes in the input; eventually these
 * would be proper TEI @corresp attributes.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:djb="http://www.obdurodon.org"
                xmlns:wf="http://www.wwp.northeastern.edu/ns/functions"
                xmlns:tmp="http://www.wwp.neu.edu/temp/ns"
                exclude-result-prefixes="#all"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                xmlns:svg="http://www.w3.org/2000/svg" version="2.0">

  <xsl:output method="xml" indent="yes"/>
  <!-- input file that has @corresp that point to other input file: -->
  <xsl:param name="inS" select="'../Bampfield.xml'"/>
  <!-- input file that has @xml:ids that are pointed at by other input file:-->
  <xsl:param name="inT" select="'../McArthur.xml'"/>
  <xsl:variable name="source" select="document($inS)" as="document-node()"/>
  <xsl:variable name="target" select="document($inT)" as="document-node()"/>
  <!-- height of each rectangle in each document column in output: -->
  <xsl:param name="rectHeight" as="xs:integer" select="24"/>
  <!-- width of each rectangle in each document column in output: -->
  <xsl:param name="rectWidth" as="xs:integer" select="100"/>
  <!-- distance between the two columns in output: -->
  <xsl:param name="colDist" as="xs:integer" select="400"/>
  <!-- how far each line of text inside a cell is indented from L edge of cell: -->
  <xsl:param name="txtIndent" as="xs:integer" select="8"/>
  <!-- how far above bottom of cell text baseline is: -->
  <xsl:param name="txtLeading" as="xs:integer" select="16"/>
  <!-- colors: -->
  <xsl:param name="backgroundColor">#EAD</xsl:param>
  <xsl:param name="cellColor">#FBE</xsl:param>

  <xsl:template match="/">
    <html>
      <head>
        <title>B vs M</title>
        <meta name="generated" content="{current-dateTime()}"/>
        <style type="text/css">
          body {
             margin: 2em;
             background-color: <xsl:value-of select="$backgroundColor"/>;
             }
        </style>
        <script type="text/javascript">
          <!--
            Thanks to _SVG Essentials_ by J. David Eisenberg and to my son
            David Bauman for the Javascript
          -->
          function highlight(nam) {
            console.log( nam );
            const srect = document.getElementById('S'+nam);
            const trect = document.getElementById('T'+nam);
            const line  = document.getElementById('L'+nam);
            srect.setAttribute("stroke-width", 6 );
            srect.setAttribute("stroke","red");
            trect.setAttribute("stroke-width", 6 );
            trect.setAttribute("stroke","red");
            line.setAttribute("stroke-width", 6 );
            line.setAttribute("stroke","red");
            }
          function normal(nam) {
            const srect = document.getElementById('S'+nam);
            const trect = document.getElementById('T'+nam);
            const line  = document.getElementById('L'+nam);
            console.log( 'duck'+nam );
            srect.setAttribute("stroke-width", 2 );
            srect.setAttribute("stroke","black");
            trect.setAttribute("stroke-width", 2 );
            trect.setAttribute("stroke","black");
            line.setAttribute("stroke-width", 1 );
            line.setAttribute("stroke","black");
          }
        </script>
      </head>
      <body>
        <h1>Bampfield vs McArthur</h1>
        <svg:svg width="100%" height="{max( ( count($source//div[@tmp:corresp]), count($target//div[@xml:id]) ) ) * $rectHeight}">
          <svg:g id="wrapper"> <!-- ← currently no need for this outer wrapper -->
            <!-- starting in upper L corner, generate L column of source <div>s: -->
            <svg:g id="BampfieldSet" transform="translate( 0, 0)">
              <xsl:apply-templates select="$source//div[@tmp:corresp]" mode="drawRect">
                <!-- and draw the connecting lines while we are at it: -->
                <xsl:with-param name="sourceDiv" select="true()"/>
              </xsl:apply-templates>
            </svg:g>
            <!-- starting $colDist to R, generate R column of target <div>s: -->
            <svg:g id="McArthurSet" transform="translate( {$colDist}, 0)">
              <xsl:apply-templates select="$target//div[@xml:id]" mode="drawRect">
                <xsl:with-param name="sourceDiv" select="false()"/>
              </xsl:apply-templates>
            </svg:g>
          </svg:g>
        </svg:svg>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="div" mode="drawRect">
    <xsl:param name="sourceDiv" as="xs:boolean"/>
    <xsl:variable name="corresp" select="substring-after( @tmp:corresp,'#')"/>
    <xsl:variable name="corresponds" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="$sourceDiv">
          <xsl:value-of select="$target//div/@xml:id = $corresp"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$source//div/@tmp:corresp => substring-after('#') = @xml:id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="myName">
      <xsl:choose>
        <xsl:when test="$sourceDiv">
          <xsl:value-of select="'S'||$corresp"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'T'||normalize-space(@xml:id)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:comment select="' '||@xml:id||'('||$sourceDiv||'). '"/>
    <xsl:variable name="cellContent">
      <xsl:choose>
        <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
        <xsl:when test="@tmp:corresp"><xsl:value-of select="$corresp"/></xsl:when>
        <xsl:otherwise>INTERNAL ERROR</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="yPos" as="xs:integer" select="(position() - 1) * $rectHeight"/>
    <svg:rect x="0" y="{$yPos}" width="{$rectWidth}" height="{$rectHeight}"
      stroke="black" stroke-width="2" fill="{$cellColor}" id="{$myName}"
      onmouseover="highlight('{substring($myName,2)}')"
      onmouseout="normal('{substring($myName,2)}')"/>
    <svg:text x="{$txtIndent}" y="{$yPos + $txtLeading}"
      onmouseout="normal('{substring($myName,2)}')"
      onmouseover="highlight('{substring($myName,2)}')">
      <xsl:value-of select="$cellContent"/>
    </svg:text>
    <xsl:if test="$sourceDiv">
      <xsl:if test="$corresponds">
        <xsl:variable name="yPosTarget" as="xs:integer"
          select="($rectHeight div 2) + $rectHeight * ( count( $target//div[ @xml:id eq $corresp ]/(preceding::div[ @xml:id] | ancestor::div[@xml:id] ) ) )"/>
        <svg:line stroke="black" stroke-width="1" id="{'L'||substring($myName,2)}"
          x1="{$rectWidth}" y1="{$yPos + ($rectHeight div 2)}"
          x2="{$colDist}"   y2="{$yPosTarget}"
          onmouseout="normal('{substring($myName,2)}')"
          onmouseover="highlight('{substring($myName,2)}')"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
