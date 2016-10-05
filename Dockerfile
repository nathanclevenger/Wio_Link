FROM python:2.7
MAINTAINER Jack Shao "jacky.shaoxg@gmail.com"

#get the toolchain
WORKDIR /opt
RUN wget http://arduino.esp8266.com/linux64-xtensa-lx106-elf-gb404fb9.tar.gz
RUN tar -zxvf linux64-xtensa-lx106-elf-gb404fb9.tar.gz
ENV PATH /opt/xtensa-lx106-elf/bin:$PATH

#install python modules
RUN apt-get update && \
    apt-get install -qqy --force-yes python-dev supervisor vim

RUN apt-get install software-properties-common
RUN add-apt-repository ppa:olipo186/git-auto-deploy
RUN apt-get update
RUN apt-get install git-auto-deploy

RUN pip install tornado
RUN pip install PyJWT
RUN pip install pycrypto
RUN pip install PyYaml
RUN pip install tornado-cors

#add the files into image
RUN mkdir -p /root/esp8266_iot_node
WORKDIR /root/esp8266_iot_node
COPY . /root/esp8266_iot_node
RUN python ./scan_drivers.py
RUN mv ./update.sh ../update.sh
RUN chmod a+x ../update.sh

#config supervisor
RUN mv ./esp8266_server.conf /etc/supervisor/conf.d/esp8266_server.conf
RUN mv ./git-auto-deploy.conf.json /etc/git-auto-deploy.conf.json
RUN mkdir -p /root/supervisor_log

#expose ports
EXPOSE 8000 8001 8080 8081 8181

CMD /etc/init.d/supervisor start && /bin/bash
