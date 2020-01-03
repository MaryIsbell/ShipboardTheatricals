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
 
 * Known limitation/problem: presumes, without checking, that every
 * @tmp:corresp points to the target file. We just strip off the
 * fragment identifier and presume it is a bare name, and use it as
 * a pointer into the target file.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tmp="http://www.wwp.neu.edu/temp/ns"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="#all" version="2.0">

  <xsl:output method="xml" indent="yes"/>
  <!-- input file that has @corresp that point to other input file: -->
  <xsl:param name="source" select="'../Bampfield.xml'"/>
  <!-- input file that has @xml:ids that are pointed at by other input file:-->
  <xsl:param name="target" select="'../McArthur.xml'"/>
  <!-- get just the base filenames: -->
  <!-- (Note: stripping all after first dot; should strip all after last dot.) -->
  <xsl:variable name="sourceFN" select="substring-before( tokenize( $source, '/')[last()], '.') => replace('\C','')"/>
  <xsl:variable name="targetFN" select="substring-before( tokenize( $target, '/')[last()], '.') => replace('\C','')"/>
  <!-- read in the actual input documents: -->
  <!-- (Note: need to add error-catching code in case file is not readable XML.) -->
  <xsl:variable name="sourceDoc" select="document($source)" as="document-node()"/>
  <xsl:variable name="targetDoc" select="document($target)" as="document-node()"/>
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
      <xsl:call-template name="HTMLhead"/>
      <body>
        <h1>
          <xsl:value-of select="$sourceFN||' vs '||$targetFN"/>
        </h1>
        <svg:svg width="100%" height="{max( ( count($sourceDoc//div[@tmp:corresp]), count($targetDoc//div[@xml:id]) ) ) * $rectHeight}">
          <svg:g id="wrapper"> <!-- ← currently no need for this outer wrapper -->
            <!-- starting in upper L corner, generate L column of source <div>s: -->
            <svg:g id="{$sourceFN}Set" transform="translate( 0, 0)">
              <xsl:apply-templates select="$sourceDoc//div[@tmp:corresp]" mode="drawRect">
                <!-- and draw the connecting lines while we are at it: -->
                <xsl:with-param name="isFromSource" select="true()"/>
              </xsl:apply-templates>
            </svg:g>
            <!-- starting $colDist to R, generate R column of target <div>s: -->
            <svg:g id="{$targetFN}Set" transform="translate( {$colDist}, 0)">
              <xsl:apply-templates select="$targetDoc//div[@xml:id]" mode="drawRect">
                <xsl:with-param name="isFromSource" select="false()"/>
              </xsl:apply-templates>
            </svg:g>
          </svg:g>
        </svg:svg>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="div" mode="drawRect">
    <xsl:param name="isFromSource" as="xs:boolean"/>
    <!-- get the ID of the target this <div> corresponds to: -->
    <xsl:variable name="corresp" select="@tmp:corresp => substring-after('#') => normalize-space()"/>
    <!--
      set a flag to true there is a correspondence between us (the
      <div> currently being processed) and a <div> in the other file;
      i.e. set to true if
      a) our @tmp:corresp points to a target <div>, or
      b) a <div> from source has a @tmp:corresp that points to us.
    -->
    <xsl:variable name="corresponds" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="$isFromSource">
          <xsl:value-of select="$targetDoc//div/@xml:id = $corresp"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$sourceDoc//div/@tmp:corresp!substring-after( ., '#') = @xml:id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="myNamePrefix" select="if ($isFromSource) then 'S' else 'T'"/>
    <xsl:variable name="myName" select="if ($isFromSource) then $corresp else normalize-space(@xml:id)"/>
    <xsl:variable name="cellContent">
      <xsl:choose>
        <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
        <xsl:when test="@tmp:corresp"><xsl:value-of select="normalize-space( @tmp:corresp )"/></xsl:when>
        <xsl:otherwise>INTERNAL ERROR</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:comment select="' '||$cellContent||'('||$isFromSource||'). '"/>
    <xsl:variable name="yPos" as="xs:integer" select="(position() - 1) * $rectHeight"/>
    <svg:rect x="0" y="{$yPos}" width="{$rectWidth}" height="{$rectHeight}"
      stroke="black" stroke-width="2" fill="{$cellColor}" id="{$myNamePrefix||$myName}"
      onmouseover="highlight('{$myName}')" onmouseout="normal('{$myName}')"/>
    <svg:text x="{$txtIndent}" y="{$yPos + $txtLeading}"
      onmouseout="normal('{$myName}')" onmouseover="highlight('{$myName}')">
      <xsl:value-of select="$cellContent"/>
    </svg:text>
    <xsl:if test="$isFromSource and $corresponds">
      <xsl:variable name="yPosTarget" as="xs:integer"
        select="($rectHeight div 2) + $rectHeight * ( count( $targetDoc//div[ @xml:id eq $corresp ]/(preceding::div[ @xml:id] | ancestor::div[@xml:id] ) ) )"/>
      <svg:line stroke="black" stroke-width="1" id="{'L'||$myName}"
        x1="{$rectWidth}" y1="{$yPos + ($rectHeight div 2)}"
        x2="{$colDist}"   y2="{$yPosTarget}"
        onmouseout="normal('{$myName}')"
        onmouseover="highlight('{$myName}')"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="HTMLhead">
    <head>
      <title>
        <xsl:value-of select="substring( $sourceFN, 1, 1)||' vs '||substring( $targetFN, 1, 1 )"/>
      </title>
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
          console.log( nam );
          const srect = document.getElementById('S'+nam);
          const trect = document.getElementById('T'+nam);
          const line  = document.getElementById('L'+nam);
          srect.setAttribute("stroke-width", 2 );
          srect.setAttribute("stroke","black");
          trect.setAttribute("stroke-width", 2 );
          trect.setAttribute("stroke","black");
          line.setAttribute("stroke-width", 1 );
          line.setAttribute("stroke","black");
        }
      </script>
    </head>
  </xsl:template>

</xsl:stylesheet>
