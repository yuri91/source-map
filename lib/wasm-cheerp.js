let cachedWasm = null;

module.exports = function wasm() {
  if (cachedWasm) {
    return cachedWasm;
  }

  let currentCallback = null;

  cachedWasm = require("./mappings-cheerp.js")
    .then(mod => {
    return {
      exports: mod,
    };
  }).then(null, e => {
    cachedWasm = null;
    throw e;
  });

  return cachedWasm;
};
