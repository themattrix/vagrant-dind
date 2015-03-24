FROM themattrix/develop:latest

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

# Add docker from the external environment
ADD ./bin/docker /usr/local/bin/docker
ADD ./bin/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker

CMD ["/sbin/my_init", "--skip-startup-files", "--quiet", "--", "wrapdocker"]
