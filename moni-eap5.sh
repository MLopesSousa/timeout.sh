#!/bin/bash

DIRNAME=`dirname $0`
TIMESTAMP="date +%Y-%m-%dT%H:%M:%S-0300"
ENVIRONMENT="PRODUCAO-S2GPR"
APP_SERVER="jboss-eap-5.0"
PROFILE="standalone"

INPUT_LIST=(
        "PAEJ1004:10.100.2.37:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1005:10.100.2.38:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1006:10.100.2.39:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1009:10.100.2.42:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1012:10.100.2.45:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1013:10.100.2.46:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1017:10.100.2.53:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1018:10.100.2.54:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"
        "PAEJ1021:10.100.2.57:1099:sefaz-default-01:ciclo-orcamentario-ear.ear:/ciclo-orcamentario-web"

        "PAEJ1011:10.100.2.44:1099:sefaz-default-01:sgc-ear.ear:/sgc-web"

        "PAEJ1014:10.100.2.47:1499:sefaz-default-05:licita-ear.ear:/licita-web"
        "PAEJ1015:10.100.2.51:1499:sefaz-default-05:licita-ear.ear:/licita-web"
        "PAEJ1019:10.100.2.55:1499:sefaz-default-05:licita-ear.ear:/licita-web"
        "PAEJ1020:10.100.2.56:1599:sefaz-default-05:licita-ear.ear:/licita-web"

        "PAEJ1014:10.100.2.47:1299:sefaz-default-02:cadastro-pessoas-compras-ear.ear:/fornecedor-web"
        "PAEJ1015:10.100.2.51:1299:sefaz-default-02:cadastro-pessoas-compras-ear.ear:/fornecedor-web"

        "PAEJ1014:10.100.2.47:1099:sefaz-default-01:catalogo-ear.ear:/catalogo-web"
        "PAEJ1015:10.100.2.51:1099:sefaz-default-01:catalogo-ear.ear:/catalogo-web"

        "PAEJ1008:10.100.2.41:1799:sefaz-default-07:viproc-ear.ear:/viproc-web"
        "PAEJ1015:10.100.2.51:1799:sefaz-default-07:viproc-ear.ear:/viproc-web"
        "PAEJ1019:10.100.2.55:1799:sefaz-default-07:viproc-ear.ear:/viproc-web"
        "PAEJ1020:10.100.2.56:1799:sefaz-default-07:viproc-ear.ear:/viproc-web"

        "PAEJ1014:10.100.2.47:1399:sefaz-default-03:cotacaoeletronica-ear.ear:/cotacao-web"
        "PAEJ1015:10.100.2.51:1399:sefaz-default-03:cotacaoeletronica-ear.ear:/cotacao-web"
        "PAEJ1019:10.100.2.55:1399:sefaz-default-03:cotacaoeletronica-ear.ear:/cotacao-web"
        "PAEJ1019:10.100.2.55:1999:sefaz-default-09:cotacaoeletronica-ear.ear:/cotacao-web"
)


function buildApplicationListFunction() {
        echo "$(eval $TIMESTAMP) APPLICATION $ENVIRONMENT $HOST $APP_SERVER $TARGET $INSTANCE $APPLICATION $CONTEXT"
}

function buildInstanceListFunction() {
        PORT=$($CMD serverinfo -l |grep 'jboss.web:type=GlobalRequestProcessor,name=ajp' |awk -F'-' '{print $NF}')
        echo "$(eval $TIMESTAMP) INSTANCE $ENVIRONMENT $HOST $APP_SERVER $TARGET $INSTANCE $PORT $PROFILE"
}

function buildJVMMetrics() {
         T_HEAP_MAX=$($CMD get java.lang:type=Memory HeapMemoryUsage |tr '[ ]' '\n' |grep 'max=' |awk -F'=' '{print $2}' |awk -F',' '{print $1}');
         T_HEAP_USED=$($CMD get java.lang:type=Memory HeapMemoryUsage |tr '[ ]' '\n' |grep 'used=' |awk -F'=' '{print $2}' |awk -F'}' '{print $1}');

         T_PERMGEN_MAX=$($CMD get java.lang:type=Memory NonHeapMemoryUsage |tr '[ ]' '\n' |grep 'max=' |awk -F'=' '{print $2}' |awk -F',' '{print $1}');
         T_PERMGEN_USED=$($CMD get java.lang:type=Memory NonHeapMemoryUsage |tr '[ ]' '\n' |grep 'used=' |awk -F'=' '{print $2}' |awk -F'}' '{print $1}');

         echo "$(eval $TIMESTAMP) JVMMEMORIA $ENVIRONMENT $HOST $APP_SERVER $TARGET $INSTANCE $T_HEAP_MAX $T_HEAP_USED $T_PERMGEN_MAX $T_PERMGEN_USED"
}

