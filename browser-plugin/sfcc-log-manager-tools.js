// ==UserScript==
// @name         SFCC Log Manager tools
// @namespace    http://tampermonkey.net/
// @version      1.0.0
// @description  Tools for improving Log Manager usage, such as making related attributes searchable and emails clickable.
// @author       Lawrence Walters
// @match        https://logcenter-us.visibility.commercecloud.salesforce.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=salesforce.com
// @grant        none
// @updateURL    https://raw.githubusercontent.com/lawrencewalters/sfcc/refs/heads/main/browser-plugin/sfcc-log-manager-tools.js
// @downloadURL  https://raw.githubusercontent.com/lawrencewalters/sfcc/refs/heads/main/browser-plugin/sfcc-log-manager-tools.js
// ==/UserScript==

(function() {
    'use strict';

    function getCsrfValue() {
        const link = document.querySelector('a[href*="_csrf="]');
        if (link) {
            const url = new URL(link.href, window.location.origin);
            return url.searchParams.get('_csrf');
        }
        return null;
    }

    function searchFromAnywhere(keywords) {
        const csrfValue = getCsrfValue();
        if (!csrfValue) {
            alert('CSRF token not found!');
            return;
        }

        // Create a hidden form
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'https://logcenter-us.visibility.commercecloud.salesforce.com/logcenter/search';
        form.style.display = 'none';

        // Add keywords field
        const keywordsInput = document.createElement('input');
        keywordsInput.type = 'hidden';
        keywordsInput.name = 'keywords';
        keywordsInput.value = keywords;
        form.appendChild(keywordsInput);

        // Add _csrf field
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = '_csrf';
        csrfInput.value = csrfValue;
        form.appendChild(csrfInput);

        document.body.appendChild(form);
        form.submit();
    }

    function makeRelatedAttributesSearchable() {
        const containers = document.querySelectorAll('.list-cell-container');
        console.log('Found containers:', containers.length);

        const targetLabels = ["Session Id", "Request Id", "External Id", "Category"];

        containers.forEach(container => {
            const cells = container.querySelectorAll('.list-cell');
            const label = cells[0]?.textContent.trim();
            if (cells.length === 2 && targetLabels.includes(label)) {
                const valueCell = cells[1];
                valueCell.style.cursor = 'pointer';
                valueCell.style.textDecoration = 'underline';
                valueCell.style.color = '#0645AD';

                if (!valueCell.dataset.sessionListener) {
                    valueCell.dataset.sessionListener = 'true';
                    valueCell.addEventListener('click', function() {
                        const value = valueCell.textContent.trim();
                        searchFromAnywhere(value);
                    });
                }
            }
        });

        document.querySelectorAll('dt').forEach(dt => {
            const label = dt.textContent.trim();
            if (targetLabels.includes(label)) {
                const dd = dt.nextElementSibling;
                if (dd && dd.tagName.toLowerCase() === 'dd') {
                    dd.style.cursor = 'pointer';
                    dd.style.textDecoration = 'underline';
                    dd.style.color = '#0645AD';

                    if (!dd.dataset.sessionListener) {
                        dd.dataset.sessionListener = 'true';
                        dd.addEventListener('click', function() {
                            const value = dd.textContent.trim();
                            searchFromAnywhere(value);
                        });
                    }
                }
            }
        });
    }

    function makeEmailsSearchable() {
        const emailRegex = /([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/g;

        // Walk through all text nodes in the body
        function walk(node) {
            if (node.nodeType === 3) { // Text node
                const parent = node.parentNode;
                if (parent && parent.tagName !== 'A' && parent.tagName !== 'SPAN') {
                    const text = node.nodeValue;
                    let match;
                    let lastIndex = 0;
                    const frag = document.createDocumentFragment();

                    while ((match = emailRegex.exec(text)) !== null) {
                        // Text before the email
                        if (match.index > lastIndex) {
                            frag.appendChild(document.createTextNode(text.slice(lastIndex, match.index)));
                        }
                        // Email span
                        const emailSpan = document.createElement('span');
                        emailSpan.textContent = match[0];
                        emailSpan.style.cursor = 'pointer';
                        emailSpan.style.textDecoration = 'underline';
                        emailSpan.style.color = '#0645AD';
                        emailSpan.dataset.sessionListener = 'true';
                        emailSpan.addEventListener('click', function() {
                            console.log("clicky");
                            searchFromAnywhere(this.textContent);
                        });
                        frag.appendChild(emailSpan);
                        lastIndex = match.index + match[0].length;
                    }
                    // Remaining text
                    if (lastIndex < text.length) {
                        frag.appendChild(document.createTextNode(text.slice(lastIndex)));
                    }
                    if (frag.childNodes.length) {
                        parent.replaceChild(frag, node);
                    }
                }
            } else if (node.nodeType === 1 && node.childNodes && !['SCRIPT', 'STYLE', 'TEXTAREA'].includes(node.tagName)) {
                Array.from(node.childNodes).forEach(walk);
            }
        }

        walk(document.body);
    }

    // always make emails available to search
    makeEmailsSearchable();

    // only do structured related attributes on log detail pages
    if (location.pathname.startsWith('/logcenter/search/daralog')) {
        makeRelatedAttributesSearchable();

        // MutationObserver for dynamic content
        const observer = new MutationObserver(makeRelatedAttributesSearchable);
        observer.observe(document.body, { childList: true, subtree: true });
    }
})();