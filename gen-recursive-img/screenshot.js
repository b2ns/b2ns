#!/usr/bin/env node
import puppeteer from 'puppeteer';
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

  await page.screenshot({ path: filename });
  await browser.close();
}

screenshot();
