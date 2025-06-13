<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="tei">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/tei:TEI">

    <html>
        <head>
            <meta charset="UTF-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <title>
                <xsl:value-of select="tei:teiHeader/tei:fileDesc//tei:title[@type='article']"/>
            </title>
            <link rel="stylesheet" type="text/css" href="stile.css"/>
        </head>
        <body>
            <div class="header-info">
                <h2>Metadati</h2>
                <p>
                    <strong>Titolo: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc//tei:title[@type='article']"/>
                </p>
                <p><strong>Autore: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/></p>
                <p><strong>Editore: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor"/></p>
                <p><strong>Ente responsabile: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:principal"/></p>
                <p>
                    <strong>Responsabilità:</strong>
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:resp"/> -
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:name"/>
                </p>

                <p><strong>Data: </strong>
                    <!-- Logica di recuperazione della data -->
                    <xsl:variable name="headerDateNode" select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date"/>
                    <xsl:choose>
                        <xsl:when test="normalize-space($headerDateNode) and not($headerDateNode/@when)">
                            <xsl:value-of select="$headerDateNode"/>
                        </xsl:when>
                        <xsl:when test="normalize-space($headerDateNode) and $headerDateNode/@when">
                            <xsl:value-of select="$headerDateNode"/>
                        </xsl:when>
                        <xsl:when test="$headerDateNode/@when">
                            <xsl:value-of select="$headerDateNode/@when"/>
                        </xsl:when>
                
                    </xsl:choose>
                </p>
                <p><strong>Volume: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:biblScope[@unit='volume']"/></p>
                <p><strong>Numero: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='issue']"/></p>
                <p><strong>Pagine: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:biblScope[@unit='pages']"/></p>
                <p><strong>Fonte: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:p"/></p>
                <p><strong>Lingua: </strong> <xsl:value-of select="tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language"/></p>
                <p><strong>Descrizione della codifica: </strong> <xsl:value-of select="tei:teiHeader/tei:encodingDesc/tei:p"/></p>
            </div>
        </body>
    </html>

    </xsl:template>

</xsl:stylesheet>