FROM node

ADD tests/e2e /usr/app

WORKDIR /usr/app
RUN npm install -D @playwright/test
RUN npx playwright install
RUN npx playwright install-deps

RUN rm playwright.config.ts
RUN mv playwright.docker.config.ts playwright.config.ts
CMD npx playwright test
