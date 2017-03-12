FROM centos:latest
MAINTAINER Gabriel Mateescu "gabriel.mateescu@gmail.com"

# Import GPG key
RUN [[ -f /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 ]] && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# Install CentOS release package
#RUN  yum install -y centos-release

# Update packages
RUN yum -y update


