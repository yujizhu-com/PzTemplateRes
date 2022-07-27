#!/usr/bin/expect
set keystorePath [lindex $argv 0]
set signTo [lindex $argv 1]
set signFrom [lindex $argv 2]

# spawn "$sign_in_path" "$key" "$from" "$to" "$alias"
# expect "输入密钥库的口令短语： "
# set timeout 300
# send "${password}\n"
# interact
# spawn "export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8"
# spawn "echo $keystorePath"
# spawn "echo $signTo"
# $signFrom

spawn /usr/bin/jarsigner -verbose -keystore $keystorePath -signedjar $signTo $signFrom daguan.keystore -digestalg SHA1 -sigalg MD5withRSA
expect "输入密钥库的口令短语： "
set timeout 300
send "daguan\n"
interact