function buildHTTPSessionMetrics() {
        HTTPSESSIONS=$($CMD get jboss.web:type=Manager,path=$CONTEXT,host=localhost activeSessions |awk -F'=' '{print $2}')
        echo "$(eval $TIMESTAMP) HTTPSESSION $ENVIRONMENT $HOST $APP_SERVER $TARGET $INSTANCE $APPLICATION $HTTPSESSIONS"

}

function buildDatasourceMetrics() {
        for DATASOURCE in $($CMD serverinfo -l |grep 'jboss.jca:service=DataSourceBinding,name=' |awk -F'=' '{print $NF}' |sort |uniq); do
                JNDI=$DATASOURCE
                MAX=$($CMD get jboss.jca:service=ManagedConnectionPool,name=$JNDI MaxSize |awk -F'=' '{print $2}')
                USED=$($CMD get jboss.jca:service=ManagedConnectionPool,name=$JNDI InUseConnectionCount |awk -F'=' '{print $2}')
                FREE=$($CMD get jboss.jca:service=ManagedConnectionPool,name=$JNDI AvailableConnectionCount |awk -F'=' '{print $2}')

                echo "$(eval $TIMESTAMP) DATASOURCE $ENVIRONMENT $HOST $APP_SERVER $TARGET $INSTANCE $DATASOURCE $MAX $USED $FREE \"$JNDI\" "
        done
}

function buildHTTPThreadMetrics() {
        PORT=$($CMD serverinfo -l |grep 'jboss.web:type=GlobalRequestProcessor,name=ajp' |awk -F'-' '{print $NF}')
        QUEUE_SIZE=$($CMD get jboss.web:type=ThreadPool,name=ajp-${IP}-${PORT} currentThreadCount |awk -F'=' '{print $2}')
        QUEUE_MAX=0;
        POOL='AJP'

        echo "$(eval $TIMESTAMP) HTTPTHREAD $ENVIRONMENT $HOST $APP_SERVER $TARGET $INSTANCE $POOL $QUEUE_MAX $QUEUE_SIZE"

}

function timeout() {
        local variavelDeControle="A$(head -200 /dev/urandom | cksum |awk '{print $1}')$(date |sed 's/ //g; s/://g')"
        local timeout=$1
        shift
        local command=$@
        echo '0' > /tmp/$variavelDeControle

        $command && echo '1' > /tmp/${variavelDeControle} &
        PID=$!

        count=1
        while [[ $(cat /tmp/${variavelDeControle}) -eq 0 && $count -le $timeout ]]; do
                sleep 1
                count=$(($count + 1))
        done

        if [ $(cat /tmp/${variavelDeControle}) -eq 0 ]; then
                kill -9 $(pstree -p $PID |tr ')' '\n' |awk -F'(' '{print $2}' |grep -v -w 1 |grep '^[0-9]*$')
        fi

        rm -rf /tmp/$variavelDeControle
}

function doJob() {
        local entry=$1

        if [[ $entry =~ '^PAE' ]]; then
                IP=$(echo $entry |awk -F':' '{print $2}');
                HOST=$(echo $entry |awk -F':' '{print $1}');
                URL=$(echo $entry |awk -F':' '{print $2 ":" $3}');
                INSTANCE=$(echo $entry |awk -F':' '{print $4}');
                APPLICATION=$(echo $entry |awk -F':' '{print $5}');
                TARGET=$APPLICATION;
                CONTEXT=$(echo $entry |awk -F':' '{print $6}');
                CMD="/usr/jboss/jboss-eap-5.1.2/jboss-as/bin/twiddle.sh -u admin -p admin -s jnp://${URL}"

                RET="X$(timeout 10 $CMD serverinfo -l)"
                if [ "$RET" != "X" ]; then
                        buildInstanceListFunction;
                        buildApplicationListFunction;
                        buildJVMMetrics;
                        buildHTTPSessionMetrics;
                        buildDatasourceMetrics;
                        buildHTTPThreadMetrics;
                else
                        echo "Aparentemente o servidor: $1 esta fora !!!"
                fi

        fi
}

for entry in ${INPUT_LIST[@]}; do
        doJob $entry
done
