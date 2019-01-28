FROM ubuntu:bionic

RUN apt-get -yq update                                  \
 && DEBIAN_FRONTEND=noninteractive                      \
        apt-get -yqq install software-properties-common \
 && add-apt-repository -y ppa:malteworld/ppa            \
 && add-apt-repository -y ppa:alex-p/tesseract-ocr      \
 && apt-get -yq update                                  \
 && DEBIAN_FRONTEND=noninteractive apt-get -yq install  \
        entr                                            \
        imagemagick                                     \
        pdftk                                           \
        poppler-utils                                   \
        python                                          \
        tesseract-ocr-all                               \
        wget                                            \
 && rm -rf /var/lib/apt/lists/*

RUN RELEASES='https://github.com/Yelp/dumb-init/releases/download'            \
 && wget -O /usr/local/bin/dumb-init "$RELEASES/v1.2.2/dumb-init_1.2.2_amd64" \
 && chmod +x /usr/local/bin/dumb-init

RUN sed_script='s/rights="none" pattern="'                             \
 && sed_script="${sed_script}"'\(\(PS\)\|\(EPI\)\|\(PDF\)\|\(XPS\)\)"' \
 && sed_script="${sed_script}"'/rights="read|write" pattern="\1"/g'    \
 && sed -i "$sed_script" /etc/ImageMagick-6/policy.xml

COPY entrypoint.py .
COPY worker.bash .

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "python", "entrypoint.py"]
CMD ["--help"]
