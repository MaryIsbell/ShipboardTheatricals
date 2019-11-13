<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  version="3.0">

  <!-- Copyleft 2019 Syd Bauman -->
  
  <xsl:output method="xml" indent="no"/>
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:param name="initLet" select="tokenize(base-uri(/),'/')[last()] => substring( 1, 1 )"/>

  <xsl:template match="div">
    <xsl:variable name="vol" select="count( ancestor-or-self::div[ last() ]/preceding-sibling::div )+1"/>
    <xsl:variable name="iss" select="count( ancestor-or-self::div[ last()-1 ]/preceding-sibling::div )+1"/>
    <xsl:variable name="art" select="count( ancestor-or-self::div[ last()-2 ]/preceding-sibling::div )+1"/>
    <xsl:variable name="xid">
      <xsl:choose>
        <xsl:when test="@type eq 'volume'  and  not( ancestor::div )">
          <xsl:value-of select="$initLet||$vol"/>
        </xsl:when>
        <xsl:when test="@type eq 'issue'  and  count( ancestor::div ) eq 1">
          <xsl:value-of select="$initLet||$vol||'.'||format-integer( $iss,'00')"/>
        </xsl:when>
        <xsl:when test="count( ancestor::div ) eq 2  and  not( @type = ('volume','issue'))">
          <xsl:value-of select="$initLet||$vol||'.'||format-integer( $iss,'00')||'.'||format-integer( $art,'00')"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="'ERROR_'||generate-id()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:id" select="$xid"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
