DIR_NAME=submission

if [ -d "${DIR_NAME}" ]; then
  rm -rf ${DIR_NAME}
fi

mkdir -p ${DIR_NAME}/distinguishers
mkdir -p ${DIR_NAME}/logs
mkdir -p ${DIR_NAME}/src

cp -r distinguishers/ ${DIR_NAME}/distinguishers/
cp -r logs/*/*.log ${DIR_NAME}/logs
cp -r src/ ${DIR_NAME}/src/
cp CMakeLists.txt ${DIR_NAME}/
cp README.md ${DIR_NAME}/
