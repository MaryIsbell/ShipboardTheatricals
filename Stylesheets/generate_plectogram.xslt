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
                exclude-result-prefixes="#all" xmlns="http://www.w3.org/1999/xhtml"
                xmlns:svg="http://www.w3.org/2000/svg" version="2.0">

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="rectHeight" as="xs:integer" select="20"/>
  <xsl:param name="rectWidth" as="xs:integer" select="500"/>

  <xsl:function name="djb:processYear" as="element()">
    <xsl:param name="year"/>
    <xsl:variable name="precedingYear" select="$year/preceding-sibling::year[1]"/>
    <svg:g id="{concat('y', $year/@n)}"
           transform="translate({$year/count(preceding-sibling::year) * 1000}, 0)">
      <xsl:for-each select="$year/monument">
        <xsl:variable name="yPos" as="xs:integer" select="(position() - 1) * $rectHeight"/>
        <svg:rect x="0" y="{$yPos}" width="{$rectWidth}" height="{$rectHeight}"
                  stroke="black" stroke-width="2" fill="none"/>
        <svg:text x="2" y="{$yPos + 16}">
          <xsl:value-of select="."/>
        </svg:text>
        <xsl:if test="$precedingYear">
          <xsl:if test="$precedingYear/monument = current()">
            <xsl:variable name="yPosPreceding" as="xs:integer"
                          select="($rectHeight div 2) + $rectHeight * (count($precedingYear/monument[. = current()]/preceding-sibling::monument))"/>
            <svg:line x1="{$rectWidth - 1000}" y1="{$yPosPreceding}" x2="0"
                      y2="{$yPos + ($rectHeight div 2)}" stroke="black" stroke-width="1"/>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </svg:g>
  </xsl:function>

  <xsl:template match="/">
    <html>
      <head>
        <title>Monuments</title>
        <link rel="stylesheet" type="text/css" href="http://www.obdurodon.org/css/style.css"
              />
      </head>
      <body>
        <h1>Monuments</h1>
        <svg:svg width="100%" height="{max(//year/count(monument)) * $rectHeight}">
          <svg:g id="wrapper">
            <xsl:for-each select="//year">
              <xsl:sequence select="djb:processYear(.)"/>
            </xsl:for-each>
          </svg:g>
        </svg:svg>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
