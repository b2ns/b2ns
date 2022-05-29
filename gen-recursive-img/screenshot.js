#!/usr/bin/env node
import puppeteer from 'puppeteer';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
const __dirname = dirname(fileURLToPath(import.meta.url));
const filename = process.argv[2];

async function screenshot() {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('https://github.com/b2ns');
  await page.setViewport({
    width: 1080,
    height: 700,
    deviceScaleFactor: 2,
  });

  await page.screenshot({ path: resolve(__dirname, '..', filename) });
  await browser.close();
}

screenshot();
