FROM alpine
WORKDIR ~/
COPY ca-csr.json ca-csr.json
COPY create_ca.sh create_ca.sh
RUN wget https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64
RUN mv cfssljson_1.4.1_linux_amd64 cfssljson
RUN chmod +x cfssljson
RUN wget https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64
RUN mv cfssl_1.4.1_linux_amd64 cfssl
RUN chmod +x cfssl
RUN chmod +x create_ca.sh
RUN mkdir host
CMD ./create_ca.sh && tail -f /dev/null