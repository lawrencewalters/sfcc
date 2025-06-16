// ==UserScript==
// @name         SFCC Business Manager
// @namespace    http://tampermonkey.net/
// @version      1.0.1
// @description  Handy business manager management scripts ALT-D to open Admin menu, ALT-J for Merchant Tools
// @author       Lawrence Walters
// @match        https://*/on/demandware.store/Sites-Site*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=salesforce.com
// @grant        none
// @updateURL    https://raw.githubusercontent.com/lawrencewalters/sfcc/refs/heads/main/browser-plugin/sfcc-business-manager.js
// @downloadURL  https://raw.githubusercontent.com/lawrencewalters/sfcc/refs/heads/main/browser-plugin/sfcc-business-manager.js
// ==/UserScript==

(function() {
    'use strict';
    function openMerchantTools() {
        document.querySelector('.merchant-tools > button:nth-child(2)').click()
    }
    function openAdministration() {
        document.querySelector('div.admin:nth-child(1) > button:nth-child(2)').click()
    }
    function onKeydown(evt) {
        // Use https://keycode.info/ to get keys
        // ALT-J
        if (evt.altKey && evt.keyCode == 74) {
            openMerchantTools();
        }
        // ALT-D
        if (evt.altKey && evt.keyCode == 68) {
            openAdministration();
        }
    }

    function onMenuSearchKeydown(evt) {
        if(evt.keyCode == 13){
            var firstItem = document.querySelector('div.show-menu div.overview_item_bm:not([style="display: none;"]) a');
            if(firstItem != null) {
                firstItem.click();
            }
        }
    }

    function setTitleFromTable() {
        const hostname = window.location.hostname;
        var firstPart = hostname.split('.')[0];
        firstPart = firstPart.split('-')[0]; // handle 'staging-na-acushnetcompany' - only want 'staging'

        var td = document.querySelector('td.table_title');
        if (td && td.textContent.trim()) {
            document.title = firstPart + ' ' + td.textContent.trim();
        } else {
            td = document.querySelector('td.overview_title');
            if (td && td.textContent.trim()) {
                document.title = firstPart + ' ' + td.textContent.trim();
            }
        }
    }

    // always show all results in lists except in a few places
    const NEVERALL = [
        "/on/demandware.store/Sites-Site/default/ViewOrderList_52-Dispatch",
        "/on/demandware.store/Sites-Site/default/ViewReplicationProcessList-List",
        "/on/demandware.store/Sites-Site/default/ViewReplicationProcessList-Dispatch",
        "/on/demandware.store/Sites-Site/default/ViewCodeReplicationProcessList-List",
        "/on/demandware.store/Sites-Site/default/ViewCodeReplicationProcessList-Dispatch",
    ];

    const alwaysAll = () => {
        if (NEVERALL.indexOf(window.location.pathname) === -1) {
            document.querySelectorAll("button").forEach((button) => {
                if (button.innerText === "All") {
                    button.click();
                }
            });
        }
    };

    alwaysAll();

    window.addEventListener('DOMContentLoaded', setTitleFromTable);

    // Optional: Run again if the page content changes dynamically
    const observer = new MutationObserver(setTitleFromTable);
    observer.observe(document.body, { childList: true, subtree: true });

    document.addEventListener('keydown', onKeydown, true);

    var merchMenu = document.getElementById('bm-menu-merch-search');
    merchMenu.addEventListener('keydown',onMenuSearchKeydown,true);
    var adminMenu = document.getElementById('bm-menu-admin-search');
    adminMenu.addEventListener('keydown',onMenuSearchKeydown,true);

})();