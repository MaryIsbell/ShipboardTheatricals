<?xml version="1.0" encoding="UTF-8"?>

<!-- 
 * generate_plectogram.xslt

 * © 2019 Syd Bauman and David Birnbaum
 * Available under terms of GPL 3.0.
 * See https://github.com/djbpitt/hwang/blob/master/LICENSE

 * This program is based very heavily on David Birnbaum's work
 * on plectograms, in particular on his wonderful starter set
 * available at https://github.com/djbpitt/hwang.
 
 * Code not written yet, but the plan is to read in two XML
 * files (defaulting to ../Bampfield.xml and ../McArthur.xml, but
 * that would be controlled by parameter) and generate an SVG
 * and tiny HTML wrapper therefrom. For now I expect that there
 * may be @tmp:corresp attributes in the input; eventually these
 * would be proper TEI @corresp attributes. Furthermore, I am
 * expecting to eventually move the proccessing function from
 * the djb: namespace to a ShipboardTheatricals namespace, but 
 * in the meantime will use the WWP functions namespace.
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
  <xsl:param name="rectHeight" as="xs:integer" select="20"/>
  <xsl:param name="rectWidth" as="xs:integer" select="80"/>
  <xsl:param name="colDist" as="xs:integer" select="400"/>

  <xsl:function name="wf:processDivs" as="element()">
    <xsl:param name="input"/>
    <xsl:variable name="myN" as="xs:integer" select="count( $input/preceding::div[@tmp:corresp] ) +1"/>
    <xsl:variable name="precedingDiv" select="$input/preceding-sibling::div[1]"/>
    <svg:g id="Mdiv{format-number($myN,'000')}" transform="translate({$myN * $colDist}, 0)">
      <xsl:for-each select="$input//div[@tmp:corresp]">
        <xsl:variable name="yPos" as="xs:integer" select="(position() - 1) * $rectHeight"/>
        <svg:rect x="0" y="{$yPos}" width="{$rectWidth}" height="{$rectHeight}"
                  stroke="black" stroke-width="2" fill="none"/>
        <svg:text x="2" y="{$yPos + 16}">
          <xsl:value-of select="@xml:id"/>
        </svg:text>
        <xsl:if test="DUCK">
          <xsl:if test="$precedingDiv/monument = current()">
            <xsl:variable name="yPosPreceding" as="xs:integer"
                          select="($rectHeight div 2) + $rectHeight * (count($precedingDiv/monument[. = current()]/preceding-sibling::monument))"/>
            <svg:line x1="{$rectWidth - $colDist}" y1="{$yPosPreceding}" x2="0"
                      y2="{$yPos + ($rectHeight div 2)}" stroke="black" stroke-width="1"/>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </svg:g>
  </xsl:function>

  <xsl:template match="/">
    <html>
      <head>
        <title>B vs M</title>
        <link rel="stylesheet" type="text/css" href="http://www.obdurodon.org/css/style.css"/>
      </head>
      <body>
        <h1>Bampfield vs McArthur</h1>
        <svg:svg width="100%" height="{max( ( count($source//div[@tmp:corresp]), count($target//div[@xml:id]) ) ) * $rectHeight}">
          <svg:g id="wrapper">
            <svg:g id="BampfieldSet" transform="translate( 0, 0)">
              <xsl:apply-templates select="$source//div[@tmp:corresp]" mode="drawRect">
                <xsl:with-param name="drawLine" select="true()"/>
              </xsl:apply-templates>
            </svg:g>
            <svg:g id="McArthurSet" transform="translate( {$colDist}, 0)">
              <xsl:apply-templates select="$target//div[@xml:id]" mode="drawRect">
                <xsl:with-param name="drawLine" select="false()"/>
              </xsl:apply-templates>
            </svg:g>
          </svg:g>
        </svg:svg>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="div" mode="drawRect">
    <xsl:param name="drawLine" as="xs:boolean"/>
    <xsl:variable name="corresp" select="substring-after( @tmp:corresp,'#')"/>
    <xsl:variable name="value">
      <xsl:choose>
        <xsl:when test="@tmp:corresp"><xsl:value-of select="$corresp"/></xsl:when>
        <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
        <xsl:otherwise>INTERNAL ERROR</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="yPos" as="xs:integer" select="(position() - 1) * $rectHeight"/>
    <svg:rect x="0" y="{$yPos}" width="{$rectWidth}" height="{$rectHeight}"
      stroke="black" stroke-width="2" fill="none"/>
    <svg:text x="2" y="{$yPos + 16}">
      <xsl:value-of select="$value"/>
    </svg:text>
    <xsl:if test="$drawLine">
      <xsl:if test="$target//div/@xml:id = $corresp">
        <xsl:variable name="yPosPreceding" as="xs:integer"
          select="($rectHeight div 2) + $rectHeight * (count( preceding::div[@tmp:corresp]))"/>
        <svg:line x1="{$rectWidth - $colDist}" y1="{$yPosPreceding}" x2="0"
          y2="{$yPos + ($rectHeight div 2)}" stroke="black" stroke-width="1"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
