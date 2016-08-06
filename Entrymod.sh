cat <<'EOFENTRYMOD' > entrymod.sh
#!/bin/bash
# File: entrymod.sh
# Purpose: Adds a few key elements to wp-config.php
# History 2016-06-20 changed to make entrymod the entry point and it just points to entrypoint.sh at the end
# Reference: https://wordpress.org/support/topic/wordpress-behind-reverse-proxy-1

infile1=/var/www/html/wp-config.php
tmpfile1=/tmp/295816928f7597.tmp
tmpfile2=/tmp/295816928f7598.tmp
WP_BLOGDIR=$( echo "${WP_HOME}" | sed 's!https\?://[^/]*!!;' )

function dotask {

rm -rf ${tmpfile1} ${tmpfile2} >/dev/null 2>&1

{
   sed -n -e '1,/.*define.*DB_NAME.*/p;' ${infile1}
   echo "# BEGIN ADDITIONS"
   [[ -n "${WP_HOME}" ]] && echo "define('WP_HOME','${WP_HOME}');"
   [[ -n "${WP_SITEURL}" ]] && echo "define('WP_SITEURL','${WP_SITEURL}');"
   [[ -n "${WP_BLOGDIR}" ]] && {
      echo "\$_SERVER['REQUEST_URI'] = '${WP_BLOGDIR}' . \$_SERVER['REQUEST_URI'];"
      echo "\$_SERVER['SCRIPT_NAME'] = '${WP_BLOGDIR}' . \$_SERVER['SCRIPT_NAME'];"
      #echo "\$_SERVER['PHP_SELF'] = '${WP_BLOGDIR}' . $_SERVER['PHP_SELF'];"
   }

   cat <<'EOF'
$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
$_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_FORWARDED_FOR'];
# END ADDITIONS
EOF
   tac ${infile1} | sed -n -e '1,/^define.*DB_NAME.*\|^\# END ADDITIONS/{/^define.*DB_NAME.*\|^\# END ADDITIONS/!p;}' | tac

} > ${tmpfile1}

chmod 0644 ${tmpfile1}
mv ${tmpfile1} ${infile1} >/dev/null 2>&1
}

{ while [[ ! -f ${infile1} ]]; do echo "waiting for ${infile1} to exist. Sleeping 3." && sleep 3; done; dotask;} &

exec /entrypoint.sh "$@"
EOFENTRYMOD
