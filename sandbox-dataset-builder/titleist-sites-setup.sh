# Titleist: copy a relevant set of products from staging
source "$(dirname "$0")/paths.env"
## from clubs catalog
# 559C|561C|667C|668C|669C|670C|671C|675C|676C|753C:CP-C753|753C:CP-H753|856C|CF001:CF-ATUZ|CF001:CF-ATUZJ|CF001:CF-BTFGL|CF001:CF-BTL14|CF001:CF-CPW|CF001:CF-LCLR|CD001:CD-MW1|CD001:CD-M50|CD001:CD-GZ8|CD001:CD-GX5|CD001:CD-GI6|CD001:CD-DAC|CD001:CD-FA1|CD001:CD-P60|CD001:CD-MS5

## from master catalog 
# 001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105

## repeat for each storefront + currency (these are all going into tmp/001PVLT and tmp/559C)

# US
./copy-product.sh "sbx-products-us1|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront usd-titleist-list USD
./copy-product.sh "sbx-products-us2|559C|561C|667C|668C|669C|670C|671C|675C|676C|753C:CP-C753|753C:CP-H753|856C|CF001:CF-ATUZ|CF001:CF-ATUZJ|CF001:CF-BTFGL|CF001:CF-BTL14|CF001:CF-CPW|CF001:CF-LCLR|CD001:CD-MW1|CD001:CD-M50|CD001:CD-GZ8|CD001:CD-GX5|CD001:CD-GI6|CD001:CD-DAC|CD001:CD-FA1|CD001:CD-P60|CD001:CD-MS5C" titleist-clubs-master titleist-storefront titleist-clubs-prices USD

# canada
./copy-product.sh "sbx-products-ca1|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-CA cad-titleist-list CAD
./copy-product.sh "sbx-products-ca2|559C|561C|667C|668C|669C|670C|671C|675C|676C|753C:CP-C753|753C:CP-H753|856C|CF001:CF-ATUZ|CF001:CF-ATUZJ|CF001:CF-BTFGL|CF001:CF-BTL14|CF001:CF-CPW|CF001:CF-LCLR|CD001:CD-MW1|CD001:CD-M50|CD001:CD-GZ8|CD001:CD-GX5|CD001:CD-GI6|CD001:CD-DAC|CD001:CD-FA1|CD001:CD-P60|CD001:CD-MS5CC" titleist-clubs-master titleist-storefront-CA titleist-clubs-prices-CAD CAD

# europe (note, no clubs in europe right now)
./copy-product.sh "sbx-products-eu|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-UK euro-titleist-eu-list EUR

./copy-product.sh "sbx-products-eu2|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-UK euro-titleist-ie-list EUR

./copy-product.sh "sbx-products-eu3|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-UK gbp-titleist-uk-list GBP

./copy-product.sh "sbx-products-eu4|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-UK sek-titleist-se-list SEK

# Australia/New Zealand (no clubs)
./copy-product.sh "sbx-products-au|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-au-nz nzd-titleist-list-prices NZD

# JP
./copy-product.sh "sbx-products-jp|001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-JP jpy-titleist-list JPY
./copy-product.sh "sbx-products-jp2|559C-J|561C-J|667C-J|668C-J|669C-J|670C-J|671C-J|675C-J|676C-J|753C:CP-C753-J|753C:CP-H753-J|856C-J|CF001:CF-ATUZ-J|CF001:CF-ATUZJ-J|CF001:CF-BTFGL-J|CF001:CF-BTL14-J|CF001:CF-CPW-J|CF001:CF-LCLR-J|CD001:CD-MW1-J|CD001:CD-M50-J|CD001:CD-GZ8-J|CD001:CD-GX5-J|CD001:CD-GI6-J|CD001:CD-DAC-J|CD001:CD-FA1-J|CD001:CD-P60-J|CD001:CD-MS5-J" titleist-clubs-master-JP titleist-storefront-JP titleist-clubs-prices-JP JPY

# Korea (no clubs)
./copy-product.sh "sbx-products-kr|003EL1T|001PVLT|RMMPV01|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105" titleist-master titleist-storefront-KR krw-titleist-list KRW

# there's some duplication here, but also makes sure that everything gets into the 
# shared library without overwriting each other's stuff
./site-content-setup.sh sbx-content-us titleist titleist-storefront TitleistSharedLibrary titleist-master titleist-clubs-master

./site-content-setup.sh sbx-content-au titleist-au-nz titleist-storefront-au-nz TitleistSharedLibrary titleist-master titleist-clubs-master
./site-content-setup.sh sbx-content-ca titleist-ca titleist-storefront-CA TitleistSharedLibrary titleist-master titleist-clubs-master
./site-content-setup.sh sbx-content-jp titleist-jp titleist-storefront-JP TitleistSharedLibrary titleist-master titleist-clubs-master-JP
./site-content-setup.sh sbx-content-kr titleist-kr titleist-storefront-KR TitleistSharedLibrary titleist-master titleist-clubs-master
./site-content-setup.sh sbx-content-uk titleist-uk titleist-storefront-UK TitleistSharedLibrary titleist-master titleist-clubs-master
