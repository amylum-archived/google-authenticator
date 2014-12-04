FROM dock0/arch
MAINTAINER akerl <me@lesaker.org>
RUN pacman -S --needed --noconfirm ruby openssh base-devel
RUN gem install --no-user-install --no-rdoc --no-ri targit
WORKDIR /opt/google-authenticator
CMD ["make", "local"]
