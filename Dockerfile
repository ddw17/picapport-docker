ARG IMAGE="ubuntu:20.04"

FROM ${IMAGE}
ARG VERSION=10-3-01
ARG BUILD_DATE
ARG PICAPPORT_USER="picapport"
ARG PICAPPORT_UID="5000"

ENV PICAPPORT_PORT="8888"
ENV PICAPPORT_LANG="de"
ENV PICAPPORT_LOGLEVEL="WARNING"
ENV PICAPPORT_JAVAPARS=""

RUN echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  \
        && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  \
        && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean  \
        && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages  \
        && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes  \
        && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests \
        && apt-get -y update \
        && apt-get --no-upgrade --no-install-suggests --no-install-recommends -y install tini openjdk-11-jre-headless  libjpeg-progs dcraw exiftool psmisc locales

RUN locale-gen de_DE.UTF-8
ENV LANG de_DE.UTF-8
ENV LC_CTYPE de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8

ADD https://www.picapport.de/download/${VERSION}/picapport-headless.jar /opt/picapport/picapport-headless.jar

# Plugin do not carry versions in their files / download locations. Current versions according to https://www.picapport.de/de/plugins.php
# PicApportJavaImagePlugin: 1.1.00
# PicApportVideoThumbnailPlugin: 1.7.00
RUN mkdir /plugins
ADD https://www.picapport.de/plugins/downloads/PicApportDcRawPlugin.zip \
  https://www.picapport.de/plugins/downloads/PicApportJavaImagePlugin.zip \
  https://www.picapport.de/plugins/downloads/PicApportPdfPlugin.zip \
  https://www.picapport.de/plugins/downloads/PicApportVideoThumbnailPlugin.zip /plugins/
RUN mkdir /addons
ADD https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/apache-groovy-binary-3.0.8.zip \
  https://www.picapport.de/download/add-ons/pagpPicApportAITagger-2.0.0.zip \
  https://www.picapport.de/download/add-ons/pagpOSMGeoReverseEncoder-2.0.0.zip \
  https://www.picapport.de/download/add-ons/pagpOpenrouteGeoJSONRoute-1.0.0.zip \
  https://www.picapport.de/download/add-ons/pagpMetadataAnalyser-1.1.0.zip \
  https://www.picapport.de/download/add-ons/pagfNonJpgTitleField-1.0.0.zip \
  https://www.picapport.de/download/add-ons/pagpExifToolSimpleInfo-1.0.0.zip \
  https://www.picapport.de/download/add-ons/pagcPrivateFileFilter-1.0.0.zip /addons/

ADD picapport.sh /opt/picapport/picapport.sh
RUN addgroup --gid $PICAPPORT_UID $PICAPPORT_USER \
   && adduser $PICAPPORT_USER  --shell /bin/bash --uid $PICAPPORT_UID --home /opt/picapport --no-create-home --gid $PICAPPORT_UID --gecos 'Picapport Application User' --disabled-password \
   && chmod 666 /opt/picapport/picapport-headless.jar /plugins/* /addons/*

VOLUME [ "/opt/picapport/data", "/opt/picapport/photos" ]
USER $PICAPPORT_USER
ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash", "-c" , "/opt/picapport/picapport.sh $PICAPPORT_PORT $PICAPPORT_LANG $PICAPPORT_LOGLEVEL $PICAPPORT_JAVAPARS" ]

LABEL version=$VERSION \
      name="picapport" \
      build-date=$BUILD_DATE

