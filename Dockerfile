FROM qnib/alpn-python

RUN apk update && \
    apk add git perl gcc python-dev musl-dev linux-headers && \
    # Inspired by https://github.com/Clever/docker-stats/blob/master/Dockerfile
    pip install git+git://github.com/Clever/Diamond.git@e4800e82b4056366609726b5e7bbc0a59df5b436 && \
    pip install boto && \
    pip install docker-py==1.6 && \
    apk del git perl gcc && \
    rm -rf /var/cache/apk/*
ENV DOCKER_SERVER=boot2docker \
    COLLECT_METRICS=true \
    DIAMOND_COLLECTORS=DockerStatsCollector \
    DIAMOND_PATH_PREFIX=diamond
ADD etc/diamond/diamond.conf.stdout \
    /etc/diamond/
ADD etc/diamond/collectors/*.conf.disabled \
    /etc/diamond/collectors/
ADD etc/diamond/handlers/* /etc/diamond/handlers/
RUN echo "diamond -f -c /etc/diamond/diamond.conf.stdout -l --skip-pidfile" >> /root/.bash_history
ADD etc/consul-templates/diamond/diamond.conf.ctmpl /etc/consul-templates/diamond/
ADD etc/supervisord.d/diamond.ini /etc/supervisord.d/
ADD opt/qnib/diamond/bin/start.sh /opt/qnib/diamond/bin/


## do not collect network metrics, since it's brocken with new version of DockerStat-API (network vs networks)
ADD usr/share/diamond/collectors/docker_stats/docker_stats.py /usr/share/diamond/collectors/docker_stats/
## Make collection timeout configurable
ADD usr/lib/python2.7/site-packages/diamond/utils/scheduler.py /usr/lib/python2.7/site-packages/diamond/utils/
