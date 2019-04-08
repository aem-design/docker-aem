FROM aemdesign/aem-base:latest

MAINTAINER devops <devops@aem.design>

LABEL   app.version="aem 6.4.0" \
        os.version="centos atomic 7" \
        java.version="oracle 8" \
        container.description="aem instance, will run as author unless specified otherwise"

ARG AEM_VERSION="6.4.0"
ARG AEM_JVM_OPTS="-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"
ARG AEM_START_OPTS="start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties"
ARG AEM_JARFILE="/aem/crx-quickstart/app/cq-quickstart-${AEM_VERSION}-standalone-quickstart.jar"
ARG AEM_RUNMODE="-Dsling.run.modes=author,crx3,crx3tar,nosamplecontent"

ENV AEM_JVM_OPTS="${AEM_JVM_OPTS}" \
    AEM_START_OPTS="${AEM_START_OPTS}"\
    AEM_JARFILE="${AEM_JARFILE}" \
    AEM_RUNMODE="${AEM_RUNMODE}"

WORKDIR /aem

COPY aemdesign-aem/dist/cq-quickstart-6.jar ./aem-quickstart.jar

#unpack the jar
RUN java -jar aem-quickstart.jar -unpack && \
    rm aem-quickstart.jar

COPY "start.sh" "run.sh" "run-tini.sh" ./
COPY dist/install.first/*.config ./crx-quickstart/install/
COPY dist/install.first/logs/*.config ./crx-quickstart/install/
COPY dist/install.first/conf/sling.properties ./crx-quickstart/conf/sling.properties

#expose port
EXPOSE 8080 58242 57345 57346

VOLUME ["/aem/crx-quickstart/repository", "/aem/crx-quickstart/logs", "/aem/backup"]

#ensure script has exec permissions
RUN chmod +x /aem/run-tini.sh

#make java pid 1
ENTRYPOINT ["/bin/tini", "--", "/aem/run-tini.sh"]

#CMD exec java $AEM_JVM_OPTS $AEM_RUNMODE -jar $AEM_JARFILE $AEM_START_OPTS
#ENTRYPOINT ["/aem/run.sh"]
