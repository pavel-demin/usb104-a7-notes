import { EleventyHtmlBasePlugin } from "@11ty/eleventy";
import { InputPathToUrlTransformPlugin } from "@11ty/eleventy";

import site from './_data/site.js';

export default function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("css");
  eleventyConfig.addPassthroughCopy("img");

  eleventyConfig.addPlugin(EleventyHtmlBasePlugin);
  eleventyConfig.addPlugin(InputPathToUrlTransformPlugin);

  eleventyConfig.addShortcode("canonical", url => site.baseurl + url);

  eleventyConfig.setLiquidOptions({
    dynamicPartials: false,
    root: [
      '_includes',
      '.'
    ]
  });
};

export const config = {
  dir: {
    input: ".",
    includes: "_includes",
    layouts: "_layouts",
    output: "_site"
  },
  htmlTemplateEngine: "liquid",
  markdownTemplateEngine: "liquid"
};
