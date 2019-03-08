#!/bin/bash
set -ev

pushd agent/java/
mkdir integration-test/jacoco/temp
cp engine/target/original-rasp-engine.jar integration-test/jacoco/temp
cp engine/target/rasp-engine.jar integration-test/jacoco/temp
cp boot/target/rasp.jar integration-test/jacoco/temp
pushd integration-test/jacoco/temp/
if [[ -f "rasp-engine.jar" ]] && [[ -f "rasp.jar" ]]; then
	jar -xvf original-rasp-engine.jar  com/baidu/
    pushd com/baidu/openrasp/
    fileList=
    for file in $(ls); do
       echo $file
       fileList="com/baidu/openrasp/$file $fileList"
    done
    popd
    rm -rf com/
    jar -xvf rasp-engine.jar $fileList
    jar -xvf ../../boot/rasp.jar com/baidu
    cp -r com/ ../classes
    popd
    cp -r engine/src/main/java/* integration-test/jacoco/sources
    cp -r boot/src/main/java/com/baidu/openrasp/* integration-test/jacoco/sources/com/baidu/openrasp/
fi
pushd integration-test/jacoco
dataFile=/home/travis/build/baidu/openrasp/agent/java
java -jar jacococli.jar report $dataFile/jacoco.exec --classfiles ../classes/ --sourcefiles ../sources --xml jacoco.xml
popd
rm -rf integration-test/temp/