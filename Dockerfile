FROM centos:7

LABEL name="JFrog OSS Repository Manager" \            
            version="5.3.1"
            
# OpenShift Labels
LABEL io.k8s.description="JFrog OSS Repository Manager" \
      io.k8s.display-name="JFrog OSS Repository Manager"

RUN yum -y install --setopt=tsflags=nodocs java-1.8.0-openjdk-devel.x86_64 maven lsof curl tar unzip && yum clean all

ENV ARTIFACTORY_VERSION 5.3.1
ENV ARTIFACTORY_HOME /opt/artifactory
ENV ARTIFACTORY_URL=https://bintray.com/artifact/download/jfrog/artifactory/jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.zip

RUN groupadd -r artifactory -g 1001 && useradd -u 1001 -r -g artifactory -d /opt/artifactory -s /sbin/nologin -c "artifactory user" artifactory

# Install the binaries
RUN mkdir -p ${ARTIFACTORY_HOME} \
  && curl -o /tmp/artifactory.zip  --fail --silent --location --retry 3 ${ARTIFACTORY_URL} \ 
  && unzip /tmp/artifactory.zip -d /tmp \
  && mv /tmp/artifactory-oss-${ARTIFACTORY_VERSION}/* ${ARTIFACTORY_HOME}/ \
  && rm /tmp/artifactory.zip

RUN chown -R artifactory:0 ${ARTIFACTORY_HOME}
RUN chmod 774 -R ${ARTIFACTORY_HOME}

USER 1001

EXPOSE 8081

VOLUME /opt/artifactory/data

WORKDIR $ARTIFACTORY_HOME

CMD ["/opt/artifactory/bin/artifactory.sh"]
