<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Template principale per l'intero documento TEI -->
    <xsl:template match="/tei:TEI">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='article']"/>
                </title>
                <link rel="stylesheet" type="text/css" href="stile.css"/>
            </head>
            <body>
                <!-- Sezione Metadati -->
                <div class="header-info">
                    <h2>Metadati</h2>
                    <p><strong>Titolo: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='article']"/></p>
                    <p><strong>Autore: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName | tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[not(tei:persName)]"/></p>
                    <p><strong>Editore (ruolo): </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor/tei:name | tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[not(tei:name)]"/></p>
                    <p><strong>Ente responsabile: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:principal/tei:orgName | tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:principal[not(tei:orgName)]"/></p>
                    <p><strong>Responsabilità: </strong>
                        <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:resp"/> -
                        <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:name/tei:persName | tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:name[not(tei:persName)]"/>
                    </p>
          
                    <p>
                        <strong>Casa editrice: </strong>
                        <xsl:value-of select="tei:teiHeader//tei:publicationStmt/tei:publisher/tei:name[@type='publication']"/>
                    </p>
                    <p><strong>Luogo di pubblicazione: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:placeName | tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace[not(tei:placeName)]"/></p>
                    <p><strong>Data: </strong>
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
                    <p><strong>Volume: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:biblScope[@unit='volume']"/></p> <!-- Mantenuto se usato in altri XML -->
                    <p><strong>Numero: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='issue']"/></p>
                    <p><strong>Pagine: </strong> <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='pages']"/></p>
                    <p><strong>Fonte: </strong> <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr | tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:p"/></p>
                    <p><strong>Lingua: </strong> <xsl:value-of select="tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language/@ident | tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language[not(@ident)]"/></p>
                    <p><strong>Descrizione della codifica: </strong> <xsl:value-of select="tei:teiHeader/tei:encodingDesc/tei:p"/></p>
                </div>

                <!-- Applica i template per le divisioni del corpo del testo -->
                <!-- Il tuo XML usa tei:text/tei:body/tei:div[@type='review']/tei:div per le pagine -->
                <xsl:apply-templates select="tei:text/tei:body/tei:div[@type='review']/tei:div"/>

                <!--
                    LA SEZIONE SEGUENTE PER GENERARE I DATI DELLE ZONE È COMMENTATA.
                    DECOMMENTALA QUANDO IL TUO FILE XML CONTIENE LA SEZIONE <facsimile>
                    CON GLI ELEMENTI <surface> E <zone> CORRETTAMENTE DEFINITI.
                -->
                <!--
                <script id="zoneData" type="application/json">
                    {
                        <xsl:for-each select="tei:facsimile/tei:surface/tei:zone">
                            "<xsl:value-of select="@xml:id"/>": {
                                "points": "<xsl:value-of select="normalize-space(@points)"/>",
                                "originalWidth": "<xsl:value-of select="normalize-space(translate(ancestor::tei:surface/tei:graphic/@width, 'px', ''))"/>",
                                "originalHeight": "<xsl:value-of select="normalize-space(translate(ancestor::tei:surface/tei:graphic/@height, 'px', ''))"/>"
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                    }
                </script>
                -->

                <!-- Includi lo script JavaScript principale -->
                <script src="script.js"></script>
            </body>
        </html>
    </xsl:template>

    <!-- Template per ogni divisione (pagina) nel corpo del testo -->
    <!-- Modificato per corrispondere a tei:text/tei:body/tei:div[@type='review']/tei:div -->
    <xsl:template match="tei:text/tei:body/tei:div[@type='review']/tei:div">
        <!-- Cerca il pb per n di pagina e facs. Se non c'è @n sul div, usa position() come fallback -->
        <xsl:variable name="page_pb" select="tei:pb"/>
        <xsl:variable name="page_n" select="if ($page_pb/@n) then $page_pb/@n else (if (@n) then @n else position())"/>
        <xsl:variable name="surface_ref" select="$page_pb/@facs"/>
        <xsl:variable name="surface_id" select="if (starts-with($surface_ref, '#')) then substring-after($surface_ref, '#') else $surface_ref"/>
        <xsl:variable name="current_surface" select="/tei:TEI/tei:facsimile/tei:surface[@xml:id = $surface_id]"/>

        <div class="container page-container" id="page-container-{$page_n}">
            <xsl:if test="$current_surface">
                <div class="image-column">
                    <xsl:apply-templates select="$current_surface/tei:graphic">
                        <xsl:with-param name="page_identifier" select="$page_n"/>
                    </xsl:apply-templates>
                    <div class="highlight-overlay" id="highlight-overlay-page-{$page_n}"></div>
                </div>
            </xsl:if>
        <div class="text-column" id="text-column-page-{$page_n}">
            <!-- Processa elementi di testo come head, p, note, bibl, e div type="col" -->
            <xsl:apply-templates select="*[self::tei:head or self::tei:p or self::tei:note or self::tei:bibl or self::tei:div[@type='col']]"/>
        </div>
        </div>
    </xsl:template>

    <!-- Template per gestire le <div type="col"> -->
    <xsl:template match="tei:div[@type='col']">
        <div class="text-column-internal"> <!-- Puoi aggiungere classi CSS se necessario per le colonne interne -->
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Template per l'immagine del facsimile -->
    <xsl:template match="tei:graphic">
        <xsl:param name="page_identifier"/>
        <img class="facsimile" id="facsimileImage-page-{$page_identifier}" src="{@url}" alt="Facsimile Pagina {$page_identifier}"
            data-original-width="{normalize-space(translate(@width, 'px', ''))}"
            data-original-height="{normalize-space(translate(@height, 'px', ''))}"/>
    </xsl:template>

    <!-- Template per ricostruire le parole spezzate (word join) -->
    <xsl:template match="tei:w[@part='I' and @xml:id]">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="second_part_node" select="//tei:w[@part='F' and @corresp=concat('#', $id)]"/>
        <xsl:element name="w">
            <xsl:copy-of select="@*[not(name()='part') and not(name()='corresp')]"/>
            <xsl:value-of select="."/>
            <xsl:if test="$second_part_node">
                <xsl:value-of select="$second_part_node/text()"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:w[@part='F' and @corresp]"/>

    <!-- Template per ricostruire i paragrafi spezzati -->
    <xsl:template match="tei:p[@part='I' and @xml:id]">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="second_part_node" select="//tei:p[@part='F' and @corresp=concat('#', $id)]"/>
        <xsl:element name="p">
            <xsl:copy-of select="@*[not(name()='part') and not(name()='corresp')]"/>
            <xsl:apply-templates/>
            <xsl:if test="$second_part_node">
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="$second_part_node/node()"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:p[@part='F' and @corresp]"/>

    <!-- Template generico per i paragrafi non spezzati -->
    <xsl:template match="tei:p">
        <p>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Template per le note -->
    <xsl:template match="tei:note">
        <div class="note">
            <xsl:copy-of select="@*"/>
            <sup><xsl:value-of select="@n"/></sup>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Template per le intestazioni -->
    <xsl:template match="tei:head">
        <h2>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <!-- Template per bibl nel corpo del testo -->
    <xsl:template match="tei:text//tei:bibl">
        <div class="bibliographical-entry-inline"> <!-- Usiamo div invece di p per contenere altri blocchi o per flessibilità -->
            <xsl:copy-of select="@facs | @xml:id"/> <!-- Copia facs e xml:id se presenti -->
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Template per formattare la fonte dai metadati -->
    <xsl:template match="tei:sourceDesc/tei:biblStruct/tei:monogr">
        <xsl:if test="tei:author/tei:persName">
            <xsl:value-of select="tei:author/tei:persName"/>,
        </xsl:if>
        <xsl:if test="tei:title">
            <i><xsl:value-of select="tei:title"/></i>.
        </xsl:if>
        <xsl:if test="tei:imprint/tei:pubPlace/tei:placeName">
            <xsl:value-of select="tei:imprint/tei:pubPlace/tei:placeName"/>:
        </xsl:if>
        <xsl:if test="tei:imprint/tei:publisher/tei:name">
            <xsl:value-of select="tei:imprint/tei:publisher/tei:name"/>,
        </xsl:if>
        <xsl:value-of select="tei:imprint/tei:date/@when | tei:imprint/tei:date"/>.
    </xsl:template>
    <!-- Fallback per tei:sourceDesc/tei:p -->
    <xsl:template match="tei:sourceDesc/tei:p">
        <xsl:value-of select="."/>
    </xsl:template>


    <!-- Template per rs (referencing string) -->
    <xsl:template match="tei:rs">
       <span class="{concat('rs-', @type)}">
            <xsl:if test="@subtype">
                <xsl:attribute name="class" select="concat('rs-', @type, ' rs-subtype-', @subtype)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

  <!-- Template per name -->
    <xsl:template match="tei:name">
        <span> <!-- Elemento generico, si può specializzare con classi se type è significativo -->
            <xsl:if test="@type">
                <xsl:attribute name="class" select="concat('name-', @type)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xsl:template match="tei:persName | tei:term">
        <strong><xsl:apply-templates/></strong>
    </xsl:template>

    <xsl:template match="tei:orgName">
        <em><xsl:apply-templates/></em>
    </xsl:template>

    <xsl:template match="tei:placeName | tei:title">
        <xsl:choose>
            <xsl:when test="self::tei:title and (@level='m' or @level='j' or @level='s' or @level='u' or @level='a')">
                <i><xsl:apply-templates/></i> <!-- Titoli di monografie, journal, series, unit, analytic in corsivo -->
            </xsl:when>
            <xsl:when test="self::tei:placeName">
                <u><xsl:apply-templates/></u> <!-- Nomi di luogo sottolineati -->
            </xsl:when>
            <xsl:otherwise> <!-- Altri titoli (es. senza @level) o altri elementi -->
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:ref">
        <xsl:variable name="target_id" select="substring-after(@target, '#')"/>
        <xsl:variable name="note_node" select="//tei:note[@xml:id=$target_id]"/>
        <a href="{@target}" title="{normalize-space(string-join($note_node//text(), ''))}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:date">
        <xsl:variable name="currentDateNode" select="."/>
        <xsl:choose>
            <xsl:when test="normalize-space($currentDateNode) and not($currentDateNode/@when)">
                <xsl:value-of select="$currentDateNode"/>
            </xsl:when>
            <xsl:when test="normalize-space($currentDateNode) and $currentDateNode/@when">
                <xsl:value-of select="$currentDateNode"/>
            </xsl:when>
            <xsl:when test="$currentDateNode/@when">
                <xsl:value-of select="$currentDateNode/@when"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:pb"/>
</xsl:stylesheet>