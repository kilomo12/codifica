<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <body>
                <h2>Catalogo Libri</h2>
                <ul>
                    <xsl:for-each select="catalogo/libro">
                        <li>
                            <b><xsl:value-of select="titolo"/></b> - 
                            <i><xsl:value-of select="autore"/></i>
                        </li>
                    </xsl:for-each>
                </ul>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
