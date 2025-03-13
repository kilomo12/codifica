<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ns="http://example.org/namespace">
    
    <xsl:output method="text" indent="yes"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>Transformation XSL</title>
            </head>
            <body>
                <h1>Texte Transformé</h1>
                <xsl:apply-templates select="ns:doc/ns:p"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="ns:p">
        <p>
            <strong>Paragraphe <xsl:value-of select="@n"/>:</strong>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="ns:placeName">
        <span style="color: red; font-weight: bold;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
</xsl:stylesheet>
