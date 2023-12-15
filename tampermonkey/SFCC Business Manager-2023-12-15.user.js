// ==UserScript==
// @name         SFCC Business Manager
// @namespace    http://tampermonkey.net/
// @version      2023-12-15
// @description  Handy business manager management scripts ALT-D to open Admin menu, ALT-J for Merchant Tools
// @author       Lawrence Walters
// @match        https://*/on/demandware.store/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=salesforce.com
// @grant        none
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

    document.addEventListener('keydown', onKeydown, true);

    var merchMenu = document.getElementById('bm-menu-merch-search');
    merchMenu.addEventListener('keydown',onMenuSearchKeydown,true);
    var adminMenu = document.getElementById('bm-menu-admin-search');
    adminMenu.addEventListener('keydown',onMenuSearchKeydown,true);

})();