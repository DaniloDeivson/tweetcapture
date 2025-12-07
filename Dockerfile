# Usamos imagem Python e Alpine pra manter leve
FROM python:3.11-alpine as base

# Instala dependências do sistema (caso precise de libs para renderização, imagem, etc).
RUN apk add --no-cache \
    build-base \
    libjpeg-turbo-dev \
    zlib-dev \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Copia arquivos de definição de dependências
COPY requirements.txt ./

# Instala dependências python
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante do código fonte
COPY . .

# Caso o app tenha um entrypoint ou comando default
# Exemplo: chamar um script principal ou CLI
CMD ["python", "-m", "tweetcapture.cli"]
