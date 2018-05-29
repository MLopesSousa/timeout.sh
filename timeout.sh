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

RET="X$(timeout 10 $CMD serverinfo -l)"
if [ "$RET" != "X" ]; then
  # do something
fi
