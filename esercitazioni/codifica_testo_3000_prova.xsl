<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>


    <xsl:template match="tei:TEI">
        <html>
            <head>
                <title>
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'short']"/>
                </title>
            </head>
            <body>
                <div>
                    <span>
                        1.
                    </span>
                    <xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
                </div>
            </body>
        </html>
    </xsl:template>


</xsl:stylesheet>