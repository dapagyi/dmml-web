(() => {
    'use strict'

    const VISUALIZATIONS_URL = "https://dmml.dapagyi.dedyn.io/static/visualizations.json";
    const container = document.getElementById('visualizations-container');
    const last_updated = document.getElementById('last-updated');

    function fetchVisualizations() {
        return axios.get(VISUALIZATIONS_URL)
            .then(function (response) {
                const date = new Date(response.data.last_updated);
                last_updated.textContent = date.toLocaleString("hu-HU", {
                    timeZone: "Europe/Budapest",
                    hour: "2-digit",
                    minute: "2-digit",
                    year: "numeric",
                    month: "2-digit",
                    day: "2-digit"
                });
                return response.data.visualizations || [];
            })
            .catch(function (error) {
                console.error("Error fetching visualizations:", error);
                return [];
            });
    }

    function renderVisualizations(visualizations, container) {
        container.innerHTML = '';

        if (visualizations.length === 0) {
            container.innerHTML = '<p class="text-center">No visualizations available.</p>';
            return;
        }

        visualizations.sort(() => Math.random() - 0.5);
        visualizations.sort((a, b) => {
            const isDavidA = a.uploader.includes('Dávid');
            const isDavidB = b.uploader.includes('Dávid');
            if (isDavidA === isDavidB) return 0;
            return isDavidA ? 1 : -1;
        });
        visualizations.sort((a, b) => {
            const isHighlightedA = a.is_highlighted ?? false;
            const isHighlightedB = b.is_highlighted ?? false;
            if (isHighlightedA === isHighlightedB) return 0;
            return isHighlightedA ? -1 : 1;
        });

        visualizations.forEach((viz) => {
            if (!viz.title || !viz.source || !viz.url) {
                return;
            }


            let display_name = viz.uploader ? viz.uploader.split(' ').map(n => n.charAt(0).toUpperCase() + '.').join(' ') : '';

            // HOTFIX: For students with digraphs at the beginning of their names
            // TODO: Refactor.
            if (display_name === "S. M.") {
                display_name = "Sz. M.";
            }
            else if (display_name === "G. E.") {
                display_name = "Gy. E.";
            }
            else if (display_name === "T. Z.") {
                display_name = "T. Zs.";
            }
            else if (display_name === "Z.") {
                display_name = "Zs.";
            }

            const is_highlighted = viz.is_highlighted ?? false;

            const card = document.createElement('div');
            card.className = "visualization-card col-sm-6 col-md-4 col-lg-3 mb-4";
            card.innerHTML = `
                <div class="card border ${is_highlighted ? 'border-success' : ''}">
                    ${is_highlighted ? '<div class="card-header">Featured</div>' : ''}
                    <div class="card-body d-flex flex-column">
                        ${viz.preview_url ? `<img src="${viz.preview_url}" class="card-img-top" alt="${viz.title}">` : ''}
                        <p class="card-title fw-semibold">${viz.title}</p>
                        <p class="card-subtitle mb-3"><i class="bi bi-link-45deg me-1"></i>Source: ${viz.source}</p>
                        <div class="mt-auto d-flex justify-content-between align-items-center">
                            <a href="${viz.url}" target="_blank" class="btn ${is_highlighted ? 'btn-success' : 'btn-outline-primary'} stretched-link">Open</a>
                            ${display_name ? `<small class="text-muted"><i class="bi bi-person me-1"></i><i>${display_name}</i></small>` : ''}
                        </div>
                    </div>
                </div>
            `;
            container.appendChild(card);
        });




    }

    fetchVisualizations()
        .then(visualizations => renderVisualizations(visualizations, container))
        .then(() => {
            const images = container.querySelectorAll('img');
            const imagePromises = Array.from(images).map(img => {
                if (img.complete) return Promise.resolve();
                return new Promise(resolve => {
                    img.onload = img.onerror = resolve;
                });
            });
            return Promise.all(imagePromises);
        })
        .then(() => {
            new Masonry(container, {
                itemSelector: '.visualization-card',
                percentPosition: true
            });
        });

})();