FROM ubuntu:18.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install curl \
    && chmod 777 /opt \
    && apt install -y r-base \
    && apt-get install -y libssl-dev \
    && apt-get install -y libcurl4-gnutls-dev \
    && R -e "install.packages('rsconnect')"

ENV PATH="/opt/miniconda-latest/bin:$PATH"

RUN useradd --create-home --shell /bin/bash coder
USER coder

RUN export PATH="/opt/miniconda-latest/bin:$PATH" \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && mkdir /home/coder/projects

WORKDIR /home/coder/projects

COPY --chown=coder . /home/coder/projects/

RUN conda env create -f environment.yml
RUN bash -c 'conda init && . /home/coder/.bashrc && . activate io'

ENTRYPOINT ["/bin/bash", "/home/coder/projects/validation/run.sh"]