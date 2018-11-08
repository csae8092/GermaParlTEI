<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
version="2.0">
    <xsl:output indent="yes" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
    
<!--    by peter.andorfer@oeaw.ac.at; creates a valid tei document-->
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="date">
        <xsl:value-of select="//date[@when]/text()[1]"/>
    </xsl:variable>
    
    <xsl:variable name="period">
        <xsl:value-of select="//legislativePeriod/text()"/>
    </xsl:variable>

    <xsl:variable name="session">
        <xsl:value-of select="//sessionNo/text()"/>
    </xsl:variable>
    
    <xsl:template match="teiHeader">
        <teiHeader>
            <fileDesc>
                <titleStmt xmlns="http://www.tei-c.org/ns/1.0">
                    <title type="main">Plenarprotokoll der Sitzung vom <date><xsl:attribute name="when"><xsl:value-of select="$date"/></xsl:attribute></date><xsl:value-of select="$date"/></title>
                    <title type="sub" subtype="period" n="{$period}">Periode: <xsl:value-of select="$period"/></title>
                    <title type="sub" subtype="session" n="{$session}">Sitzung: <xsl:value-of select="$session"/></title>
                </titleStmt>
                <publicationStmt>
                    <publisher>Austrian Centre for Digital Humanities, Austrian Academy of
                        Sciences</publisher>
                    <pubPlace ref="http://d-nb.info/gnd/4066009-6">Vienna</pubPlace>
                    <availability>
                        <licence>
                            <p>
                                Blaette, Andreas (2017): GermaParl. Corpus of Plenary Protocols of the German Bundestag. TEI files, availables at: https://github.com/PolMine/GermaParlTEI.
                            </p>
                            <p>
                                The data comes with a CLARIN PUB+BY+NC+SA license. That means:</p><p>
                                PUB - The language resource can be distributed publicly.
                                BY - Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any wa$
                                NC - NonCommercial — You may not use the material for commercial purposes.
                                SA - ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
                                The CLARIN licenses are modelled on the Creative Commons licenses. See the CC Attribution-NonCommercial-ShareAlike 3.0 Unported License for further explanations.
                            </p>
                        </licence >
                    </availability>
                </publicationStmt>
                <sourceDesc>
                    <p>The original data was taken from https://github.com/PolMine/GermaParlTEI.</p>
                </sourceDesc>
            </fileDesc>
        </teiHeader>
        
    </xsl:template>
    
    <xsl:template match="div[@type='agenda_item']">
        <div>
            <xsl:attribute name="type">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
            <xsl:if test="exists(./@subtype)">
                <xsl:attribute name="subtype">
                    <xsl:value-of select="./@what"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="exists(./@what)">
                   <head>
                    <xsl:value-of select="./@desc"/>
                </head>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="sp">
        <sp>
            <xsl:attribute name="who">
                <xsl:value-of select="./@who"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </sp>
    </xsl:template>
    <xsl:template match="speaker">
        <xsl:variable name="who">
            <xsl:value-of select="parent::sp[last()]/@who"/>
        </xsl:variable>
        <xsl:variable name="xmlid">
            <xsl:value-of select="concat('#per__', translate(lower-case(replace($who, ' ', '-')), 'äöü', 'aou'))"/>
        </xsl:variable>
        <speaker>
            <rs type="person">
                <xsl:attribute name="ref">
                    <xsl:value-of select="$xmlid"/>
                </xsl:attribute>
                <xsl:attribute name="role">
                    <xsl:value-of select="parent::sp[last()]/@role"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </rs>
        </speaker>
    </xsl:template>
    
    <xsl:template match="text">
        <text>
            <xsl:apply-templates/>
            <back>
                <listPerson>
                    <xsl:for-each-group select="//sp" group-by="./@who">
                        <xsl:variable name="who">
                            <xsl:value-of select="data(./@who)"/>
                        </xsl:variable>
                        <xsl:variable name="xmlid">
                            <xsl:value-of select="concat('per__', translate(lower-case(replace($who, ' ', '-')), 'äöü', 'aou'))"/>
                        </xsl:variable>
                        <person>
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="$xmlid"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains($who, '.')">
                                    <persName>
                                        <surname>
                                            <xsl:value-of select="tokenize($who, ' ')[last()]"/>
                                        </surname>
                                        <forename>
                                            <xsl:value-of select="subsequence(tokenize($who, ' '), 2, count(tokenize($who, ' '))-2)"/>
                                        </forename>
                                        <roleName><xsl:value-of select="tokenize($who, ' ')[1]"/></roleName>
                                    </persName>
                                </xsl:when>
                                <xsl:otherwise>
                                    <persName>
                                        <surname>
                                            <xsl:value-of select="tokenize($who, ' ')[last()]"/>
                                        </surname>
                                        <forename>
                                            <xsl:value-of select="subsequence(tokenize($who, ' '), 1, count(tokenize($who, ' '))-1)"/>
                                        </forename>
                                    </persName>
                                </xsl:otherwise>
                            </xsl:choose>
                            <affiliation>
                                <rs type="org" subtype="party">
                                    <xsl:attribute name="ref">
                                        <xsl:value-of select="concat('#org__', ./@party)"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="./@party"/></rs> 
                            </affiliation>
                            <xsl:choose>
                                <xsl:when test="data(./@position) eq 'NA'"/>
                                <xsl:otherwise>
                                    <occupation>
                                        <xsl:attribute name="notBefore">
                                            <xsl:value-of select="$date"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="notAfter">
                                            <xsl:value-of select="$date"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="./@position"/>
                                    </occupation>
                                </xsl:otherwise>
                            </xsl:choose>
                        </person> 
                    </xsl:for-each-group>
                    <!--<xsl:for-each select="//sp">
                        <person>
                            <persName>
                                <xsl:value-of select="./@who"/>
                            </persName>
                            <affiliation>
                                <xsl:value-of select="./@party"/>
                            </affiliation>
                            <affiliation>
                                <xsl:value-of select="./@position"/>
                            </affiliation>
                            
                        </person>
                    </xsl:for-each>-->
                </listPerson>
            </back>
        </text>
    </xsl:template>
    
    
    <xsl:template match="*">
        <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    
    

</xsl:stylesheet>