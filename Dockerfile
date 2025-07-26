FROM jdecode/devops:php84-node22


RUN docker-php-ext-install pcntl

RUN apt update && apt install systemd -y

RUN apt-get install -y ca-certificates gnupg cron supervisor rsync

RUN journalctl -u supervisor

RUN pecl install xdebug
RUN docker-php-ext-enable xdebug


# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable unzip wget

# Install ChromeDriver (match Chrome version)
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '[0-9.]+' | head -1) \
    && CHROMEDRIVER_VERSION=$(wget -qO- "https://chromedriver.storage.googleapis.com/LATEST_RELEASE") \
    && wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
    && rm /tmp/chromedriver.zip \
    && chmod +x /usr/local/bin/chromedriver


