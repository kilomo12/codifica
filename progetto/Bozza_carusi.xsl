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
          <xsl:value-of select=".//tei:titleStmt/tei:title[@type ='article']"/>
        </title>
        <link rel="stylesheet" type="text/css" href="stile.css"/>
      </head>
      <body>
        <div class="header-info">
          <h2>Metadati</h2>
          <p><strong>Titolo: </strong> <xsl:value-of select=".//tei:titleStmt/tei:title[@type='article']"/></p>
          <p><strong>Autore: </strong> <xsl:value-of select=".//tei:titleStmt/tei:author"/></p>
          <p><strong>Editor: </strong> <xsl:value-of select=".//tei:titleStmt/tei:editor"/></p>
          <p><strong>Ente responsabile: </strong> <xsl:value-of select=".//tei:titleStmt/tei:principal"/></p>
          <p><strong>Responsabilità:</strong> 
            <xsl:value-of select=".//tei:respStmt/tei:resp"/> - 
            <xsl:value-of select=".//tei:respStmt/tei:name"/>
          </p>
          <p><strong>Casa editrice: </strong> <xsl:value-of select=".//tei:publicationStmt/tei:publisher"/></p>
          <p><strong>Luogo di pubblicazione: </strong> <xsl:value-of select=".//tei:publicationStmt/tei:pubPlace"/></p>
          <p><strong>Data: </strong> <xsl:value-of select=".//tei:publicationStmt/tei:date/@when"/></p>
          <p><strong>Volume: </strong> <xsl:value-of select=".//tei:seriesStmt/tei:biblScope[@unit='volume']"/></p>
          <p><strong>Numero: </strong> <xsl:value-of select=".//tei:publicationStmt/tei:idno[@type='issue']"/></p>
          <p><strong>Pagine: </strong> <xsl:value-of select=".//tei:seriesStmt/tei:biblScope[@unit='pages']"/></p>
          <p><strong>Fonte: </strong> <xsl:value-of select=".//tei:sourceDesc/tei:p"/></p>
          <p><strong>Lingua: </strong> <xsl:value-of select=".//tei:profileDesc/tei:langUsage/tei:language"/></p>
          <p><strong>Descrizione della codifica: </strong> <xsl:value-of select=".//tei:encodingDesc/tei:p"/></p>
        </div>

        <xsl:apply-templates select="tei:text/tei:body/tei:div"/>

        <script id="zoneData" type="application/json">
          {
            <xsl:for-each select="tei:facsimile/tei:surface/tei:zone">
              "<xsl:value-of select="@xml:id"/>": {
                "points": "<xsl:value-of select="normalize-space(@points)"/>",
                "originalWidth": "<xsl:value-of select="normalize-space(translate(../tei:graphic/@width, 'px', ''))"/>",
                "originalHeight": "<xsl:value-of select="normalize-space(translate(../tei:graphic/@height, 'px', ''))"/>"
              }<xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
          }
        </script>
        <script src="script.js"></script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="tei:text/tei:body/tei:div">
    <xsl:variable name="page_n" select="if (@n) then @n else position()"/>
    <xsl:variable name="surface_ref" select="tei:pb/@facs"/>
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
        <xsl:apply-templates select="*[self::tei:head or self::tei:p or self::tei:note]"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="tei:graphic">
    <xsl:param name="page_identifier"/>
    <img class="facsimile" id="facsimileImage-page-{$page_identifier}" src="{@url}" alt="Facsimile Page {$page_identifier}"
         data-original-width="{normalize-space(translate(@width, 'px', ''))}"
         data-original-height="{normalize-space(translate(@height, 'px', ''))}"/>
  </xsl:template>

  <xsl:template match="tei:p">
    <p>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="tei:note">
    <div class="note">
        <xsl:copy-of select="@*"/>
        <sup><xsl:value-of select="@n"/></sup>
        <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:head">
    <h2>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="tei:persName | tei:term">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="tei:orgName">
    <em><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="tei:placeName | tei:title">
     <xsl:choose>
        <xsl:when test="@level='j'">
            <i><xsl:apply-templates/></i> <!-- Italic for journal titles -->
        </xsl:when>
        <xsl:otherwise>
            <u><xsl:apply-templates/></u> <!-- Underline for others -->
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:ref">
    <xsl:variable name="target_id" select="substring-after(@target, '#')"/>
    <xsl:variable name="note_content" select="//tei:note[@xml:id=$target_id]"/>
    <a href="{@target}" title="{normalize-space($note_content)}">
        <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="tei:date">
      <xsl:value-of select="@when"/>
  </xsl:template>
  
  <xsl:template match="tei:pb"/>
</xsl:stylesheet>