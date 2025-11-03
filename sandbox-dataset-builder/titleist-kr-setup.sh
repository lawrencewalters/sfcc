# Titleist: copy a relevant set of products from staging
source "$(dirname "$0")/paths.env"
## from clubs catalog
# 559C|561C|667C|668C|669C|670C|671C|675C|676C|753C:CP-C753|753C:CP-H753|856C|CF001:CF-ATUZ|CF001:CF-ATUZJ|CF001:CF-BTFGL|CF001:CF-BTL14|CF001:CF-CPW|CF001:CF-LCLR|CD001:CD-MW1|CD001:CD-M50|CD001:CD-GZ8|CD001:CD-GX5|CD001:CD-GI6|CD001:CD-DAC|CD001:CD-FA1|CD001:CD-P60|CD001:CD-MS5

## from master catalog 
# 001PVLT|RMMPV01|003EL1T|005PV1T|005PVXT|007GL1TAU|011GL1TAU|22TA33|23TGB06|23TH26|23TH27|24TASCU|25TBSX5|25TF2DP|22TGB01|25THATP|25THATPM|LL23GB19|SE23H105

## repeat for each storefront + currency (these are all going into tmp/001PVLT and tmp/559C)

# Korea (no clubs)
./copy-product.sh "sbx-products-kr|024GB1TK|003EL1T-K|001PVLT-K|RMMPV01|005PV1T-K|005PVXT-K|007GL1TK|011GL1TK|22TA33K|23TGB06K|23TH26K|23TH27K|24TASCUK|25TBSX5K|25TF2DPK|22TGB01K|25THATPK|25THATPMK|LL23GB19K|SE23H105K|23TH20K|21008TK" titleist-master titleist-storefront-KR krw-titleist-list KRW

# there's some duplication here, but also makes sure that everything gets into the 
# shared library without overwriting each other's stuff
./site-content-setup.sh sbx-content-kr titleist-kr titleist-storefront-KR TitleistSharedLibrary titleist-master titleist-clubs-master
