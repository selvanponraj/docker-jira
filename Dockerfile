FROM java:7

# Configuration variables.
ENV JIRA_HOME     /var/local/atlassian/jira
ENV JIRA_INSTALL  /usr/local/atlassian/jira
ENV JIRA_VERSION  6.4.2

# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 xmlstarlet \
    && apt-get clean \
    && mkdir -p                "${JIRA_HOME}" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R root:root  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && chmod -R 700            "${JIRA_INSTALL}/conf" \
    && chmod -R 700            "${JIRA_INSTALL}/logs" \
    && chmod -R 700            "${JIRA_INSTALL}/temp" \
    && chmod -R 700            "${JIRA_INSTALL}/work" \
    && chown -R root:root      "${JIRA_INSTALL}/conf" \
    && chown -R root:root      "${JIRA_INSTALL}/logs" \
    && chown -R root:root      "${JIRA_INSTALL}/temp" \
    && chown -R root:root      "${JIRA_INSTALL}/work" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties"

COPY server.xml "${JIRA_INSTALL}/conf/service.xml"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER root:root

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/local/atlassian/jira"]

# Set the default working directory as the installation directory.
WORKDIR ${JIRA_HOME}

# Run Atlassian JIRA as a foreground process by default.
CMD ["/usr/local/atlassian/jira/bin/start-jira.sh", "-fg"]
