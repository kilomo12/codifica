<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> <!-- elemento radice -->
    <xsl:output method="html" />
    <xsl:strip-space elements="expan abbr ex"/> <!-- per togliere gli spazi-->
    <xsl:template match="/"> <!-- modello di trasformazione -->
        <html>
            <head>
                <title>
                    <xsl:value-of select="//titleStmt/title"/>
                </title>
                <style>
                    .edition[color: red]
                </style>
            </head>
            <body>
                <xsl:apply-templates select="current()/descendant::test" />
            </body>  <!-- va inserito il contenuto Html della pagina -->
        </html> 
    </xsl:template> 
    <xsl:template match="div[@type]"></xsl:template>

    <xsl:template match="div"/>

</xsl:stylesheet>