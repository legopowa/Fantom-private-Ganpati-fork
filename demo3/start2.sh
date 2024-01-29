#!/usr/bin/env bash
cd $(dirname $0)
. ./_params.sh

set -e

echo -e "\nStart $N nodes as validators:\n"

go build -o ../build/demo_opera ../cmd/opera

rm -f ./transactions.rlp
for ((i=0;i<$N;i+=1))
do
    DATADIR="${PWD}/opera$i.datadir"
    mkdir -p ${DATADIR}

    PORT=$(($PORT_BASE+$i))
    RPCP=$(($RPCP_BASE+$i))
    WSP=$(($WSP_BASE+$i))
    ACC=$(($i+1))
    VALIDATOR_ID="--validator.id $ACC"
    VALIDATOR_PUBKEY=""
    case $ACC in
        1)
            VALIDATOR_PUBKEY="--validator.pubkey 0xc0048d505c351f4837cec72bce6f4254f5e4bc3f2c9a4816841db64319eee8b714ef9173fbf66d039b782624713791840846b2788d4b65a425adeba85a4b57efe0cd"
            ;;
        2)
            VALIDATOR_PUBKEY="--validator.pubkey 0xc0043b4060fe18b3ae3a639e7e7b65a1ad01fb236a0dcf4ff4c8d7dd7e3ed4c4ef7a8c52e690a864ca953802f6f5b8e2e37adcfe97e1b740111a6ca782fc54efef11"
            ;;
        3)
            VALIDATOR_PUBKEY="--validator.pubkey 0xc0045a463b88e6df3edad80dd667b80dcd9d4685706cbcc5879e3cfbfe27ebab3318b0ace95f2d7ae943748d4c6aa7970882a77d0e044196ac777f7a5202582778d2"
            ;;
    esac
    (../build/demo_opera \
    --fakenet 0/3 \
    --cache 7951 \
    --datadir=${DATADIR} \
    --port=${PORT} \
    --nat extip:127.0.0.1 \
    --http --http.addr="127.0.0.1" --http.port=${RPCP} --http.corsdomain="*" --http.api="eth,debug,net,admin,web3,personal,txpool,ftm,dag" \
    --ws --ws.addr="127.0.0.1" --ws.port=${WSP} --ws.origins="*" --ws.api="eth,debug,net,admin,web3,personal,txpool,ftm,dag" \
    --verbosity=3 --tracing --log.debug \
    --allow-insecure-unlock --rpc --rpcapi="db,eth,net,web3,personal,txpool,miner" \
    $VALIDATOR_ID $VALIDATOR_PUBKEY \
    --validator.password "/home/devbox4/Desktop/fakepassword.txt" \
    --genesis ./3val030.g --genesis.allowExperimental >> opera$i.log 2>&1)&

    echo -e "\tnode$i ok"
done

echo -e "\nConnect nodes to ring:\n"
for ((i=0;i<$N;i+=1))
do
    for ((n=0;n<$M;n+=1))
    do
        j=$(((i+n+1) % N))

	enode=$(attach_and_exec $j 'admin.nodeInfo.enode')
        echo "    p2p address = ${enode}"

        echo " connecting node-$i to node-$j:"
        res=$(attach_and_exec $i "admin.addPeer(${enode})")
        echo "    result = ${res}"
    done
done
