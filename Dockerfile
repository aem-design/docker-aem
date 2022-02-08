FROM aemdesign/aem-base:jdk8

LABEL   os="debian" \
        java="oracle 8" \
        maintainer="devops <devops@aem.design>" \
        container.description="aem instance, will run as author unless specified otherwise" \
        version="6.4.2.0" \
        imagename="aem" \
        test.command=" java -version 2>&1 | grep 'java version' | sed -e 's/.*java version "\(.*\)".*/\1/'" \
        test.command.verify="1.8"

ARG AEM_VERSION="6.4.0"
ARG AEM_JVM_OPTS="-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"
ARG AEM_START_OPTS="start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties"
ARG AEM_RUNMODE="-Dsling.run.modes=author,crx3,crx3tar,nosamplecontent"
ARG PACKAGE_PATH="./crx-quickstart/install"

ENV AEM_JVM_OPTS="${AEM_JVM_OPTS}" \
    AEM_START_OPTS="${AEM_START_OPTS}"\
    AEM_RUNMODE="${AEM_RUNMODE}"

WORKDIR /aem

COPY scripts/*.sh /aem/
COPY jar/aem*.jar /aem/

#unpack the jar
RUN java -jar aem*.jar -unpack && \
    rm aem*.jar

COPY dist/install.first/*.config ./crx-quickstart/install/
COPY dist/install.first/logs/*.config ./crx-quickstart/install/
COPY dist/install.first/conf/sling.properties ./crx-quickstart/conf/sling.properties

COPY packages/ $PACKAGE_PATH/

#expose port
EXPOSE 8080 58242 57345 57346

VOLUME ["/aem/crx-quickstart/repository", "/aem/crx-quickstart/logs", "/aem/backup"]

#ensure script has exec permissions
RUN chmod +x /aem/*.sh

#make java pid 1
ENTRYPOINT ["/bin/tini", "--", "/aem/run-tini.sh"]
