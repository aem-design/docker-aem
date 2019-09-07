BEGIN {
    RS="";
    FS="\n";
}
{

    split($1, assets, "},{")
    assets_length=length(assets)
    x=0
    do {
        if ( index(assets[x],GITHUB_LATEST_FILTER) ) {

                "sed -e 's/.*\"browser_download_url\":\"\\(.*\\)\".*/\\1/'<<<'"assets[x]"'"  | getline url

                if ( length(url) > 1 ) {
                    printf url
                    exit
                }
        }
        x+=1;
    }
    while(x<=assets_length)

}