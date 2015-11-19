FROM registry.access.redhat.com/rhel7
MAINTAINER Daniel Tschan <tschan@puzzle.ch>

EXPOSE 6379

ENV REDIS_VERSION=2.8 http_proxy=http://outappl.pnet.ch:3128/ https_proxy=http://outappl.pnet.ch:3128/ no_proxy=127.0.0.1,localhost,172.27.40.68,.pnet.ch,172.28.39.140

LABEL io.k8s.description="Redis 2.8 NoSQL database" \
      io.k8s.display-name="Redis 2.8" \
      io.openshift.expose-services="6379:resp" \
      io.openshift.tags="redis"

RUN yum-config-manager --enable rhel-server-rhscl-7-rpms \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs redis && \
    yum clean all -y

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /var/*/redis && chmod -R og+rwx /var/*/redis

VOLUME /var/lib/redis
WORKDIR /var/lib/redis

USER 1001

CMD ["/usr/bin/redis-server"]
