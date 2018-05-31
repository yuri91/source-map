#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.chrome.options import Options as ChromeOptions

import itertools

impls = [
    "Rust",
    "Cheerp"
]
browsers = [
    "Chrome",
    "Firefox"
]
benches = [
    "set.first.breakpoint",
    "first.pause.at.exception",
    "subsequent.setting.breakpoints",
    "subsequent.pausing.at.exceptions",
    "parse.and.iterate",
    "iterate.already.parsed",
]
sources_and_factors = [
    ("SELF_SOURCE_MAP",1),
    ("ANGULAR_MIN_SOURCE_MAP",1),
    ("ANGULAR_MIN_SOURCE_MAP",10),
    ("SCALA_JS_RUNTIME_SOURCE_MAP",1),
    ("SCALA_JS_RUNTIME_SOURCE_MAP",2),
]

data = "Implementation,Browser,Mappings.Size,Operation,Time"

headless = True
for impl,browser,bench,(source,factor) in itertools.product(impls,browsers,benches,sources_and_factors):
    print("Running "+str((impl,browser,bench,source,factor)))
    if browser == "Firefox":
        options = FirefoxOptions()
        options.set_headless(headless)
        driver = webdriver.Firefox(firefox_options=options)
    else:
        options = ChromeOptions()
        options.set_headless(headless)
        driver = webdriver.Chrome(chrome_options=options)
    driver.get("http://localhost:8000/bench/bench.html")
    select_map = Select(driver.find_element_by_id("input-map"))
    select_map.select_by_value(source)
    multiply = driver.find_element_by_id("multiply-size-by")
    multiply.clear()
    multiply.send_keys(str(factor))
    impl_and_browser = driver.find_element_by_id("impl-and-browser")
    impl_and_browser.clear()
    impl_and_browser.send_keys(impl+","+browser)
    select_impl = Select(driver.find_element_by_id("impl"))
    select_impl.select_by_value(impl)
    button = driver.find_element_by_id(bench)
    button.click()

    element = WebDriverWait(driver,60*3).until(
        EC.presence_of_element_located((By.ID, "data."+bench))
    )

    data += "\n" + element.text

    mean = driver.find_elements_by_tag_name("td")[6]
    print('Done! mean: '+mean.text)

    driver.close()
with open("data.csv","w") as f:
    f.write(data)

