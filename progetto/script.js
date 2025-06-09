document.addEventListener('DOMContentLoaded', () => {
    const zoneDataScript = document.getElementById('zoneData');
    let allZoneData = {};

    try {
        allZoneData = JSON.parse(zoneDataScript.textContent);
    } catch (e) {
        console.error("Errore nel parsing dei dati delle zone:", e);
        return;
    }

    let activeClickedZoneId = null; // ID della zona attualmente cliccata/attiva

    // Funzione generica per disegnare un poligono di highlight
    function drawPolygonHighlight(zoneInfo, imageElement, overlayElement) {
        if (!zoneInfo || !imageElement || !overlayElement) {
            console.warn("drawPolygonHighlight: Parametri mancanti", zoneInfo, imageElement, overlayElement);
            return null;
        }

        const pointsStr = zoneInfo.points;
        const originalWidth = parseFloat(zoneInfo.originalWidth || imageElement.dataset.originalWidth);
        const originalHeight = parseFloat(zoneInfo.originalHeight || imageElement.dataset.originalHeight);

        if (isNaN(originalWidth) || isNaN(originalHeight) || originalWidth === 0 || originalHeight === 0) {
            console.error("Dimensioni originali dell'immagine non valide o non trovate per la zona:", zoneInfo);
            return null;
        }
        
        const currentImgWidth = imageElement.offsetWidth;
        const currentImgHeight = imageElement.offsetHeight;

        const scaleX = currentImgWidth / originalWidth;
        const scaleY = currentImgHeight / originalHeight;

        const coords = pointsStr.split(' ').map(p => {
            const xy = p.split(',');
            return { x: parseFloat(xy[0]) * scaleX, y: parseFloat(xy[1]) * scaleY };
        });

        // Rimuovi eventuali SVG precedenti per evitare sovrapposizioni multiple
        const existingSvg = overlayElement.querySelector('svg');
        if (existingSvg) {
            existingSvg.remove();
        }

        const svgNS = "http://www.w3.org/2000/svg";
        const svg = document.createElementNS(svgNS, "svg");
        svg.setAttribute("width", currentImgWidth + "px");
        svg.setAttribute("height", currentImgHeight + "px");
        svg.style.position = "absolute";
        svg.style.left = "0";
        svg.style.top = "0";
        svg.style.pointerEvents = "none";
        svg.classList.add('zone-highlight-svg'); // Classe per identificare l'SVG dell'highlight

        const polygon = document.createElementNS(svgNS, "polygon");
        const pointsAttr = coords.map(p => `${p.x},${p.y}`).join(' ');
        polygon.setAttribute("points", pointsAttr);
        // Applica stili direttamente o tramite CSS per .zone-highlight-svg polygon
        polygon.setAttribute("fill", "rgba(255, 223, 0, 0.4)"); // Giallo semitrasparente più scuro
        polygon.setAttribute("stroke", "rgba(255, 165, 0, 0.9)"); // Arancione più scuro
        polygon.setAttribute("stroke-width", "2");

        svg.appendChild(polygon);
        overlayElement.appendChild(svg);
        overlayElement.style.display = 'block'; // Assicura che l'overlay sia visibile
        return svg; // Restituisce l'elemento SVG creato
    }
    
    // Funzione per pulire un overlay specifico
    function clearOverlay(overlayElement) {
        if (overlayElement) {
            const svg = overlayElement.querySelector('.zone-highlight-svg');
            if (svg) {
                svg.remove();
            }
            // Non nascondere l'overlay stesso, solo il suo contenuto SVG
            // overlayElement.style.display = 'none'; 
        }
    }

    // Gestione dell'interazione per un elemento (testo o metadato)
    function setupElementInteraction(element, zoneId, imageElement, overlayElement) {
        if (!allZoneData[zoneId] || !imageElement || !overlayElement) {
            // console.warn("Dati mancanti per l'interazione:", zoneId, element);
            return;
        }

        element.addEventListener('mouseenter', () => {
            if (activeClickedZoneId !== zoneId) { // Mostra solo se non è già la zona cliccata
                 // Pulisci prima gli overlay di altre zone (non cliccate) sulla stessa immagine
                document.querySelectorAll('.page-container').forEach(pc => {
                    const ov = pc.querySelector('.highlight-overlay');
                    if (ov && ov !== overlayElement) clearOverlay(ov);
                });
                drawPolygonHighlight(allZoneData[zoneId], imageElement, overlayElement);
            }
        });

        element.addEventListener('mouseleave', () => {
            if (activeClickedZoneId !== zoneId) { // Pulisci solo se non è la zona cliccata
                clearOverlay(overlayElement);
            }
        });

        element.addEventListener('click', () => {
            // Rimuovi la classe 'text-active' da tutti gli elementi
            document.querySelectorAll('.text-active').forEach(el => el.classList.remove('text-active'));
             // Pulisci tutti gli overlay prima di impostare quello nuovo (o nessuno)
            document.querySelectorAll('.highlight-overlay').forEach(ov => clearOverlay(ov));


            if (activeClickedZoneId === zoneId) { // Se si clicca sulla zona già attiva
                activeClickedZoneId = null; // Disattiva
            } else {
                activeClickedZoneId = zoneId;
                drawPolygonHighlight(allZoneData[zoneId], imageElement, overlayElement);
                // Aggiungi 'text-active' all'elemento cliccato
                element.classList.add('text-active');
                // E a tutti gli altri elementi che puntano alla stessa zona
                document.querySelectorAll(`[data-zone-id="${zoneId}"], [facs="#${zoneId}"]`).forEach(el => el.classList.add('text-active'));
            }
        });
    }


    // 1. Interazioni per gli elementi del corpo del testo (paragrafi, note, head)
    document.querySelectorAll('.page-container').forEach(pageContainer => {
        const imageElement = pageContainer.querySelector('.facsimile');
        const overlayElement = pageContainer.querySelector('.highlight-overlay');
        
        if (!imageElement || !overlayElement) return;

        const textElements = pageContainer.querySelectorAll('.text-column [facs]');
        textElements.forEach(el => {
            const zoneId = el.getAttribute('facs').replace('#', '');
            if (imageElement.complete) {
                 setupElementInteraction(el, zoneId, imageElement, overlayElement);
            } else {
                imageElement.addEventListener('load', () => {
                    setupElementInteraction(el, zoneId, imageElement, overlayElement);
                });
            }
        });
    });

    // 2. Interazioni per i metadati dell'header
    const highlightableMetadataItems = document.querySelectorAll('.header-info .highlightable-metadata[data-zone-id]');
    // Assumiamo che i metadati dell'header si riferiscano sempre alla prima pagina
    const firstPageImage = document.getElementById('facsimileImage-page-1');
    const firstPageOverlay = document.getElementById('highlight-overlay-page-1');

    if (firstPageImage && firstPageOverlay) {
        highlightableMetadataItems.forEach(item => {
            const zoneId = item.getAttribute('data-zone-id');
             if (firstPageImage.complete) {
                setupElementInteraction(item, zoneId, firstPageImage, firstPageOverlay);
            } else {
                firstPageImage.addEventListener('load', () => {
                    setupElementInteraction(item, zoneId, firstPageImage, firstPageOverlay);
                });
            }
        });
    } else {
        if (!firstPageImage) console.warn("Immagine della prima pagina (facsimileImage-page-1) non trovata per l'highlight dei metadati.");
        if (!firstPageOverlay) console.warn("Overlay della prima pagina (highlight-overlay-page-1) non trovato per l'highlight dei metadati.");
    }
    
    // Gestione ridimensionamento finestra per l'highlight cliccato
    window.addEventListener('resize', () => {
        if (activeClickedZoneId) {
            // Trova l'immagine e l'overlay corretti per la zona attiva
            let targetImage, targetOverlay;
            
            // Prova prima a vedere se è un metadato dell'header
            if (firstPageImage && firstPageOverlay) {
                 const metaItem = document.querySelector(`.header-info .highlightable-metadata[data-zone-id="${activeClickedZoneId}"]`);
                 if (metaItem) {
                     targetImage = firstPageImage;
                     targetOverlay = firstPageOverlay;
                 }
            }

            // Altrimenti, cerca nel corpo del testo
            if (!targetImage) {
                const textItem = document.querySelector(`.text-column [facs="#${activeClickedZoneId}"]`);
                if (textItem) {
                    const pageContainer = textItem.closest('.page-container');
                    if (pageContainer) {
                        targetImage = pageContainer.querySelector('.facsimile');
                        targetOverlay = pageContainer.querySelector('.highlight-overlay');
                    }
                }
            }

            if (targetImage && targetOverlay && allZoneData[activeClickedZoneId]) {
                // Pulisci l'overlay prima di ridisegnare per evitare sovrapposizioni
                clearOverlay(targetOverlay);
                drawPolygonHighlight(allZoneData[activeClickedZoneId], targetImage, targetOverlay);
            }
        }
    });
});