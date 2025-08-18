document.addEventListener('DOMContentLoaded', () => {
    // --- PARTE 1: GESTIONE NAVIGAZIONE ARTICOLI ---
    let currentArticleIndex = 0;
    const articles = document.querySelectorAll('.article-container');
    const totalArticles = articles.length;
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    const counter = document.getElementById('article-counter');

    function showArticle(index) {
        articles.forEach((article, i) => {
            article.style.display = i === index ? 'block' : 'none';
        });
        updateNavigationControls();
        if (counter) {
            counter.textContent = `Articolo ${index + 1} di ${totalArticles}`;
        }
    }

    function changeArticle(direction) {
        const newIndex = currentArticleIndex + direction;
        if (newIndex >= 0 && newIndex < totalArticles) {
            currentArticleIndex = newIndex;
            showArticle(currentArticleIndex);
        }
    }

    function updateNavigationControls() {
        if (prevBtn) prevBtn.disabled = currentArticleIndex === 0;
        if (nextBtn) nextBtn.disabled = currentArticleIndex === totalArticles - 1;
    }

    if (totalArticles > 0) {
        if (prevBtn) prevBtn.addEventListener('click', () => changeArticle(-1));
        if (nextBtn) nextBtn.addEventListener('click', () => changeArticle(1));
        showArticle(0); // Mostra il primo articolo all'avvio
    } else if (counter) {
        if (prevBtn) prevBtn.style.display = 'none';
        if (nextBtn) nextBtn.style.display = 'none';
        counter.textContent = 'Nessun articolo trovato.';
    }

    // --- PARTE 2: GESTIONE HIGHLIGHTING ---
    const zoneDataScript = document.getElementById('zoneData');
    let allZoneData = {};

    try {
        if (zoneDataScript) {
            allZoneData = JSON.parse(zoneDataScript.textContent);
        } else {
            console.warn("Elemento <script id='zoneData'> non trovato. L'highlight non funzionerà.");
            return;
        }
    } catch (e) {
        console.error("Errore nel parsing dei dati delle zone:", e);
        return;
    }

    let activeClickedZoneId = null;
    let activeOverlay = null;

    function drawPolygonHighlight(zoneInfo, imageElement, overlayElement) {
        if (!zoneInfo || !imageElement || !overlayElement) return null;

        const pointsStr = zoneInfo.points;
        const originalWidth = parseFloat(zoneInfo.originalWidth || imageElement.dataset.originalWidth);
        const originalHeight = parseFloat(zoneInfo.originalHeight || imageElement.dataset.originalHeight);

        if (isNaN(originalWidth) || isNaN(originalHeight) || originalWidth === 0 || originalHeight === 0) {
             console.error("Dimensioni originali dell'immagine non valide per la zona:", zoneInfo);
             return null;
        }
        
        const currentImgWidth = imageElement.offsetWidth;
        const currentImgHeight = imageElement.offsetHeight;
        const scaleX = currentImgWidth / originalWidth;
        const scaleY = currentImgHeight / originalHeight;

        const coords = pointsStr.split(' ').map(p => {
            const [x, y] = p.split(',');
            return { x: parseFloat(x) * scaleX, y: parseFloat(y) * scaleY };
        });

        clearOverlay(overlayElement); // Pulisce prima di disegnare

        const svgNS = "http://www.w3.org/2000/svg";
        const svg = document.createElementNS(svgNS, "svg");
        svg.setAttribute("width", currentImgWidth);
        svg.setAttribute("height", currentImgHeight);
        svg.style.position = "absolute";
        svg.style.left = "0";
        svg.style.top = "0";
        svg.style.pointerEvents = "none";
        svg.classList.add('zone-highlight-svg');

        const polygon = document.createElementNS(svgNS, "polygon");
        polygon.setAttribute("points", coords.map(p => `${p.x},${p.y}`).join(' '));
        polygon.setAttribute("fill", "rgba(255, 223, 0, 0.4)");
        polygon.setAttribute("stroke", "rgba(255, 165, 0, 0.9)");
        polygon.setAttribute("stroke-width", "2");

        svg.appendChild(polygon);
        overlayElement.appendChild(svg);
        return svg;
    }
    
    function clearOverlay(overlayElement) {
        if (overlayElement) {
            const svg = overlayElement.querySelector('.zone-highlight-svg');
            if (svg) svg.remove();
        }
    }

    function setupElementInteraction(element, zoneId, imageElement, overlayElement) {
        if (!allZoneData[zoneId] || !imageElement || !overlayElement) return;

        element.addEventListener('mouseenter', () => {
            if (activeClickedZoneId !== zoneId) {
                drawPolygonHighlight(allZoneData[zoneId], imageElement, overlayElement);
            }
        });

        element.addEventListener('mouseleave', () => {
            if (activeClickedZoneId !== zoneId) {
                clearOverlay(overlayElement);
            }
        });

        element.addEventListener('click', (e) => {
            e.stopPropagation();
            // Rimuove la classe attiva da tutti gli elementi
            document.querySelectorAll('.text-active').forEach(el => el.classList.remove('text-active'));
            // Pulisce tutti gli overlay
            document.querySelectorAll('.highlight-overlay').forEach(ov => clearOverlay(ov));
            
            if (activeClickedZoneId === zoneId) {
                // Se si clicca di nuovo sullo stesso elemento, lo si disattiva
                activeClickedZoneId = null;
                activeOverlay = null;
            } else {
                // Altrimenti, si attiva il nuovo elemento
                activeClickedZoneId = zoneId;
                activeOverlay = overlayElement; // Salva l'overlay attivo
                drawPolygonHighlight(allZoneData[zoneId], imageElement, overlayElement);
                // Aggiunge la classe attiva a tutti gli elementi con lo stesso zoneId
                document.querySelectorAll(`[data-zone-id="${zoneId}"], [facs="#${zoneId}"]`).forEach(el => {
                    el.classList.add('text-active');
                });
            }
        });
    }

    // Itera su tutti gli elementi interattivi di tutti gli articoli
    document.querySelectorAll('[facs], [data-zone-id]').forEach(el => {
        const zoneId = el.getAttribute('facs')?.replace('#', '') || el.getAttribute('data-zone-id');
        if (!zoneId) return;

        const pageContainer = el.closest('.page-container');
        if (!pageContainer) return; // Se l'elemento non è in una pagina, ignora (es. metadati)

        const imageElement = pageContainer.querySelector('.facsimile');
        const overlayElement = pageContainer.querySelector('.highlight-overlay');
        
        if (imageElement && overlayElement) {
            if (imageElement.complete) {
                setupElementInteraction(el, zoneId, imageElement, overlayElement);
            } else {
                imageElement.addEventListener('load', () => {
                    setupElementInteraction(el, zoneId, imageElement, overlayElement);
                });
            }
        }
    });

    // Gestione interattività anche per i metadati (che si riferiscono alla prima immagine dell'articolo)
    document.querySelectorAll('.article-container').forEach(article => {
        const highlightableMetadata = article.querySelectorAll('.header-info .highlightable-metadata[data-zone-id]');
        const firstImage = article.querySelector('.facsimile');
        const firstOverlay = article.querySelector('.highlight-overlay');

        if (firstImage && firstOverlay) {
            highlightableMetadata.forEach(item => {
                const zoneId = item.getAttribute('data-zone-id');
                if (zoneId) {
                     if (firstImage.complete) {
                        setupElementInteraction(item, zoneId, firstImage, firstOverlay);
                    } else {
                        firstImage.addEventListener('load', () => {
                            setupElementInteraction(item, zoneId, firstImage, firstOverlay);
                        });
                    }
                }
            });
        }
    });

    window.addEventListener('resize', () => {
        if (activeClickedZoneId && activeOverlay) {
            const imageElement = activeOverlay.closest('.image-column').querySelector('.facsimile');
            if (imageElement && allZoneData[activeClickedZoneId]) {
                drawPolygonHighlight(allZoneData[activeClickedZoneId], imageElement, activeOverlay);
            }
        }
    });
});