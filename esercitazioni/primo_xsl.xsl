<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:value-of select="//tei:titleStmt/tei:title[@type='short']"/>
    </xsl:template>
</xsl:stylesheet>