document.addEventListener('DOMContentLoaded', () => {
  // Carica i dati delle zone
  const zoneDataScript = document.getElementById('zoneData');
  let zonesData = {};
  
  try {
    zonesData = JSON.parse(zoneDataScript.textContent);
  } catch (e) {
    console.error("Error parsing zone data:", e);
    return;
  }

  let activeZoneId = null;
  let activeHighlight = null;

  // Inizializza tutte le pagine
  document.querySelectorAll('.page-container').forEach(pageContainer => {
    const facsimileImage = pageContainer.querySelector('.facsimile');
    const highlightOverlay = pageContainer.querySelector('.highlight-overlay');
    const textColumn = pageContainer.querySelector('.text-column');

    if (!facsimileImage || !highlightOverlay || !textColumn) {
      return;
    }

    // Configura le interazioni quando l'immagine è caricata
    const setupInteractions = () => {
      // Elementi interattivi nel testo
      const interactiveElements = textColumn.querySelectorAll('[facs]');
      
      interactiveElements.forEach(element => {
        const zoneId = element.getAttribute('facs').replace('#', '');
        
        // Mouse enter - mostra highlight
        element.addEventListener('mouseenter', () => {
          if (activeZoneId !== zoneId) {
            showHighlight(zoneId, facsimileImage, highlightOverlay);
          }
        });

        // Click - attiva/disattiva highlight persistente
        element.addEventListener('click', () => {
          if (activeZoneId === zoneId) {
            clearActiveHighlight();
          } else {
            setActiveHighlight(zoneId, facsimileImage, highlightOverlay);
          }
        });
      });

      // Mouse leave - nascondi highlight solo se non è quello attivo
      textColumn.addEventListener('mouseleave', () => {
        if (!activeZoneId) {
          clearHighlights(highlightOverlay);
        }
      });
    };

    // Gestione caricamento immagine
    if (facsimileImage.complete) {
      setupInteractions();
    } else {
      facsimileImage.addEventListener('load', setupInteractions);
      facsimileImage.addEventListener('error', () => {
        console.error('Error loading facsimile image:', facsimileImage.src);
      });
    }
  });

  // Gestione ridimensionamento finestra
  window.addEventListener('resize', () => {
    if (activeZoneId && activeHighlight) {
      const { facsimileImage, highlightOverlay } = activeHighlight;
      showHighlight(activeZoneId, facsimileImage, highlightOverlay, false);
    }
  });

  // Funzione per mostrare un highlight
  function showHighlight(zoneId, facsimileImage, highlightOverlay, resetActive = true) {
    const zoneInfo = zonesData[zoneId];
    if (!zoneInfo) return;

    // Calcola le dimensioni
    const originalWidth = parseFloat(facsimileImage.dataset.originalWidth || zoneInfo.originalWidth);
    const originalHeight = parseFloat(facsimileImage.dataset.originalHeight || zoneInfo.originalHeight);
    const scaleX = facsimileImage.offsetWidth / originalWidth;
    const scaleY = facsimileImage.offsetHeight / originalHeight;

    // Processa i punti della zona
    const points = zoneInfo.points.trim().split(/\s+/).map(pair => {
      const [x, y] = pair.split(',').map(Number);
      return { x, y };
    });

    // Calcola il rettangolo di delimitazione
    const xCoords = points.map(p => p.x * scaleX);
    const yCoords = points.map(p => p.y * scaleY);
    const left = Math.min(...xCoords);
    const top = Math.min(...yCoords);
    const width = Math.max(...xCoords) - left;
    const height = Math.max(...yCoords) - top;

    // Crea o aggiorna l'highlight
    let highlight = highlightOverlay.querySelector(`.zone-highlight[data-zone-id="${zoneId}"]`);
    if (!highlight) {
      highlight = document.createElement('div');
      highlight.className = 'zone-highlight';
      highlight.dataset.zoneId = zoneId;
      highlightOverlay.appendChild(highlight);
    }

    // Applica lo stile
    highlight.style.left = `${left}px`;
    highlight.style.top = `${top}px`;
    highlight.style.width = `${width}px`;
    highlight.style.height = `${height}px`;
    highlight.classList.add('active');

    // Resetta gli highlight attivi se richiesto
    if (resetActive) {
      document.querySelectorAll('.zone-highlight.active').forEach(el => {
        if (el !== highlight) el.classList.remove('active');
      });
    }

    return highlight;
  }

  // Imposta un highlight come attivo
  function setActiveHighlight(zoneId, facsimileImage, highlightOverlay) {
    clearActiveHighlight();
    
    const highlight = showHighlight(zoneId, facsimileImage, highlightOverlay);
    if (!highlight) return;

    activeZoneId = zoneId;
    activeHighlight = { facsimileImage, highlightOverlay };

    // Aggiungi classe attiva agli elementi di testo corrispondenti
    document.querySelectorAll(`[facs="#${zoneId}"]`).forEach(el => {
      el.classList.add('text-active');
    });
  }

  // Cancella l'highlight attivo
  function clearActiveHighlight() {
    if (!activeZoneId) return;

    // Rimuovi gli highlight visivi
    document.querySelectorAll(`.zone-highlight[data-zone-id="${activeZoneId}"]`).forEach(el => {
      el.classList.remove('active');
    });

    // Rimuovi le classi attive dal testo
    document.querySelectorAll(`[facs="#${activeZoneId}"]`).forEach(el => {
      el.classList.remove('text-active');
    });

    activeZoneId = null;
    activeHighlight = null;
  }

  // Cancella tutti gli highlight temporanei
  function clearHighlights(highlightOverlay) {
    highlightOverlay.querySelectorAll('.zone-highlight:not(.persistent)').forEach(el => {
      el.classList.remove('active');
    });
  }
});