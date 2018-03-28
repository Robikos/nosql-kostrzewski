unzip dataset.json.zip | mongoimport -d markets -c markets2 --file dataset.json --jsonArray

mongod --port 27001
        --replSet mongo-replset
        --dbpath ~/mongo-replset/data-1
        --bind_ip localhost

mongod --port 27002
       --replSet mongo-replset
       --dbpath ~/mongo-replset/data-2
       --bind_ip localhost

mongod --port 27003
       --replSet mongo-replset
       --dbpath ~/mongo-replset/data-3
       --bind_ip localhost

unzip dataset.json.zip | mongoimport --host mongo-replset/localhost:27001,localhost:27002,localhost:27003 -d markets -c markets10 --writeConcern 1 --jsonArray

