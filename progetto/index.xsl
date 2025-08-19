<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Template principale per il teiCorpus -->
    <xsl:template match="/tei:teiCorpus">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
                </title>
                <link rel="stylesheet" type="text/css" href="stile_1.css"/>
                <script defer="defer" src="index.js"></script>
            </head>
            <body>
                <h1><xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></h1>

                <div class="navigation-controls">
                    <button id="prevBtn">← Precedente</button>
                    <span id="article-counter">Articolo 1 di <xsl:value-of select="count(tei:TEI)"/></span>
                    <button id="nextBtn">Successivo →</button>
                </div>

                <div id="corpus-container">
                    <xsl:apply-templates select="tei:TEI"/>
                </div>

                <!-- Script per i dati delle zone di TUTTI gli articoli -->
                <script id="zoneData" type="application/json">
                    {
                        <xsl:for-each select="//tei:zone">
                            "<xsl:value-of select="@xml:id"/>": {
                                "points": "<xsl:value-of select="normalize-space(@points)"/>",
                                "originalWidth": "<xsl:value-of select="normalize-space(translate(ancestor::tei:surface/tei:graphic/@width, 'px', ''))"/>",
                                "originalHeight": "<xsl:value-of select="normalize-space(translate(ancestor::tei:surface/tei:graphic/@height, 'px', ''))"/>"
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                    }
                </script>
            </body>
        </html>
    </xsl:template>

    <!-- Template per ogni Articolo TEI -->
    <xsl:template match="tei:TEI">
        <div class="article-container">
            <div class="header-info">
                <h2>Metadati</h2>
                <p><strong>Titolo: </strong> <span class="highlightable-metadata" data-zone-id="{substring-after(tei:text/tei:body/tei:head/@facs, '#')}"><xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></span></p>
                <p><strong>Autore: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName"/></p>
                <p><strong>Editore: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor/tei:name"/></p>
                <p><strong>Ente responsabile: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:principal/tei:orgName"/></p>
                <p><strong>Responsabilità: </strong>
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:resp"/> -
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:name/tei:persName"/>
                </p>
                <p><strong>Casa editrice: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:name"/></p>
                <p><strong>Luogo di pubblicazione: </strong>
                    <span class="highlightable-metadata" data-zone-id="{substring-after(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/@facs, '#')}">
                        <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:placeName | tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:imprint/tei:pubPlace/tei:placeName"/>
                    </span>
                </p>
                <p><strong>Data: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when"/></p>
                <p><strong>Volume: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:biblScope[@unit='volume'] | tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='volume']"/></p>
                <p><strong>Numero: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='issue']"/></p>
                <p><strong>Pagine: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:biblScope[@unit='pages'] | tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='pages']"/></p>
            </div>
            
            <!-- 1. Approccio basato su surface (per articoli con facsimile) -->
            <xsl:apply-templates select="tei:facsimile/tei:surface"/>
    
        </div>
    </xsl:template>
    
    <!-- Template per ogni surface (approccio facsimile) -->
    <xsl:template match="tei:surface">
        <xsl:variable name="zone_ids" select="tei:zone/@xml:id"/>
        
        <div class="page-container" id="{@xml:id}">
            <!-- 1. Colonna Immagine -->
            <div class="image-column">
                <xsl:apply-templates select="tei:graphic">
                    <xsl:with-param name="page_identifier" select="@xml:id"/>
                </xsl:apply-templates>
                <div class="highlight-overlay"></div>
            </div>
            
            <!-- 2. Colonna Testo -->
            <div class="text-column">
                <!-- Cerca in tutto il body gli elementi che puntano alle zone di QUESTA surface -->
                <xsl:apply-templates select="ancestor::tei:TEI/tei:text/tei:body//*[substring-after(@facs, '#') = $zone_ids]"/>
            </div>
        </div>
    </xsl:template>



    <!-- Template per l'immagine del facsimile -->
    <xsl:template match="tei:graphic">
        <xsl:param name="page_identifier"/>
        <img class="facsimile" id="facsimileImage-page-{$page_identifier}" src="{@url}" 
             alt="Facsimile {if ($page_identifier) then concat('Pagina ', $page_identifier) else 'della pagina'}"
             data-original-width="{normalize-space(translate(@width, 'px', ''))}"
             data-original-height="{normalize-space(translate(@height, 'px', ''))}"/>
    </xsl:template>

    <!-- Template per processare gli elementi di testo -->
    <xsl:template match="tei:p | tei:head | tei:note | tei:bibl | tei:signed">
        <xsl:variable name="element-name" select="local-name()"/>
        <xsl:element name="{if ($element-name = 'head') then 'h2' else if ($element-name = 'note') then 'div' else 'p'}">
            <xsl:if test="$element-name = 'note'">
                <xsl:attribute name="class">note</xsl:attribute>
            </xsl:if>
            <xsl:if test="@facs">
                <xsl:attribute name="facs">
                    <xsl:value-of select="@facs"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:if test="@n and $element-name = 'note'">
                <sup><xsl:value-of select="@n"/> </sup>
            </xsl:if>
            
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <!-- Gestione degli elementi semantici inline -->
    <xsl:template match="tei:persName | tei:term | tei:rs">
        <strong><xsl:apply-templates/></strong>
    </xsl:template>

    <xsl:template match="tei:orgName">
        <em><xsl:apply-templates/></em>
    </xsl:template>

    <xsl:template match="tei:title[@level='m'] | tei:title[@level='j']">
        <i><xsl:apply-templates/></i>
    </xsl:template>

    <xsl:template match="tei:placeName | tei:title[not(@level)]">
        <u><xsl:apply-templates/></u>
    </xsl:template>

    <xsl:template match="tei:ref">
        <xsl:variable name="target_id" select="substring-after(@target, '#')"/>
        <xsl:variable name="note_node" select="//tei:note[@xml:id=$target_id]"/>
        <a href="{@target}" title="{normalize-space(string-join($note_node//text(), ''))}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:foreign">
        <i><xsl:apply-templates/></i>
    </xsl:template>

    <xsl:template match="tei:emph">
        <em><xsl:apply-templates/></em>
    </xsl:template>

    <!-- Gestione del testo con parole spezzate -->
    <xsl:template match="text()">
        <xsl:analyze-string select="." regex="(\w+)-\s*$">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <!-- Rimuove tutti i <lb/> -->
    <xsl:template match="tei:lb"/>
    
    <!-- Ignora i cambi di pagina e le colonne -->
    <xsl:template match="tei:pb | tei:cb"/>
</xsl:stylesheet>