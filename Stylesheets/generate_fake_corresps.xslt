<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tmp="TEMP_NAMESPACE_FIX_ME"
  version="3.0">
  
  <!-- Run this pgm on Bampfield.xml, the output is a replacement for
  Bampfield.xml -->
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="McArthur" select="document('../McArthur.xml')"/>

  <xsl:template match="div/div/div">
    <!-- probably would be better to use <xsl:count> for this, but count() is
    faster and easier (on this human), even if far less efficient (for the computer) -->
    <xsl:variable name="count" select="count( preceding::div[ parent::div/parent::div ] )+1"/>
    <xsl:copy>
      <xsl:variable name="correspondingDiv" select="($McArthur//div/div/div)[$count]"/>
      <xsl:variable name="correspVal">
        <xsl:choose>
          <xsl:when test="$correspondingDiv/@xml:id">
            <xsl:value-of select="'#'||$correspondingDiv/@xml:id"/>
          </xsl:when>
          <xsl:otherwise>#NONE</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="tmp:corresp" select="$correspVal"/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
