depencencies:

- R
- R package ggplot2
- python3
- python3 selenium package
- geckodriver
- chrome/chromium
- [optional] safari (+ selenium driver?)


steps:

```

npm install
npm run-script build
python3 -m http.server

```

in another shell:

```

cd bench
./run_benches.py
mkdir plots
cd plots
../plot-cheerp.r ../data.csv
ls

```

